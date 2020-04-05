local Var = require "latticeVar"

local Cell = {}


function Cell:InitWithScope(stack)
	local latticeElements = {}
	local newCell = {elements = latticeElements}

	for idx, varName in ipairs(stack) do
		local element = Var:initWithNameAndIndex(varName, idx)
		table.insert(latticeElements, element)
	end

	setmetatable(newCell, self)
	self.__index = self
	return newCell
end


return Cell
