local Element = require "lattice.element"

local op = {}

op["^"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 ^ n2)
	else return Element:InitWithBottom() end
end

op[".."] = function(e1, e2)
	local b1, s1 = e1:getString()
	local b2, s2 = e2:getString()
	if b1 and b2 then return Element:InitWithString(s1 .. s2)
	else return Element:InitWithBottom() end
end

op["*"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 * n2)
	else return Element:InitWithBottom() end
end

op["/"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 / n2)
	else return Element:InitWithBottom() end
end

op["//"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 // n2)
	else return Element:InitWithBottom() end
end

op["%"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 % n2)
	else return Element:InitWithBottom() end
end


op["+"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 + n2)
	else return Element:InitWithBottom() end
end

op["-"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 - n2)
	else return Element:InitWithBottom() end
end


op["<<"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 << n2)
	else return Element:InitWithBottom() end
end

op[">>"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 >> n2)
	else return Element:InitWithBottom() end
end


op["&"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 & n2)
	else return Element:InitWithBottom() end
end

op["~"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 ~ n2)
	else return Element:InitWithBottom() end
end

op["|"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithNumber(n1 | n2)
	else return Element:InitWithBottom() end
end

-- Unops
op["not"] = function(e)
	local isNil = e:isNil()
	local isBool, bool = e:getBool()

	if isNil then
		return Element:InitWithBool(true)
	elseif isBool then
		return Element:InitWithBool(not bool)
	elseif e:isBottom() then
		return Element:InitWithBottom()
	else
		return Element:InitWithBool(false)
	end
end

op["#"] = function()
	return Element:InitWithBottom()
end

op["u-"] = function(e)
	local b, n = e:getNumber()
	if b then return Element:InitWithNumber(-n)
	else return Element:InitWithBottom() end
end

op["u~"] = function(e)
	local b, n = e:getNumber()
	if b then return Element:InitWithNumber(~n)
	else return Element:InitWithBottom() end
end

-- LogBinOps
op["and"] = function(e1, e2)
	local isConstant1, constant1 = e1:test()
	if not isConstant1 then
		return Element:InitWithBottom()
	elseif not constant1 then
		return e1:copy()
	else
		return e2:copy()
	end
end

op["or"] = function(e1, e2)
	local isConstant1, constant1 = e1:test()
	if not isConstant1 then
		return Element:InitWithBottom()
	elseif constant1 then
		return e1:copy()
	else
		return e2:copy()
	end
end


-- Compare ops
op["<"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithBool(n1 < n2)
	else return Element:InitWithBottom() end
end

op["<="] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithBool(n1 <= n2)
	else return Element:InitWithBottom() end
end

op[">"] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithBool(n1 > n2)
	else return Element:InitWithBottom() end
end

op[">="] = function(e1, e2)
	local b1, n1 = e1:getNumber()
	local b2, n2 = e2:getNumber()
	if b1 and b2 then return Element:InitWithBool(n1 >= n2)
	else return Element:InitWithBottom() end
end

op["=="] = function(e1, e2)
	if e1:isBottom() or e2:isBottom()
		or e1:isTop() or e2:isTop() then
		return Element:InitWithBottom()
	else
		return Element:InitWithBool(e1:compare(e2))
	end
end

op["~="] = function(e1, e2)
	if e1:isBottom() or e2:isBottom()
		or e1:isTop() or e2:isTop() then
		return Element:InitWithBottom()
	else
		return Element:InitWithBool(not e1:compare(e2))
	end
end

return op
