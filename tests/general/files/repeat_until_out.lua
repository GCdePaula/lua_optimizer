local v1, v2 = 3, 0
repeat
	v1 = 5
	v2 = (v2 + 1)
	_ENV["print"](v2, 5)
until (v2 == 10)
local v3 = 5
v3 = v2
v3 = "1"
local v4 = 1
repeat
	v4 = 1
until _ENV["global"]
local v5 = 1
v5 = "2"
local v6 = 1
do
	v6 = 2
end
local v7 = 2
v7 = "3"
local v8 = 1
repeat
	v8 = (v8 + 1)
until false