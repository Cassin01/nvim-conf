local gen_obj = require'fzw.common'.gen_obj
local static = require'fzw.static'
local full_name = static.full_name
local _g = static._g
local input_win_row_offset = static.input_win_row_offset
local bmap = static.bmap
local au = require'fzw.util'.au
local _update_output_obj = require'fzw.output'._update_output_obj
local cell = require'cell'

local function input_obj_gen(output_obj, choices, co, prompt)
  local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)
  local _lines = vim.o.lines
  local buf, win = gen_obj(_row_offset)
  -- vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")
  --
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

  vim.fn.sign_define(full_name .. "prompt", {
    text = prompt,
    texthl = "Error",
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
  au(_g, "TextChangedI", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local _res = vim.fn.matchfuzzypos(choices, lines[1])
    local matches = _res[1]
    local poss = _res[2]
    for _, match in ipairs(vim.fn.getmatches(output_obj.win)) do
      if match.group == "IncSearch" then
        vim.fn.matchdelete(match.id, output_obj.win)
      end
    end
    for i, _ in ipairs(matches) do
      for _, v in ipairs(poss[i]) do
          vim.fn.matchaddpos("IncSearch", { { i, v + 1 } }, 0, -1, { window = output_obj["win"] })
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
        local c = string.match(matches[1], "^%d+")
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

  local to_fuzzy = function()
  end
  local to_witch = function()
    -- オブジェクトを作成
       local choices_obj = {}
    for i, val in ipairs(choices) do
      choices_obj[i] = cell.new(i, tostring(i), val)
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local matches_obj = vim.fn.matchfuzzy(choices_obj, lines[1], {key = 'text'})
    -- local matches = vim.fn.matchfuzzy(choices, lines[1])
    for lnum, match in pairs(matches_obj) do
      -- local c = string.match(match, "^%d+")
      -- print(vim.inspect(match))
      local c = match.key
      vim.fn.sign_define(full_name .. "prompt" .. c, {
        text = c,
        texthl = "Error",
      })
      vim.fn.sign_place(0, _g, full_name .. "prompt" .. c, output_obj.buf, { lnum = lnum, priority = 10 })
    end

    vim.cmd("redraw!")

    local getchar = function()
      while true do
        if vim.fn.getchar(1) then
          local c = vim.fn.getchar()
          return c
        end
      end
    end
    local c = getchar()
    if c ~= nil then
      local callback = co()
      if callback ~= nil then
        print(vim.fn.nr2char(c))
        -- local num = tonumber(vim.fn.nr2char(c))
        -- if 1 <= num and num <= #choices then
        --   callback(num)
        -- else
        --   print(num)
        -- end
        del()
      end
    end
  end
  local update_selector = function(direction)
    return function()
      if direction == "up" then
        do
          -- TODO
        end
      elseif direction == "down" then
        do
          -- TODO
        end
      end
    end
  end
  bmap(buf, { "i", "n" }, "<c-c>", del, "quit")
  bmap(buf, { "n" }, "<esc>", del, "quit")
  bmap(buf, { "i", "n" }, "<c-m>", on_choice, "choice")
  bmap(buf, { "i", "n" }, "<c-w>", to_witch, "start witch key mode")
  bmap(buf, { "i", "n" }, "<c-f>", to_fuzzy, "start fuzzy finder mode")
  bmap(buf, { "i" }, "<c-k>", update_selector("up"), "up selector")
  bmap(buf, { "i" }, "<c-j>", update_selector("down"), "down selector")
  bmap(buf, { "n" }, "k", update_selector("up"), "up selector")
  bmap(buf, { "n" }, "j", update_selector("down"), "down selector")

  return { buf = buf, win = win }, co
end

return { input_obj_gen = input_obj_gen }
