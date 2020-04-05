local Element = require "latticeElement"

local Var = {}

function Var:initWithNameAndIndex(name, index)
	local newVar = {_name = name, _index = index}
	newVar._element = Element:InitWithTop()
	setmetatable(newVar, self)
	self.__index = self
	return newVar
end


return Var

