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
		return function(node, cell)
			local tag = node.tag
			if LuaOps.binops[tag] or
				LuaOps.cmpops[tag] or
				LuaOps.logbinops[tag] then

				local e1
				local e2
				if tag == '^' or tag == '..' then
					e1 = dispatchProcessExp(node.lhs, cell)
					e2 = dispatchProcessExp(node.rhs, cell)
				else
					e2 = dispatchProcessExp(node.rhs, cell)
					e1 = dispatchProcessExp(node.lhs, cell)
				end

				local newElement = Ops[tag](e1, e2)
				node.element = newElement
				return newElement

			elseif LuaOps.unops[tag] or LuaOps.unops[tag] then
				local e = dispatchProcessExp(node.exp, cell)
				local newElement = Ops[tag](e)
				node.element = newElement
				return newElement

			else
				error("Tag for prepare exp not implemented " .. tag)
			end
		end
	end
})

function processExp.Nil(node, _)
	local newElement = Element:InitWithNil()
	node.element = newElement
	return newElement
end

function processExp.StringLiteral(node, _)
	local newElement = Element:InitWithString(node.literal)
	node.element = newElement
	return newElement
end

function processExp.NumberLiteral(node, _)
	local newElement = Element:InitWithNumber(node.literal)
	node.element = newElement
	return newElement
end

function processExp.BoolLiteral(node, _)
	local newElement = Element:InitWithBool(node.literal)
	node.element = newElement
	return newElement
end

function processExp.VarExp(node, cell)
	local var = cell:getVar(node.name)
	local newElement = var:getElement()
	node.element = newElement

	return newElement
end

function processExp.IndexationExp(node, cell)
	dispatchProcessExp(node.exp, cell)
	dispatchProcessExp(node.index, cell)
	local newElement = Element:InitWithBottom()
	node.element = newElement
	return newElement
end

function processExp.FunctionCall(node, cell)
	dispatchProcessExp(node.func, cell)

	for _,v in ipairs(node.args) do
		dispatchProcessExp(v, cell)
	end

	local newElement = Element:InitWithBottom()
	node.element = newElement
	return newElement
end

local processStat = {}
local function dispatchProcessStat(node, workList)
	local changed = node.inCell:updateWithInEdges(node.inEdges)

	if changed or not node.touched then
		node.touched = true
		return processStat[node.tag](node, workList)
	end
end

function processStat.Assign(node, workList)
	local vars, exps = node.vars, node.exps
	local cell = node.inCell:copy()

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
				-- 
			end
		end
	end

	node.outCell = cell
	workList:addEdge(node.outEdge)
end

function processStat.LocalAssign(node, workList)
	local vars, exps = node.vars, node.exps
	local cell = node.inCell:copy()

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

	node.outCell = cell
	workList:addEdge(node.outEdge)
end

function processStat.IfStatement(node, workList)
	local condition = node.condition
	local thenEdge, elseEdge = node.thenEdge, node.elseEdge
	local cell = node.inCell:copy()

	local condElement = dispatchProcessExp(condition, cell)
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

function processStat.While(node, workList)
	local condition = node.condition
	local trueEdge, falseEdge = node.trueEdge, node.falseEdge
	local cell = node.inCell:copy()

	local condElement = dispatchProcessExp(condition, cell)
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

function processStat.Repeat(node, workList)
	local condition = node.condition
	local repeatEdge, continueEdge = node.repeatEdge, node.continueEdge
	local cell = node.inCell:copy()

	local condElement = dispatchProcessExp(condition, cell)

	-- outEdge changed, need to schedule outBranches
	node.outCell = cell

	local isConstant, test = condElement:test()
	if isConstant then
		-- May take only one branch
		if test then
			workList:addEdge(continueEdge)
		else
			workList:addEdge(repeatEdge)
		end
	else
		-- Both branches must be taken
		workList:addEdge(continueEdge)
		workList:addEdge(repeatEdge)
	end
end

function processStat.FunctionCallStat(node, workList)
	local func, args = node.func, node.args
	local cell = node.inCell:copy()

	dispatchProcessExp(func, cell)
	for _,arg in ipairs(args) do
		dispatchProcessExp(arg, cell)
	end

	node.outCell = cell
	workList:addEdge(node.outEdge)
end

function processStat.Break(node, workList)
	local outEdge = node.outEdge
	workList:addEdge(outEdge)
end

function processStat.EndNode() end

function processStat.Block()
	error("process block!")
end


local function findFixedPoint(startEdge)
	local workList = newWorkList()
	local edge = startEdge
	startEdge:setExecutable()

	repeat
		local node = edge:getToNode()
		print(node.tag)
		dispatchProcessStat(node, workList)
		edge = workList:pop()
	until not edge
end

return findFixedPoint
