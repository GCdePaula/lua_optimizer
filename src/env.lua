local LatticeCell = require "lattice.cell"
local Func = require "func"

local Env = {}

--[[
type Env = {
	-- Local vars are kept in a dictionary, that maps
	-- names to newNames. Whenever a new one appears,
	-- it is added to this dictionary and a unique newName
	-- is created.
	-- Whenever a new block/scope is created we copy the
	-- dictionary and return the old one to the caller.
	-- It is the caller's responsibility to restore the old
	-- dictionary whtn the block finishes.
	vars: (string, string) dictionary

	-- Previous env, used for closures. The env chain is
	-- used to resolve upvalues
	previousEnv: Env optional
	sharedCounter: {value: Int}
	currentFunc: Func

	funcs: [Func]
}
--]]

function Env:Init(oldEnv, startEdge, node)
	local newEnv = {_vars = {}}

	if oldEnv then
		newEnv._previousEnv = oldEnv
		newEnv._sharedCounter = oldEnv._sharedCounter

		local funcs = oldEnv.funcs
		local currentFunc = Func:Init(#funcs+1, startEdge, node)
		table.insert(funcs, currentFunc)
		newEnv.funcs = funcs
		newEnv.currentFunc = currentFunc
	else
		newEnv._previousEnv = false
		newEnv._sharedCounter = {value = 0}

		newEnv.funcs = {}
		newEnv.currentFunc = false
	end

	setmetatable(newEnv, self)
	self.__index = self

	return newEnv
end

-- Call when starting new Block, to start
-- a new scope. Returns previous scope to be
-- passed later to endBlock.
function Env:startBlock()
	local newVars = {}
	local oldVars = self._vars

	for name, newName in pairs(oldVars) do
		newVars[name] = newName
	end

	self._vars = newVars
	return oldVars
end

-- Call after a block is done, to restore previous
-- scope and close upvalues. Pass the value returned
-- by env:startBlock.
function Env:endBlock(previousVars)
	self._vars = previousVars
end

-- Returns a new latticeCell, describing the current
-- state of env.
function Env:newLatticeCell()
	--  It is essentially a snapshot of env, but
	--  with Var instead of just names.
	return LatticeCell:InitWithScope(self._vars)
end

-- Adds a new local var to scope. Returns its new name.
function Env:newLocalVar(name)
	local counter = self._sharedCounter
	counter.value = counter.value + 1
	local newName = 'v' .. tostring(counter.value)
	self._vars[name] = newName
	return newName
end

function Env:getVar(name)
	local newName = self._vars[name]
	if newName then
		return newName
	else
		-- TODO: add upvalue to closure
		local previousEnv = self._previousEnv
		if previousEnv then
			local upval = previousEnv:getVar(name)
			self._vars[name] = upval
			return upval
		else
			if name == '_ENV' then
				return '_ENV'
			else
				return false
			end
		end
	end
end

function Env:getFuncs()
	return self.funcs
end

function Env:getCurrentFunc()
	return self.currentFunc
end

return Env
