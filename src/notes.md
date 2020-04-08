TODO
	Env:
		It is used during prepare phase.
		startBlock, endBlock, newLatticeCell, newLocalVar, addVar (does nothing for now)



First prepare AST for propagation. That means creating a pseudo CFG,
and gathering upvalues and anonimous functions data.

Need an edge object. It contains a *from* and *to* fields. And a lattice
cell object.

Each statement needs an in-edges field, and an out-edges field, of type edge.
Assignment will only have one out-field. Ifs will have two, (then, and else or continue).

The object latticeCell will contain all variables up to that point. That means all visibile
local vars and shadowed local vars. Local vars are initialised with top. Will also have a meet
operator between a set of latticeCell.

Do note that vars are numbered, first on it's enclosing function and then on its local number.
The meet operator on latticeCells will over var indexes.




All funcs will have a list of upvalues. Each upvalue might be either in local scope (and therefore it's
just an index), be an upvalue of the calling function (just an index of a list of this same type, but of
the enclosing function) or closed (and is a latticeElement). This won't be easy to build. I'll leave
this for later.













-- Returns lattice element that correspond
-- to the meet operation between e1 and e2.
lattice.meet(e1, e2)

-- Applies op to e1 and e2, returning
-- the resulting lattice element. Op is a
-- string that corresponds to Lua's ops.
lattice.op(op, e1, e2)


-- Adds var to local vars set
env.addLocalVar(varName)

-- Returns lattice element of var.
env.getVarLatticeElement(varName)

-- Sets lattice element for var.
env.setVarLatticeElement(varName, element)

-- Returns new env and scope, where the new scope is a shallow
-- copy of the previous one. To use when starting a
-- new block. When exiting scope, you need to restore previous
-- scope.
env.newScope()

-- Restores old scope.
env.restoreScope(scope)

-- Returns new env, where new scope is a deep copy
-- off the previous one. To use when branching.
env.branchEnv()

-- Meet every common element from e1 and e2,
-- and assign them to elements of env. Use to
-- join envs of two different branches into the
-- "master" env.
env.joinEnvs(e1, e2)





-- Assigns bottom to all escaped and global vars.
env.bottomGlobalVars()

-- Assigns bottom to all upvalues of
-- func with index funcIndex
env.bottomUpvaluesOf(funcIndex)

-- Returns if func has been visited, for
-- breaking recursive inline.
env.beenVisited(funcIndex)




-- This is the prototype for var
var = {
	name = string
	latticeElement = {
		tag = "top" | "bottom" | "constant"
		constant = { -- in case tag is constant
			tag = "func" | "number" | "table" | "string"
			funcIndex = int -- tag is "func"
			number = number -- tag is "number"
			string = string -- tag is "string"
		}
	}
	hasEscaped = bool
	isUpvalue = bool -- Is this needed?
	index = int
	funcIndex = int
}





env = {
	-- "Static" throughout the interpretation. That is
	-- it "doesn't chage" between function calls.

	-- Data on global vars.
	globalVars = {
		varName = var
	}

	-- Funcs. The array of "static" functions, of the
	-- "compilation" of a given function code
	-- *in a given scope*
	funcs = {
		[n] = {
			ast = {...}

			upvalues = {
				varName = var
			}

			nestedIn = func index
		}
	}

	-- Scope. Contains the "dinamic" scope of
	-- abstract interpretation within a block.
	localVars = {
		varName = var
	}
	varCounter = int

	visited = {[funcIndex] = bool}


	-- Previous function scope.
	funcIndex = index
	previousEnv = {...}
}




local Env = {}

--[[
type Env = {
	-- "Static" throughout the interpretation. That is
	-- it "doesn't chage" between function calls.

	-- Data on global vars.
	globalVars: {
		varName: Var
	}

	escapedVars: {
		indexes: [int]
		[n]: Var
	}

	-- Funcs. The array of "static" functions, of the
	-- "compilation" of a given function code
	-- *in a given scope*
	funcs: {
		[n]: {
			ast: {...}

			upvalues: {
				[varName]: var
			}

			nestedIn: int
		}
	}

	-- Scope. Contains the "dinamic" scope of
	-- abstract interpretation within a block.
	localVars: {
		[varName]: Var
	}
	varCounter: int

	visited: {
		[funcIndex] = bool
	}


	-- Previous function scope.
	funcIndex: int
	previousEnv: Env
}

--]]



function Env:Init(oldEnv)
	oldEnv = oldEnv or false

end


-- Adds var to local vars set
function Env:addLocalVar(varName)

end

-- Returns lattice element of var.
function Env:getVarLatticeElement(varName)

end

-- Sets lattice element for var.
function Env:setVarLatticeElement(varName, element)

end

-- Returns new scope, where the new scope is a shallow
-- copy of the previous one. To use when starting a
-- new block. When exiting scope, you need to restore previous
-- scope.
function Env:newScope()

end

-- Restores old scope.
function Env:restoreScope(scope)

end

-- Returns new env, where new scope is a deep copy
-- off the previous one. To use when branching.
function Env:branchEnv()

end

-- Meet every common element from e1 and e2,
-- and assign them to elements of function Env: Use to
-- join envs of two different branches into the
-- "master" function Env:
function Env:joinEnvs(e1, e2)

end

