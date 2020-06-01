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

local function indentation(indent)
	return string.rep('\t', indent)
end
--]]

local stringOfExp = {}
local stringOfStat = {}


local function dispatchStringOfStat(stat, buffer, indent)
	if stat.visited then
		return stringOfStat[stat.tag](stat, buffer, indent)
	end
end

local function stringOfStatList(list, buffer, indent)
	local head = list.head

	while head do
		dispatchStringOfStat(head, buffer, indent)
		list = list.tail
		head = list.head
	end
end

local function dispatchStringOfExp(exp, indent)
	return stringOfExp[exp.tag](exp, indent)
end

setmetatable(stringOfExp, {__index = function(_)
	return function(exp, indent)
		local tag = exp.tag
		local str
		if tag == 'u-' then
			str = '-' .. dispatchStringOfExp(exp.exp, indent)

		elseif tag == 'u~' then
			str = '~' .. dispatchStringOfExp(exp.exp, indent)

		elseif LuaOps.binops[tag]
			or LuaOps.logbinops [tag]
			or LuaOps.cmpops[tag] then

			local lhs = exp.lhs
			local rhs = exp.rhs
			str = dispatchStringOfExp(lhs, indent) .. tag .. dispatchStringOfExp(rhs, indent)

		elseif LuaOps.unops[tag] then
			str = tag .. dispatchStringOfExp(exp.exp, indent)

		else
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

function stringOfExp.IndexationExp(node, indent)
	local index, exp = node.index, node.exp
	local indexStr = dispatchStringOfExp(index, indent)
	local expStr = dispatchStringOfExp(exp, indent)

	return expStr .. '[' .. indexStr .. ']'
end

function stringOfExp.FunctionCall(node, indent)
	local funcStr = dispatchStringOfExp(node.func, indent)

	local args = {}
	for _,arg in ipairs(node.args) do
		table.insert(args, dispatchStringOfExp(arg, indent))
	end
	local argsStr = table.concat(args, ', ')

	return funcStr .. '(' .. argsStr .. ')'
end

function stringOfExp.TableConstructor(node, indent)
	local fields = {}
	for _,field in ipairs(node.fields) do
		local value = dispatchStringOfExp(field.value, indent)
		local key

		local tag = field.tag
		if tag == 'ExpAssign' then
			key = '[ ' .. dispatchStringOfExp(field.exp, indent) .. ' ]' .. ' = '
		elseif tag == 'NameAssign' then
			key = field.name .. ' = '
		else
			key = ""
		end
		table.insert(fields, key .. value)
	end

	return '{ ' .. table.concat(fields, ', ') .. ' }'
end


function stringOfExp.AnonymousFunction(node, indent)
	local buffer = {}

	local params = {}
	for _,param in ipairs(node.params) do
		if param.tag == 'LocalVar' then
			table.insert(params, param.name)
		else
			table.insert(params, '...')
		end
	end

	table.insert(buffer, 'function(' .. table.concat(params, ', ') .. ')')
	stringOfStatList(node.body.statements, buffer, '\t' .. indent)
	table.insert(buffer, indent .. 'end')
	return table.concat(buffer, '\n')
end


function stringOfStat.Assign(stat, buffer, indent)
	local vars, exps = stat.vars, stat.exps

	local varBuffer = {}
	for _,var in ipairs(vars) do
		if var.tag == 'Var' then
			table.insert(varBuffer, var.name)
		else
			local indexStr = dispatchStringOfExp(var.index, indent)
			local expStr = dispatchStringOfExp(var.exp, indent)
			table.insert(varBuffer, expStr .. '[ ' .. indexStr .. ' ]')
		end
	end

	local expBuffer = {}
	for _,exp in ipairs(exps) do
		table.insert(expBuffer, dispatchStringOfExp(exp, indent))
	end

	table.insert(buffer, indent ..
		table.concat(varBuffer, ', ') .. ' = ' .. table.concat(expBuffer, ', '))
end

function stringOfStat.LocalAssign(stat, buffer, indent)
	local vars, exps = stat.vars, stat.exps

	local varBuffer = {}
	for _,var in ipairs(vars) do
		table.insert(varBuffer, var.name)
	end

	if #exps ~= 0 then
		local expBuffer = {}
		for _,exp in ipairs(exps) do
			table.insert(expBuffer, dispatchStringOfExp(exp, indent))
		end

		table.insert(buffer, indent .. 'local ' ..
			table.concat(varBuffer, ', ') .. ' = ' .. table.concat(expBuffer, ', '))
	else
		table.insert(buffer, indent .. 'local ' .. table.concat(varBuffer, ', '))
	end
end


function stringOfStat.IfStatement(node, buffer, indent)
	local condition = node.condition
	local thenBody, elseBody = node.thenBody, node.elseBody

	table.insert(buffer, indent ..
		'if ' .. dispatchStringOfExp(condition, indent) .. ' then')

	stringOfStatList(thenBody.statements, buffer, '\t' .. indent)

	if elseBody then
		table.insert(buffer, indent .. 'else')
		stringOfStatList(elseBody.statements, buffer, '\t' .. indent)
	end

	table.insert(buffer, indent .. 'end')
end

function stringOfStat.GenericFor(node, buffer, indent)
	local vars, exps, body = node.vars, node.exps, node.body

	local varBuffer = {}
	for _,var in ipairs(vars) do
		table.insert(varBuffer, var.name)
	end

	local expBuffer = {}
	for _,exp in ipairs(exps) do
		table.insert(expBuffer, dispatchStringOfExp(exp, indent))
	end

	local varsStr = table.concat(varBuffer, ', ')
	local expsStr = table.concat(expBuffer, ', ')

	table.insert(buffer, indent ..
		'for ' .. varsStr .. ' in ' .. expsStr .. ' do')

	stringOfStatList(body.statements, buffer, '\t' .. indent)

	table.insert(buffer, indent .. 'end')
end

function stringOfStat.While(node, buffer, indent)
	local condition, body = node.condition, node.body

	table.insert(buffer, indent ..
		'while ' .. dispatchStringOfExp(condition, indent) .. ' do')

	stringOfStatList(body.statements, buffer, '\t' .. indent)

	table.insert(buffer, indent .. 'end')
end

function stringOfStat.Repeat(node, buffer, indent)
	local condition, body = node.condition, node.body

	table.insert(buffer, indent .. 'repeat')

	stringOfStatList(body.statements, buffer, '\t' .. indent)

	table.insert(buffer, indent .. 'until '
		.. dispatchStringOfExp(condition, indent))
end

function stringOfStat.Do(node, buffer, indent)
	table.insert(buffer, indent .. 'do')
	stringOfStatList(node.body.statements, buffer, '\t' .. indent)
	table.insert(buffer, indent .. 'end')
end

function stringOfStat.FunctionCallStat(node, buffer, indent)
	local func, args = node.func, node.args

	local funcString = dispatchStringOfExp(func, indent)

	local argsStr = {}
	for _,arg in ipairs(args) do
		table.insert(argsStr, dispatchStringOfExp(arg, indent))
	end

	table.insert(buffer, indent .. funcString
		.. '(' .. table.concat(argsStr, ', ') .. ')')

end

function stringOfStat.Break(_, buffer, indent)
	table.insert(buffer, indent .. 'break')
end

function stringOfStat.Nop() end

local function toLua(ast)
	local buffer = {}
	stringOfStatList(ast.statements, buffer, '')
	return table.concat(buffer, '\n')
end

return toLua
