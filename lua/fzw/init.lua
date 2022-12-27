local util = require("fzw.util")
local cmd = util.cmd
local input_obj_gen = require("fzw.fuzzy").input_obj_gen
local output_obj_gen = require("fzw.output").output_obj_gen

-- core
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
  select({ "tabs", "spaces", "core", "hoge", "huga", "hoge", "cole", "ghoe", "falf", "thoe", "oewi", "ooew", "feow" },
    {
      prompt = "❯ ",
      format_item = function(item)
        return "I'd like to choose " .. item
      end,
    }, function(choice)
    -- return "You chose: " .. choice
    print("You chose " .. choice)
  end)
end

-- test
(function()
  -- user options
  local plug_name = "fz_witch"

  -- util
  local function bmap(buf, mode, key, f, desc)
    util.bmap(buf, mode, key, f, "[" .. plug_name .. "] " .. desc)
  end

  cmd("WindowNew", test)
  bmap(0, "n", "<space>mw", test, "windownew")
end)()
