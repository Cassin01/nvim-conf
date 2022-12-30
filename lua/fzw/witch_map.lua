local plug_name = require("fzw.static").plug_name
-- local bmap = require("fzw.static").bmap

local function ctrl(c)
  return "<C-" .. c .. ">"
end

local function ctrl_shift(c)
  return "<C-S-" .. c .. ">"
end

local function meta(c)
  return "<M-" .. c .. ">"
end

local function alt(c)
  return "<A-" .. c .. ">"
end

local function map(black_dict, buf)
  local function bmap(key, send, desc)
    vim.api.nvim_buf_set_keymap(buf, "i", key, "", {
      callback = function()
        return send
      end,
      nowait = true,
      noremap = true,
      silent = true,
      expr = true,
      desc = "[" .. plug_name .. "]" .. desc,
    })
  end

  for i = 1, 26 do
    local c = string.char(i + 64)
    if not black_dict[ctrl(c)] then
      bmap(ctrl(c), ctrl(c), "send key")
    end
    if not black_dict[ctrl_shift(c)] then
      bmap(ctrl_shift(c), ctrl_shift(c), "send key")
    end
    if not black_dict[meta(c)] then
      bmap(meta(c), meta(c), "send key")
    end
    if not black_dict[alt(c)] then
      bmap(alt(c), meta(c), "send key")
    end
  end
end

local function setup(buf, black_list)
  local black_dict = {
    ["<C-I>"] = true,
    ["<C-H>"] = true,
    ["<C-M>"] = true,
  }
  for _, name in ipairs(black_list) do
    black_dict[name:upper()] = true
  end
  map(black_dict, buf)
  return black_dict
end

return { setup = setup }
