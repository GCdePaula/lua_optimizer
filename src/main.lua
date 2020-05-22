package.path = package.path .. ";./libs/?.lua"
package.cpath = package.path .. ";./libs/?/?.so"

pretty = require "pl.pretty"
local parser = require "parser"
local prepare = require "prepareAst"
local findFixedPoint = require "abstractInterp"
local propagate = require "propagation"
local toLua = require "toLua"

local params = {...}
local filepath = params[1]

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
	local _, startEdge  = prepare(ast)
	findFixedPoint(startEdge)
	propagate(startEdge)
	local program = toLua(ast)
	print(program)
	--]]
end
