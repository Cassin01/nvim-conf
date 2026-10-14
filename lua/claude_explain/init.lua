local claude = require("claude_explain.claude")
local render = require("claude_explain.render")
local api = vim.api
local M = {}

-- Mark id base + N sits on line N of the text sent to Claude and follows every edit made since.
local LINES = api.nvim_create_namespace("claude_explain.lines")
-- Ids are never reused: undo restores extmarks by id, so a reused id would jump back to an old request's line.
local next_id = 0
local lang
-- buf -> { job = SystemObj while running, sections = list once answered, base, shown, started, warned, avail }
local states = {}

local function progress(buf, status, msg)
    -- A message wider than the cmdline waits for Enter; 18 = the "ClaudeExplain: " title, a hanging mark, 1 spare.
    msg = render.wrap(msg, math.max(vim.v.echospace - 18, 20))[1] or ""
    -- An ErrorMsg chunk instead of err=true: err makes vim.cmd() raise, and lazy's cmd stub calls us via vim.cmd().
    api.nvim_echo({ { msg, status == "failed" and "ErrorMsg" or nil } }, status ~= "running", {
        id = "claude_explain." .. buf,
        kind = "progress",
        status = status,
        title = "ClaudeExplain",
        source = "claude_explain",
    })
end

local function draw(buf)
    local st = states[buf]
    local avail = st and st.shown and render.width(buf)
    if not avail then
        return -- toggled off, still running, or in no window (BufWinEnter covers the last)
    end
    st.avail = avail
    local items, prev, eof = {}, -1, api.nvim_buf_line_count(buf)
    for _, s in ipairs(st.sections) do
        local first = api.nvim_buf_get_extmark_by_id(buf, LINES, st.base + s.first, {})[1]
        local after = api.nvim_buf_get_extmark_by_id(buf, LINES, st.base + s.last + 1, {})[1] or eof
        -- Empty once its lines are deleted. After :move moves a section's first line, sections can stretch over
        -- other lines or vanish; :ClaudeExplain! asks again. The prev check keeps the rows disjoint for render.draw.
        if first and first > prev and first < after then
            items[#items + 1], prev = { first, after - 1, s.title, s.text }, after - 1
        end
    end
    if #items == 0 and not st.warned then -- e.g. a formatter that rewrites the whole buffer
        st.warned = true
        progress(buf, "failed", "the buffer changed; :ClaudeExplain! asks again")
    end
    render.draw(buf, items, avail)
end

-- The only place that kills a request or drops a state. quiet: a new request follows, and two messages in one
-- command would wait for Enter.
local function stop(buf, quiet)
    local st = states[buf]
    if not st then
        return
    end
    states[buf] = nil
    if st.job then
        if not st.job:is_closing() then
            st.job:kill(15)
        end
        if not quiet then
            progress(buf, "cancel", "cancelled")
        end
    end
    if api.nvim_buf_is_loaded(buf) then
        api.nvim_buf_clear_namespace(buf, LINES, 0, -1)
        render.clear(buf)
    end
end

local function start(buf)
    local bt = vim.bo[buf].buftype
    if bt == "terminal" or bt == "prompt" then
        return progress(buf, "failed", "cannot explain a " .. bt .. " buffer")
    end
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    if not table.concat(lines):find("%S") then
        return progress(buf, "failed", "the buffer is empty")
    end
    local path = api.nvim_buf_get_name(buf)
    local name = path ~= "" and vim.fn.fnamemodify(path, ":~:.") or "[No Name]" -- "" would expand to the cwd
    local st = { shown = false, started = vim.uv.now() }
    local job, err = claude.run(lines, name, vim.bo[buf].filetype, lang, function(sections, why)
        if states[buf] ~= st then
            return -- cancelled, replaced by !, or the buffer went away
        end
        st.job = nil
        if not sections then
            stop(buf)
            return progress(buf, "failed", why)
        end
        st.sections, st.shown = sections, true
        local secs = math.floor((vim.uv.now() - st.started) / 1000)
        local plural = #sections == 1 and "" or "s"
        -- The name goes last: a long path would otherwise push the result out of the one-line message.
        progress(buf, "success", ("%d section%s in %d s: %s"):format(#sections, plural, secs, name))
        draw(buf)
    end)
    if not job then
        return progress(buf, "failed", err)
    end
    st.job, states[buf] = job, st
    st.base, next_id = next_id, next_id + #lines
    -- Same main-loop tick as the snapshot, so no edit can come between the text sent and the marks.
    for i = 1, #lines do
        api.nvim_buf_set_extmark(buf, LINES, i - 1, 0, { id = st.base + i })
    end
    progress(buf, "running", "explaining " .. name .. " ...")
end

local function command(opts)
    local buf = api.nvim_get_current_buf()
    local st = states[buf]
    if st and not opts.bang then
        if st.job then
            return stop(buf)
        end
        st.shown = not st.shown
        if st.shown then
            st.warned = false
            draw(buf)
        else
            render.clear(buf)
        end
        return
    end
    stop(buf, true)
    start(buf)
end

function M.setup(opts)
    vim.validate("opts", opts, "table", true)
    vim.validate("opts.lang", opts and opts.lang, "string", true)
    lang = opts and opts.lang or "Japanese"
    local group = api.nvim_create_augroup("claude_explain", { clear = true })
    -- InsertLeave too: TextChanged does not fire for text typed in Insert mode.
    api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufWinEnter" }, {
        group = group,
        callback = function(ev)
            draw(ev.buf)
        end,
    })
    -- Only a new text width changes the layout: completion menus and other floats resize while typing, and a
    -- buffer can leave its narrowest window without any resize (:tabclose, :edit in that window).
    api.nvim_create_autocmd({ "WinResized", "TabClosed", "BufWinEnter" }, {
        group = group,
        callback = function()
            for buf, st in pairs(states) do
                if render.width(buf) ~= st.avail then
                    draw(buf)
                end
            end
        end,
    })
    -- BufUnload also runs for every loaded buffer when Neovim exits, which kills running requests.
    -- BufReadPost catches reloads (:e!, autoread), after which the marks no longer match the text.
    api.nvim_create_autocmd({ "BufUnload", "BufReadPost" }, {
        group = group,
        callback = function(ev)
            stop(ev.buf)
        end,
    })
    api.nvim_create_user_command("ClaudeExplain", command, {
        bang = true,
        desc = "Explain the current file with Claude (toggle or cancel; ! asks again)",
    })
end

return M
