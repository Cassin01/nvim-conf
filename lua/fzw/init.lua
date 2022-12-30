local util = require("fzw.util")
local cmd = util.cmd
local au = util.au
local match_front = util.match_front
local fill_spaces = util.fill_spaces
local fuzzy = require("fzw.fuzzy")
local witch = require("fzw.witch")
local output_obj_gen = require("fzw.output").output_obj_gen
local static = require("fzw.static")
local bmap = static.bmap
local _g = static._g
local input_win_row_offset = static.input_win_row_offset
local sign_group_prompt = static.sign_group_prompt
local sign_group_witch = static.sign_group_witch
local cell = require("fzw.cell")
local _update_output_obj = require("fzw.output")._update_output_obj
local fg_witch = "#f38ba8"
local fg_fuzzy = "#72D4F2" -- "#7ec9d8"
local fg_rem = "#585b70"
local witch_insert_map = require("fzw.witch_map").setup

local function setup()
    vim.api.nvim_set_hl(0, "FzwWitchRem", { fg = fg_rem, bold = true })
    vim.api.nvim_set_hl(0, "FzwFuzzy", { fg = fg_fuzzy, bold = true })
    vim.api.nvim_set_hl(0, "FzwFreeze", { fg = fg_rem })
end

local function objs_setup(fuzzy_obj, witch_obj, output_obj, choices_obj, callback)
    local objs = { fuzzy_obj, witch_obj, output_obj }

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
    end
    for _, o in ipairs(objs) do
        au(_g, "BufWinLeave", function()
            del()
        end, { buffer = o.buf })
    end

    local inputs = { fuzzy_obj, witch_obj }
    local to_witch = function()
        vim.api.nvim_set_current_win(witch_obj.win)
    end
    local to_fuzzy = function()
        vim.api.nvim_set_current_win(fuzzy_obj.win)
    end
    for _, o in ipairs(inputs) do
        bmap(o.buf, { "i", "n" }, "<c-c>", del, "quit")
        bmap(o.buf, { "n" }, "<esc>", del, "quit")
    end
    local toggle = "<C-T>"
    bmap(fuzzy_obj.buf, { "i", "n" }, toggle, to_witch, "start witch key mode")
    bmap(witch_obj.buf, { "i", "n" }, toggle, to_fuzzy, "start witch key mode")
    local black_dict = witch_insert_map(witch_obj.buf, { toggle })
    local select_ = function()
        local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
        local witch_line = vim.api.nvim_buf_get_lines(witch_obj.buf, 0, -1, true)[1]
        -- local choices_obj = {}
        -- for i, val in ipairs(choices) do
        --   choices_obj[i] = cell.new(i, tostring(i), val)
        -- end
        local fuzzy_matched_obj = (function()
            if fuzzy_line == "" then
                return choices_obj
            else
                return vim.fn.matchfuzzy(choices_obj, fuzzy_line, { key = "text" })
            end
        end)()
        for _, match in ipairs(fuzzy_matched_obj) do
            print(match.key, witch_line)
            if match.key == witch_line then
                del()
                callback(match.id)
            end
        end
    end
    bmap(witch_obj.buf, { "n", "i" }, "<cr>", select_, "select matched witch key")
    bmap(fuzzy_obj.buf, { "n", "i" }, "<cr>", select_, "select matched witch key")
    return { del = del, black_dict = black_dict }
end

local sign_place_witch = function(choices_obj, witch_obj, fuzzy_obj, output_obj, obj_handlers)
    local _lines = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)
    for _, match in ipairs(vim.fn.getmatches(output_obj.win)) do
        if match.group == "IncSearch" then
            vim.fn.matchdelete(match.id, output_obj.win)
        end
    end
    local prefix_size = 7
    local diff = 5 + prefix_size
    local matches_obj = (function()
        if _lines[1] == "" then
            return choices_obj
        else
            local obj = vim.fn.matchfuzzypos(choices_obj, _lines[1], { key = "text" })
            local poss = obj[2]
            for i, _ in ipairs(obj[1]) do
                for _, v in ipairs(poss[i]) do
                    vim.fn.matchaddpos("IncSearch", { { i, diff + v + 2 } }, 0, -1, { window = output_obj["win"] })
                end
            end
            return obj[1]
        end
    end)()
    local lines = vim.api.nvim_buf_get_lines(witch_obj.buf, 0, -1, true)
    local ids = {}
    local texts = {}
    local match_posses = {}
    for lnum, match in pairs(matches_obj) do
        if match_front(match.key, lines[1]) then
            table.insert(ids, { id = match.id, key = match.key })
            local _c = string.sub(match.key, 1 + #lines[1], 2 + #lines[1])
            local c = fill_spaces(_c, prefix_size)
            local text = string.format(" %s %s %s", c, "→", match.text)
            table.insert(texts, text)
            table.insert(match_posses, { lnum, 2, vim.fn.strdisplaywidth(string.match(c, ".")) })
        end
    end
    if lines[1] == "" then
        texts = {}
        for _, match in ipairs(matches_obj) do
            local c = fill_spaces(match.key, prefix_size)
            local text = string.format(" %s %s %s", c, "→", match.text)
            table.insert(texts, text)
        end
    end
    local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset
    _update_output_obj(output_obj, texts, vim.o.lines, _row_offset + input_win_row_offset)
    for _, match in ipairs(vim.fn.getmatches(output_obj.win)) do
        if match.group == "FzwWith" then
            vim.fn.matchdelete(match.id, output_obj.win)
        end
    end
    for i, match_pos in ipairs(match_posses) do
        vim.fn.matchaddpos("FzwWitchRem", { { i, 2, prefix_size } }, 9, -1, { window = output_obj.win })
        vim.fn.matchaddpos("FzwWitch", { match_pos }, 10, -1, { window = output_obj.win })
        vim.fn.matchaddpos(
            "FzwArrow",
            { { i, prefix_size + 3, vim.fn.strdisplaywidth("→") } },
            9,
            -1,
            { window = output_obj.win }
        )
    end

    if lines[1] == "" then
        return nil
    else
        if #ids == 1 and ids[1].key == lines[1] then
            return ids[1].id
        else
            return nil
        end
    end
end

local function swap_win_pos(up, down)
    local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)
    local height = 1
    local row = vim.o.lines - height - _row_offset - 1
    local wcnf = vim.api.nvim_win_get_config(up.win)
    vim.api.nvim_win_set_config(up.win, vim.fn.extend(wcnf, { row = row - input_win_row_offset }))
    local fcnf = vim.api.nvim_win_get_config(down.win)
    vim.api.nvim_win_set_config(down.win, vim.fn.extend(fcnf, { row = row }))
end

local function fuzzy_setup(witch_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)
    au(_g, "TextChangedI", function()
        sign_place_witch(choices_obj, witch_obj, fuzzy_obj, output_obj, obj_handlers)
    end, { buffer = fuzzy_obj.buf })
    au(_g, "WinEnter", function()
        vim.api.nvim_set_hl(0, "FzwArrow", { fg = fg_fuzzy, bold = true })
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = fuzzy_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "fuzzy",
            sign_group_prompt .. "fuzzy",
            fuzzy_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(fuzzy_obj.win, "winhl", "Normal:Normal")
        swap_win_pos(fuzzy_obj, witch_obj)
    end, { buffer = fuzzy_obj.buf })
    au(_g, "WinLeave", function()
        vim.api.nvim_set_hl(0, "FzwArrow", { fg = fg_rem, bold = true })
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = fuzzy_obj.buf })
        vim.fn.sign_unplace(sign_group_prompt .. "fuzzy", { buffer = fuzzy_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "freeze",
            sign_group_prompt .. "freeze",
            fuzzy_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(fuzzy_obj.win, "winhl", "Normal:Comment")
    end, { buffer = fuzzy_obj.buf })
end

local function witch_setup(witch_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)
    au(_g, "BufEnter", function()
        vim.fn.sign_unplace(sign_group_prompt .. "freeze", { buffer = witch_obj.buf })
        local _, _ = pcall(function()
            require("cmp").setup.buffer({ enabled = false })
        end)
    end, { buffer = witch_obj.buf })
    au(_g, "WinLeave", function()
        vim.api.nvim_set_hl(0, "FzwWitch", { fg = fg_rem, bold = true })
        vim.fn.sign_unplace(sign_group_prompt .. "witch", { buffer = witch_obj.buf })
        vim.fn.sign_unplace(sign_group_witch, { buffer = output_obj.buf })
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "freeze",
            sign_group_prompt .. "freeze",
            witch_obj.buf,
            { lnum = 1, priority = 10 }
        )
        vim.api.nvim_win_set_option(witch_obj.win, "winhl", "Normal:Comment")
    end, { buffer = witch_obj.buf })
    au(_g, "TextChangedI", function()
        -- vim.fn.sign_unplace(sign_group_witch, { buffer = output_obj.buf })
        local id = sign_place_witch(choices_obj, witch_obj, fuzzy_obj, output_obj, obj_handlers)
        if id ~= nil then
            obj_handlers.del()
            callback(id)
        end
    end, { buffer = witch_obj.buf })
    au(_g, "WinEnter", function()
        vim.api.nvim_set_hl(0, "FzwWitch", { fg = fg_witch, bold = true, underdashed = true })
        vim.api.nvim_win_set_option(witch_obj.win, "winhl", "Normal:Normal")
        vim.fn.sign_place(
            0,
            sign_group_prompt .. "witch",
            sign_group_prompt .. "witch",
            witch_obj.buf,
            { lnum = 1, priority = 10 }
        )
        sign_place_witch(choices_obj, witch_obj, fuzzy_obj, output_obj, obj_handlers)
        swap_win_pos(witch_obj, fuzzy_obj)
    end, { buffer = witch_obj.buf })
    bmap(witch_obj.buf, { "n", "i" }, "<cr>", function()
        local fuzzy_line = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)[1]
        local witch_line = vim.api.nvim_buf_get_lines(witch_obj.buf, 0, -1, true)[1]
        local fuzzy_matched_obj = (function()
            if fuzzy_line == "" then
                return choices_obj
            else
                return vim.fn.matchfuzzy(choices_obj, fuzzy_line, { key = "text" })
            end
        end)()
        for _, match in ipairs(fuzzy_matched_obj) do
            print(match.key, witch_line)
            if match.key == witch_line then
                obj_handlers.del()
                callback(match.id)
            end
        end
    end, "match")
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
    local _opts = { prompt = "> ", selector = "witch" }
    opts = opts or _opts
    for k, v in pairs(_opts) do
        if vim.fn.has_key(opts, k) == 0 then
            opts[k] = v
        end
    end

    vim.fn.sign_define(sign_group_prompt .. "fuzzy", {
        text = opts.prompt,
        texthl = "FzwFuzzy",
    })
    vim.fn.sign_define(sign_group_prompt .. "witch", {
        text = opts.prompt,
        texthl = "FzwWitch",
    })
    vim.fn.sign_define(sign_group_prompt .. "freeze", {
        text = opts.prompt,
        texthl = "FzwFreeze",
    })

    local choices_list = nil
    local choices_obj = {}
    if is_array(choices) then
        choices_list = choices
        for i, val in ipairs(choices) do
            choices_obj[i] = cell.new(i, tostring(i), val)
        end
        print(vim.inspect(choices))
    else -- dict
        choices_list = vim.fn.values(choices)
        for key, val in pairs(choices) do
            table.insert(choices_obj, cell.new(key, key, val))
        end
    end

    -- 表示用バッファを作成
    local output_obj = output_obj_gen()

    -- -- 入力用バッファを作成
    local witch_obj = witch.input_obj_gen(output_obj)
    local fuzzy_obj = fuzzy.input_obj_gen(output_obj, choices_list)

    local obj_handlers = objs_setup(fuzzy_obj, witch_obj, output_obj, choices_obj, callback)
    witch_setup(witch_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)
    fuzzy_setup(witch_obj, fuzzy_obj, output_obj, choices_obj, callback, obj_handlers)

    if vim.fn.mode() == "n" then
        vim.fn.feedkeys("i", "n")
    end
    if opts.selector == "fuzzy" then
        vim.api.nvim_set_current_win(fuzzy_obj.win)
    elseif opts.selector == "witch" then
        vim.api.nvim_set_current_win(witch_obj.win)
    else
        print("selector must be fuzzy or witch")
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

(function()
    setup()
    local function test()
        select(
            { "tabs", "spaces", "core", "hoge", "huga", "hoge", "cole", "ghoe", "falf", "thoe", "oewi", "ooew", "feow" },
            {
                prompt = "> ",
            },
            function(choice)
                print("You chose " .. choice)
            end
        )
    end

    local function test2()
        local buf = vim.api.nvim_get_current_buf()
        local keys = vim.api.nvim_get_keymap("n")
        local choices = {}
        for _, val in ipairs(keys) do
            if not string.match(val.lhs, "^<Plug>") then
                choices[val.lhs] = val.desc or val.rhs
            end
        end
        -- print(vim.inspect(choices))
        select(choices, {
            prompt = "> ",
        }, function(rhs, lhs)
            while buf ~= vim.api.nvim_get_current_buf() do
            end
            local function rt(str)
                return vim.api.nvim_replace_termcodes(str, true, false, true)
            end

            local mode = vim.fn.mode()
            if mode == "i" then
                vim.api.nvim_feedkeys(rt("<esc>"), "n", 0)
                vim.api.nvim_feedkeys(lhs, "m", 1)
            elseif vim.fn.mode() == "n" then
            end
        end)
    end

    -- test
    cmd("WF", test2)
    -- bmap(0, "n", "<space>mw", test2, "WF")
    vim.api.nvim_set_keymap("n", "<space>mw", "", { callback = test2, noremap = true, silent = true, desc = "wf" })
    vim.api.nvim_set_keymap("n", "<C-W>mw", "", {
        callback = function()
            print("WF!")
        end,
        noremap = true,
        silent = true,
        desc = "[window] WF!",
    })
end)()
