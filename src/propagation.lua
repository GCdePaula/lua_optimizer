local LuaOps = require "luaOps"

--[[
local function makeTag(tp)
	if tp == 'string' then return 'StringLiteral'
	elseif tp == 'number' then return 'NumberLiteral'
	elseif tp == 'bool' then return 'BoolLiteral'
	elseif tp == nil then return 'Nil'
end
--]]

local propagateExp = {}
local function dispatchPropagateExp(exp)
	local isConstant, literal, tag = exp.element:getConstant()
	if isConstant then
		exp.tag = tag
		exp.literal = literal
	else
		propagateExp[exp.tag](exp)
	end
end

setmetatable(propagateExp, {__index = function(_)
	return function(node)
		local tag = node.tag
		if LuaOps.binops[tag] then
			local lhs, rhs = node.lhs, node.rhs

			-- I don't think this matters
			if tag == '^' then
				dispatchPropagateExp(rhs)
				dispatchPropagateExp(lhs)
			else
				dispatchPropagateExp(lhs)
				dispatchPropagateExp(rhs)
			end

			local isNumber1, n1 = lhs.tag == 'NumberLiteral', lhs.literal
			local isNumber2, n2 = rhs.tag == 'NumberLiteral', rhs.literal

			if isNumber1 and isNumber2 then
				local literal = LuaOps.makeOp(tag, n1, n2)
				node.lhs, node.rhs = nil, nil
				node.tag = 'NumberLiteral'
				node.literal = literal
			end
		elseif LuaOps.cmpops[tag] then
			local lhs, rhs = node.lhs, node.rhs
			dispatchPropagateExp(lhs)
			dispatchPropagateExp(rhs)

			local literalTag = lhs.tag
			local compatible = lhs.tag == rhs.tag
			local comparable = literalTag == 'StringLiteral' or literalTag == 'NumberLiteral'

			if compatible and comparable then
				local literal = LuaOps.makeOp(tag, lhs.literal, rhs.literal)
				node.lhs, node.rhs = nil, nil
				node.tag = literalTag
				node.literal = literal
			end

		elseif LuaOps.unops[tag] then
			local exp = node.exp
			dispatchPropagateExp(exp)

			local isNumber, n = exp.tag == 'NumberLiteral', exp.literal

			if isNumber then
				local literal = LuaOps.makeOp(tag, n)
				node.exp = nil
				node.tag = 'NumberLiteral'
				node.literal = literal
			end
		else
			error("Tag for prepare exp not implemented " .. tag)
		end
	end
end
})

propagateExp['and'] = function(node)
	local lhs, rhs = node.lhs, node.rhs
	dispatchPropagateExp(lhs)

	local isLhsTestable, lhsTest = lhs.element:test()
	if isLhsTestable then
		if not lhsTest then
			-- Eliminate rhs. Node becomes lhs.
			for k,v in pairs(lhs) do
				node[k] = v
			end
			return
		end
	else
		dispatchPropagateExp(rhs)
	end
end

propagateExp['or'] = function(node)
	local lhs, rhs = node.lhs, node.rhs
	dispatchPropagateExp(lhs)

	local isLhsTestable, lhsTest = lhs.element:test()
	if isLhsTestable then
		if lhsTest then
			-- Eliminate rhs. Node becomes lhs.
			for k,v in pairs(lhs) do
				node[k] = v
			end
			return
		end
	else
		dispatchPropagateExp(rhs)
	end
end

propagateExp['=='] = function(node)
	error("Tag for prepare exp not implemented " .. node.tag)
end

propagateExp['~='] = function (node)
	error("Tag for prepare exp not implemented " .. node.tag)
end

propagateExp['not'] = function (node)
	error("Tag for prepare exp not implemented " .. node.tag)
end

propagateExp['#'] = function (node)
	error("Tag for prepare exp not implemented " .. node.tag)
end


function propagateExp.VarExp(_, _)
	-- Do nothing. If it got here there's nothing to
	-- be done.
end

function propagateExp.IndexationExp(node, cell)
	dispatchPropagateExp(node.exp, cell)
	dispatchPropagateExp(node.index, cell)
end

function propagateExp.FunctionCall(node, cell)
	dispatchPropagateExp(node.func, cell)
	for _,v in ipairs(node.args) do
		dispatchPropagateExp(v, cell)
	end
end


local propagateStat = {}
local function dispatchPropagateStatFromEdge(edge)
	if edge:isExecutable() then
		local node = edge:getToNode()
		if node and not node.visited then
			node.visited = true
			propagateStat[node.tag](node)
		end
	end
end

local function propagateAssign(node)
	local exps = node.exps
	for _,exp in ipairs(exps) do
		dispatchPropagateExp(exp)
	end
	dispatchPropagateStatFromEdge(node.outEdge)
end

function propagateStat.Assign(node)
	propagateAssign(node)
end

function propagateStat.LocalAssign(node)
	propagateAssign(node)
end

function propagateStat.IfStatement(node)
	local condition = node.condition
	dispatchPropagateExp(condition)

	local condElement = condition.element

	local testable, test = condElement:test()
	if testable then
		local outEdge
		local body
		if test then
			-- Take only then branch
			outEdge = node.thenEdge
			body = node.thenBody
		else
			-- Take only else branch
			outEdge = node.elseEdge
			body = node.elseBody
		end
		-- propagate body
		dispatchPropagateStatFromEdge(outEdge)
		node.tag = 'Do'
		node.body = body
	else
		dispatchPropagateStatFromEdge(node.thenEdge)
		dispatchPropagateStatFromEdge(node.elseEdge)
	end
end

function propagateStat.While(node)
	local condition = node.condition
	dispatchPropagateExp(condition)

	local condElement = condition.element

	local testable, test = condElement:test()
	if testable then
		if not test then
			node.tag = 'Nop'
			return dispatchPropagateStatFromEdge(node.falseEdge)
		else
			return dispatchPropagateStatFromEdge(node.trueEdge)
		end
	else
		dispatchPropagateStatFromEdge(node.falseEdge)
		dispatchPropagateStatFromEdge(node.trueEdge)
	end
end

function propagateStat.FunctionCallStat(node)
	local func, args = node.func, node.args

	dispatchPropagateExp(func)
	for _,arg in ipairs(args) do
		dispatchPropagateExp(arg)
	end

	dispatchPropagateStatFromEdge(node.outEdge)
end
function propagateStat.Break(node)
	dispatchPropagateStatFromEdge(node.outEdge)
end

local function constantPropagation(startEdge)
	dispatchPropagateStatFromEdge(startEdge)
end

return constantPropagation
