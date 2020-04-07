local Element = require "lattice.element"

local Var = {}

function Var:InitWithNameAndIndex(name, index)
	local newVar = {_name = name, _index = index}
	newVar._element = Element:InitWithTop()
	setmetatable(newVar, self)
	self.__index = self
	return newVar
end

function Var:getName()
	return self._name
end

function Var:getIndex()
	return self._index
end

function Var:getElement()
	return self._element
end

function Var:setElement(element)
	self._element = element
end

function Var:meet(otherVar)
	self._element:meet(otherVar:getElement())
end

function Var:equal(otherVar)
	if self:getName() == otherVar:getName() and
		self:getIndex() == otherVar:getIndex() and
		self:getElement():compare(otherVar:getElement()) then
		return true
	else
		return false
	end
end

function Var:copy()
	local newVar = {}
	newVar._name = self:getName()
	newVar._index = self:getIndex()
	newVar._element = self:getElement():copy()

	setmetatable(newVar, getmetatable(self))
	return newVar
end



return Var

