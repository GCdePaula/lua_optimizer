local lattice = {}

-- Returns LatticeElement resulting from
-- meeting e1 and e2
function lattice.meet(e1, e2)

end


lattice.op["^"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 ^ n2)
	else return LatticeElement:InitWithBottom() end
end


lattice.op["*"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 * n2)
	else return LatticeElement:InitWithBottom() end
end

lattice.op["/"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 / n2)
	else return LatticeElement:InitWithBottom() end
end

lattice.op["//"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 // n2)
	else return LatticeElement:InitWithBottom() end
end

lattice.op["%"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 % n2)
	else return LatticeElement:InitWithBottom() end
end


lattice.op["+"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 + n2)
	else return LatticeElement:InitWithBottom() end
end

lattice.op["-"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 - n2)
	else return LatticeElement:InitWithBottom() end
end


lattice.op["<<"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 << n2)
	else return LatticeElement:InitWithBottom() end
end

lattice.op[">>"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 >> n2)
	else return LatticeElement:InitWithBottom() end
end


lattice.op["&"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 & n2)
	else return LatticeElement:InitWithBottom() end
end

 lattice.op["~"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 ~ n2)
	else return LatticeElement:InitWithBottom() end
end

lattice.op["|"] = function(e1, e2)
	local b1, n1 = e1.getNumber()
	local b2, n2 = e2.getNumber()
	if b1 and b2 then return LatticeElement:InitWithNumber(n1 | n2)
	else return LatticeElement:InitWithBottom() end
end



