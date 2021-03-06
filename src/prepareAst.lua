local LuaOps = require "luaOps"
local Edge = require "edge"
local Env = require "env"

local function concatArrays(a, b)
	for _, v in ipairs(b) do
    table.insert(a, v)
	end
	return a
end

local function renameVar(var, newName)
	if newName then
		var.name = newName
	else
		-- Change to global var
		var.tag = 'Indexation'
		var.index = {tag = 'StringLiteral', literal = var.name}
		var.exp = {tag = 'VarExp', name = '_ENV'}
	end
end

local function renameVarExp(varExp, newName)
	if newName then
		varExp.name = newName
	else
		-- Change to global var
		varExp.tag = 'IndexationExp'
		varExp.index = {tag = 'StringLiteral', literal = varExp.name}
		varExp.exp = {tag = 'VarExp', name = '_ENV'}
	end
end



local function setToEdges(edges, target)
	for _,edge in ipairs(edges) do
		edge:setToNode(target)
	end
end

local function newControlTable()
	local control = {_loops = {}}

	function control:startLoop()
		table.insert(self._loops, {})
	end

	function control:pushBreakEdge(edge)
		local loops = self._loops
		local lastLoop = loops[#loops]
		table.insert(lastLoop, edge)
	end

	function control:endLoop()
		return table.remove(self._loops)
	end

	return control
end

local prepareExp = {}
local prepareStatement = {}

local function dispatchPrepareStat(node, inEdges, env, control)
	return prepareStatement[node.tag](node, inEdges, env, control)
end

local function dispatchPrepareExp(node, env)
	return prepareExp[node.tag](node, env)
end

-- returns outEdges, and if continues
local function prepareStatementList(list, inEdges, env, control)
	local head = list.head
	if not head then
		return inEdges
	end

	local outEdges = dispatchPrepareStat(head, inEdges, env, control)
	return prepareStatementList(list.tail, outEdges, env, control)
end


setmetatable(prepareExp, {__index = function(_)
		return function(node, env)
			-- This should cover the generic cases.
			local tag = node.tag
			if LuaOps.binops[tag] or
				LuaOps.cmpops[tag] or
				LuaOps.logbinops[tag] then
				dispatchPrepareExp(node.lhs, env)
				dispatchPrepareExp(node.rhs, env)
			elseif LuaOps.unops[tag] then
				dispatchPrepareExp(node.exp, env)
			elseif tag == 'StringLiteral' or
				tag == 'NumberLiteral' or
				tag == 'BoolLiteral' or
				tag == 'Nil' then
					-- Do nothing
					;
			else
				error("Tag for prepare exp not implemented " .. tag)
			end
		end
	end
})

function prepareExp.IndexationExp(node, env)
	dispatchPrepareExp(node.index, env)
	dispatchPrepareExp(node.exp, env)
end

function prepareExp.VarExp(node, env)
	local newName = env:getVar(node.name)
	renameVarExp(node, newName)
end


local function prepareFuncCallExp(node, env, exp)
	dispatchPrepareExp(exp, env)

	for _,v in ipairs(node.args) do
		dispatchPrepareExp(v, env)
	end
end

function prepareExp.FunctionCall(node, env)
	return prepareFuncCallExp(node, env, node.func)
end

function prepareExp.MethodCall(node, env)
	return prepareFuncCallExp(node, env, node.receiver)
end

function prepareExp.TableConstructor(node, env)
	local fields = node.fields

	for _,field in ipairs(fields) do
		dispatchPrepareExp(field.value, env)
		if field.tag == 'ExpAssign' then
			dispatchPrepareExp(field.exp, env)
		end
  end
end

function prepareExp.AnonymousFunction(node, env)
	local startEdge = Edge:InitStartEdge()
	local newEnv = Env:Init(env, startEdge, node)
	local control = newControlTable()

	local params = node.params
	for k, param in ipairs(params) do
		if param.tag == 'LocalVar' then
			local newName = newEnv:newLocalVar(param.name)
			params[k].name = newName
		else
			env:addVararg()
		end
	end

	node.funcIndex = newEnv:getCurrentFunc():getIndex()

	local endEdges = prepareStatementList(node.body.statements, {startEdge}, newEnv, control)
	local endNode = {tag = 'EndNode', inEdges=endEdges}
	setToEdges(endEdges, endNode)
end

function prepareExp.Vararg() end

function prepareStatement.Block(node, inEdges, env, control)
	local oldScope = env:startBlock()
	local outEdges = prepareStatementList(node.statements, inEdges, env, control)
	env:endBlock(oldScope)
	return outEdges
end

function prepareStatement.GenericFor(node, inEdges, env, control)
	local vars, exps, body = node.vars, node.exps, node.body

	local oldScope = env:startBlock()
	control:startLoop()

	for _,exp in ipairs(exps) do
		dispatchPrepareExp(exp, env)
	end

	node.inCell = env:newLatticeCell()

	for _,var in ipairs(vars) do
		local newName = env:newLocalVar(var.name)
		renameVar(var, newName)
	end

	node.outCell = env:newLatticeCell()

	-- Create outEdges
	local loopEdge, continueEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.loopEdge = loopEdge
	node.continueEdge = continueEdge

	-- Set edges
	local bodyOutEdges = prepareStatementList(body.statements, {loopEdge}, env, control)
	concatArrays(inEdges, bodyOutEdges)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	local breakEdges = control:endLoop()
	table.insert(breakEdges, continueEdge)

	env:endBlock(oldScope)
	return breakEdges
end

function prepareStatement.NumericFor(node, inEdges, env, control)
	local var, init, limit, step, body = node.var, node.init, node.limit, node.step, node.body

	local oldScope = env:startBlock()
	control:startLoop()

	dispatchPrepareExp(init, env)
	dispatchPrepareExp(limit, env)
	if step then dispatchPrepareExp(limit, env) end

	node.inCell = env:newLatticeCell()

	local newName = env:newLocalVar(var.name)
	renameVar(var, newName)

	node.outCell = env:newLatticeCell()

	-- Create outEdges
	local loopEdge, continueEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.loopEdge = loopEdge
	node.continueEdge = continueEdge

	-- Set edges
	local bodyOutEdges = prepareStatementList(body.statements, {loopEdge}, env, control)
	concatArrays(inEdges, bodyOutEdges)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	local breakEdges = control:endLoop()
	table.insert(breakEdges, continueEdge)

	env:endBlock(oldScope)
	return breakEdges
end

function prepareStatement.While(node, inEdges, env, control)
	local condition, body = node.condition, node.body

	control:startLoop()

	-- Set latticeCell
	dispatchPrepareExp(condition, env)
	node.inCell = env:newLatticeCell()
	node.outCell = env:newLatticeCell()

	-- Create outEdges
	local trueEdge, falseEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.trueEdge = trueEdge
	node.falseEdge = falseEdge

	-- Set edges
	local bodyOutEdges = dispatchPrepareStat(body, {trueEdge}, env, control)
	concatArrays(inEdges, bodyOutEdges)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	local breakEdges = control:endLoop()
	table.insert(breakEdges, falseEdge)

	return breakEdges
end

function prepareStatement.Repeat(node, inEdges, env, control)
	local condition, body = node.condition, node.body

	control:startLoop()

	-- Set latticeCell
	dispatchPrepareExp(condition, env)
	node.inCell = env:newLatticeCell()
	node.outCell = env:newLatticeCell()

	-- Create outEdges
	local repeatEdge, continueEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.repeatEdge = repeatEdge
	node.continueEdge = continueEdge

	-- Set edges
	table.insert(inEdges, repeatEdge)
	local bodyOutEdges = dispatchPrepareStat(body, inEdges, env, control)
	setToEdges(bodyOutEdges, node)
	node.inEdges = bodyOutEdges

	local breakEdges = control:endLoop()
	table.insert(breakEdges, continueEdge)

	return breakEdges
end

function prepareStatement.IfStatement(node, inEdges, env, control)
	local condition, thenBody, elseBody = node.condition, node.thenBody, node.elseBody

	-- Set inEdges
	setToEdges(inEdges, node)
	node.inEdges = inEdges


	-- Set latticeCell
	dispatchPrepareExp(condition, env)
	node.inCell = env:newLatticeCell()
	node.outCell = env:newLatticeCell()

	-- Create and set condition out edges
	local thenEdge, elseEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.thenEdge, node.elseEdge = thenEdge, elseEdge

	-- Then outEdges
	local outEdges = dispatchPrepareStat(thenBody, {thenEdge}, env, control)

	-- Check if there's an else
	if elseBody then
		-- Else outEdges
		local elseOutEdges = dispatchPrepareStat(elseBody, {elseEdge}, env, control)
		concatArrays(outEdges, elseOutEdges)
	else
		-- If there's no else, else edge points to "continuation".
		table.insert(outEdges, elseEdge)
	end

	return outEdges
end

function prepareStatement.LocalAssign(node, inEdges, env)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	local outEdge = Edge:InitWithFromNode(node)
	node.outEdge = outEdge

	for _,exp in ipairs(node.exps) do
		dispatchPrepareExp(exp, env)
	end

	node.inCell = env:newLatticeCell()

	for _,var in ipairs(node.vars) do
		local newName = env:newLocalVar(var.name)
		renameVar(var, newName)
	end

	node.outCell = env:newLatticeCell()

	return {outEdge}
end

function prepareStatement.Assign(node, inEdges, env)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	local outEdge = Edge:InitWithFromNode(node)
	node.outEdge = outEdge

	-- Add vars to env
	for _,var in ipairs(node.vars) do
		if var.tag == 'Var' then
			local newName = env:getVar(var.name)
			renameVar(var, newName)
		else
			-- indexation
			local index = var.index
			local exp = var.exp
			dispatchPrepareExp(index, env)
			dispatchPrepareExp(exp, env)
		end
	end

	for _,exp in ipairs(node.exps) do
		dispatchPrepareExp(exp, env)
	end
	--

	node.inCell = env:newLatticeCell()
	node.outCell = env:newLatticeCell()

	return {outEdge}
end

local function prepareFuncStat(node, inEdges, env, exp)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	dispatchPrepareExp(exp, env)

	for _,arg in ipairs(node.args) do
		dispatchPrepareExp(arg, env)
	end

	node.inCell = env:newLatticeCell()
	node.outCell = env:newLatticeCell()

	local outEdge = Edge:InitWithFromNode(node)
	node.outEdge = outEdge

	return {outEdge}
end

function prepareStatement.FunctionCallStat(node, inEdges, env)
	return prepareFuncStat(node, inEdges, env, node.func)
end

function prepareStatement.MethodCallStat(node, inEdges, env)
	return prepareFuncStat(node, inEdges, env, node.receiver)
end


function prepareStatement.Break(node, inEdges, env, control)
	setToEdges(inEdges, node)
	node.inEdges = inEdges
	node.inCell = env:newLatticeCell()

	local outEdge = Edge:InitWithFromNode(node)
	node.outEdge = outEdge
	control:pushBreakEdge(outEdge)

	return {}
end


function prepareStatement.Return(node, inEdges, env)
	setToEdges(inEdges, node)
	node.inEdges = inEdges
	node.inCell = env:newLatticeCell()

	local exps = node.exps

	if exps then
		for _,exp in ipairs(exps) do
			dispatchPrepareExp(exp, env)
		end
	end

	node.outEdge = false

	return {}
end

function prepareStatement.Nop(_, inEdges)
	return inEdges
end

return function(ast)
	-- Prepare Chunk
	local env = Env:Init()
	local control = newControlTable()
	local startEdge = Edge:InitStartEdge()
	local endEdges = prepareStatementList(ast.statements, {startEdge}, env, control)
	local endNode = {tag = 'EndNode', inEdges=endEdges}
	setToEdges(endEdges, endNode)

	-- Get all closure's start edges.
	local funcs = env:getFuncs()
	local funcsEdges = {}
	for _,func in ipairs(funcs) do
		table.insert(funcsEdges, func:getStartEdge())
	end

	return startEdge, funcsEdges
end
