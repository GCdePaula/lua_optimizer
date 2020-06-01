local Func = {}

function Func:Init(index, edge, node)
	local func = {index = index, upvalues = {}, startEdge = edge, node = node}

	setmetatable(func, self)
	self.__index = self
	return func
end

function Func:addUpvalue(name)
	table.insert(self.upvalues, name)
end

function Func:getStartEdge()
	return self.startEdge
end

function Func:getIndex()
	return self.index
end

return Func
