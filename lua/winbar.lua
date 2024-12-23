-- local HighlightGroup = require('lua.highlighting.highlight-groups')
-- local Highlighter = require('lua.highlighting.highlighter')
local Navic = require("nvim-navic")

-- local theme = {}
-- theme.white = '#1e1e2e'
-- theme.purple = '#c792ea'
-- theme.black = '#89b4fa'
-- theme.red = '#a6e3a1'

-- local highlights = HighlightGroup({
--     WinBarSeparator = { guifg = theme.white },
--     WinBarContent = { guifg = theme.black, guibg = theme.white },
--     WinBarContentModified = {
--         guifg = theme.red,
--         guibg = theme.white,
--     },
-- })
-- Highlighter:new():add(highlights):register_highlights()

local function hl(name)
    if vim.fn.hlexists(name) then
        vim.api.nvim_set_hl(0, "NavicIcons" .. name, { default = true, link = name })
    else
        vim.api.nvim_set_hl(0, "NavicIcons" .. name, { default = true, link = "Structure" })
    end
end

local M = {}
function M.setup()
    vim.api.nvim_set_hl(0, "Navic" .. "Text", { default = true, link = "Function" })
    vim.api.nvim_set_hl(0, "Navic" .. "Separator", { default = true, link = "Function" })
    hl("File")
    hl("Module")
    hl("Namespace")
    hl("Package")
    hl("Class")
    hl("Method")
    hl("Property")
    hl("Field")
    hl("Constructor")
    hl("Enum")
    hl("Interface")
    hl("Function")
    hl("Variable")
    hl("Constant")
    hl("String")
    hl("Number")
    hl("Boolean")
    hl("Array")
    hl("Object")
    hl("Key")
    hl("Null")
    hl("EnumMember")
    hl("Struct")
    hl("Event")
    hl("Operator")
    hl("TypeParameter")
end

M.exec = function()
    local file_path = vim.api.nvim_eval_statusline("%f", {}).str
    local modified = vim.api.nvim_eval_statusline("%m", {}).str == "[+]" and "  " or ""

    local navic_is_available = Navic.is_available()
    file_path = file_path:gsub("/", " ➤ ")
    file_path = file_path
    -- .. (function()
    --     if navic_is_available then
    --         return " ➤ "
    --     else
    --         return ""
    --     end
    -- end)()
    local location = (function()
        if navic_is_available then
            return " ➤  " .. Navic.get_location() -- .. "%*"
        else
            return ""
        end
    end)()

    return "%#Function#" .. file_path .. "%*" .. "%#Function#" .. location

    -- return '%#WinBarSeparator#'
    --     .. ''
    --     .. '%*'
    --     -- .. '%#WinBarContentModified#'
    --     -- .. modified
    --     -- .. '%*'
    --     -- .. '%#WinBarContent#'
    --     -- .. file_path
    --     -- .. '%*'
    --     .. '%#WinBarContent#'
    --     .. location
    --     .. '%*'
    --     .. '%#WinBarSeparator#'
    --     .. ''
    --     .. '%*'
end

return M
