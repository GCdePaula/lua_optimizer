local Element = require "lattice.element"

local Var = {}

function Var:InitWithName(name)
	local newVar = {_name = name}
	newVar._element = Element:InitWithTop()
	setmetatable(newVar, self)
	self.__index = self
	return newVar
end

function Var:getName()
	return self._name
end

function Var:getElement()
	return self._element
end

function Var:setElement(element)
	self._element = element
end

function Var:setBottom()
	self._element = Element:InitWithBottom()
end

function Var:meet(otherVar)
	return self._element:meet(otherVar:getElement())
end

function Var:equal(otherVar)
	if self:getName() == otherVar:getName() and
		self:getElement():compare(otherVar:getElement()) then
		return true
	else
		return false
	end
end

function Var:copy()
	local newVar = {}
	newVar._name = self:getName()
	newVar._element = self:getElement():copy()

	setmetatable(newVar, getmetatable(self))
	return newVar
end



return Var

