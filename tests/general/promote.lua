package.path = package.path
  ..";../src/?.lua"
  ..";../src/libs/?.lua"
  ..";../src/libs/?/?.lua"
  ..";../src/libs/?/init.lua"

package.cpath = package.cpath
  .."../src/libs/?.so;"
  .."../src/libs/?/?.so;"

local file_names = {
  "ops",
  "if",
  "globals",
  "while",
  "upval",
  "repeat_until",
  "generic_for",
  "numeric_for",
  "function",
}

local params = {...}
local name_param = params[1]

local function promote_file(name)
  print("Promoting: ", name)
  local path_to_src = "../src/"
  local program = loadfile(path_to_src .. "main.lua")

  local in_path = "general/files/" .. name .. "_in.lua"
  local out_path = "general/files/" .. name .. "_out.lua"

  program(in_path, out_path)
end


if name_param then
  promote_file(name_param)
else
  for _,file_name in ipairs(file_names) do
    promote_file(file_name)
  end
end
