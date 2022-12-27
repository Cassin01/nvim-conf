local util = require("fzw.util")
local cmd = util.cmd
local au = util.au
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

local function setup()
  vim.api.nvim_set_hl(0, "FzwWitch", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "FzwFuzzy", { fg = "#7ec9d8", bold = true })
end

local function objs_setup(fuzzy_obj, witch_obj, output_obj)
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
  bmap(fuzzy_obj.buf, { "i", "n" }, "<c-w>", to_witch, "start witch key mode")
  bmap(witch_obj.buf, { "i", "n" }, "<c-w>", to_fuzzy, "start witch key mode")

  return { del = del }
end

local sign_place_witch = function(choices, witch_obj, fuzzy_obj, output_obj)
  -- オブジェクトを作成
  local choices_obj = {}
  for i, val in ipairs(choices) do
    choices_obj[i] = cell.new(i, tostring(i), val)
  end

  local _lines = vim.api.nvim_buf_get_lines(fuzzy_obj.buf, 0, -1, true)
  local matches_obj = (function()
    if _lines[1] == "" then
      return choices_obj
    else
      return vim.fn.matchfuzzy(choices_obj, _lines[1], { key = "text" })
    end
  end)()
  local lines = vim.api.nvim_buf_get_lines(witch_obj.buf, 0, -1, true)
  local ids = {}
  local texts = {}
  local cs = {}
  for lnum, match in pairs(matches_obj) do
    if string.find(match.key, "^" .. lines[1]) then
      table.insert(ids, match.id)
      table.insert(texts, match.text)
      local c = string.sub(match.key, 1 + #lines[1], 2 + #lines[1])
      table.insert(cs, lnum, c)
    end
  end
  local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset
  -- _update_output_obj(output_obj, texts, vim.o.lines, _row_offset + input_win_row_offset)
  for lnum, c in pairs(cs) do
    print("hoge" .. c)
    vim.fn.sign_define(sign_group_witch .. c, {
      text = c,
      texthl = "Error",
    })
    vim.fn.sign_place(0, sign_group_witch, sign_group_witch .. c, output_obj.buf, { lnum = lnum, priority = 10 })
  end

  if lines[1] == "" then
    return {}
  else
    return ids
  end
end

local function witch_setup(witch_obj, fuzzy_obj, output_obj, choices, callback, obj_handlers)
  au(_g, "BufEnter", function()
    local _, _ = pcall(function()
      require("cmp").setup.buffer({ enabled = false })
    end)
  end, { buffer = witch_obj.buf })
  au(_g, "WinLeave", function()
    vim.fn.sign_unplace(sign_group_prompt .. "witch", { buffer = witch_obj.buf })
    vim.fn.sign_unplace(sign_group_witch, { buffer = output_obj.buf })
  end, { buffer = witch_obj.buf })
  au(_g, "TextChangedI", function()
    vim.fn.sign_unplace(sign_group_witch, { buffer = output_obj.buf })
    local ids = sign_place_witch(choices, witch_obj, fuzzy_obj, output_obj)
    if #ids == 1 then
      callback(ids[1])
      obj_handlers.del()
    end
  end, { buffer = witch_obj.buf })
  au(_g, "WinEnter", function()
    vim.fn.sign_place(
      0,
      sign_group_prompt .. "witch",
      sign_group_prompt .. "witch",
      witch_obj.buf,
      { lnum = 1, priority = 10 }
    )
    local ids = sign_place_witch(choices, witch_obj, fuzzy_obj, output_obj)
    if #ids == 1 then
      callback(ids[1])
      -- obj_handlers.del()
    end
  end, { buffer = witch_obj.buf })
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

  -- 表示用バッファを作成
  local output_obj = output_obj_gen()

  -- -- 入力用バッファを作成
  local witch_obj = witch.input_obj_gen(output_obj, choices, callback)
  local fuzzy_obj = fuzzy.input_obj_gen(output_obj, choices, callback)

  local obj_handlers = objs_setup(fuzzy_obj, witch_obj, output_obj)
  witch_setup(witch_obj, fuzzy_obj, output_obj, choices, callback, obj_handlers)

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
  for _, item in pairs(items) do
    table.insert(choices, format_item(item))
  end
  local callback = function(choice)
    if choice < 1 or choice > #items then
      on_choice(nil, nil)
    else
      on_choice(items[choice], choice)
    end
  end
  inputlist(choices, callback, opts)
  -- co()(callback)
end

(function()
  setup()
  local function test()
    select(
      { "tabs", "spaces", "core", "hoge", "huga", "hoge", "cole", "ghoe", "falf", "thoe", "oewi", "ooew", "feow" },
      {
        prompt = "❯ ",
        format_item = function(item)
          return "I'd like to choose " .. item
        end,
      },
      function(choice)
        print("You chose " .. choice)
      end
    )
  end

  -- test
  cmd("WindowNew", test)
  bmap(0, "n", "<space>mw", test, "windownew")
end)()
