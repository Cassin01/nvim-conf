local rt = function(str)
    vim.api.nvim_replace_termcodes(str, true, false, true)
end

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
table.insert(maps, Map.new({ striker = "q", {prefix = ";", ret = "1"}}))
table.insert(maps, Map.new({ striker = "w", {prefix = ";", ret = "2"}}))
table.insert(maps, Map.new({ striker = "e", {prefix = ";", ret = "3"}}))
table.insert(maps, Map.new({ striker = "r", {prefix = ";", ret = "4"}}))
table.insert(maps, Map.new({ striker = "t", {prefix = ";", ret = "5"}}))
table.insert(maps, Map.new({ striker = "y", {prefix = ";", ret = "6"}}))
table.insert(maps, Map.new({ striker = "u", {prefix = ";", ret = "7"}}))
table.insert(maps, Map.new({ striker = "i", {prefix = ";", ret = "8"}}))
table.insert(maps, Map.new({ striker = "o", {prefix = ";", ret = "9"}}))
table.insert(maps, Map.new({ striker = "p", {prefix = ";", ret = "0"}}))

table.insert(maps, Map.new({ striker = "a", {prefix = ";", ret = "!"}}))
table.insert(maps, Map.new({ striker = "s", {prefix = ";", ret = "@"}}))
table.insert(maps, Map.new({ striker = "d", {prefix = ";", ret = "#"}}))
table.insert(maps, Map.new({ striker = "f", {prefix = ";", ret = "$"}}))
table.insert(maps, Map.new({ striker = "g", {prefix = ";", ret = "%"}}))
table.insert(maps, Map.new({ striker = "h", {prefix = ";", ret = "^"}}))
table.insert(maps, Map.new({ striker = "j", {prefix = ";", ret = "&"}, {prefix = "j", ret = "<ESC>"}}))
table.insert(maps, Map.new({ striker = "k", {prefix = ";", ret = "*"}}))
table.insert(maps, Map.new({ striker = "l", {prefix = ";", ret = "("}}))
table.insert(maps, Map.new({ striker = ";", {prefix = ";", ret = ")"}}))

for _, m in ipairs(maps) do
    vim.keymap.set("i", m.striker, function()
        local prefix = vim.fn.getline("."):sub(vim.fn.col(".") - 1, vim.fn.col(".") - 1)
        for _, a in ipairs(m) do
            if prefix == a.prefix then
                return "<BS>" .. a.ret
            end
        end
        return m.striker
    end, { noremap = true, silent = true, expr = true })
end
