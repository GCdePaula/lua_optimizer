local v1 = {  }
local v2
v2 = function(v3)
	local v4 = {  }
	_ENV["setmetatable"](v4, v3)
	v3[ "__index" ] = v3
	return v4
end
v1[ "InitWithTop" ] = function(v5)
	local v6 = v2(v5)
	v6[ "tag" ] = "Top"
	return v6
end
v1[ "InitWithNil" ] = function(v7)
	local v8 = v2(v7)
	v8[ "tag" ] = "Nil"
	return v8
end
v1[ "InitWithBottom" ] = function(v9)
	local v10 = v2(v9)
	v10[ "tag" ] = "Bot"
	return v10
end
v1[ "InitWithNumber" ] = function(v11, v12)
	local v13 = v2(v11)
	v13[ "tag" ] = "Number"
	v13[ "constant" ] = v12
	return v13
end
v1[ "InitWithBool" ] = function(v14, v15)
	local v16 = v2(v14)
	v16[ "tag" ] = "Bool"
	v16[ "constant" ] = v15
	return v16
end
v1[ "InitWithString" ] = function(v17, v18)
	local v19 = v2(v17)
	v19[ "tag" ] = "String"
	v19[ "constant" ] = v18
	return v19
end
v1[ "InitWithFunc" ] = function(v20, v21)
	local v22 = v2(v20)
	v22[ "tag" ] = "Func"
	v22[ "number" ] = v21
	return v22
end
v1[ "getNumber" ] = function(v23)
	if (v23["tag"]=="Number") then
		return true, v23["constant"]
	else
	end
end
v1[ "getBool" ] = function(v24)
	if (v24["tag"]=="Bool") then
		return true, v24["constant"]
	else
	end
end
v1[ "getString" ] = function(v25)
	if (v25["tag"]=="String") then
		return true, v25["constant"]
	else
	end
end
v1[ "getFunc" ] = function(v26)
	if (v26["tag"]=="Func") then
		return true, v26["number"]
	else
	end
end
v1[ "getConstant" ] = function(v27)
	if (v27["tag"]=="Nil") then
		return true, nil, "Nil"
	else
		if (v27["tag"]=="String") then
			return true, v27["constant"], "StringLiteral"
		else
			if (v27["tag"]=="Number") then
				return true, v27["constant"], "NumberLiteral"
			else
				if (v27["tag"]=="Bool") then
					return true, v27["constant"], "BoolLiteral"
				else
				end
			end
		end
	end
end
v1[ "isTop" ] = function(v28)
	return (v28["tag"]=="Top")
end
v1[ "isBottom" ] = function(v29)
	return (v29["tag"]=="Bot")
end
v1[ "isNil" ] = function(v30)
	return (v30["tag"]=="Nil")
end
v1[ "test" ] = function(v31)
	if v31:isBottom() then
		return false
	else
	end
end
v1[ "compare" ] = function(v34, v35)
	for v36, v37 in _ENV["pairs"](v34) do
		if (v37~=v35[v36]) then
			return false
		end
	end
	return true
end
v1[ "meet" ] = function(v38, v39)
	if v38:isBottom() then
		return false
	else
		if v38:isTop() then
			v38:assign(v39)
			return (not v39:isTop())
		else
			if (not v38:compare(v39)) then
				v38:assign(v1:InitWithBottom())
				return true
			else
			end
		end
	end
end
v1[ "copy" ] = function(v40)
	local v41 = {  }
	for v42, v43 in _ENV["pairs"](v40) do
		v41[ v42 ] = v43
	end
	_ENV["setmetatable"](v41, _ENV["getmetatable"](v40))
	return v41
end
v1[ "assign" ] = function(v44, v45)
	for v46, v47 in _ENV["pairs"](v44) do
		v44[ v46 ] = nil
	end
	for v48, v49 in _ENV["pairs"](v45) do
		v44[ v48 ] = v49
	end
end
return v1