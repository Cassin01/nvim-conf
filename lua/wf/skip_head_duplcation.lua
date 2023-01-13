local same_len = function(lines, prefix_size)
  if #lines == 0 then
    return 0
  end
  local same_len = 0
  while true do
    local head = lines[1]:sub(2 + same_len, prefix_size + 1):sub(1, 1)
    if head == "" then
      return same_len
    end
    for l = 2, #lines do
      local head_ = lines[l]:sub(2 + same_len, prefix_size + 1):sub(1, 1)
      if head ~= head_ then
        return same_len
      end
    end
    same_len = same_len + 1
  end
end

local function retrieve(lines, len)
  local new_lines = {}
  for _, line in ipairs(lines) do
    local line_ = " " .. line:sub(2 + len)
    table.insert(new_lines, line_)
  end
  return new_lines
end

local function shorcut(texts, prefix_size)
    local len = same_len(texts, prefix_size)
    return retrieve(texts, len)
end

return shorcut
