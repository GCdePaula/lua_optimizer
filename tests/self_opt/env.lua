local v1 = _ENV["require"]("lattice.cell")
local v2 = _ENV["require"]("func")
local v3 = {  }
v3[ "Init" ] = function(v4, v5, v6, v7)
	local v8 = { _vars = {  } }
	if v5 then
		v8[ "_previousEnv" ] = v5
		v8[ "_sharedCounter" ] = v5["_sharedCounter"]
		local v9 = v5["funcs"]
		local v10 = v2:Init(((# v9)+1), v6, v7)
		_ENV["table"]["insert"](v9, v10)
		v8[ "funcs" ] = v9
		v8[ "currentFunc" ] = v10
	else
	end
	_ENV["setmetatable"](v8, v4)
	v4[ "__index" ] = v4
	return v8
end
v3[ "startBlock" ] = function(v11)
	local v12 = {  }
	local v13 = v11["_vars"]
	for v14, v15 in _ENV["pairs"](v13) do
		v12[ v14 ] = v15
	end
	v11[ "_vars" ] = v12
	return v13
end
v3[ "endBlock" ] = function(v16, v17)
	v16[ "_vars" ] = v17
end
v3[ "newLatticeCell" ] = function(v18)
	return v1:InitWithScope(v18["_vars"])
end
v3[ "newLocalVar" ] = function(v19, v20)
	local v21 = v19["_sharedCounter"]
	v21[ "value" ] = (v21["value"]+1)
	local v22 = ("v".._ENV["tostring"](v21["value"]))
	v19["_vars"][ v20 ] = v22
	return v22
end
v3[ "addVararg" ] = function(v23)
	v23["_vars"][ "..." ] = "..."
end
v3[ "getVar" ] = function(v24, v25)
	local v26 = v24["_vars"][v25]
	if v26 then
		return v26
	else
	end
end
v3[ "getFuncs" ] = function(v29)
	return v29["funcs"]
end
v3[ "getCurrentFunc" ] = function(v30)
	return v30["currentFunc"]
end
return v3