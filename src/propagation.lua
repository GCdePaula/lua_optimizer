local Cell = require "latticeCell"

local processExp = {}
local function dispatchProcessExp(exp, cell)
	return processExp[exp.tag](exp, cell)
end

local processStat = {}
local function dispatchProcessStat(node, workList)
	return processStat[node.tag](node, workList)
end

function processStat.Assign(node, workList)
	local vars, exps = node.vars, node.exps
	local outEdge, inEdges, outCell = node.outEdge, node.inEdges, node.outCell

	local cell = Cell:InitWithInEdges(inEdges)

	local expElements = {}
	for _,exp in ipairs(exps) do
		local element = dispatchProcessExp(exp, cell)
		table.insert(expElements, element)
	end

	for _,var in ipairs(vars) do
		if var.tag == 'Var' then
			cell:setElementToVar(var.name)
		else
			error("Assign to indexation!")
		end
	end

	local equal = cell:compareWithCell(outCell)
	if not equal then
		node.outCell = cell
		table.insert(workList, outEdge)
	end
end

function processStat.Assign(node, workList)
	local vars, exps = node.vars, node.exps
	local outEdge, inEdges, outCell = node.outEdge, node.inEdges, node.outCell

	local cell = Cell:InitWithInEdges(inEdges)

	local expElements = {}
	for _,exp in ipairs(exps) do
		local element = dispatchProcessExp(exp, cell)
		table.insert(expElements, element)
	end

	for _,var in ipairs(vars) do
		if var.tag == 'Var' then
			cell:setElementToVar(var.name)
		else
			error("Assign to indexation!")
		end
	end

	local equal = cell:compareWithCell(outCell)
	if not equal then
		node.outCell = cell
		table.insert(workList, outEdge)
	end
end

function processStat.Block()
	error("process block!")
end


local function findFixedPoint(startEdge)
	local workList = {}
	local edge = startEdge

	repeat
		local node = edge:getToNode()
		dispatchProcessStat(node, workList)
		edge = table.remove(workList)
	until edge
end

return {propagate = propagate}
