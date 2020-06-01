local Element = {}

--[[
type latticeElement =
	Top
	Bottom
	Nil
	Number of number
		-- NumberType
	Bool of bool
		-- BoolType
		-- Func of int
	String of string
		-- StringType
		-- Table of table
		-- Truthy
		-- Falsy
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
	newElement.constant = n
	return newElement
end

function Element:InitWithBool(b)
	local newElement = init(self)
	newElement.tag = "Bool"
	newElement.constant = b
	return newElement
end

function Element:InitWithString(s)
	local newElement = init(self)
	newElement.tag = "String"
	newElement.constant = s
	return newElement
end

function Element:InitWithFunc(i)
	local newElement = init(self)
	newElement.tag = "Func"
	newElement.number = i
	return newElement
end

-- Returns true and number if number,
-- or false if not a number.
function Element:getNumber()
	if self.tag == 'Number' then
		return true, self.constant
	else
		return false
	end
end

-- Returns true and bool if bool,
-- or false if not a bool.
function Element:getBool()
	if self.tag == 'Bool' then
		return true, self.constant
	else
		return false
	end
end

-- Returns true and string if String,
-- or false if not a String.
function Element:getString()
	if self.tag == 'String' then
		return true, self.constant
	else
		return false
	end
end

function Element:getFunc()
	if self.tag == 'Func' then
		return true, self.number
	else
		return false
	end
end


-- Returns true, value and AST tag if constant,
-- or false if not constant.
function Element:getConstant()
	if self.tag == 'Nil' then
		return true, nil, 'Nil'
	elseif self.tag == 'String' then
		return true, self.constant, 'StringLiteral'
	elseif self.tag == 'Number' then
		return true, self.constant, 'NumberLiteral'
	elseif self.tag == 'Bool' then
		return true, self.constant, 'BoolLiteral'
	else
		return false
	end
end

-- Returns if receiver is top.
function Element:isTop()
	return self.tag == 'Top'
end

-- Returns if receiver is bottom.
function Element:isBottom()
	return self.tag == 'Bot'
end

-- Returns if receiver is nil.
function Element:isNil()
	return self.tag == 'Nil'
end

-- Returns true and bool if can be tested,
-- or false if not constant
function Element:test()
	if self:isBottom() then
		return false
	else
		local isBool, bool = self:getBool()
		if self:isNil() then
			return true, false
		elseif isBool then
			return true, bool
		else
			return true, true
		end
	end
end

function Element:compare(otherElement)
	for k,v in pairs(self)do
		if v ~= otherElement[k] then
			return false
		end
	end
	return true
end

-- Returns true if element changed, false otherwise
function Element:meet(e)
	if self:isBottom() then
		return false
	elseif self:isTop() then
		self:assign(e)
		return not e:isTop()
	elseif not self:compare(e) then
		self:assign(Element:InitWithBottom())
		return true
	else
		return false
	end
end

-- Returns a copy of receiver.
function Element:copy()
	local new = {}
	for k,v in pairs(self) do
		-- Shallow copy, as all values are
		-- 'values'
		new[k] = v
	end
	setmetatable(new, getmetatable(self))
	return new
end

-- Returns a copy of receiver.
function Element:assign(e)
	for k,_ in pairs(self) do self[k] = nil end
	for k,v in pairs(e) do
		self[k] = v
	end
end

return Element
