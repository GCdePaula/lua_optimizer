local x, y = 3, 0

while y ~= 2*x do
  x = 5
  y = y + 1
  print(y, x)
end
local z = x
z = y
z = "1"

local x = 1
while global do
  x = 2 - x
end
local z = x
z = "2"

local x = 1
while false do
  x = x + 1
end
local z = x
z = "3"

local x = 1
while true do
  x = x + 1
  if global then break end
end
local z = x
z = "4"

local x = 1
while true do
  x = x + 1
end
local z = x
z = "5"
