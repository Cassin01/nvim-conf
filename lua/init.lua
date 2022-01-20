Keys = {}

function Keys:get_n() return self.n end

function Keys:get_i() return self.i end

function Keys:get_v() return self.v end

function Keys:set_n(key, description)
   self.n[key] = description
end

function Keys:set_i(key, description)
   self.i[key] = description
end

function Keys:set_v(key, description)
   self.v[key] = description
end

function Keys:set_map_n(key, command, description)
   vim.api.nvim_set_keymap('n', key, command, {noremap=true, silent=true})
   self:set_n(key, description)
end

function Keys:set_map_i(key, command, description)
   vim.api.nvim_set_keymap('i', key, command, {noremap=true, silent=true})
   self:set_i(key, description)
end

function Keys:set_map_v(key, command, description)
   vim.api.nvim_set_keymap('v', key, command, {noremap=true, silent=true})
   self:set_v(key, description)
end

function Keys:get_info()
   lines = {}
   for k, v in pairs(self.i) do
      table.insert(lines, k.." "..v)
   end
   return lines
end

function Keys:show_i()
   for k, v in pairs(self.i) do
      print(v)
   end
end

function Keys.new()
   local obj = {
      n = {},
      i = {},
      v = {}
   }
   return setmetatable(obj, {__index = Keys})
end
