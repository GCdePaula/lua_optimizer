local v1 = _ENV["require"]("lattice.var")
local v2 = _ENV["require"]("lattice.element")
local v3 = {  }
v3[ "InitWithScope" ] = function(v4, v5)
	local v6 = {  }
	local v7 = { _vars = v6 }
	for v8, v9 in _ENV["pairs"](v5) do
		v6[ v9 ] = v1:InitWithName(v9)
	end
	_ENV["setmetatable"](v7, v4)
	v4[ "__index" ] = v4
	return v7
end
v3[ "getVar" ] = function(v10, v11)
	local v12 = v10["_vars"][v11]
	if (not v12) then
		v12 = v1:InitWithName(v11)
		v12:setBottom()
		return v12
	else
		return v12
	end
end
v3[ "addVar" ] = function(v13, v14)
	v13["_vars"][ v14 ] = v1:InitWithName(v14)
end
v3[ "setElementToVar" ] = function(v15, v16, v17)
	local v18 = v15:getVar(v16)
	v18:setElement(v17)
end
v3[ "updateWithInEdges" ] = function(v19, v20)
	local v21 = {  }
	for v22, v23 in _ENV["ipairs"](v20) do
		if v23:isExecutable() then
			_ENV["table"]["insert"](v21, v23:getFromNode()["outCell"])
		end
	end
	local v24 = false
	local v25 = v19["_vars"]
	for v26, v27 in _ENV["pairs"](v25) do
		for v28, v29 in _ENV["ipairs"](v21) do
			local v30 = v29:getVar(v26)
			v24 = (v27:meet(v30) or v24)
		end
	end
	return v24
end
v3[ "compareWithCell" ] = function(v31, v32)
	for v33, v34 in _ENV["pairs"](v31["_vars"]) do
		local v35 = v32:getVar(v33)
		if (not v34:equal(v35)) then
			return false
		end
	end
	return true
end
v3[ "copy" ] = function(v36)
	local v37 = {  }
	local v38 = { _vars = v37 }
	for v39, v40 in _ENV["pairs"](v36["_vars"]) do
		v37[ v39 ] = v40:copy()
	end
	_ENV["setmetatable"](v38, _ENV["getmetatable"](v36))
	return v38
end
v3[ "bottomAllVars" ] = function(v41)
	for v42, v43 in _ENV["ipairs"](v41["_vars"]) do
		v43:setElement(v2:InitWithBottom())
	end
end
return v3