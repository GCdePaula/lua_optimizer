local v1 = 0
local v2 = 0
_ENV[ "f" ] = function()
	v1 = 1
end
v2 = v1
v2 = "1"
local v3 = 2
local v4 = 2
local v5
v5 = function()
	local v6 = v3
	local v7
	v7 = function()
		v3 = 3
	end
end
v4 = v3
v4 = "2"
local v8 = 2
local v9 = 2
local v10
v10 = function()
	local v11 = v8
end
v9 = v8
v9 = "3"