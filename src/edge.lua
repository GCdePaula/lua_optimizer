local Edge = {}

function Edge:InitStartEdge(env)
	local startNode = {tag = "StartNode", outLatticeCell = env:newLatticeCell()}
	return self:InitWithFromNode(startNode)
end

function Edge:InitWithFromNode(node)
	local newEdge = {_fromNode = node}
	setmetatable(newEdge, self)
	self.__index = self
	return newEdge
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

