local new = function(id, key, text)
  return {
    key = key,
    id = id,
    text = text,
  }
end

return { new = new }
