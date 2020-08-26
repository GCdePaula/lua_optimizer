local x, y = 3, 0

repeat
  x = 5
  y = y + 1
  print(y, x)
until y == 2*x
local z = x
z = y
z = "1"

local x = 1
repeat
  x = 2 - x
until global
local z = x
z = "2"

local x = 1
repeat
  x = x + 1
until true
local z = x
z = "3"

local x = 1
repeat
  x = x + 1
until false
local z = x
z = "4"
