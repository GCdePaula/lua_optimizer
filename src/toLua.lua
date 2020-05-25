local LuaOps = require "luaOps"

local function wrapParentheses(str)
	return '(' .. str .. ')'
end

--[[
local function findMaxEquals(str)
	local max = -1
	for word in str:gmatch("%[=*%[") do
		local len = string.len(word)
		max = math.max(max, len - 2)
	end
	for word in str:gmatch("%]=*%]") do
		local len = string.len(word)
		max = math.max(max, len - 2)
	end
	return max
end

local function indentation(depth)
	return string.rep('\t', depth)
end
--]]

local stringOfExp = {}
local function dispatchStringOfExp(exp)
	return stringOfExp[exp.tag](exp)
end

setmetatable(stringOfExp, {__index = function(_)
	return function(exp)
		local tag = exp.tag
		local str
		if tag == 'u-' then
			str = '-' .. dispatchStringOfExp(exp.exp)

		elseif tag == 'u~' then
			str = '~' .. dispatchStringOfExp(exp.exp)

		elseif LuaOps.binops[tag]
			or LuaOps.logbinops [tag]
			or LuaOps.cmpops[tag] then

			local lhs = exp.lhs
			local rhs = exp.rhs
			str = dispatchStringOfExp(lhs) .. tag .. dispatchStringOfExp(rhs)

		elseif LuaOps.unops[tag] then
			str = tag .. dispatchStringOfExp(exp.exp)

		else
			pretty.dump(exp)
			error('stringOfExp tag not implemented ' .. tag)
		end

		return wrapParentheses(str)
	end
end})

function stringOfExp.NumberLiteral(exp)
	return tostring(exp.literal)
end

function stringOfExp.BoolLiteral(exp)
	return tostring(exp.literal)
end

function stringOfExp.StringLiteral(exp)
	return string.format("%q", exp.literal)
end

function stringOfExp.Nil()
	return 'nil'
end

function stringOfExp.VarExp(exp)
	return exp.name
end

function stringOfExp.IndexationExp(node)
	local index, exp = node.index, node.exp
	local indexStr = dispatchStringOfExp(index)
	local expStr = dispatchStringOfExp(exp)

	return expStr .. '[' .. indexStr .. ']'
end

local stringOfStat = {}

local function dispatchStringOfStat(stat, str, depth)
	if not stat.untouched then
	-- if stat.untouched then
		return stringOfStat[stat.tag](stat, str, depth)
	else
		return str
	end
end

local function stringOfStatList(list, buffer, depth)
	local head = list.head

	while head do
		dispatchStringOfStat(head, buffer, depth)
		list = list.tail
		head = list.head
	end
end

function stringOfStat.Assign(stat, buffer, depth)
	local vars, exps = stat.vars, stat.exps

	local varBuffer = {}
	for _,var in ipairs(vars) do
		if var.tag == 'Var' then
			table.insert(varBuffer, var.name)
		else
			local indexStr = dispatchStringOfExp(var.index)
			local expStr = dispatchStringOfExp(var.exp)
			table.insert(varBuffer, expStr .. '[ ' .. indexStr .. ' ]')
		end
	end

	local expBuffer = {}
	for _,exp in ipairs(exps) do
		table.insert(expBuffer, dispatchStringOfExp(exp))
	end

	table.insert(buffer, depth ..
		table.concat(varBuffer, ', ') .. ' = ' .. table.concat(expBuffer, ', '))
end

function stringOfStat.LocalAssign(stat, buffer, depth)
	local vars, exps = stat.vars, stat.exps

	local varBuffer = {}
	for _,var in ipairs(vars) do
		table.insert(varBuffer, var.name)
	end

	local expBuffer = {}
	if #exps ~= 0 then
		for _,exp in ipairs(exps) do
			table.insert(expBuffer, dispatchStringOfExp(exp))
		end

		table.insert(buffer, depth .. 'local ' ..
			table.concat(varBuffer, ', ') .. ' = ' .. table.concat(expBuffer, ', '))
	else
		table.insert(buffer, depth .. 'local ' .. table.concat(varBuffer, ', '))
	end
end


function stringOfStat.IfStatement(node, buffer, depth)
	local condition = node.condition
	local thenBody, elseBody = node.thenBody, node.elseBody

	table.insert(buffer, depth ..
		'if ' .. dispatchStringOfExp(condition) .. ' then')

	stringOfStatList(thenBody.statements, buffer, depth+1)

	if elseBody then
		table.insert(buffer, depth .. 'else')
		stringOfStatList(elseBody.statements, buffer, '\t' .. depth)
	end

	table.insert(buffer, depth .. 'end')
end

function stringOfStat.While(node, buffer, depth)
	local condition, body = node.condition, node.body

	table.insert(buffer,depth ..
		'while ' .. dispatchStringOfExp(condition) .. ' do')

	stringOfStatList(body.statements, buffer, '\t' .. depth)

	table.insert(buffer, depth .. 'end')
end

function stringOfStat.Do(node, buffer, depth)
	table.insert(buffer, depth .. 'do')
	stringOfStatList(node.body.statements, buffer, '\t' .. depth)
	table.insert(buffer, depth .. 'end')
end

function stringOfStat.Break(_, buffer, depth)
	table.insert(buffer, depth .. 'break')
end

function stringOfStat.Nop() end

local function toLua(ast)
	local buffer = {}
	stringOfStatList(ast.statements, buffer, '')
	return table.concat(buffer, '\n')
end

return toLua
