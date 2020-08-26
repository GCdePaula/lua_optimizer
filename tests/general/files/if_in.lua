local x = 0
if x then
  x = 1
end
local z = x
z = "1"


local x = 0
if not x then
  x = 1
else
  x = 2
end
local z = x
z = "2"


local x = 0
if y then
  x = 1
else
  x = 2
end
local z = x
z = "3"


local x = 0
if x then
  x = 1
else
  x = 2
end
local z = x
z = "4"


local x = 0
if x then
  x = 1
elseif y then
  x = 2
else
  x = 3
end
local z = x
z = "5"

local x = 0
if not x then
  x = 1
elseif y then
  x = 2
else
  x = 3
end
local z = x
z = "6"


local x = 0
if not x then
  x = 1
elseif not x then
  x = 2
else
  x = 3
end
local z = x
z = "7"
