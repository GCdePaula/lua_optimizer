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
}

local params = {...}
local name_param = params[1]

local function readFile(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*all"
	file:close()
	return content
end

local function test_file(name)
  local path_to_src = "../src/"
  local program = loadfile(path_to_src .. "main.lua")

  local in_path = "general/files/" .. name .. "_in.lua"
  local out_path = "general/files/out.lua"
  local expected_path = "general/files/" .. name .. "_out.lua"

  program(in_path, out_path)

  local got = readFile(out_path)
  local expected = readFile(expected_path)

  local result = got == expected
  print("Test general file " .. name ..":\t", result)

  return result
end


if name_param then
  test_file(name_param)
else
  for _,file_name in ipairs(file_names) do
    local result = test_file(file_name)
    if not result then return end
  end
end
