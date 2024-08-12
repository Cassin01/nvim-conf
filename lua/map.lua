vim.keymap.set("n", "<Space><Space>", "<cmd>update<cr>", { silent = true, noremap = true })

-- ╭──────────────────────────────────────────────────────────────────────────────╮
-- │                                    Bracket                                    │
-- ╰──────────────────────────────────────────────────────────────────────────────╯
local bracket = {
    new = function(p_, n_)
        return { prev_ = p_, next_ = n_ }
    end,
}
local brackets = {
    bracket.new("(", ")"),
    bracket.new("[", "]"),
    bracket.new("{", "}"),
    bracket.new("<", ">"),
    bracket.new('"', '"'),
    bracket.new("'", "'"),
    bracket.new("`", "`"),
}
local function space()
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local prev_ = line:sub(col - 1, col - 1)
    local next_ = line:sub(col, col)
    for _, v in ipairs(brackets) do
        if v.prev_ == prev_ and v.next_ == next_ then
            return "<Space><Space><Left>"
        end
    end
    return "<Space>"
end

local function backspace()
    local col = vim.fn.col(".")
    local line = vim.fn.getline(".")
    local prev_ = line:sub(col - 1, col - 1)
    local next_ = line:sub(col, col)
    for _, v in ipairs(brackets) do
        if v.prev_ == prev_ and v.next_ == next_ then
            return "<BS><Del>"
        end
    end
    -- "  " -> ""
    local eol = vim.api.nvim_strwidth(line)
    if col >= 3 and col + 1 <= eol then
        local prev__ = line:sub(col - 2, col - 2)
        local next__ = line:sub(col + 1, col + 1)
        if prev_ == " " and next_ == " " then
            for _, v in ipairs(brackets) do
                if v.prev_ == prev__ and v.next_ == next__ then
                    return "<BS><Del>"
                end
            end
        end
    end
    return "<BS>"
end

local function enter()
    local col = vim.fn.col(".")
    local line = vim.fn.getline(".")
    local prev_ = line:sub(col - 1, col - 1)
    local next_ = line:sub(col, col)
    for _, v in ipairs(brackets) do
        if v.prev_ == prev_ and v.next_ == next_ then
            -- return "<CR><ESC>O" .. string.rep("<Space>", vim.bo.shiftwidth)
            return "<CR><ESC>O"
        end
    end
    return "<CR>"
end

local function wrap_(line, col, next_)
    local back = line:sub(col + 1)
    for i = 1, #back do
        local c = back:sub(i, i)
        for _, v in ipairs(brackets) do
            if c == v.prev_ then
                return "<Del><ESC>f" .. v.prev_ .. "%A" .. next_
            end
        end
    end
    return "<C-;>"
end

local function wrap()
    local col = vim.fn.col(".")
    local line = vim.fn.getline(".")
    local prev_ = line:sub(col - 1, col - 1)
    local next_ = line:sub(col, col)
    for _, v in ipairs(brackets) do
        if v.prev_ == prev_ and v.next_ == next_ then
            return wrap_(line, col, next_)
        end
    end
    return "<C-;>"
end

vim.keymap.set("i", "<Space>", space, { silent = true, noremap = true, expr = true })
vim.keymap.set("i", "<BS>", backspace, { silent = true, noremap = true, expr = true })
vim.keymap.set("i", "<C-h>", backspace, { silent = true, noremap = true, expr = true })
vim.keymap.set("i", "<CR>", enter, { silent = true, noremap = true, expr = true })
vim.keymap.set("i", "<C-;>", wrap, { silent = true, noremap = true, expr = true })

-- ╭──────────────────────────────────────────────────────────────────────────────╮
-- │                                  Hyper Map                                   │
-- ╰──────────────────────────────────────────────────────────────────────────────╯
-- provides non-blocking mapping at insert mode
-- https://github.com/kuuote/dotvim/blob/16bbd416f5c6cd27fd88acb7235655897c6ffcaf/autoload/hypermap.vim
-- Original idea from https://thinca.hatenablog.com/entry/20120716/1342374586

local Map = {
    new = function(opts)
        local obj = opts
        return obj
    end,
}

local maps = {}

table.insert(maps, Map.new({ prefix = "j", striker = "j", ret = "<ESC>" }))

-- Number
table.insert(maps, Map.new({ striker = "q", { prefix = ";", ret = "1" } }))
table.insert(maps, Map.new({ striker = "w", { prefix = ";", ret = "2" } }))
table.insert(maps, Map.new({ striker = "e", { prefix = ";", ret = "3" } }))
table.insert(maps, Map.new({ striker = "r", { prefix = ";", ret = "4" } }))
table.insert(maps, Map.new({ striker = "t", { prefix = ";", ret = "5" } }))
table.insert(maps, Map.new({ striker = "y", { prefix = ";", ret = "6" } }))
table.insert(maps, Map.new({ striker = "u", { prefix = ";", ret = "7" } }))
table.insert(maps, Map.new({ striker = "i", { prefix = ";", ret = "8" } }))
table.insert(maps, Map.new({ striker = "o", { prefix = ";", ret = "9" } }))
table.insert(maps, Map.new({ striker = "p", { prefix = ";", ret = "0" } }))

table.insert(maps, Map.new({ striker = "a", { prefix = ";", ret = "!" } }))
table.insert(maps, Map.new({ striker = "s", { prefix = ";", ret = "@" } }))
table.insert(maps, Map.new({ striker = "d", { prefix = ";", ret = "#" } }))
table.insert(maps, Map.new({ striker = "f", { prefix = ";", ret = "$$<left>" } }))
table.insert(maps, Map.new({ striker = "g", { prefix = ";", ret = "%" } }))
table.insert(maps, Map.new({ striker = "h", { prefix = ";", ret = "^" } }))
table.insert(maps, Map.new({ striker = "j", { prefix = ";", ret = "&" }, { prefix = "j", ret = "<ESC>" } }))
table.insert(maps, Map.new({ striker = "k", { prefix = ";", ret = "*" } }))
table.insert(maps, Map.new({ striker = "l", { prefix = ";", ret = "()<left>" }, { prefix = ";;", ret = "()<Left>" } }))

table.insert(
    maps,
    Map.new({
        striker = "(",
        { prefix = "", ret = "()<left>" },
        { prefix = ";", ret = "(" },
        {
            prefix = ";;",
            ret = function()
                return "()<Left><CR><ESC>O" .. string.rep("<Space>", vim.bo.shiftwidth)
            end,
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = "{",
        { prefix = "", ret = "{}<left>" },
        { prefix = ";", ret = "{" },
        {
            prefix = ";;",
            ret = function()
                return "{}<Left><CR><ESC>O" .. string.rep("<Space>", vim.bo.shiftwidth)
            end,
        },
        {
            prefix = "c;",
            ret = function()
                local header = string.format(vim.opt_local.commentstring["_value"], " {{{ ")
                local footer = string.format(vim.opt_local.commentstring["_value"], " }}} ")
                return header .. footer .. string.rep("<Left>", string.len(footer)) .. "<CR><ESC>O" .. string.rep("<Space>", vim.bo.shiftwidth)
            end
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = "[",
        { prefix = "", ret = "[]<left>" },
        { prefix = ";", ret = "[" },
        {
            prefix = ";;",
            ret = function()
                return "[]<Left><CR><ESC>O" .. string.rep("<Space>", vim.bo.shiftwidth)
            end,
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = "'",
        { prefix = "", ret = "''<left>" },
        { prefix = ";", ret = "'" },
        {
            prefix = ";;",
            ret = "''''''<Left><Left><Left><CR><ESC>O",
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = "`",
        { prefix = "", ret = "``<left>" },
        { prefix = ";", ret = "`" },
        {
            prefix = ";;",
            ret = "``````<Left><Left><Left><CR><ESC>O",
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = '"',
        { prefix = "", ret = '""<left>' },
        { prefix = ";", ret = '"' },
        {
            prefix = ";;",
            ret = '""""""<Left><Left><Left><CR><ESC>O',
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = "<",
        { prefix = "", ret = "<><left>" },
        { prefix = ";", ret = "<" },
        {
            prefix = ";;",
            ret = "<><Left><CR><ESC>O",
        },
    })
)
table.insert(
    maps,
    Map.new({
        striker = "-",
        {
            prefix = ";;",
            ret = "------<Left><Left><Left><ESC>O",
        },
    })
)

table.insert(maps, Map.new({ striker = "z", { prefix = ";", ret = "-" } }))
table.insert(maps, Map.new({ striker = "x", { prefix = ";", ret = "_" } }))
table.insert(maps, Map.new({ striker = "c", { prefix = ";", ret = "+" } }))
table.insert(maps, Map.new({ striker = "v", { prefix = ";", ret = "=" } }))
table.insert(maps, Map.new({ striker = "b", { prefix = ";", ret = "|" } }))
table.insert(maps, Map.new({ striker = "n", { prefix = ";", ret = "\\" } }))
table.insert(maps, Map.new({ striker = "m", { prefix = ";", ret = "~" } }))
table.insert(maps, Map.new({ striker = ",", { prefix = ";", ret = "`" } }))

local function match_back(str, patt)
    if string.len(patt) == 0 then
        return true
    end
    return string.sub(str, string.len(patt) * -1, -1) == patt
end

local core = function(m)
    return function()
        local prefix = vim.fn.getline("."):sub(1, vim.fn.col(".") - 1)
        local max_len = -1
        local cont
        for _, a in ipairs(m) do
            if match_back(prefix, a.prefix) then
                if string.len(a.prefix) > max_len then
                    cont = function()
                        return string.rep("<BS>", string.len(a.prefix))
                        .. (type(a.ret) == "function" and a.ret() or a.ret)
                    end
                    max_len = string.len(a.prefix)
                end
            end
        end
        if max_len ~= -1 then
            return cont()
        end
        return m.striker
    end
end

for _, m in ipairs(maps) do
    vim.keymap.set("i", m.striker, core(m), { noremap = true, silent = true, expr = true })
end

-- vim.api.nvim_create_autocmd(
--     {"BufRead", "BufNewFile"},
--     {
--         callback = function ()
--             vim.key
--         end,
--         pattern = {".html"},
--         group = create_augroup("specific_stiker", {clear = true})
--     }
--     )
