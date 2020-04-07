local Var = require "lattice.var"
local Element = require "lattice.element"

local Cell = {}


function Cell:InitWithScope(stack)
	local vars = {}
	local newCell = {_vars = vars}

	for idx, varName in ipairs(stack) do
		local var = Var:InitWithNameAndIndex(varName, idx)
		table.insert(vars, var)
	end

	setmetatable(newCell, self)
	self.__index = self
	return newCell
end

function Cell:getVarWithIndex(i)
	return self._vars[i]
end

function Cell:getVar(name)
	local vars = self._vars
	for i = #vars, 1, -1 do
		local var = vars[i]
		if var:getName() == name then
			return var
		end
	end
end

function Cell:addVar(name)
	local vars = self._vars
	table.insert(vars, Var:InitWithNameAndIndex(name, #vars+1))
end

function Cell:setElementToVar(name, element)
	local var = self:getVar(name)
	var:setElement(element)
end

function Cell:updateWithInEdges(edges)
	local cells = {}
	for _,edge in ipairs(edges) do
		if edge:isExecutable() then
			table.insert(cells, edge:getFromNode().outCell)
		end
	end

	local vars = self._vars
	for k,var in ipairs(vars) do
		var:setElement(Element:InitWithTop())
		for _,cell in ipairs(cells) do
			local otherVar = cell:getVarWithIndex(k)
			assert(var._name == otherVar._name, "names do not match " .. var._name .. " " .. otherVar._name)
			var:meet(otherVar)
		end
	end
end

function Cell:compareWithCell(cell)
	for k,var in ipairs(self._vars)do
		local otherVar = cell:getVarWithIndex(k)
		if not var:equal(otherVar) then
			return false
		end
	end

	return true
end

function Cell:copy()
	local vars = {}
	local newCell = {_vars = vars}

	for _, var in ipairs(self._vars) do
		table.insert(vars, var:copy())
	end

	setmetatable(newCell, getmetatable(self))
	return newCell
end


return Cell
