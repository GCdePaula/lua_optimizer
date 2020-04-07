local LuaOps = require "luaOps"
local Edge = require "edge"
local Env = require "env"

local function concatArrays(a, b)
	for _, v in ipairs(b) do
    table.insert(a, v)
	end
	return a
end



local prepareExp = {}
local function dispatchPrepareExp(node, env)
	return prepareExp[node.tag](node, env)
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
				tag == 'IntLiteral' or
				tag == 'FloatLiteral' or
				tag == 'BoolLiteral' or
				tag == 'Nil' then
				-- Do nothing
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
	env:addVar(node.name)
end



local prepareStatement = {}

local function dispatchPrepareStat(node, inEdges, env)
	return prepareStatement[node.tag](node, inEdges, env)
end

local function setToEdges(edges, target)
	for _,edge in ipairs(edges) do
		edge:setToNode(target)
	end
end

-- returns outEdges, and if continues
local function prepareStatementList(list, inEdges, env)
	if list.tag == "EmptyList" then
		return inEdges
	end

	local head = list.head
	local tail = list.tail
	local outEdges = dispatchPrepareStat(head, inEdges, env)

	return prepareStatementList(tail, outEdges, env)
end

prepareStatement["Block"] = function(node, inEdges, env)
	local oldScope = env:startBlock()
	local outEdges = prepareStatementList(node.statements, inEdges, env)
	env:endBlock(oldScope)
	return outEdges
end

function prepareStatement.While(node, inEdges, env)
	local condition, body = node.condition, node.body

	-- Set inEdges
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	-- Set latticeCell
	dispatchPrepareExp(condition, env)
	node.inCell = env:newLatticeCell()
	node.outCell = env:newLatticeCell()

	-- Create outEdges
	local trueEdge, falseEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.trueEdge = trueEdge
	node.falseEdge = falseEdge

	-- Set outEdges
	local outEdges = dispatchPrepareStat(body, {trueEdge}, env)
	table.insert(outEdges, falseEdge)

	return outEdges
end

function prepareStatement.IfStatement(node, inEdges, env)
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
	local outEdges = dispatchPrepareStat(thenBody, {thenEdge}, env)

	-- Check if there's an else
	if elseBody then
		-- Else outEdges
		local elseOutEdges = dispatchPrepareStat(elseBody, {elseEdge}, env)
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
		env:newLocalVar(var.name)
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
			env:addVar(var.name)
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



return function(ast)
		local env = Env:Init()
		local startEdge = Edge:InitStartEdge(env)
		local endEdges = prepareStatementList(ast.statements, {startEdge}, env)
		local endNode = {tag = 'EndNode', inEdges=endEdges}
		setToEdges(endEdges, endNode)
		return ast, startEdge, endNode
	end
