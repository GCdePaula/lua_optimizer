local dump = require"pl.pretty".dump

local Edge = require "edge"
local Env = require "env"

local function concatArrays(a, b)
	for _, v in ipairs(b) do
    table.insert(a, v)
	end
	return a
end


local binops = {
	['^']="pow",
	['*']="mul", ['/']="div", ['//']="idiv", ['%']="mod",
	['+']="add", ['-']="sub",
	['<<']="shl", ['>>']="shr",
	['&']="band", ['~']="bxor", ['|']="bor"
}
local cmpops = {
	['<']='lt',
	['<=']='le',
	['==']='eq',
}
local unops = {['u-']=true,['u~']=true}

local prepareExp = {}

local function dispatchPrepareExp(node, env)
	return prepareExp[node.tag](node, env)
end

setmetatable(prepareExp, {__index = function(tag)
		return function(node, env)
			-- This should cover the generic cases.
			local tag = node.tag
			if binops[tag] or cmpops[tag] then
				dispatchPrepareExp(node.lhs, env)
				dispatchPrepareExp(node.rhs, env)
			elseif unops[tag] then
				dispatchPrepareExp(node.exp, env)
			elseif tag == 'StringLiteral' or
				tag == 'IntLiteral' or
				tag == 'FloatLiteral' or
				tag == 'BoolLiteral' then
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
		if not edge.setToNode then pretty.dump(edge) end
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
	node.inLatticeCell = env:newLatticeCell()
	pretty.dump(condition)
	dispatchPrepareExp(condition, env)
	node.outLatticeCell = env:newLatticeCell()

	-- Create outEdges
	local trueEdge, falseEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.trueEdge = trueEdge
	node.falseEdge = falseEdge

	-- Set outEdges
	local outEdges = dispatchPrepareStat(body, trueEdge, env)
	table.insert(outEdges, falseEdge)

	return outEdges
end

function prepareStatement.IfStatement(node, inEdges, env)
	local condition, thenBody, elseBody = node.condition, node.thenBody, node.elseBody

	-- Set inEdges
	setToEdges(inEdges, node)
	node.inEdges = inEdges


	-- Set latticeCell
	node.inLatticeCell = env:newLatticeCell()
	dispatchPrepareExp(condition, env)
	node.outLatticeCell = env:newLatticeCell()

	-- Create and set condition out edges
	local thenEdge, elseEdge = Edge:InitWithFromNode(node), Edge:InitWithFromNode(node)
	node.thenEdge, node.elseEdge = thenEdge, elseEdge

	-- Then outEdges
	local outEdges = dispatchPrepareStat(thenBody, thenEdge, env)

	-- Check if there's an else
	if elseBody then
		-- Else outEdges
		local elseOutEdges = dispatchPrepareStat(elseBody, elseEdge, env)
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
	--

	node.inLatticeCell = env:newLatticeCell()

	-- Add vars to env
	for _,var in ipairs(node.vars) do
		env:newLocalVar(var.name)
	end

	for _,exp in ipairs(node.exps) do
		dispatchPrepareExp(exp, env)
	end
	--

	node.outLatticeCell = env:newLatticeCell()

	return {outEdge}
end

function prepareStatement.Assign(node, inEdges, env)
	setToEdges(inEdges, node)
	node.inEdges = inEdges

	local outEdge = Edge:InitWithFromNode(node)
	node.outEdge = outEdge

	node.inLatticeCell = env:newLatticeCell()

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

	node.outLatticeCell = env:newLatticeCell()

	return {outEdge}
end



return function(ast)
		local env = Env:Init()
		local startEdge = Edge:InitStartEdge(env)
		local endEdges = prepareStatementList(ast.statements, {startEdge}, env)
		local endNode = {tag = 'EndNode'}
		setToEdges(endEdges, endNode)
		return startEdge, ast
	end
