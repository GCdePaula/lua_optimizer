package.path = package.path
  ..";./self_opt/?.lua"
  ..";./self_opt/libs/?.lua"
  ..";./self_opt/libs/?/?.lua"
  ..";./self_opt/libs/?/init.lua"

package.cpath = package.cpath
  .."./self_opt/libs/?.so;"
  .."./self_opt/libs/?/?.so;"



local function readFile(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*all"
	file:close()
	return content
end

	local path_to_src = "../src/"
	local target_dir = "./self_opt/"
	local paths = {
		"abstractInterp.lua",
		"edge.lua",
		"env.lua",
		"func.lua",
		"luaOps.lua",
		"main.lua",
		"parser.lua",
		"prepareAst.lua",
		"propagation.lua",
		"toLua.lua",
		"lattice/cell.lua",
		"lattice/element.lua",
		"lattice/ops.lua",
		"lattice/var.lua",
	}

	local program = loadfile(target_dir .. "main.lua")

	for _,name in ipairs(paths) do
		local input = path_to_src .. name
		local output = "temp.out"
		program(input, output)

		local output_str = readFile(output)
		local expected = readFile(target_dir .. name)
    print("Test self_opt file " .. name ..":\t", output_str == expected)
	end

