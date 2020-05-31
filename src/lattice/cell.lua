local Var = require "lattice.var"

local Cell = {}


function Cell:InitWithScope(scope)
	local vars = {}
	local newCell = {_vars = vars}

	for _, varName in pairs(scope) do
		vars[varName] = Var:InitWithName(varName)
	end

	setmetatable(newCell, self)
	self.__index = self
	return newCell
end

function Cell:getVar(name)
	local var = self._vars[name]
	if not var then
		-- Means it's an upvalue not assigned
		-- to before.
		var = Var:InitWithName(name)
		var:setBottom()
		return var
	else
		return var
	end
end

function Cell:addVar(name)
	self._vars[name] = Var:InitWithName(name)
end

function Cell:setElementToVar(name, element)
	local var = self:getVar(name)
	var:setElement(element)
end

-- Returns if there's some change
function Cell:updateWithInEdges(edges)
	local cells = {}
	for _,edge in ipairs(edges) do
		if edge:isExecutable() then
			table.insert(cells, edge:getFromNode().outCell)
		end
	end

	local changed = false
	local vars = self._vars
	for name, var in pairs(vars) do
		for _,cell in ipairs(cells) do
			local otherVar = cell:getVar(name)
			changed = var:meet(otherVar) or changed
		end
	end

	return changed
end

function Cell:compareWithCell(cell)
	for name,var in pairs(self._vars)do
		local otherVar = cell:getVar(name)
		if not var:equal(otherVar) then
			return false
		end
	end

	return true
end

function Cell:copy()
	local vars = {}
	local newCell = {_vars = vars}

	for name, var in pairs(self._vars) do
		vars[name] = var:copy()
	end

	setmetatable(newCell, getmetatable(self))
	return newCell
end


return Cell
