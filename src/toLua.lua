local LuaOps = require "luaOps"

local function wrapParentheses(str)
	return '(' .. str .. ')'
end

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
	local str = exp.literal
	local max = findMaxEquals(str)

	local equals = string.rep('=', max+1)

	return '[' .. equals .. '[' .. str .. ']' .. equals .. ']'
end

function stringOfExp.VarExp(exp)
	return exp.name
end

local stringOfStat = {}

local function dispatchStringOfStat(stat, str, depth)
	if not stat.untouched then
		return stringOfStat[stat.tag](stat, str, depth)
	else
		return str
	end
end

local function stringOfStatList(list, depth)
	local head = list.head
	local str = ""

	while head do
		local indent = string.rep('\t', depth)
		str = dispatchStringOfStat(head, str .. '\n' .. indent , depth)
		list = list.tail
		head = list.head
	end

	return str
end

function stringOfStat.Assign(stat, str)
	local vars, exps = stat.vars, stat.exps

	for i=1,#vars-1 do
		str = str .. vars[i] .. ", "
	end
	str = str .. vars[#vars].name .. ' = '

	for i=1,#exps-1 do
		str = str .. dispatchStringOfExp(exps[i]) .. ", "
	end
	str = str .. dispatchStringOfExp(exps[#exps])

	return str
end

function stringOfStat.LocalAssign(stat, str)
	local vars, exps = stat.vars, stat.exps
	str = str .. 'local '

	for i=1,#vars-1 do
		str = str .. vars[i] .. ", "
	end
	str = str .. vars[#vars].name

	if #exps ~= 0 then
		str = str .. ' = '
		for i=1,#exps-1 do
			str = str .. dispatchStringOfExp(exps[i]) .. ", "
		end
		str = str .. dispatchStringOfExp(exps[#exps])
	end

	return str
end


function stringOfStat.IfStatement(node, str, depth)
	local condition = node.condition
	local thenBody, elseBody = node.thenBody, node.elseBody

	str = str .. 'if ' .. dispatchStringOfExp(condition) .. ' then'
	str = str .. stringOfStatList(thenBody.statements, depth+1)

	if elseBody then
		str = str .. '\nelse'
		str = str .. stringOfStatList(elseBody.statements, depth+1)
	end

	str = str .. '\n' .. string.rep('\t', depth) .. 'end'

	return str
end

function stringOfStat.While(node, str, depth)
	local condition, body = node.condition, node.body

	str = str .. 'while ' .. dispatchStringOfExp(condition) .. ' do'
	str = str .. stringOfStatList(body.statements, depth+1)
	str = str .. '\n' .. string.rep('\t', depth) .. 'end'

	return str
end

function stringOfStat.Do(node, str, depth)
	str = str .. 'do'
	str = str .. stringOfStatList(node.body.statements, depth + 1)
	str = str .. '\n' .. indentation(depth) .. 'end'
	return str
end

function stringOfStat.Nop(_, str, _) return str end

local function toLua(ast)
	return stringOfStatList(ast.statements, 0)
end

return toLua
