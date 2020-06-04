_ENV["package"][ "path" ] = (_ENV["package"]["path"]..";./libs/?.lua")
_ENV["package"][ "cpath" ] = ("./libs/?/?.so;".._ENV["package"]["cpath"])
_ENV[ "pretty" ] = _ENV["require"]("pl.pretty")
local v1 = _ENV["require"]("parser")
local v2 = _ENV["require"]("prepareAst")
local v3 = _ENV["require"]("abstractInterp")
local v4 = _ENV["require"]("propagation")
local v5 = _ENV["require"]("toLua")
local v6 = { ... }
local v7 = v6[1]
local v8 = v6[2]
local v9
v9 = function(v10)
	local v11 = _ENV["io"]["open"](v10, "rb")
	if (not v11) then
		return nil
	end
	local v12 = v11:read("*all")
	v11:close()
	return v12
end
local v13 = v9(v7)
if v13 then
	local v14 = v1["parse"](v13)
	local v15, v16 = v2(v14)
	v3(v15, v16)
	v4(v15, v16)
	local v17 = v5(v14)
	if v8 then
		local v18 = _ENV["io"]["open"](v8, "w+")
		v18:write(v17)
		v18:close()
	else
	end
else
end