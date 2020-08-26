local v1 = _ENV["require"]("lattice.cell")
local v2 = _ENV["require"]("lattice.element")
local v3 = _ENV["require"]("func")
local v4 = {  }
v4[ "Init" ] = function(v5, v6, v7, v8)
	local v9 = { _vars = {  }, upvalueVars = {  } }
	if v6 then
		v9[ "_previousEnv" ] = v6
		v9[ "_sharedCounter" ] = v6["_sharedCounter"]
		local v10 = v6["funcs"]
		local v11 = v3:Init(((# v10) + 1), v7, v8)
		_ENV["table"]["insert"](v10, v11)
		v9[ "funcs" ] = v10
		v9[ "currentFunc" ] = v11
	else
		v9[ "_previousEnv" ] = false
		v9[ "_sharedCounter" ] = { value = 0 }
		v9[ "funcs" ] = {  }
		v9[ "currentFunc" ] = false
	end
	_ENV["setmetatable"](v9, v5)
	v5[ "__index" ] = v5
	return v9
end
v4[ "startBlock" ] = function(v12)
	local v13 = {  }
	local v14 = v12["_vars"]
	for v15, v16 in _ENV["pairs"](v14) do
		v13[ v15 ] = v16
	end
	v12[ "_vars" ] = v13
	return v14
end
v4[ "endBlock" ] = function(v17, v18)
	v17[ "_vars" ] = v18
end
v4[ "newLatticeCell" ] = function(v19)
	local v20 = v1:InitWithScope(v19["_vars"])
	for v21, v22 in _ENV["ipairs"](v19["upvalueVars"]) do
		v20:setElementToVar(v22, v2:InitWithBottom())
	end
	return v20
end
v4[ "newLocalVar" ] = function(v23, v24)
	local v25 = v23["_sharedCounter"]
	v25[ "value" ] = (v25["value"] + 1)
	local v26 = ("v" .. _ENV["tostring"](v25["value"]))
	v23["_vars"][ v24 ] = v26
	return v26
end
v4[ "addVararg" ] = function(v27)
	v27["_vars"][ "..." ] = "..."
end
v4[ "getVar" ] = function(v28, v29, v30)
	local v31 = v28["_vars"][v29]
	if v31 then
		if v30 then
			_ENV["table"]["insert"](v28["upvalueVars"], v31)
		end
		return v31
	else
		local v32 = v28["_previousEnv"]
		if v32 then
			local v33 = v32:getVar(v29, true)
			v28["_vars"][ v29 ] = v33
			if v30 then
				_ENV["table"]["insert"](v28["upvalueVars"], v33)
			end
			return v33
		else
			if (v29 == "_ENV") then
				return "_ENV"
			else
				return false
			end
		end
	end
end
v4[ "getFuncs" ] = function(v34)
	return v34["funcs"]
end
v4[ "getCurrentFunc" ] = function(v35)
	return v35["currentFunc"]
end
return v4