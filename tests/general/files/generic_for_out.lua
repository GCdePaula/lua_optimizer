local v1, v2 = 3, 0
for v3, v4 in _ENV["pairs"]({  }) do
	v1 = 5
	v2 = (v2 + 1)
	_ENV["print"](v2, 5)
end
local v5 = v1
v5 = v2
v5 = "1"
local v6 = 1
for v7 in _ENV["some_func"]({  }) do
	v6 = 1
	local v8 = v7
end
local v9 = 1
v9 = "2"