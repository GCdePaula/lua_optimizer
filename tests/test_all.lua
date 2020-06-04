require 'paths'
require 'busted.runner'()

local function readFile(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*all"
	file:close()
	return content
end

describe("self optimization", function()
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
	local src_strings = {}

	setup(function()
		local program = loadfile(path_to_src .. "main.lua")

		for _,name in ipairs(paths) do
			local input = path_to_src .. name
			local output = target_dir .. name

			program(input, output)

			local output_str = readFile(output)
			src_strings[name] = output_str
		end

	end)

	it("test self optimized optimizer", function()
		local program = loadfile(target_dir .. "main.lua")

		for _,name in ipairs(paths) do
			local input = path_to_src .. name

			program(input, 'temp.out')

			local output = readFile('temp.out')
			assert.equal(src_strings[name], output)
		end
	end)

end)

