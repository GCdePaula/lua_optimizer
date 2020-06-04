local v1 = _ENV["require"]("lattice.cell")
local v2 = {  }
v2[ "InitWithFromNode" ] = function(v3, v4)
	local v5 = { _fromNode = v4, _executable = false }
	_ENV["setmetatable"](v5, v3)
	v3[ "__index" ] = v3
	return v5
end
v2[ "InitStartEdge" ] = function(v6)
	local v7 = { tag = "StartNode", outCell = v1:InitWithScope({  }) }
	return v6:InitWithFromNode(v7)
end
v2[ "isExecutable" ] = function(v8)
	return v8["_executable"]
end
v2[ "setExecutable" ] = function(v9)
	v9[ "_executable" ] = true
end
v2[ "reset" ] = function(v10)
	v10[ "_executable" ] = false
end
v2[ "getFromNode" ] = function(v11)
	return v11["_fromNode"]
end
v2[ "getToNode" ] = function(v12)
	return (v12["_toNode"]orfalse)
end
v2[ "setToNode" ] = function(v13, v14)
	v13[ "_toNode" ] = v14
end
v2[ "getLatticeCell" ] = function(v15)
	return v15["_fromNode"]["outLatticeCell"]
end
return v2