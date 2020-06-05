local v1 = _ENV["require"]("lattice.element")
local v2 = {  }
v2[ "InitWithName" ] = function(v3, v4)
	local v5 = { _name = v4 }
	v5[ "_element" ] = v1:InitWithTop()
	_ENV["setmetatable"](v5, v3)
	v3[ "__index" ] = v3
	return v5
end
v2[ "getName" ] = function(v6)
	return v6["_name"]
end
v2[ "getElement" ] = function(v7)
	return v7["_element"]
end
v2[ "setElement" ] = function(v8, v9)
	v8[ "_element" ] = v9
end
v2[ "setBottom" ] = function(v10)
	v10[ "_element" ] = v1:InitWithBottom()
end
v2[ "meet" ] = function(v11, v12)
	return v11["_element"]:meet(v12:getElement())
end
v2[ "equal" ] = function(v13, v14)
	if ((v13:getName() == v14:getName()) and v13:getElement():compare(v14:getElement())) then
		return true
	else
		return false
	end
end
v2[ "copy" ] = function(v15)
	local v16 = {  }
	v16[ "_name" ] = v15:getName()
	v16[ "_element" ] = v15:getElement():copy()
	_ENV["setmetatable"](v16, _ENV["getmetatable"](v15))
	return v16
end
return v2