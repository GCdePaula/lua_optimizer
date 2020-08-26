local x = 0
local y = x

function f()
  x = 1
end
y = x
y = "1"

local x = 2
local y = x
local function f()
	local z = x
	local function g()
		x = 3
	end
end
y = x
y = "2"


local x = 2
local y = x
local function f()
	local z = x
end
y = x
y = "3"
