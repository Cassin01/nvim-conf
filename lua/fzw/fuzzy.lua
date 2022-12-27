local gen_obj = require("fzw.common").gen_obj
local static = require("fzw.static")
local full_name = static.full_name
local sign_group_prompt = static.sign_group_prompt
local sign_group_witch = static.sign_group_witch
local _g = static._g
local input_win_row_offset = static.input_win_row_offset
local bmap = static.bmap
local au = require("fzw.util").au
local _update_output_obj = require("fzw.output")._update_output_obj

local function input_obj_gen(output_obj, choices, callback)
  local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset
  local _lines = vim.o.lines
  local buf, win = gen_obj(_row_offset)

  -- vim.fn.sign_place(0, sign_group_prompt .. "fuzzy", full_name .. "prompt" .. "fuzzy", buf, { lnum = 1, priority = 10 })

  _update_output_obj(output_obj, choices, _lines, _row_offset + input_win_row_offset)
  au(_g, "BufEnter", function()
    local _, _ = pcall(function()
      -- turn off the completion
      require("cmp").setup.buffer({ enabled = false })
    end)
  end, { buffer = buf })
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
  au(_g, "WinEnter", function()
    vim.fn.sign_place(
      0,
      sign_group_prompt .. "fuzzy",
      sign_group_prompt .. "fuzzy",
      buf,
      { lnum = 1, priority = 10 }
    )
  end, { buffer = buf })
  au(_g, "WinLeave", function()
    vim.fn.sign_unplace(sign_group_prompt .. "fuzzy", { buffer = buf })
  end, { buffer = buf })
  local on_choice = function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local matches = vim.fn.matchfuzzy(choices, lines[1])
    if #matches == 1 then
      if callback ~= nil then
        local c = string.match(matches[1], "^%d+")
        if c ~= nil then
          local num = tonumber(c)
          callback(num)
        end
      end
      -- del()
    elseif #matches > 1 then
      -- TODO: select with allow
    else
      print("not matched")
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
  -- bmap(buf, { "i", "n" }, "<c-m>", on_choice, "choice")
  -- bmap(buf, { "i", "n" }, "<c-w>", to_witch, "start witch key mode")
  -- bmap(buf, { "i", "n" }, "<c-f>", to_fuzzy, "start fuzzy finder mode")
  bmap(buf, { "i" }, "<c-k>", update_selector("up"), "up selector")
  bmap(buf, { "i" }, "<c-j>", update_selector("down"), "down selector")
  bmap(buf, { "n" }, "k", update_selector("up"), "up selector")
  bmap(buf, { "n" }, "j", update_selector("down"), "down selector")

  return { buf = buf, win = win }, co
end

return { input_obj_gen = input_obj_gen }
