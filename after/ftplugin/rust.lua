local function u_cmd(name, f, _opt)
  local opt = _opt or {}
  opt["force"] = true
  vim.api.nvim_create_user_command(name, f, opt)
end

local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

local function check(crates)
  if not file_exists(vim.fn.expand('%:p')) then
    print("File not found")
    return
  end
  local ret = {}
  for k, v in pairs(crates) do
    local flag = false
    local lines = io.lines(vim.fn.expand('%:p'))
    for line in lines do
      if string.match(line, v) ~= nil then
        flag = true
      end
    end
    if flag then
      table.insert(ret, k)
    end
  end
  return ret
end

u_cmd("RustAddDependencies", function()
  -- local file_path = vim.fn.expand('%:p')

  local toml_path = vim.fn.expand('%:p:h') .. "/../Cargo.toml"
  if not file_exists(toml_path) then
    print("Cargo.toml not found")
    return
  end

  local crates = check({
    itertools = "use itertools.*$",
    ['ac-library-rs'] = "^.+ac_library.*"
  })
  for _, v in pairs(crates) do
    if v == nil then break end
    print("Adding " .. v)
    local cmd = string.format("(cd %s; cargo add %s)", vim.fn.expand('%:p:h'), v)
    vim.fn.execute("!" .. cmd)
  end
end)
u_cmd("RustEdit", function()
  vim.cmd(":vi ~/.config/nvim/after/ftplugin/rust.lua")
end)
