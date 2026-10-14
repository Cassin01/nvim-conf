local api = vim.api
local M = {}

local NS = api.nvim_create_namespace("claude_explain")
local GAP = 1 -- blank cells between typical code and the panel
local MIN_CODE = 40 -- the panel may start left of this column only when the code is narrower
local MIN_TEXT, MAX_TEXT = 30, 60 -- explanation width in cells
local RESERVE = 7 -- gap, bracket and space (3), a hanging 。 (2), a sign column appearing later (2)
local NOSTART = {} -- closing marks that may not start a line (all 2 cells wide)
for c in ("、。，．・：；！？）」』】〕〉》"):gmatch("[\194-\244][\128-\191]*") do
    NOSTART[c] = true
end

for name, link in pairs({
    ClaudeExplainText = "NormalFloat", -- not Comment: several colorschemes make it italic, which hurts Japanese
    ClaudeExplainTitle = "Title",
    ClaudeExplainBracket = "FloatBorder",
}) do
    api.nvim_set_hl(0, name, { link = link, default = true })
end
local TEXT = "ClaudeExplainText"
local TITLE = { TEXT, "ClaudeExplainTitle" } -- stacked, so the title keeps the panel background
local BRACKET = { TEXT, "ClaudeExplainBracket" }

-- Lines of at most w cells. Runs of printable ASCII stay whole unless wider than w; other characters break
-- anywhere. A single closing mark may hang 2 cells past w. s has no control characters (callers clean them).
function M.wrap(s, w)
    local lines, cur, cw = {}, "", 0
    local function push()
        lines[#lines + 1] = (cur:gsub(" $", ""))
        cur, cw = "", 0
    end
    local function add(tok, tw)
        if cw > 0 and cw + tw > w and not (NOSTART[tok] and cw <= w) then
            push()
            if tok == " " then
                return
            end
        end
        cur, cw = cur .. tok, cw + tw
    end
    local i = 1
    while i <= #s do
        local tok = s:match("^[!-~]+", i) or s:match("^[\194-\244][\128-\191]*", i) or s:sub(i, i)
        i = i + #tok
        local tw = api.nvim_strwidth(tok)
        if tw > w and tok:byte() < 128 then -- an ASCII run wider than a line breaks anywhere
            for c in tok:gmatch(".") do
                add(c, 1)
            end
        else
            add(tok, tw)
        end
    end
    if cur ~= "" then
        push()
    end
    return lines
end

-- Narrowest text area among the normal windows showing buf (nil if none); floats such as menus are ignored.
-- ponytail: one layout for every window; per-window layouts need a decoration provider.
function M.width(buf)
    local w
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if api.nvim_win_get_config(win).relative == "" then
            local info = vim.fn.getwininfo(win)[1]
            w = math.min(w or math.huge, info.width - info.textoff)
        end
    end
    return w
end

local function chunks(line, ntitle) -- the first ntitle bytes of line are the title
    ntitle = math.min(ntitle, #line)
    if ntitle == 0 then
        return { { line, TEXT } }
    end
    return { { line:sub(1, ntitle), TITLE }, { line:sub(ntitle + 1), TEXT } }
end

function M.clear(buf)
    api.nvim_buf_clear_namespace(buf, NS, 0, -1)
end

-- items: { {first_row, last_row, title, text}, ... } with 0-based rows inside the buffer, ascending and disjoint.
-- avail: M.width(buf).
-- ponytail: redraws every row on each call (~20 ms at 3000 lines); draw only the visible rows if big files lag.
function M.draw(buf, items, avail)
    M.clear(buf)
    local tab, widths = (" "):rep(vim.bo[buf].tabstop), {}
    for i, l in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
        widths[i] = api.nvim_strwidth((l:gsub("\t", tab))) -- a tab as a full tabstop: an upper bound
    end
    local sorted = vim.list_slice(widths)
    table.sort(sorted)
    -- The column follows typical code (the 95th percentile), so a few long lines do not push it off the screen.
    -- ponytail: edits to those lines can shift the panel by a few cells; cache the column if that bothers.
    local want = sorted[math.ceil(#sorted * 0.95)] + GAP
    local limit = avail - RESERVE - MIN_TEXT
    local right = limit >= math.min(want, MIN_CODE) -- otherwise too few rows would leave room for the panel
    local col = right and math.min(want, limit) or 0
    local width = math.min(avail - RESERVE - col, MAX_TEXT)
    -- A block row is "│ " + text + a hang + sign slack: RESERVE without the gap cell. It never goes below MIN_TEXT,
    -- so a tiny window clips the text instead of growing it.
    local full = math.max(avail - (RESERVE - 1), MIN_TEXT)
    local pad = { (" "):rep(vim.o.columns), TEXT } -- clipped at the window edge, for an even panel background
    for _, it in ipairs(items) do
        local first, last, title, body = it[1], it[2], it[3], it[4]
        -- The panel never covers code: rows whose code reaches the column get no panel and the text flows past them.
        local free = {}
        if right then
            for row = first, last do
                if widths[row + 1] <= col then
                    free[#free + 1] = row
                end
            end
        end
        local text = title ~= "" and body ~= "" and title .. ": " .. body or title .. body
        local lines = M.wrap(text, #free > 0 and width or full)
        for i, row in ipairs(free) do
            local glyph = first == last and "─ " or row == first and "╭ " or row == last and "╰ " or "│ "
            local vt = { { " ", BRACKET }, { glyph, BRACKET } }
            vim.list_extend(vt, chunks(lines[i] or "", i == 1 and #title or 0))
            vt[#vt + 1] = pad
            api.nvim_buf_set_extmark(buf, NS, row, 0, {
                virt_text = vt,
                virt_text_win_col = col,
                priority = 65535, -- the maximum: diagnostics created later would otherwise draw over the panel
                invalidate = true,
            })
        end
        local vl = {}
        for i = #free + 1, #lines do
            local l = #free > 0 and { { (" "):rep(col) }, { "   ", TEXT } } or { { "│ ", BRACKET } }
            vim.list_extend(l, chunks(lines[i], i == 1 and #title or 0))
            l[#l + 1] = pad
            vl[#vl + 1] = l
        end
        if #vl > 0 then -- the overflow under the range, or a block under its first row when no row is free
            api.nvim_buf_set_extmark(buf, NS, #free > 0 and last or first, 0, { virt_lines = vl, invalidate = true })
        end
    end
end

return M
