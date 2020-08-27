local v1, v2 = 3, 0
while (v2 ~= (2 * v1)) do
	v1 = 5
	v2 = (v2 + 1)
	_ENV["print"](v2, 5)
end
local v3 = v1
v3 = v2
v3 = "1"
local v4 = 1
while _ENV["global"] do
	v4 = 1
end
local v5 = 1
v5 = "2"
local v6 = 1
local v7 = 1
v7 = "3"
local v8 = 1
while true do
	v8 = (v8 + 1)
	if _ENV["global"] then
		break
	end
end
local v9 = v8
v9 = "4"
local v10 = 1
while true do
	v10 = (v10 + 1)
end