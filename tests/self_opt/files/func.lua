local v1 = {  }
v1[ "Init" ] = function(v2, v3, v4, v5)
	local v6 = { index = v3, upvalues = {  }, startEdge = v4, node = v5 }
	_ENV["setmetatable"](v6, v2)
	v2[ "__index" ] = v2
	return v6
end
v1[ "addUpvalue" ] = function(v7, v8)
	_ENV["table"]["insert"](v7["upvalues"], v8)
end
v1[ "getStartEdge" ] = function(v9)
	return v9["startEdge"]
end
v1[ "getIndex" ] = function(v10)
	return v10["index"]
end
return v1