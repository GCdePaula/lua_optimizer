-- require "paths"
package.path = package.path..";./libs/?.lua"
package.cpath = package.path..";./libs/?/?.so"

local bb = require "b"
local xx = require "xx.a"
local yy = require "yy.a"
local pretty = require "pl.pretty"
local lpeg = require "lpeg"

local t = {1, 2, 3, a = "a", b = "b"}

print(xx, yy, bb)

pretty.dump(t)
