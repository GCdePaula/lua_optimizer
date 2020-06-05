package.path = package.path .. ";./libs/?.lua"
package.cpath = "./libs/?/?.so;" .. package.cpath

pretty = require "pl.pretty"
local parser = require "parser"
local prepare = require "prepareAst"
local findFixedPoint = require "abstractInterp"
local propagate = require "propagation"
local toLua = require "toLua"

local params = {...}
local filepath = params[1]
local target = params[2]

local function readFile(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*all"
	file:close()
	return content
end

local content = readFile(filepath)

if content then
	local ast = parser.parse(content)
	-- local program = toLua(ast)
	-- print(program)
	-- pretty.dump(ast)
  ---[[
	local startEdge, closures  = prepare(ast)
	-- local program = toLua(ast)
	-- print(program)

	findFixedPoint(startEdge, closures)
	propagate(startEdge, closures)
	local program = toLua(ast)
	print(program)
  --]]

	if target then
		local file = io.open(target, "w+")
		file:write(program)
		file:close()
	else
		return program
	end
else
	print("failed to open content")
	return false
end
