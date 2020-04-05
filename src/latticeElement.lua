local Element = {}

--[[
type latticeElement =
	Top
	Bottom
	Nil
	Number of number
	Bool of bool
	Func of int
	String of string
	Table of table
--]]

local function init(self)
	local newElement = {}
	setmetatable(newElement, self)
	self.__index = self
	return newElement
end

function Element:InitWithTop()
	local newElement = init(self)
	newElement.tag = "Top"
	return newElement
end

function Element:InitWithNil()
	local newElement = init(self)
	newElement.tag = "Nil"
	return newElement
end

function Element:InitWithBottom()
	local newElement = init(self)
	newElement.tag = "Bot"
	return newElement
end

function Element:InitWithNumber(n)
	local newElement = init(self)
	newElement.tag = "Number"
	newElement.number = n
	return newElement
end


-- Returns a copy of receiver.
function Element:copy()
	local new = {}
	for k,v in pairs(self)do
		-- Shallow copy, as all values are
		-- 'values'
		new[k] = v
	end
	return new
end

-- function Element:setNumber(n)

-- end

-- Returns true and number if number,
-- or false if not a number.
function Element:getNumber()
	if self.tag == 'Number' then
		return self.number
	else
		return false
	end
end

-- Returns if receiver is top.
function Element:isTop()
	if self.tag == 'Top' then
		return true
	else
		return false
	end
end

-- Returns if receiver is bottom.
function Element:isBottom()
	if self.tag == 'Bot' then
		return true
	else
		return false
	end
end

-- Returns if receiver is nil.
function Element:isNil()
	if self.tag == 'Nil' then
		return true
	else
		return false
	end
end

return Element
