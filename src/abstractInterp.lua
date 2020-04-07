local Element = require "lattice.element"
local Ops = require "lattice.ops"
-- local Cell = require "lattice.cell"
local LuaOps = require "luaOps"

local function newWorkList()
	local workList = {_edges = {}}

	function workList:addEdge(edge)
		edge:setExecutable()
		table.insert(self._edges, edge)
	end

	function workList:pop()
		return table.remove(self._edges)
	end

	return workList
end

local processExp = {}
local function dispatchProcessExp(exp, cell)
	return processExp[exp.tag](exp, cell)
end

setmetatable(processExp, {__index = function(_)
		return function(node, env)
			local tag = node.tag
			if LuaOps.binops[tag] or
				LuaOps.cmpops[tag] or
				LuaOps.logbinops[tag] then
				local e1 = dispatchProcessExp(node.lhs, env)
				local e2 = dispatchProcessExp(node.rhs, env)
				return Ops[tag](e1, e2)
			elseif LuaOps.unops[tag] or LuaOps.logunops[tag] then
				local e = dispatchProcessExp(node.exp, env)
				return Ops[tag](e)
			else
				error("Tag for prepare exp not implemented " .. tag)
			end
		end
	end
})

function processExp.Nil(_, _)
	return Element:InitWithNil()
end

function processExp.StringLiteral(node, _)
	return Element:InitWithString(node.literal)
end

function processExp.IntLiteral(node, _)
	return Element:InitWithNumber(node.literal)
end

function processExp.FloatLiteral(node, _)
	return Element:InitWithNumber(node.literal)
end

function processExp.BoolLiteral(node, _)
	return Element:InitWithBool(node.literal)
end

function processExp.VarExp(node, cell)
	return cell:getVar(node.name):getElement()
end

local processStat = {}
local function dispatchProcessStat(node, workList)
	return processStat[node.tag](node, workList)
end

function processStat.Assign(node, workList)
	local vars, exps = node.vars, node.exps
	local inEdges, outEdge, inCell, outCell = node.inEdges, node.outEdge, node.inCell, node.outCell

	inCell:updateWithInEdges(inEdges)
	local cell = inCell:copy()

	local expElements = {}
	for _,exp in ipairs(exps) do
		local element = dispatchProcessExp(exp, cell)
		table.insert(expElements, element)
	end

	for k,var in ipairs(vars) do
		local expElement = expElements[k]
		if expElement then
			if var.tag == 'Var' then
				cell:setElementToVar(var.name, expElement)
			else
				error("Assign to indexation!")
			end
		end
	end

	local equal = cell:compareWithCell(outCell)
	if not equal then
		node.outCell = cell
		workList:addEdge(outEdge)
	end
end

function processStat.LocalAssign(node, workList)
	local vars, exps = node.vars, node.exps
	local inEdges, outEdge, inCell, outCell = node.inEdges, node.outEdge, node.inCell, node.outCell

	inCell:updateWithInEdges(inEdges)
	local cell = inCell:copy()

	local expElements = {}
	for _,exp in ipairs(exps) do
		local element = dispatchProcessExp(exp, cell)
		table.insert(expElements, element)
	end

	for k,var in ipairs(vars) do
		cell:addVar(var.name)
		local expElement = expElements[k]
		if expElement then
			cell:setElementToVar(var.name, expElement)
		else
			cell:setElementToVar(var.name, Element:InitWithNil())
		end
	end

	local equal = cell:compareWithCell(outCell)
	if not equal then
		node.outCell = cell
		workList:addEdge(outEdge)
	end
end

function processStat.IfStatement(node, workList)
	local condition = node.condition
	local inEdges, thenEdge, elseEdge = node.inEdges, node.thenEdge, node.elseEdge
	local inCell, outCell = node.inCell, node.outCell

	inCell:updateWithInEdges(inEdges)
	local cell = inCell:copy()

	local condElement = dispatchProcessExp(condition, cell)

	local equal = cell:compareWithCell(outCell)
	if not equal then
		-- outEdge changed, need to schedule outBranches
		node.outCell = cell

		local isConstant, test = condElement:test()
		if isConstant then
			-- May take only one branch
			if test then
				workList:addEdge(thenEdge)
			else
				workList:addEdge(elseEdge)
			end

		else
			-- Both branches must be taken
			workList:addEdge(thenEdge)
			workList:addEdge(elseEdge)
		end
	end
end

function processStat.While(node, workList)
	local condition = node.condition
	local inEdges, trueEdge, falseEdge = node.inEdges, node.trueEdge, node.falseEdge
	local inCell, outCell = node.inCell, node.outCell

	inCell:updateWithInEdges(inEdges)
	local cell = inCell:copy()

	local condElement = dispatchProcessExp(condition, cell)

	local equal = cell:compareWithCell(outCell)
	if not equal then
		-- outEdge changed, need to schedule outBranches
		node.outCell = cell

		local isConstant, test = condElement:test()
		if isConstant then
			-- May take only one branch
			if test then
				workList:addEdge(trueEdge)
			else
				workList:addEdge(falseEdge)
			end

		else
			-- Both branches must be taken
			workList:addEdge(trueEdge)
			workList:addEdge(falseEdge)
		end
	end
end

function processStat.EndNode() end

function processStat.Block()
	error("process block!")
end


local function findFixedPoint(startEdge)
	local workList = newWorkList()
	local edge = startEdge

	repeat
		local node = edge:getToNode()

		-- if not node then pretty.dump(edge:getFromNode()) end


		dispatchProcessStat(node, workList)
		edge = workList:pop()
	until not edge
end

return findFixedPoint
