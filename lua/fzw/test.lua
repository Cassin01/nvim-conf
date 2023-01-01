-- local function is_array(t)
--   local i = 0
--   for _ in pairs(t) do
--       i = i + 1
--       if t[i] == nil then return false end
--   end
--   return true
-- end

-- local d = {}
-- d["hoge"] = "huga"
-- d["hog1"] = "huga"
-- d["hog2"] = "huga"

-- local l = {"a", 2, 3, 4, 5}
-- local n = {}
-- for k, v in pairs(d) do
--   -- table.insert(n, k, v)
--   n[k] = v
-- end

-- print(is_array(n))
-- s = "<hoge"
-- if string.match(s, "^<Plug>") then
--   print(true)
-- end
-- print(string.match(" <ab>", "^<[%w%-]+>"))
-- for _ = 1, 1 do
--   print("a")
-- end

-- local sub = string.sub(match.key, 1 + #witch_line, prefix_size + #witch_line)

-- local function array_reverse(x)
--   local n, m = #x, #x/2
--   for i=1, m do
--     x[i], x[n-i+1] = x[n-i+1], x[i]
--   end
--   return x
-- end
-- local ret = array_reverse({"a", "b"})
-- for i, v in ipairs(ret) do
-- print(i, v)
-- end
-- local function replace_nth(str, n, old, new)
--   if n <= #str and str:sub(n, n) == old then
--     return str:sub(1, n - 1) .. new ..str:sub(n + 1)
--   end
--   return str
-- end

-- local ret = replace_nth("ac", 3, "c", "d")

-- print(ret)
local obj = {
  c = function()
    print("c")
  end,
}

local c_ = obj.c
obj.c = function()
  print("d")
  c_()
end
obj.c()
