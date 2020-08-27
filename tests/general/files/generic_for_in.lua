local x, y = 3, 0

for k,v in pairs({}) do
  x = 5
  y = y + 1
  print(y, x)
end
local z = x
z = y
z = "1"

local x = 1
for k in some_func({}) do
  x = 2 - x
	local y = k
end
local z = x
z = "2"
