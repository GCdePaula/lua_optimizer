local Cell = require "lattice.cell"
local Edge = {}

function Edge:InitWithFromNode(node)
	local newEdge = {_fromNode = node, _executable = false}
	setmetatable(newEdge, self)
	self.__index = self
	return newEdge
end

function Edge:InitStartEdge()
	local startNode = {tag = "StartNode", outCell = Cell:InitWithScope({})}
	return self:InitWithFromNode(startNode)
end

-- Returns if edge is executable
function Edge:isExecutable()
	return self._executable
end

-- Marks edge as executable
function Edge:setExecutable()
	self._executable = true
end


-- Returns from node
function Edge:getFromNode()
	return self._fromNode
end

-- Returns to node
function Edge:getToNode()
	return self._toNode or false
end

-- Sets to node
function Edge:setToNode(node)
	self._toNode = node
end

-- Returns latticeCell of from node
function Edge:getLatticeCell()
	return self._fromNode.outLatticeCell
end

return Edge

