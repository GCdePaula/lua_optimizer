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


local function processFuncCallExp(node, cell, exp)
	dispatchProcessExp(exp, cell)

	for _,v in ipairs(node.args) do
		dispatchProcessExp(v, cell)
	end

	local newElement = Element:InitWithBottom()
	node.element = newElement
	return newElement
end

function processExp.FunctionCall(node, cell)
	return processFuncCallExp(node, cell, node.func)
end

function processExp.MethodCall(node, cell)
	return processFuncCallExp(node, cell, node.receiver)
end

function processExp.TableConstructor(node, cell)
  local fields = node.fields

  for _,field in ipairs(fields) do
    dispatchProcessExp(field.value, cell)
    if field.tag == 'ExpAssign' then
      dispatchProcessExp(field.exp, cell)
    end
  end

	local newElement = Element:InitWithBottom()
	node.element = newElement
	return newElement
end

function processExp.AnonymousFunction(node, _)
	local newElement = Element:InitWithFunc(node.funcIndex)
	node.element = newElement
	return newElement
end

function processExp.Vararg(node)
	local newElement = Element:InitWithBottom()
	node.element = newElement
	return newElement
end

local processStat = {}
local function dispatchProcessStat(node, workList)
  if node.tag == 'EndNode' then
    return
  end

	local changed = node.inCell:updateWithInEdges(node.inEdges)
	if changed or not node.touched then
		node.touched = true
		return processStat[node.tag](node, workList)
	end
end

local function getExpsElements(exps, cell)
	local multipleReturns = false

	local expElements, nexps = {}, #exps
	for k,exp in ipairs(exps) do
		local element = dispatchProcessExp(exp, cell)
		table.insert(expElements, element)

		-- Breaking compositionality
		if k == nexps then
			local tag = exp.tag
			if tag == 'FunctionCall' or
				tag == 'MethodCall' or
				tag == 'Vararg' then
				multipleReturns = true
			end
		end
	end

	return expElements, multipleReturns
end

function processStat.Assign(node, workList)
	local vars, exps = node.vars, node.exps
	local cell = node.inCell:copy()

	local expElements, multipleReturns = getExpsElements(exps, cell)

	for k,var in ipairs(vars) do
		local expElement = expElements[k]
		if var.tag == 'Var' then
			if expElement then
				cell:setElementToVar(var.name, expElement)
			else
				if multipleReturns then
					cell:setElementToVar(var.name, Element:InitWithBottom())
				else
					cell:setElementToVar(var.name, Element:InitWithNil())
				end
			end
		end
	end

	node.outCell = cell
	workList:addEdge(node.outEdge)
end

function processStat.LocalAssign(node, workList)
	local vars, exps = node.vars, node.exps
	local cell = node.inCell:copy()

	local expElements, multipleReturns = getExpsElements(exps, cell)

	for k,var in ipairs(vars) do
		cell:addVar(var.name)
		local expElement = expElements[k]
		if expElement then
			cell:setElementToVar(var.name, expElement)
		else
			if multipleReturns then
				cell:setElementToVar(var.name, Element:InitWithBottom())
			else
				cell:setElementToVar(var.name, Element:InitWithNil())
			end
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

function processStat.GenericFor(node, workList)
	local vars, exps = node.vars, node.exps
	local loopEdge, continueEdge = node.loopEdge, node.continueEdge
	local cell = node.inCell:copy()

	for _,exp in ipairs(exps) do
		dispatchProcessExp(exp, cell)
	end

	for _,var in ipairs(vars) do
		cell:addVar(var.name)
		cell:setElementToVar(var.name, Element:InitWithBottom())
	end

	node.outCell = cell

	workList:addEdge(loopEdge)
	workList:addEdge(continueEdge)
end

function processStat.NumericFor(node, workList)
	local var, init, limit, step = node.var, node.init, node.limit, node.step
	local loopEdge, continueEdge = node.loopEdge, node.continueEdge
	local cell = node.inCell:copy()

	dispatchProcessExp(init, cell)
	dispatchProcessExp(limit, cell)
	if step then dispatchProcessExp(step, cell) end

	cell:addVar(var.name)
	cell:setElementToVar(var.name, Element:InitWithBottom())

	node.outCell = cell

	workList:addEdge(loopEdge)
	workList:addEdge(continueEdge)
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

local function processFuncCallStat(node, workList, exp)
	local args = node.args
	local cell = node.inCell:copy()

	dispatchProcessExp(exp, cell)
	for _,arg in ipairs(args) do
		dispatchProcessExp(arg, cell)
	end

	node.outCell = cell
	workList:addEdge(node.outEdge)
end

function processStat.FunctionCallStat(node, workList)
	processFuncCallStat(node, workList, node.func)
end

function processStat.MethodCallStat(node, workList)
	processFuncCallStat(node, workList, node.receiver)
end

function processStat.Break(node, workList)
	local outEdge = node.outEdge
	workList:addEdge(outEdge)
end

function processStat.Return(node)
	local cell = node.inCell:copy()
	local exps = node.exps
	if exps then
		for _,exp in ipairs(exps) do
			dispatchProcessExp(exp, cell)
		end
	end
	node.outCell = cell
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
		dispatchProcessStat(node, workList)
		edge = workList:pop()
	until not edge
end

return function(startEdge, closureEdges)
	findFixedPoint(startEdge)

	for _,edge in ipairs(closureEdges) do
		local cell = edge:getToNode().inCell
		if cell then
			-- Set all parameters to bottom
			cell:bottomAllVars()
			findFixedPoint(edge)
		end
	end
end
