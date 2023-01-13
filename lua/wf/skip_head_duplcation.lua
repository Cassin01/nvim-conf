local same_len = function(lines)
  if #lines == 0 then
    return 0
  end
  local same_len = 0
  while true do
    local head = lines[1]:sub(1 + same_len, 1 + same_len)
    if head == "" then
      return same_len
    end
    for l = 2, #lines do
      local head_ = lines[l]:sub(1 + same_len, 1 + same_len)
      if head ~= head_ or head_ == "" then
        return same_len
      end
    end
    same_len = same_len + 1
  end
end

-- local function retrieve(lines, len)
--   local new_lines = {}
--   for _, line in ipairs(lines) do
--     local line_ = " " .. line:sub(2 + len)
--     table.insert(new_lines, line_)
--   end
--   return new_lines
-- end

-- local function shorcut(texts, prefix_size)
--     local len = same_len(texts, prefix_size)
--     return retrieve(texts, len)
-- end

local function same_text(lines)
  if #lines <= 1 then
    return ""
  else
    print(same_len(lines))
    return lines[1]:sub(1, same_len(lines))
  end
end

return same_text
