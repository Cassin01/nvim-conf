local M = {}

local function _find(str_, pattern_, diff)
    local s_ = str_:find(pattern_)
    if s_ ~= nil then
        local next_ = str_:sub(s_ + 1, #str_)
        if next_ ~= nil then
            local res = _find(next_, pattern_, s_ + diff)
            if res ~= nil then
                table.insert(res, s_ + diff)
            else
                return { s_ + diff }
            end
            return res
        else
            return {}
        end
    end
end

function M.gfind(str, pattern)
    return _find(str, pattern, 0)
end

function M.gfindc(str, c)
    local ret = {}
    for i = 1, #str do
        if str:sub(i, i) == c then
            table.insert(ret, i)
        end
    end
    return ret
end

function M.findc(str, c)
    for i = 1, #str do
        if str:sub(i, i) == c then
            return i
        end
    end
end

function M.nmaps(prefix, group, tbl)
  local sign = "[" .. group .. "]"
  -- table.insert(_G.__key_prefixes["n"], prefix, sign)
  -- table.insert(_G["__kaza"]["prefix"], prefix, sign)
  _G["__kaza"]["prefix"][prefix] = sign
  local set = function(key, cmd, desc, opt)
    local _opt = opt or {}
    _opt["desc"] = sign .. " " .. desc
    _opt["noremap"] = true
    vim.keymap.set("n", prefix .. key, cmd, _opt)
  end
  for _, v in ipairs(tbl)  do
    set(unpack(v))
  end
end

return M
