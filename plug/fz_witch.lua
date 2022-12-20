local util = require("util")
local cmd = util.cmd
local aug = util.aug
local au = util.au

-- user option
local _index = { "a", "s", "d", "f", "g", "h", "j", "k", "l" }
local plug_name = "fz_witch"
local full_name = (function(hash)
  return plug_name .. hash
end)("309240")
local _g = aug(full_name)
local input_win_row_offset = 3 -- shift up output-window's row with input-window's height

local function bmap(buf, mode, key, f, desc)
  util.bmap(buf, mode, key, f, "[" .. plug_name .. "] ".. desc)
end
-- util

local index = (function(list)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end)(_index)

local function open_win(buf, height, row_offset)
  local conf_ = {
    col = 0,
    relative = "editor",
    anchor = "NW",
    style = "minimal",
    border = "rounded",
  }
  local conf = vim.fn.extend(
    conf_,
    { height = height, row = vim.o.lines - height - row_offset - 1, width = vim.o.columns - conf_.col }
  )
  return vim.api.nvim_open_win(buf, true, conf)
end

local function gen_obj(row_offset)
  local buf = vim.api.nvim_create_buf(false, true)
  local height = vim.api.nvim_buf_line_count(buf)
  local win = open_win(buf, height, row_offset)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  return buf, win
end

local function _update_output_obj(obj, choices, lines, row_offset)
  vim.api.nvim_buf_set_lines(obj.buf, 0, -1, true, choices)
  local cnf = vim.api.nvim_win_get_config(obj.win)
  local height = vim.api.nvim_buf_line_count(obj.buf)
  local row = lines - height - row_offset - 1
  vim.api.nvim_win_set_config(obj.win, vim.fn.extend(cnf, { height = height, row = row }))
end

local function input_obj_gen(output_obj, choices, co, prompt)
  local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)
  local _lines = vim.o.lines
  local buf, win = gen_obj(_row_offset)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")

  local del = function() -- deliminator of the whole process
    if vim.api.nvim_win_is_valid(output_obj["win"]) then
      vim.api.nvim_win_close(output_obj["win"], true)
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_win_is_valid(output_obj["buf"]) then
      vim.api.nvim_buf_delete(output_obj["buf"], { force = true })
    end
    if vim.api.nvim_win_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  au(_g, "BufWinLeave", function()
    del()
  end, { buffer = buf })
  au(_g, "BufWinLeave", function()
    del()
  end, { buffer = output_obj["buf"] })

  -- vim.fn.sign_define("mysign", { text = prompt, texthl = prompt  })
  vim.fn.sign_define(full_name .. "prompt", {
    text = prompt,
    texthl = "Error",
    linehl = "Search",
  })
  vim.fn.sign_place(0, _g, full_name .. "prompt", buf, { lnum = 1, priority = 10 })

  _update_output_obj(output_obj, choices, _lines, _row_offset + input_win_row_offset)
  au(_g, "InsertEnter", function()
    local _, _ = pcall(function()
      -- turn off the completion
      require("cmp").setup.buffer({ enabled = false })
    end)
  end, { buffer = buf })
  if vim.fn.mode() == "n" then
    vim.fn.feedkeys("i", "n")
  end
  local match_ids = {}
  au(_g, "TextChangedI", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local _res = vim.fn.matchfuzzypos(choices, lines[1])
    local matches = _res[1]
    local poss = _res[2]
    -- vim.fn.clearmatches(output_obj['win'])
    for _, id in ipairs(match_ids) do
      vim.fn.matchdelete(id, output_obj.win)
    end
    match_ids = {}
    for i, _ in ipairs(matches) do
      for _, v in ipairs(poss[i]) do
        table.insert(
          match_ids,
          vim.fn.matchaddpos("IncSearch", { { i, v + 1 } }, 0, -1, { window = output_obj["win"] })
        )
      end
    end

    vim.cmd("redraw!")

    if lines[1] == "" then -- show choices with no input text
      _update_output_obj(output_obj, choices, _lines, _row_offset + input_win_row_offset)
    else
      _update_output_obj(output_obj, matches, _lines, _row_offset + input_win_row_offset)
    end
  end, { buffer = buf })
  local on_choice = function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local matches = vim.fn.matchfuzzy(choices, lines[1])
    if #matches == 1 then
      local callback = co()
      if callback ~= nil then
        local c = string.match(matches[1], "^[(%d)]")
        if c ~= nil then
          local num = tonumber(c)
          callback(num)
        end
      end
      del()
    elseif #matches > 1 then
      -- TODO: select with allow
    else
      print("not matched")
    end
  end
  local function getchar()
    while true do
      if vim.fn.getchar(1) then
        local c = vim.fn.getchar()
        if index[c] then
          return c
        else
          return nil
        end
      end
    end
  end

  local to_witch = function()
    local c = getchar()
    local set = {}
    if c ~= nil then
      return set[c]
    end
  end
  local to_fuzzy = function() end
  local update_selector = function(direction)
    return function()
      if direction == "up" then
        do
        end
      elseif direction == "down" then
        do
        end
      end
    end
  end
  bmap(buf, { "i", "n" }, "<c-c>", del, "")
  bmap(buf, { "n" }, "<esc>", del, "")
  bmap(buf, { "i", "n" }, "<c-m>", on_choice, "")
  bmap(buf, { "i", "n" }, "<c-w>", to_witch, "")
  bmap(buf, { "i", "n" }, "<c-f>", to_fuzzy, "")
  bmap(buf, { "i" }, "<c-k>", update_selector("up"), "")
  bmap(buf, { "i" }, "<c-j>", update_selector("down"), "")
  bmap(buf, { "n" }, "k", update_selector("up"), "")
  bmap(buf, { "n" }, "j", update_selector("down"), "")

  return { buf = buf, win = win }, co
end

local function output_obj_gen()
  local buf, win = gen_obj(vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset)
  vim.api.nvim_buf_set_option(buf, "filetype", full_name .. "output")

  return { buf = buf, win = win }
end

local function inputlist(choices, opts)
  opts = opts or { prompt = "> " }

  -- 表示用バッファを作成
  local output_obj = output_obj_gen()

  -- 入力用バッファを作成
  local co = coroutine.wrap(function()
    local callback = nil
    coroutine.yield(function(callback_)
      callback = callback_
    end)
    coroutine.yield(callback)
  end)
  input_obj_gen(output_obj, choices, co, opts.prompt)

  return co
end

local function select(items, opts, on_choice)
  vim.validate({
    items = { items, "table", false },
    on_choice = { on_choice, "function", false },
  })
  opts = opts or {}
  local choices = {}
  local format_item = opts.format_item or tostring
  for i, item in pairs(items) do
    table.insert(choices, string.format("%d: %s", i, format_item(item)))
  end
  local callback = function(choice)
    if choice < 1 or choice > #items then
      on_choice(nil, nil)
    else
      on_choice(items[choice], choice)
    end
  end
  local co = inputlist(choices, opts)
  co()(callback)
end

local function test()
  select({ "tabs", "spaces", "core", "hoge", "huga", "hoge" }, {
    prompt = "❯ ",
    format_item = function(item)
      return "I'd like to choose " .. item
    end,
  }, function(choice)
    -- return "You chose: " .. choice
    print("You chose " .. choice)
  end)
end

cmd("WindowNew", test)
bmap(0, "n", "<space><space>t", test, "windownew")
