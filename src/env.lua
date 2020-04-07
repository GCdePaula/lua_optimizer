local LatticeCell = require "lattice.cell"

local Env = {}

--[[
type Env = {
	-- Local vars are kept in a stack. Whenever a new
	-- one appears, it is pushed into the stack,
	-- whenever a new block/scope is created we
	-- update the stackBase and restore it when the
	-- block finishes.
	vars: string array
	stackBase: Int

	-- Previous env, used for closures. The env chain is
	-- used to resolve upvalues
	previousEnv: Env optional
}
--]]


function Env:Init(oldEnv)
	local newEnv = {}

	newEnv._vars = {}
	newEnv._stackBase = 1
	newEnv._previousEnv = oldEnv or false

	setmetatable(newEnv, self)
	self.__index = self

	return newEnv
end

-- Call when starting new Block, to start
-- a new scope. Returns previous scope to be
-- passed later to endBlock.
function Env:startBlock()
	local previousBase = self._stackBase
	self._stackBase = #self._vars + 1
	return previousBase
end

-- Call after a block is done, to restore previous
-- scope and close upvalues. Pass the value returned
-- by env:startBlock.
function Env:endBlock(previousBase)
	for i = self._stackBase, #self._vars do
		self._vars[i] = nil
	end
	self._stackBase = previousBase
end

-- Returns a new latticeCell, describing the current
-- state of env.
function Env:newLatticeCell()
	--  It is essentially a snapshot of env, but
	--  with Var instead of just names.
	return LatticeCell:InitWithScope(self._vars)
end

-- Adds a new local var to scope.
function Env:newLocalVar(name)
	table.insert(self._vars, name)
end

function Env:addVar(name)

end


return Env
