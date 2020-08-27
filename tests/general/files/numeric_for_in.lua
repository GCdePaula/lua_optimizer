local x, y = 3, 0

for i=1,10 do
  x = 5
  y = y + 1
  print(y, x, i)
end
local z = x
z = y
z = "1"

local x = 1
for i=1,10,2 do
  x = 2 - x
	local y = i
end
local z = x
z = "2"
