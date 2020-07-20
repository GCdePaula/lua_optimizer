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

		if LuaOps.binops[tag] or LuaOps.cmpops[tag] then
			dispatchPropagateExp(node.lhs)
			dispatchPropagateExp(node.rhs)

		elseif LuaOps.unops[tag] then
			dispatchPropagateExp(node.exp)

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

function propagateExp.VarExp()
	-- Do nothing. If it got here there's nothing to
	-- be done.
end

function propagateExp.IndexationExp(node)
	dispatchPropagateExp(node.exp)
	dispatchPropagateExp(node.index)
end

function propagateExp.FunctionCall(node)
	dispatchPropagateExp(node.func)
	for _,v in ipairs(node.args) do
		dispatchPropagateExp(v)
	end
end

function propagateExp.MethodCall(node)
	dispatchPropagateExp(node.receiver)
	for _,v in ipairs(node.args) do
		dispatchPropagateExp(v)
	end
end

function propagateExp.TableConstructor(node)
  local fields = node.fields

  for _,field in ipairs(fields) do
    dispatchPropagateExp(field.value)
    if field.tag == 'ExpAssign' then
      dispatchPropagateExp(field.exp)
    end
  end
end

function propagateExp.AnonymousFunction() end

function propagateExp.Vararg() end

local propagateStat = {}
local function dispatchPropagateStatFromEdge(edge)
	if edge:isExecutable() then
		local node = edge:getToNode()
		if node and not node.visited then
			node.visited = true
			return propagateStat[node.tag](node)
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
		if test then
			-- Take only then branch
			local body = node.thenBody

			node.tag = 'Do'
			node.body = body
			dispatchPropagateStatFromEdge(node.thenEdge)
		else
			-- Take only else branch
			local body = node.elseBody

			if body then
				node.tag = 'Do'
				node.body = body
				dispatchPropagateStatFromEdge(node.elseEdge)
			else
				node.tag = 'Nop'
			end
		end
	else
		dispatchPropagateStatFromEdge(node.thenEdge)
		dispatchPropagateStatFromEdge(node.elseEdge)
	end
end

function propagateStat.GenericFor(node)
	local exps = node.exps

	for _, exp in ipairs(exps) do
		dispatchPropagateExp(exp)
	end

	dispatchPropagateStatFromEdge(node.loopEdge)
	dispatchPropagateStatFromEdge(node.continueEdge)
end

function propagateStat.NumericFor(node)
	local init, limit, step = node.init, node.limit, node.step

	dispatchPropagateExp(init)
	dispatchPropagateExp(limit)
	if step then dispatchPropagateExp(step) end

	dispatchPropagateStatFromEdge(node.loopEdge)
	dispatchPropagateStatFromEdge(node.continueEdge)
end

function propagateStat.While(node)
	local condition = node.condition
	dispatchPropagateExp(condition)

	local condElement = condition.element

	local testable, test = condElement:test()
	if testable then
		if test then
			return dispatchPropagateStatFromEdge(node.trueEdge)
		else
			node.tag = 'Nop'
			return dispatchPropagateStatFromEdge(node.falseEdge)
		end
	else
		dispatchPropagateStatFromEdge(node.trueEdge)
		dispatchPropagateStatFromEdge(node.falseEdge)
	end
end

function propagateStat.Repeat(node)
	local condition = node.condition
	dispatchPropagateExp(condition)

	local condElement = condition.element

	local testable, test = condElement:test()
	if testable then
		if test then
			node.tag = 'Do'
			return dispatchPropagateStatFromEdge(node.continueEdge)
		else
			-- return dispatchPropagateStatFromEdge(node.repeatEdge)
		end
	else
		dispatchPropagateStatFromEdge(node.continueEdge)
		dispatchPropagateStatFromEdge(node.repeatEdge)
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

function propagateStat.MethodCallStat(node)
	local receiver, args = node.receiver, node.args

	dispatchPropagateExp(receiver)
	for _,arg in ipairs(args) do
		dispatchPropagateExp(arg)
	end

	dispatchPropagateStatFromEdge(node.outEdge)
end

function propagateStat.Break(node)
	dispatchPropagateStatFromEdge(node.outEdge)
end

function propagateStat.Return(node)
	local exps = node.exps
	if exps then
		for _,exp in ipairs(exps) do
			dispatchPropagateExp(exp)
		end
	end
end

function propagateStat.EndNode() end

local function constantPropagation(startEdge, closureEdges)
	dispatchPropagateStatFromEdge(startEdge)

  for _,func in ipairs(closureEdges) do
    dispatchPropagateStatFromEdge(func)
  end
end

return constantPropagation
