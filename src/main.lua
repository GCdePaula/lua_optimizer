package.path = package.path .. ";./libs/?.lua"
package.cpath = package.path .. ";./libs/?/?.so"

pretty = require "pl.pretty"
local parser = require "parser"
local prepare = require "prepareAst"
local findFixedPoint = require "abstractInterp"


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
	-- pretty.dump(ast)
	local _, startEdge, endNode = prepare(ast)
	-- pretty.dump(startEdge)
	findFixedPoint(startEdge)
	pretty.dump(endNode.inEdges[1]:getFromNode().outCell)
end

