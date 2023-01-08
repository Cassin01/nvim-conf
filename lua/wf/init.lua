local util = require("wf.util")
local au = util.au
local rt = util.rt
local match_from_tail = util.match_from_tail
local fuzzy = require("wf.fuzzy")
local which = require("wf.which")
local output_obj_gen = require("wf.output").output_obj_gen
local static = require("wf.static")
local bmap = static.bmap
local row_offset = static.row_offset
local _g = static._g
-- local input_win_row_offset = static.input_win_row_offset
local sign_group_prompt = static.sign_group_prompt
local cell = require("wf.cell")
local which_insert_map = require("wf.which_map").setup
local group = require("wf.group")
local core = require("wf.core").core
local setup = require("wf.setup").setup

local function objs_setup(fuzzy_obj, which_obj, output_obj, caller_obj, choices_obj, callback)
    local objs = { fuzzy_obj, which_obj, output_obj }

    local del = function() -- deliminator of the whole process
        for _, o in ipairs(objs) do
            if vim.api.nvim_win_is_valid(o.buf) then
                vim.api.nvim_set_current_win(o.win)
                vim.api.nvim_buf_delete(o.buf, { force = true })
            end
            if vim.api.nvim_win_is_valid(o.win) then
                vim.api.nvim_win_close(o.win, true)
            end
        end
        local cursor_valid, original_cursor = pcall(vim.api.nvim_win_get_cursor, caller_obj.win)
        if vim.api.nvim_win_is_valid(caller_obj.win) then
            pcall(vim.api.nvim_set_current_win, caller_obj.win)
            if cursor_valid and vim.api.nvim_get_mode().mode == "i" and caller_obj.mode ~= "i" then
                pcall(vim.api.nvim_win_set_cursor, caller_obj.win, { original_cursor[1], original_cursor[2] })
            end
        end
    end
    for _, o in ipairs(objs) do
        au(_g, "BufWinLeave", function()
            del()
        end, { buffer = o.buf })
    end

    local inputs = { fuzzy_obj, which_obj }
    local to_which = function()
        vim.api.nvim_set_current_win(which_obj.win)
    end
    local to_fuzzy = function()
        vim.api.nvim_set_current_win(fuzzy_obj.win)
    end
    -- which_key_list_operator
    local which_key_list_operator = {
        escape = "<C-C>",
        toggle = "<C-T>",
    }
    for _, o in ipairs(objs) do
        bmap(o.buf, "n", "<esc>", del, "quit")
    end
    for _, o in ipairs(inputs) do
        bmap(o.buf, { "i", "n" }, which_key_list_operator.escape, del, "quit")
        bmap(o.buf, { "n" }, "m", "", "disable sign")
    end
    bmap(fuzzy_obj.buf, { "i", "n" }, which_key_list_operator.toggle, to_which, "start which key mode")
    bmap(which_obj.buf, { "i", "n" }, which_key_list_operator.toggle, to_fuzzy, "start which key mode")
    local which_map_list =
    which_insert_map(which_obj.buf, { which_key_list_operator.toggle, which_key_list_operator.escape })
    local select_ = function()
        local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
        local which_line = vim.api.nvim_buf_get_lines(which_obj.buf, 0, -1, true)[1]
        local fuzzy_matched_obj = (function()
            if fuzzy_line == "" then
                return choices_obj
            else
                return vim.fn.matchfuzzy(choices_obj, fuzzy_line, { key = "text" })
            end
        end)()
        for _, match in ipairs(fuzzy_matched_obj) do
            if match.key == which_line then
                del()
                callback(match.id)
                return
            end
        end
    end
    bmap(which_obj.buf, { "n", "i" }, "<CR>", select_, "select matched which key")
    bmap(fuzzy_obj.buf, { "n", "i" }, "<CR>", select_, "select matched which key")
    return { del = del, which_map_list = which_map_list }
end

local function swap_win_pos(up, down, style)
    local height = 1
    local row = vim.o.lines - height - row_offset() - 1
    local wcnf = vim.api.nvim_win_get_config(up.win)
    vim.api.nvim_win_set_config(up.win, vim.fn.extend(wcnf, { row = row - style.input_win_row_offset, border = style.borderchars.center, title_pos = "center" }))
    local fcnf = vim.api.nvim_win_get_config(down.win)
    vim.api.nvim_win_set_config(down.win, vim.fn.extend(fcnf, { row = row, border = style.borderchars.bottom, title_pos="center" }))
end

local function fuzzy_setup(which_obj, fuzzy_obj, output_obj, choices_obj, groups_obj, opts)
    au(_g, { "TextChangedI", "TextChanged" }, function()
        core(choices_obj, groups_obj, which_obj, fuzzy_obj, output_obj, opts)
    end, { buffer = fuzzy_obj.buf })
    au(_g, "WinEnter", function()
        vim.api.nvim_win_set_option(fuzzy_obj.win, "winhl", "Normal:WFFocus,FloatBorder:WFFloatBorderFocus")

        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = fuzzy_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "fuzzy",
            sign_group_prompt .. "fuzzy",
            fuzzy_obj.buf,
            { lnum = 1, priority = 10 }
        )
        core(choices_obj, groups_obj, which_obj, fuzzy_obj, output_obj, opts)
        swap_win_pos(fuzzy_obj, which_obj, opts.style)
    end, { buffer = fuzzy_obj.buf })
    au(_g, "WinLeave", function()
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = fuzzy_obj.buf })
        vim.fn.sign_unplace(sign_group_prompt .. "fuzzy", { buffer = fuzzy_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "freeze",
            sign_group_prompt .. "freeze",
            fuzzy_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(fuzzy_obj.win, "winhl", "Normal:WFComment,FloatBorder:WFFloatBorder")
    end, { buffer = fuzzy_obj.buf })
end

local function which_setup(which_obj, fuzzy_obj, output_obj, choices_obj, groups_obj, callback, obj_handlers, opts)
    au(_g, "BufEnter", function()
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = which_obj.buf })
        local _, _ = pcall(function()
            require("cmp").setup.buffer({ enabled = false })
        end)
    end, { buffer = which_obj.buf })
    au(_g, "WinLeave", function()
        vim.api.nvim_set_hl(0, "WFWhich", { link = "WFFreeze" })

        vim.fn.sign_unplace(sign_group_prompt .. "which", { buffer = which_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "freeze",
            sign_group_prompt .. "freeze",
            which_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(which_obj.win, "winhl", "Normal:WFComment,FloatBorder:WFFloatBorder")
    end, { buffer = which_obj.buf })
    au(_g, { "TextChangedI", "TextChanged" }, function()
        local id = core(choices_obj, groups_obj, which_obj, fuzzy_obj, output_obj, opts)
        if id ~= nil then
            obj_handlers.del()
            callback(id)
        end
    end, { buffer = which_obj.buf })
    au(_g, "WinEnter", function()
        vim.api.nvim_set_hl(0, "WFWhich", { link = "WFWhichOn" })

        vim.api.nvim_win_set_option(which_obj.win, "winhl", "Normal:WFFocus,FloatBorder:WFFloatBorderFocus")
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "which",
            sign_group_prompt .. "which",
            which_obj.buf,
            { lnum = 1, priority = 10 }
        )
        core(choices_obj, groups_obj, which_obj, fuzzy_obj, output_obj, opts)
        swap_win_pos(which_obj, fuzzy_obj, opts.style)
    end, { buffer = which_obj.buf })
    bmap(which_obj.buf, { "n", "i" }, "<CR>", function()
        local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
        local which_line = vim.api.nvim_buf_get_lines(which_obj.buf, 0, -1, true)[1]
        local fuzzy_matched_obj = (function()
            if fuzzy_line == "" then
                return choices_obj
            else
                return vim.fn.matchfuzzy(choices_obj, fuzzy_line, { key = "text" })
            end
        end)()
        for _, match in ipairs(fuzzy_matched_obj) do
            if match.key == which_line then
                obj_handlers.del()
                callback(match.id)
            end
        end
    end, "match")
    bmap(which_obj.buf, { "i" }, "<C-H>", function()
        local pos = vim.api.nvim_win_get_cursor(which_obj.win)
        local line = vim.api.nvim_buf_get_lines(which_obj.buf, pos[1] - 1, pos[1], true)[1]
        local front = string.sub(line, 1, pos[2])
        local match = (function()
            for _, v in ipairs(obj_handlers.which_map_list) do
                if match_from_tail(front, v) then
                    return v
                end
            end
            return nil
        end)()
        if match == nil then
            return rt("<C-H>")
        else
            return rt("<Plug>(wf-erase-word)")
        end
    end, "<C-h>", { expr = true })
    bmap(which_obj.buf, { "i" }, "<Plug>(wf-erase-word)", function()
        local pos = vim.api.nvim_win_get_cursor(which_obj.win)
        local line = vim.api.nvim_buf_get_lines(which_obj.buf, pos[1] - 1, pos[1], true)[1]
        local front = string.sub(line, 1, pos[2])
        local match = (function()
            for _, v in ipairs(obj_handlers.which_map_list) do
                if match_from_tail(front, v) then
                    return v
                end
            end
            return nil
        end)()
        local back = string.sub(line, pos[2] + 1)
        local new_front = string.sub(front, 1, #front - #match)
        vim.fn.sign_unplace(sign_group_prompt .. "which", { buffer = which_obj.buf })
        vim.api.nvim_buf_set_lines(which_obj.buf, pos[1] - 1, pos[1], true, { new_front .. back })
        vim.api.nvim_win_set_cursor(which_obj.win, { pos[1], vim.fn.strdisplaywidth(new_front) })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "which",
            sign_group_prompt .. "which",
            which_obj.buf,
            { lnum = 1, priority = 10 }
        )
    end, "<C-h>")
end

local function is_array(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
    return true
end

-- core
local function inputlist(choices, callback, opts)
    local _opts = vim.fn.deepcopy(require("wf.config"))
    opts = opts or {}
    for k, v in pairs(opts) do
        if vim.fn.has_key(_opts, k) then
            _opts[k] = v
        end
    end
    opts = _opts

    vim.fn.sign_define(sign_group_prompt .. "fuzzy", {
        text = opts.prompt,
        texthl = "WFFuzzyPrompt",
    })
    vim.fn.sign_define(sign_group_prompt .. "which", {
        text = opts.prompt,
        texthl = "WFWhich",
    })
    vim.fn.sign_define(sign_group_prompt .. "freeze", {
        text = opts.prompt,
        texthl = "WFFreeze",
    })

    local _choices_obj = {}
    if is_array(choices) then
        for i, val in ipairs(choices) do
            _choices_obj[i] = cell.new(i, tostring(i), val, "key")
        end
    else -- dict
        for key, val in pairs(choices) do
            table.insert(_choices_obj, cell.new(key, key, val, "key"))
        end
    end
    local choices_obj = {}
    for _, val in ipairs(_choices_obj) do
        table.insert(choices_obj, cell.new(
            val.id,
            val.key,
            (function()
                local list = opts.output_obj_which_mode_desc_format(val)
                local str = ""
                for _, v in ipairs(list) do
                    str = str .. v[1]
                end
                return str
            end)(),
            "key"
        ))
    end

    local caller_obj = (function()
        local win = vim.api.nvim_get_current_win()
        return {
            win = win,
            buf = vim.api.nvim_get_current_buf(),
            original_mode = vim.api.nvim_get_mode().mode,
            cursor = vim.api.nvim_win_get_cursor(win),
            mode = vim.api.nvim_get_mode().mode,
        }
    end)()

    -- key group_objをリストに格納
    local groups_obj = group.new(opts.key_group_dict)

    -- 表示用バッファを作成
    local output_obj = output_obj_gen(opts.prefix_size, opts.style)

    -- -- 入力用バッファを作成
    local which_obj = which.input_obj_gen(opts.style)
    local fuzzy_obj = fuzzy.input_obj_gen(opts.style)

    local obj_handlers = objs_setup(fuzzy_obj, which_obj, output_obj, caller_obj, choices_obj, callback)
    which_setup(which_obj, fuzzy_obj, output_obj, choices_obj, groups_obj, callback, obj_handlers, opts)
    fuzzy_setup(which_obj, fuzzy_obj, output_obj, choices_obj, groups_obj, opts)

    vim.api.nvim_buf_set_lines(which_obj.buf, 0, -1, true, { opts.text_insert_in_advance })
    if opts.selector == "fuzzy" then
        vim.api.nvim_set_current_win(fuzzy_obj.win)
        vim.cmd("startinsert!")
    elseif opts.selector == "which" then
        vim.api.nvim_set_current_win(which_obj.win)
        vim.cmd("startinsert!")
    else
        print("selector must be fuzzy or which")
        obj_handlers.del()
    end
end

local function select(items, opts, on_choice)
    vim.validate({
        items = { items, "table", false },
        on_choice = { on_choice, "function", false },
    })
    opts = opts or {}
    local choices = {}
    local format_item = opts.format_item or tostring

    for k, item in pairs(items) do
        choices[k] = format_item(item)
    end
    local callback = function(choice)
        if type(choice) == "string" then
            on_choice(items[choice], choice)
        elseif choice < 1 or choice > #items then
            on_choice(nil, nil)
        else
            on_choice(items[choice], choice)
        end
    end
    inputlist(choices, callback, opts)
end

return { select = select, setup = setup }
