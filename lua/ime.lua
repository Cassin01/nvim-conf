local toggle = true
local external_ime_control = false

if vim.fn.has("mac") == 0 then
    return
end

local _ime_on = function()
    vim.cmd("highlight iCursor guibg=#cc6666")
    vim.cmd("set guicursor+=i:var25-iCursor")
    vim.g.ime_on = true
end

local _ime_off = function()
    vim.cmd("highlight iCursor guibg=#5FAFFF")
    vim.cmd("set guicursor+=i:var25-iCursor")
    vim.g.ime_on = false
end

local _lmap_on = function()
    vim.cmd("highlight iCursor guibg=#fab387")
    vim.cmd("set guicursor+=i:var25-iCursor")
    vim.g.lmap_on = true
end

-- 日本語
local ime_on = function()
    if not vim.g.ime_on then
        local script = [[osascript -e "tell application \"System Events\" to key code 104"]]
        vim.fn.system(script)
        _ime_on()
    end
end

-- 英語
local ime_off = function()
    if vim.g.ime_on then
        local script = [[osascript -e "tell application \"System Events\" to key code 102"]]
        vim.fn.system(script)
        _ime_off()
    end
end

local toggle_ime = function()
    if vim.g.ime_on then
        local script = [[osascript -e "tell application \"System Events\" to key code 102"]]
        vim.fn.system(script)
        _ime_off()
    else
        local script = [[osascript -e "tell application \"System Events\" to key code 104"]]
        vim.fn.system(script)
        _ime_on()
    end
end

local toggle_ime_swift = function()
    local exe = vim.fn.expand("$HOME/.config/nvim/") .. "script/ime"
    if vim.g.ime_on then
        vim.fn.system(exe .. " com.google.inputmethod.Japanese.Roman")
        _ime_off()
    else
        vim.fn.system(exe .. " com.google.inputmethod.Japanese.base")
        _ime_on()
    end
end

if toggle then
    vim.api.nvim_set_keymap(
        "i",
        "<c-j>",
        "",
        { nowait = true, callback = toggle_ime_swift, noremap = true, silent = true, desc = "IME on" }
    )
else
    vim.api.nvim_set_keymap(
        "i",
        "<c-k>",
        "",
        { nowait = true, callback = ime_on, noremap = true, silent = true, desc = "IME on" }
    )
    vim.api.nvim_set_keymap(
        "i",
        "<c-j>",
        "",
        { nowait = true, callback = ime_off, noremap = true, silent = true, desc = "IME off" }
    )
end

local g = vim.api.nvim_create_augroup("my_ime", { clear = true })

-- モード切り替え時の制御
if external_ime_control then -- karabiner等で制御されている場合
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = g,
        callback = function()
            _ime_off()
        end,
    })
else
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = g,
        callback = function()
            ime_off()
        end,
    })
end

vim.api.nvim_set_keymap("i", "<c-^>", "", {
    nowait = true,
    callback = function()
        if vim.g.ime_on then
            ime_off()
        end
        if vim.g.lmap_on then
          _ime_off()
        else
          _lmap_on()
        end
        local k = vim.api.nvim_replace_termcodes("<C-^>", true, false, true)
        return k
    end,
    expr = true,
    noremap = true,
    silent = true,
    desc = "lmap toggle",
})

_ime_off()

-- 参考: https://rcmdnk.com/blog/2017/03/10/computer-mac-vim/
