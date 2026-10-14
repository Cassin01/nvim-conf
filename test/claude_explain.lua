-- Headless checks for lua/claude_explain. A fake `claude` on PATH stands in for the model, so nothing is billed.
-- Run from the config root: nvim --clean --headless -l test/claude_explain.lua
vim.o.verbose = 0 -- -l sets verbose=1, which prints every message to stdout
vim.o.hidden = true
local root = vim.fn.fnamemodify(arg[0], ":p:h:h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path -- no rtp: no user ftplugins
local api = vim.api
local claude = require("claude_explain.claude")
local render = require("claude_explain.render")
local ce = require("claude_explain")
local NS = api.nvim_create_namespace("claude_explain")
local LINES = api.nvim_create_namespace("claude_explain.lines")
local TEXT = "ClaudeExplainText"

local checks, fails = 0, 0
local function eq(what, got, want)
    checks = checks + 1
    if not vim.deep_equal(got, want) then
        fails = fails + 1
        io.stderr:write(("FAIL %s\n  want %s\n  got  %s\n"):format(what, vim.inspect(want), vim.inspect(got)))
    end
end
local function ok(what, cond)
    eq(what, not not cond, true)
end

-- The fake records its argv (NUL-separated), stdin, pid, run count and the signal that stopped it, and exits 143 on
-- SIGTERM like claude. It sleeps in 0.1 s slices because sh runs a trap only after the current foreground command.
local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local fake = dir .. "/claude"
vim.fn.writefile({
    "#!/bin/sh",
    [[trap 'echo TERM > "$FAKE_DIR/signal"; exit 143' TERM]],
    [[printf '%s\0' "$@" > "$FAKE_DIR/argv"]],
    [[cat > "$FAKE_DIR/stdin"]],
    [[echo $$ > "$FAKE_DIR/pid"]],
    [[echo r >> "$FAKE_DIR/runs"]],
    [[i=0; while [ "$i" -lt "$FAKE_TICKS" ]; do sleep 0.1; i=$((i + 1)); done]],
    [[printf '%s' "$FAKE_ERR" >&2]],
    [[printf '%s' "$FAKE_OUT"]],
    [[exit "$FAKE_CODE"]],
}, fake)
vim.fn.setfperm(fake, "rwxr-xr-x")
vim.env.PATH, vim.env.FAKE_DIR = dir .. ":" .. vim.env.PATH, dir
assert(vim.fn.exepath("claude") == fake, "the fake claude is not first on PATH; refusing to call the real one")

local function read(name)
    local f = io.open(dir .. "/" .. name, "rb")
    if not f then
        return nil
    end
    local s = f:read("*a")
    f:close()
    return s
end
local function runs()
    local _, n = (read("runs") or ""):gsub("r", "")
    return n
end
local function arg_after(flag)
    local a = vim.split(read("argv") or "", "\0", { plain = true })
    for i, v in ipairs(a) do
        if v == flag then
            return a[i + 1]
        end
    end
end
local function respond(out, o)
    o = o or {}
    vim.env.FAKE_OUT, vim.env.FAKE_ERR = out or "", o.err or ""
    vim.env.FAKE_CODE, vim.env.FAKE_TICKS = tostring(o.code or 0), tostring(math.floor((o.sleep or 0) * 10 + 0.5))
end
local function result(secs)
    return vim.json.encode({
        type = "result",
        subtype = "success",
        is_error = false,
        result = "",
        structured_output = { sections = secs },
    })
end
local function sec(first, last, title, text)
    return { start_line = first, end_line = last, title = title or "t", explanation = text or "x" }
end
local function wait(cond, ms)
    return vim.wait(ms or 5000, cond, 10)
end
local function msgs()
    return vim.fn.execute("messages")
end
local function dead(pid)
    return pid and wait(function()
        return not vim.uv.kill(pid, 0)
    end, 2000)
end
-- Call before a request starts; the returned function waits for that request's fake and returns its pid.
local function new_pid()
    os.remove(dir .. "/pid")
    os.remove(dir .. "/signal")
    return function()
        wait(function()
            return tonumber(read("pid")) -- the file can exist before echo has written to it
        end)
        return tonumber(read("pid"))
    end
end

local function buffer(lines)
    vim.cmd("silent! only")
    vim.cmd("enew!")
    local buf = api.nvim_get_current_buf()
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end
-- -l has no UI, so 'columns' never resizes the window; a split does.
local function set_width(n)
    local win = api.nvim_get_current_win()
    vim.cmd("rightbelow vnew")
    api.nvim_set_current_win(win)
    api.nvim_win_set_width(win, n)
end
-- -l has no main loop, so TextChanged and WinResized never fire by themselves. A failing callback does not raise.
local function fire(ev, buf)
    vim.v.errmsg = ""
    api.nvim_exec_autocmds(ev, buf and { buf = buf } or {})
    eq(ev .. ": no callback error", vim.v.errmsg, "")
end
local function marks(buf, ns)
    return api.nvim_buf_get_extmarks(buf, ns or NS, 0, -1, { details = true })
end
local function panel(buf) -- { row, glyph } for every panel row
    local out = {}
    for _, m in ipairs(marks(buf)) do
        if m[4].virt_text then
            out[#out + 1] = { m[2], m[4].virt_text[2][1] }
        end
    end
    return out
end
local function vlines(buf) -- { row, number of virtual lines } for every virt_lines mark
    local out = {}
    for _, m in ipairs(marks(buf)) do
        if m[4].virt_lines then
            out[#out + 1] = { m[2], #m[4].virt_lines }
        end
    end
    return out
end
local function cleared(buf)
    return #marks(buf) + #marks(buf, LINES) == 0
end
-- Runs :ClaudeExplain[!] and waits for its final message (the running message stays out of the history).
local function run(bang)
    vim.cmd("messages clear")
    vim.cmd(bang and "ClaudeExplain!" or "ClaudeExplain")
    wait(function()
        return msgs():find("ClaudeExplain: ", 1, true) ~= nil
    end)
    return msgs()
end

-- A failing script exits silently once verbose is 0, so the checks run under xpcall (see the end of the file).
local function main()
    -- claude.parse --------------------------------------------------------------------------------------------
    local function res(stdout, o)
        o = o or {}
        return { code = o.code or 0, signal = o.signal or 0, stdout = stdout, stderr = o.err or "" }
    end
    local function parse(secs, n)
        return claude.parse(res(result(secs)), n or 10)
    end
    local function ranges(list)
        return vim.tbl_map(function(s)
            return { s.first, s.last }
        end, list or {})
    end
    local function why(r)
        return select(2, claude.parse(r, 10))
    end
    local function raw(sections_json)
        return '{"type":"result","subtype":"success","is_error":false,"structured_output":{"sections":'
            .. sections_json
            .. "}}"
    end

    -- Normal
    eq("parse: two sections", parse({ sec(1, 3, "A", "a"), sec(4, 9, "B", "b") }), {
        { first = 1, last = 3, title = "A", text = "a" },
        { first = 4, last = 9, title = "B", text = "b" },
    })
    -- Boundary
    eq("parse: one-line file", ranges(parse({ sec(1, 1) }, 1)), { { 1, 1 } })
    eq("parse: single lines", ranges(parse({ sec(1, 1), sec(2, 2), sec(10, 10) })), { { 1, 1 }, { 2, 2 }, { 10, 10 } })
    eq("parse: gaps kept", ranges(parse({ sec(1, 2), sec(5, 6) })), { { 1, 2 }, { 5, 6 } })
    eq("parse: clamped", ranges(parse({ sec(0, 3), sec(8, 99) })), { { 1, 3 }, { 8, 10 } })
    eq("parse: empty list", select(2, parse({})), "claude returned no usable sections")
    -- Abnormal ranges
    eq("parse: sorted", ranges(parse({ sec(4, 6), sec(1, 3) })), { { 1, 3 }, { 4, 6 } })
    eq("parse: overlap clipped", ranges(parse({ sec(1, 5), sec(3, 8) })), { { 1, 5 }, { 6, 8 } })
    eq("parse: nested dropped", ranges(parse({ sec(1, 10), sec(3, 4) })), { { 1, 10 } })
    eq("parse: same start", ranges(parse({ sec(1, 3), sec(1, 10) })), { { 1, 3 }, { 4, 10 } })
    eq("parse: duplicate", ranges(parse({ sec(2, 4), sec(2, 4) })), { { 2, 4 } })
    eq(
        "parse: bad ranges dropped",
        ranges(parse({ sec(11, 12), sec(5, 3), sec(1.5, 3), sec("1", 3), { end_line = 3 }, sec(7, 7) })),
        { { 7, 7 } }
    )
    eq(
        "parse: non-table items",
        ranges(claude.parse(res(raw('[null,"x",3,' .. vim.json.encode(sec(2, 2)) .. "]")), 10)),
        {
            { 2, 2 },
        }
    )
    eq(
        "parse: infinite end",
        why(res(raw('[{"start_line":1,"end_line":1e999,"title":"t","explanation":"x"}]'))),
        "claude returned no usable sections"
    )
    eq("parse: cleaned text", parse({ { start_line = 1, end_line = 1, explanation = " l1\nl2\r\n\27x " } })[1], {
        first = 1,
        last = 1,
        title = "",
        text = "l1 l2 x",
    })
    eq("parse: tab in title", parse({ sec(1, 1, "a\tb") })[1].title, "a b")
    -- Abnormal shapes
    -- The CLI reports API and login errors as subtype "success" with is_error set.
    local login = vim.json.encode({
        type = "result",
        subtype = "success",
        is_error = true,
        result = "Not logged in · Please run /login",
    })
    local ok_result = { type = "result", subtype = "success", is_error = false, result = "" }
    local TIMED_OUT, NO_OUTPUT = "timed out after 10 min (or terminated)", "claude returned no structured output"
    local function json(t)
        return res(vim.json.encode(t))
    end
    -- stylua: ignore
    local shapes = {
        { "timeout 124", res("", { code = 124 }), TIMED_OUT },
        { "SIGTERM 143", res("", { code = 143 }), TIMED_OUT },
        { "not JSON", res("oops"), "unexpected output: oops" },
        { "stderr first line", res("", { code = 1, err = "\nError: --json-schema is not a valid JSON Schema: x\nmore" }), "Error: --json-schema is not a valid JSON Schema: x" },
        { "no output", res("", { code = 2 }), "claude exited with code 2" },
        { "array", res("[]"), "unexpected output: []" },
        { "not a result", res('{"type":"system"}'), 'unexpected output: {"type":"system"}' },
        { "not logged in", res(login, { code = 1 }), "Not logged in · Please run /login" },
        { "multi-line result", json({ type = "result", subtype = "success", is_error = true, result = "a\nb" }), "a" },
        { "error subtype", json({ type = "result", subtype = "error_max_structured_output_retries", errors = { "gave up" } }), "gave up" },
        { "bare error subtype", json({ type = "result", subtype = "error_during_execution" }), "claude failed (error_during_execution)" },
        { "terminal reason", json({ type = "result", subtype = "error_during_execution", terminal_reason = "x" }), "claude failed (x)" },
        { "empty result", json({ type = "result", subtype = "success", is_error = true, result = "", api_error_status = 529 }), "claude failed (HTTP 529)" },
        { "NUL in result", json({ type = "result", subtype = "success", is_error = true, result = "bad\0thing" }), "bad thing" },
        { "NUL in stderr", res("", { code = 1, err = "x\0y" }), "x y" },
        { "killed by a signal", res("", { signal = 9 }), "claude was killed by signal 9" },
        { "no structured_output", json(ok_result), NO_OUTPUT },
        { "null structured_output", res('{"type":"result","subtype":"success","is_error":false,"structured_output":null}'), NO_OUTPUT },
        { "sections not a list", res(raw('"x"')), NO_OUTPUT },
    }
    for _, c in ipairs(shapes) do
        eq("parse: " .. c[1], why(c[2]), c[3])
    end
    -- Extreme
    local many = {}
    for i = 5000, 1, -1 do
        many[#many + 1] = sec(i, i)
    end
    local parsed = parse(many, 5000)
    eq("parse: 5000 sections", { #parsed, parsed[1].first, parsed[5000].first }, { 5000, 1, 5000 })
    eq("parse: huge end", ranges(parse({ sec(1, 1e12) }, 3)), { { 1, 3 } })
    eq("parse: long text kept", #parse({ sec(1, 1, "t", ("あ"):rep(100000)) })[1].text, 300000)
    eq("parse: stderr capped", vim.fn.strchars(why(res("", { code = 1, err = ("e"):rep(300) }))), 200)

    -- render.wrap ---------------------------------------------------------------------------------------------
    local wrap = render.wrap
    local CLOSING = "、。，．・：；！？）」』】〕〉》"
    -- Normal
    eq("wrap: mixed", wrap("parse: CLI の JSON 出力を検証。decode 失敗時は nil を返す。", 18), {
        "parse: CLI の JSON",
        "出力を検証。decode",
        "失敗時は nil を返",
        "す。",
    })
    -- Boundary
    eq("wrap: empty", wrap("", 10), {})
    eq("wrap: exactly w", wrap(("a"):rep(10), 10), { ("a"):rep(10) })
    eq("wrap: w + 1", wrap(("a"):rep(11), 10), { ("a"):rep(10), "a" })
    eq("wrap: words fit", wrap("aaaa bbbbb", 10), { "aaaa bbbbb" })
    eq("wrap: word moves down", wrap("aaaa bbbbbb", 10), { "aaaa", "bbbbbb" })
    eq("wrap: closing mark hangs", wrap("あいう。", 6), { "あいう。" })
    eq("wrap: wide chars", wrap("あいうえ", 6), { "あいう", "え" })
    eq("wrap: closing marks only", wrap("、、、、", 2), { "、、", "、、" })
    eq("wrap: only one mark hangs", wrap("あいう。」えお", 6), { "あいう。", "」えお" })
    -- Abnormal
    eq("wrap: zero width", wrap("ab cd", 0), { "a", "b", "c", "d" })
    eq("wrap: wide char at width 1", wrap("あ", 1), { "あ" })
    ok("wrap: invalid UTF-8", pcall(wrap, "\255\254abc", 10))
    -- Extreme
    local long = ("日本語のテキスト、説明です。"):rep(1500)
    local wrapped, fit, nostart = wrap(long, 31), true, true
    for i, l in ipairs(wrapped) do
        fit = fit and api.nvim_strwidth(l) <= 33
        nostart = nostart and (i == 1 or not CLOSING:find(vim.fn.strcharpart(l, 0, 1), 1, true))
    end
    ok("wrap: long text fits", fit)
    ok("wrap: long text keeps kinsoku", nostart)
    eq("wrap: long text intact", table.concat(wrapped), long)
    local word = ("x"):rep(100000)
    local split = wrap(word, 37)
    eq("wrap: huge word", { #split, table.concat(split) == word }, { 2703, true })

    -- render.draw ---------------------------------------------------------------------------------------------
    local function lines_of(n, f)
        local t = {}
        for i = 1, n do
            t[i] = f(i)
        end
        return t
    end
    local function draw(buf, items)
        render.draw(buf, items, render.width(buf))
    end
    local short = function(i)
        return "x = " .. i
    end
    -- Normal: 80 columns, no number column, 12 short lines: p95 = 6 cells, so col = 7 and the text is 60 wide.
    local b = buffer(lines_of(12, short))
    local long_text = ("長い説明文です。"):rep(20)
    draw(b, { { 0, 2, "f", "short" }, { 3, 3, "g", long_text } })
    eq("draw: brackets", panel(b), { { 0, "╭ " }, { 1, "│ " }, { 2, "╰ " }, { 3, "─ " } })
    local m0 = marks(b)[1][4]
    eq("draw: column and priority", { m0.virt_text_win_col, m0.priority }, { 7, 65535 })
    eq("draw: marker", m0.virt_text[1][1], " ")
    eq("draw: title chunk", m0.virt_text[3], { "f", { TEXT, "ClaudeExplainTitle" } })
    eq("draw: pad", m0.virt_text[#m0.virt_text], { (" "):rep(vim.o.columns), TEXT })
    eq("draw: overflow", vlines(b), { { 3, #wrap("g: " .. long_text, 60) - 1 } })
    local overflow = marks(b)[5][4].virt_lines[1]
    eq("draw: overflow aligned", { overflow[1], overflow[2] }, { { (" "):rep(7) }, { "   ", TEXT } })
    vim.cmd("redraw!")
    eq("draw: on screen", { vim.fn.screenstring(1, 9), vim.fn.screenstring(1, 11) }, { "╭", "f" })
    -- Boundary
    draw(b, {})
    eq("draw: nothing", #marks(b), 0)
    draw(b, { { 0, 1, "t", ("a"):rep(60) } })
    eq("draw: exact fit", vlines(b), {})
    draw(b, { { 0, 1, "", "" } })
    eq("draw: glyphs only", { panel(b), vlines(b) }, { { { 0, "╭ " }, { 1, "╰ " } }, {} })
    draw(b, { { 11, 11, "t", long_text } })
    eq("draw: overflow on the last line", vlines(b)[1][1], 11)
    b = buffer(lines_of(12, function()
        return ("y"):rep(40)
    end))
    set_width(77)
    draw(b, { { 0, 2, "t", long_text } })
    eq(
        "draw: 77 cells",
        { marks(b)[1][4].virt_text_win_col, vlines(b)[1][2] },
        { 40, #wrap("t: " .. long_text, 30) - 3 }
    )
    set_width(76)
    draw(b, { { 0, 2, "t", long_text } })
    eq("draw: 76 cells falls back", { #panel(b), vlines(b)[1][1] }, { 0, 0 })
    eq("draw: fallback lead", marks(b)[1][4].virt_lines[1][1], { "│ ", { TEXT, "ClaudeExplainBracket" } })
    local fb = marks(b)[1][4].virt_lines[1]
    eq("draw: fallback width", fb[2][1] .. fb[3][1], wrap("t: " .. long_text, 70)[1])
    vim.cmd("only")
    draw(b, { { 0, 2, "t", long_text } })
    eq("draw: 80 cells without numbers", marks(b)[1][4].virt_text_win_col, 41)
    vim.wo.number = true -- the layout uses the text area, 4 cells narrower
    eq("draw: number column", render.width(b), 76)
    draw(b, { { 0, 2, "t", long_text } })
    eq("draw: number column falls back", #panel(b), 0)
    vim.wo.number = false
    b = buffer(lines_of(12, function()
        return "\t\tx = 1"
    end))
    draw(b, { { 0, 0, "t", "x" } })
    eq("draw: tabs count as tabstop cells", marks(b)[1][4].virt_text_win_col, 2 * vim.bo[b].tabstop + 5 + 1)
    b = buffer(lines_of(41, function(i)
        return i == 40 and ("v"):rep(7) or i == 41 and ("v"):rep(8) or short(i)
    end))
    draw(b, { { 0, 40, "t", "x" } })
    local rows = vim.tbl_map(function(p)
        return p[1]
    end, panel(b))
    eq(
        "draw: a line as wide as the column keeps its panel row",
        { marks(b)[1][4].virt_text_win_col, vim.tbl_contains(rows, 39), vim.tbl_contains(rows, 40) },
        { 7, true, false }
    )
    b = buffer(lines_of(12, function()
        return ("z"):rep(10)
    end))
    set_width(50)
    draw(b, { { 0, 0, "t", "x" } })
    eq("draw: narrow code, narrow window", marks(b)[1][4].virt_text_win_col, 11)
    -- Abnormal
    b = buffer(lines_of(12, short))
    local hidden = b
    vim.cmd("enew")
    eq("draw: buffer in no window", render.width(hidden), nil)
    vim.cmd("buffer " .. hidden)
    local float = api.nvim_open_win(b, false, { relative = "editor", row = 1, col = 1, width = 20, height = 3 })
    eq("draw: floats ignored", render.width(b), 80)
    api.nvim_win_close(float, true)
    local function text_at(buf, row) -- the text chunk drawn on row (rows after a section's first)
        for _, m in ipairs(marks(buf)) do
            if m[2] == row and m[4].virt_text then
                return m[4].virt_text[#m[4].virt_text - 1][1]
            end
        end
    end
    b = buffer(lines_of(21, function(i)
        return i == 21 and ("w"):rep(200) or short(i)
    end))
    draw(b, { { 0, 20, "t", "x" } })
    eq("draw: the column ignores a few long lines", marks(b)[1][4].virt_text_win_col, 7)
    eq("draw: a long last line keeps its code", { #panel(b), panel(b)[20] }, { 20, { 19, "│ " } })
    b = buffer(lines_of(21, function(i)
        return i == 11 and ("w"):rep(200) or short(i)
    end))
    draw(b, { { 9, 11, "t", long_text } })
    local flowed = wrap("t: " .. long_text, 60)
    eq(
        "draw: text flows past a long line",
        { panel(b), text_at(b, 11), vlines(b) },
        { { { 9, "╭ " }, { 11, "╰ " } }, flowed[2], { { 11, #flowed - 2 } } }
    )
    b = buffer(lines_of(42, function(i)
        return (i == 6 or i == 7) and ("w"):rep(200) or short(i)
    end))
    draw(b, { { 5, 6, "t", "x" } })
    eq("draw: a section of long lines gets a block", { #panel(b), vlines(b) }, { 0, { { 5, 1 } } })
    b = buffer(lines_of(40, function(i)
        return ("v"):rep(i * 37 % 97)
    end))
    draw(b, { { 0, 39, "t", long_text } })
    local covered = 0
    for _, m in ipairs(marks(b)) do
        local code = api.nvim_buf_get_lines(b, m[2], m[2] + 1, false)[1]
        if m[4].virt_text and api.nvim_strwidth(code) > m[4].virt_text_win_col then
            covered = covered + 1
        end
    end
    eq("draw: mixed widths never cover code", { covered, #panel(b) > 0, #panel(b) < 40 }, { 0, true, true })
    b = buffer(lines_of(3, short))
    set_width(20)
    draw(b, { { 0, 2, "t", long_text } })
    local first_line = marks(b)[1][4].virt_lines[1]
    eq("draw: fallback width floor", first_line[2][1] .. first_line[3][1], wrap("t: " .. long_text, 30)[1])
    -- Extreme
    b = buffer({ ("x"):rep(100000) })
    draw(b, { { 0, 0, "t", long_text } })
    eq(
        "draw: one huge line gets a block",
        { #panel(b), vlines(b), marks(b)[1][4].virt_lines[1][1][1] },
        { 0, { { 0, #wrap("t: " .. long_text, 74) } }, "│ " }
    )

    -- controller, end to end through the fake -----------------------------------------------------------------
    ce.setup(nil)
    ok("setup: command with bang", api.nvim_get_commands({}).ClaudeExplain.bang)
    -- Normal
    respond(result({ sec(1, 3, "A", "first"), sec(4, 6, "B", "second") }))
    b = buffer(lines_of(6, short))
    local out = run()
    eq(
        "e2e: drawn",
        panel(b),
        { { 0, "╭ " }, { 1, "│ " }, { 2, "╰ " }, { 3, "╭ " }, { 4, "│ " }, { 5, "╰ " } }
    )
    ok("e2e: success message", out:find("ClaudeExplain: 2 sections in %d+ s: %[No Name%]"))
    local args = vim.split(read("argv"), "\0", { plain = true })
    for _, flag in ipairs({ "-p", "--safe-mode", "--no-session-persistence" }) do
        ok("argv: " .. flag, vim.tbl_contains(args, flag))
    end
    ok("argv: no --verbose", not vim.tbl_contains(args, "--verbose"))
    eq("argv: values", {
        arg_after("--setting-sources"),
        arg_after("--tools"),
        arg_after("--model"),
        arg_after("--effort"),
        arg_after("--output-format"),
    }, { "", "", "sonnet", "low", "json" })
    eq("argv: schema", vim.json.decode(arg_after("--json-schema")).required, { "sections" })
    ok("argv: language", arg_after("--system-prompt"):find("in Japanese.", 1, true))
    local stdin = read("stdin")
    ok("stdin: header", vim.startswith(stdin, "File: [No Name]\nFiletype: none\nLines: 6\n\n1\tx = 1\n2\tx = 2\n"))
    ok(
        "stdin: request last",
        vim.endswith(stdin, "\n6\tx = 6\n\nExplain the file above as instructed, using its line numbers exactly.\n")
    )
    -- Toggle and bang
    local n = runs()
    vim.cmd("ClaudeExplain")
    eq("toggle: hidden", #marks(b), 0)
    fire("TextChanged", b)
    eq("toggle: an edit keeps it hidden", #marks(b), 0)
    vim.cmd("ClaudeExplain")
    eq("toggle: shown", #panel(b), 6)
    eq("toggle: no request", runs(), n)
    run(true)
    eq("bang: asks again", { runs(), #panel(b) }, { n + 1, 6 })
    -- Edits after rendering (A = rows 0-2, B = rows 3-5)
    vim.cmd("normal! 2Gdd")
    fire("TextChanged", b)
    eq("edit: dd inside A", panel(b), { { 0, "╭ " }, { 1, "╰ " }, { 2, "╭ " }, { 3, "│ " }, { 4, "╰ " } })
    vim.cmd("normal! 1Goinserted")
    fire("InsertLeave", b)
    eq(
        "edit: line inserted into A",
        panel(b),
        { { 0, "╭ " }, { 1, "│ " }, { 2, "╰ " }, { 3, "╭ " }, { 4, "│ " }, { 5, "╰ " } }
    )
    vim.bo[b].undolevels = vim.bo[b].undolevels -- undo break
    vim.cmd("normal! gg3dd")
    fire("TextChanged", b)
    eq("edit: A deleted", panel(b), { { 0, "╭ " }, { 1, "│ " }, { 2, "╰ " } })
    vim.cmd("undo")
    fire("TextChanged", b)
    eq("edit: undo brings A back", #panel(b), 6)
    vim.bo[b].undolevels = vim.bo[b].undolevels
    vim.cmd("messages clear")
    vim.cmd("normal! ggdG")
    fire("TextChanged", b)
    fire("TextChanged", b)
    local _, warned = msgs():gsub("the buffer changed", "")
    eq("edit: everything deleted", { #panel(b), warned }, { 0, 1 })
    vim.cmd("ClaudeExplain") -- hide
    vim.cmd("ClaudeExplain") -- show again: say why nothing appears
    _, warned = msgs():gsub("the buffer changed", "")
    eq("edit: warned again when shown", warned, 2)
    vim.cmd("undo")
    fire("TextChanged", b)
    eq("edit: undo brings all back", #panel(b), 6)
    respond(result({ sec(1, 3), sec(4, 6), sec(7, 10) }))
    b = buffer(lines_of(10, short))
    run()
    vim.cmd("4move 8")
    fire("TextChanged", b)
    local moved = vim.tbl_map(function(p)
        return p[1]
    end, panel(b))
    eq("edit: :move keeps rows disjoint", #vim.fn.uniq(moved), #moved)
    -- Undo after a new request: mark ids are never reused, so undo cannot drag the new marks to old rows
    respond(result({ sec(1, 3, "A"), sec(4, 6, "B") }))
    b = buffer(lines_of(6, short))
    run()
    vim.bo[b].undolevels = vim.bo[b].undolevels
    vim.cmd("normal! gg3dd")
    respond(result({ sec(1, 1, "A2"), sec(2, 3, "B2") }))
    run(true)
    vim.cmd("undo")
    fire("TextChanged", b)
    eq("edit: undo after a new request", panel(b), { { 3, "─ " }, { 4, "╭ " }, { 5, "╰ " } })
    -- Edits while the request runs
    respond(result({ sec(1, 2, "A"), sec(3, 3, "B") }), { sleep = 0.3 })
    b = buffer({ "a1", "a2", "b3" })
    vim.cmd("messages clear")
    vim.cmd("ClaudeExplain")
    api.nvim_buf_set_lines(b, 0, 0, false, { "new1", "new2" })
    fire("TextChanged", b)
    eq("during: nothing drawn yet", #marks(b), 0)
    wait(function()
        return msgs():find(" in %d+ s")
    end)
    eq("during: rows follow the edit", panel(b), { { 2, "╭ " }, { 3, "╰ " }, { 4, "─ " } })
    -- Resize, splits and floats
    respond(result({ sec(1, 3, "A", "text") }))
    b = buffer(lines_of(3, function()
        return ("y"):rep(30)
    end))
    run()
    eq("resize: right column", marks(b)[1][4].virt_text_win_col, 31)
    set_width(40)
    fire("WinResized")
    eq("resize: narrow falls back", { #panel(b), #vlines(b) }, { 0, 1 })
    vim.cmd("only")
    fire("WinResized")
    eq("resize: wide again", #panel(b), 3)
    local draws, real_draw = 0, render.draw -- extmark ids are reused after a clear, so count the redraws
    render.draw = function(...)
        draws = draws + 1
        return real_draw(...)
    end
    float = api.nvim_open_win(b, false, { relative = "editor", row = 1, col = 1, width = 10, height = 3 })
    api.nvim_win_set_config(float, { relative = "editor", row = 1, col = 1, width = 30, height = 5 })
    fire("WinResized")
    render.draw = real_draw
    eq("resize: a float showing the buffer does not redraw", draws, 0)
    api.nvim_win_close(float, true)
    vim.cmd("vsplit")
    fire("WinResized")
    eq("resize: split of the same buffer falls back", #panel(b), 0)
    -- A buffer can leave its narrowest window without any resize
    vim.cmd("only")
    vim.cmd("tab split")
    vim.cmd("vsplit")
    fire("WinResized")
    eq("tabs: a narrow split in another tab falls back", #panel(b), 0)
    vim.cmd("tabclose")
    eq("tabs: :tabclose brings the right column back", #panel(b), 3)
    respond(result({ sec(1, 3, "A", "text") }))
    b = buffer(lines_of(3, short))
    run()
    vim.cmd("vsplit")
    api.nvim_win_set_width(0, 30)
    fire("WinResized")
    eq("enew: the narrow split falls back", #panel(b), 0)
    vim.cmd("enew")
    eq("enew: leaving the narrow window brings the right column back", #panel(b), 3)
    -- Answer arrives while the buffer is hidden
    respond(result({ sec(1, 1) }), { sleep = 0.3 })
    b = buffer({ "x = 1" })
    vim.cmd("messages clear")
    vim.cmd("ClaudeExplain")
    vim.cmd("enew")
    wait(function()
        return msgs():find(" in %d+ s")
    end)
    eq("hidden: nothing drawn", #marks(b), 0)
    vim.cmd("buffer " .. b)
    eq("hidden: BufWinEnter draws", #panel(b), 1)
    ok("hidden: singular message", msgs():find("1 section in %d+ s: %[No Name%]"))
    -- A named file
    respond(result({ sec(1, 1) }))
    b = buffer({ "x = 1" })
    vim.bo[b].swapfile = false
    api.nvim_buf_set_name(b, vim.fn.getcwd() .. "/sub/x.lua")
    vim.bo[b].filetype = "lua"
    out = run()
    ok("named: stdin header", vim.startswith(read("stdin"), "File: sub/x.lua\nFiletype: lua\nLines: 1\n"))
    ok("named: message", out:find("1 section in %d+ s: sub/x%.lua"))
    -- Cancel, bang race, wipe, reload, exit
    respond(result({ sec(1, 1) }), { sleep = 5 })
    b = buffer({ "x = 1" })
    local pid = new_pid()
    vim.cmd("ClaudeExplain")
    pid = pid()
    out = run()
    ok("cancel: message", out:find("ClaudeExplain: cancelled", 1, true))
    ok("cancel: process killed", dead(pid))
    eq("cancel: by SIGTERM", read("signal"), "TERM\n")
    ok("cancel: marks cleared", cleared(b))
    respond(result({ sec(1, 1, "A") }), { sleep = 0.4 })
    b = buffer({ "x = 1" })
    vim.cmd("ClaudeExplain")
    respond(result({ sec(1, 1, "B") }))
    out = run(true)
    ok("race: ! while running shows one message", not out:find("cancelled", 1, true))
    vim.wait(600) -- outlast the first answer
    eq("race: only the second answer", vim.tbl_get(marks(b), 1, 4, "virt_text", 3, 1), "B")
    respond(result({ sec(1, 1) }), { sleep = 5 })
    b = buffer({ "x = 1" })
    pid = new_pid()
    vim.cmd("ClaudeExplain")
    pid = pid()
    vim.cmd("bwipeout! " .. b)
    ok("wipe: process killed", dead(pid))
    eq("wipe: by SIGTERM", read("signal"), "TERM\n")
    respond(result({ sec(1, 1) }))
    b = buffer({ "x = 1" })
    run()
    fire("BufReadPost", b)
    ok("reload: state dropped", cleared(b))
    n = runs()
    run()
    eq("reload: asks again", runs(), n + 1)
    respond(result({ sec(1, 1) }), { sleep = 30 })
    pid = new_pid()
    vim.system({
        vim.v.progpath,
        "--clean",
        "--headless",
        "-n",
        "-i",
        "NONE",
        "--cmd",
        ("lua package.path = %q"):format(package.path),
        "-c",
        "lua require('claude_explain').setup()",
        "-c",
        "call setline(1, 'x = 1')",
        "-c",
        "ClaudeExplain",
        "-c",
        ("lua vim.wait(5000, function() return vim.uv.fs_stat(%q) ~= nil end)"):format(dir .. "/pid"),
        "-c",
        "qa!",
    }):wait(15000)
    pid = pid()
    ok("exit: request started", pid)
    ok("exit: process killed", dead(pid))
    -- Timeout: claude exits 143 on SIGTERM, like the fake
    local system = vim.system
    vim.system = function(cmd, opts, on_exit)
        eq("timeout: 10 min", opts.timeout, 10 * 60 * 1000)
        eq("cwd: outside any repository", opts.cwd, vim.uv.os_tmpdir())
        opts.timeout = 200
        return system(cmd, opts, on_exit)
    end
    respond(result({ sec(1, 1) }), { sleep = 2 })
    b = buffer({ "x = 1" })
    out = run()
    vim.system = system
    ok("timeout: message", out:find("timed out after 10 min (or terminated)", 1, true))
    -- Errors
    local function fails_with(what, text, lines)
        local buf = buffer(lines or { "x = 1" })
        local o = run()
        ok(what, o:find(text, 1, true))
        ok(what .. ": nothing left", cleared(buf))
    end
    local path = vim.env.PATH
    vim.env.PATH = "/nonexistent"
    fails_with("error: no claude", "cannot run claude: ENOENT")
    vim.env.PATH = path
    respond(login, { code = 1 })
    fails_with("error: not logged in", "Not logged in · Please run /login")
    respond("oops")
    fails_with("error: garbage", "unexpected output: oops")
    respond("", { err = "error: unknown option '--x'\n", code = 1 })
    fails_with("error: bad flag", "error: unknown option '--x'")
    respond(vim.json.encode(ok_result))
    fails_with("error: no structured output", "claude returned no structured output")
    respond("", { err = ("e\t\27"):rep(50), code = 1 })
    buffer({ "x = 1" })
    local last = vim.split(vim.trim(run()), "\n")
    ok("error: long message fits the cmdline", vim.fn.strdisplaywidth(last[#last]) <= vim.v.echospace)
    n = runs()
    fails_with("refused: empty buffer", "the buffer is empty", { "", "  " })
    b = buffer({ "x = 1" })
    vim.bo[b].buftype = "prompt"
    ok("refused: prompt buffer", run():find("cannot explain a prompt buffer", 1, true))
    local term = api.nvim_create_buf(true, false)
    api.nvim_open_term(term, {})
    api.nvim_set_current_buf(term)
    ok("refused: terminal buffer", run():find("cannot explain a terminal buffer", 1, true))
    eq("refused: nothing ran", runs(), n)
    respond(result({ sec(1, 1) }))
    buffer({ ("s"):rep(1000) })
    run()
    local size = 1000 + 102400 - #read("stdin") -- line length that makes stdin exactly 100 KB
    buffer({ ("s"):rep(size) })
    run()
    eq("size: exactly the limit is sent", { runs(), #read("stdin") }, { n + 2, 102400 })
    fails_with("size: one byte more is refused", "file too large: 101 KB (limit 100 KB)", { ("s"):rep(size + 1) })
    eq("size: nothing ran", runs(), n + 2)
    -- setup
    respond(result({ sec(1, 1) }))
    ce.setup({ lang = "English" })
    buffer({ "x = 1" })
    run()
    ok("setup: English", arg_after("--system-prompt"):find("in English.", 1, true))
    local okk, err = pcall(ce.setup, { lang = 1 })
    ok("setup: lang must be a string", not okk and err:find("opts.lang", 1, true))
    okk, err = pcall(ce.setup, "x")
    ok("setup: opts must be a table", not okk and err:find("opts", 1, true))
    buffer({ "x = 1" })
    run()
    ok("setup: a rejected call keeps the language", arg_after("--system-prompt"):find("in English.", 1, true))
    for _ = 1, 50 do
        ce.setup({})
    end
    eq("setup: idempotent", #api.nvim_get_autocmds({ group = "claude_explain" }), 8)
    buffer({ "x = 1" })
    run()
    ok("setup: {} means Japanese", arg_after("--system-prompt"):find("in Japanese.", 1, true))
    -- Extreme
    local secs = {}
    for i = 1, 300 do
        secs[i] = sec(i * 10 - 9, i * 10)
    end
    respond(result(secs))
    b = buffer(lines_of(3000, short))
    run()
    eq("extreme: 3000 rows", #panel(b), 3000)
end

local ran, err = xpcall(main, debug.traceback)
if not ran then
    fails = fails + 1
    io.stderr:write(("ERROR after %d checks: %s\n"):format(checks, err))
end
eq("no stray errors", vim.v.errmsg, "") -- errors raised inside scheduled callbacks land here
if fails > 0 then
    io.stderr:write(("%d of %d checks failed\n"):format(fails, checks))
    vim.cmd.cquit() -- unlike os.exit, this unloads buffers (stopping running fakes) and removes the temp directory
end
io.stdout:write(("ok: %d checks\n"):format(checks))
