package.path = package.path
  ..";../src/?.lua"
  ..";../src/libs/?.lua"
  ..";../src/libs/?/?.lua"
  ..";../src/libs/?/init.lua"

package.cpath = package.cpath
  .."../src/libs/?.so;"
  .."../src/libs/?/?.so;"

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
local program = loadfile(path_to_src .. "main.lua")

for _,name in ipairs(paths) do
	local input = path_to_src .. name
	local output = target_dir .. name

	program(input, output)
end

