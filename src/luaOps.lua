local binops = {
	['^']=true,
	['*']=true, ['/']=true, ['//']=true, ['%']=true,
	['+']=true, ['-']=true,
	['<<']=true, ['>>']=true,
	['&']=true, ['~']=true, ['|']=true,
	['..']=true
}
local unops = {['not']=true,['#']=true,['u-']=true,['u~']=true}

local logbinops = {['and']=true,['or']=true}

local cmpops = {
	['<']=true,
	['<=']=true,
	['>']=true,
	['>=']=true,
	['==']=true,
	['~=']=true,
}


local op = {}
op['^'] = function(n1, n2)
	return n1 ^ n2
end
op['*'] = function(n1, n2)
	return n1 * n2
end
op['/'] = function(n1, n2)
	return n1 / n2
end
op['//'] = function(n1, n2)
	return n1 // n2
end
op['%'] = function(n1, n2)
	return n1 % n2
end
op['+'] = function(n1, n2)
	return n1 + n2
end
op['-'] = function(n1, n2)
	return n1 - n2
end
op['<<'] = function(n1, n2)
	return n1 << n2
end
op['>>'] = function(n1, n2)
	return n1 >> n2
end
op['&'] = function(n1, n2)
	return n1 & n2
end
op['~'] = function(n1, n2)
	return n1 ~ n2
end
op['|'] = function(n1, n2)
	return n1 | n2
end
op['not'] = function(x)
	return not x
end
op['#'] = function(x)
	return #x
end
op['u-'] = function(x)
	return -x
end
op['u~'] = function(x)
	return ~x
end
op['and'] = function(e1, e2)
	return e1 and e2
end
op['or'] = function(e1, e2)
	return e1 or e2
end
op['<'] = function(n1, n2)
	return n1 < n2
end
op['<='] = function(n1, n2)
	return n1 <= n2
end
op['>'] = function(n1, n2)
	return n1 > n2
end
op['>='] = function(n1, n2)
	return n1 >= n2
end
op['=='] = function(e1, e2)
	return e1 == e2
end
op['~='] = function(e1, e2)
	return e1 ~= e2
end
op['..'] = function(e1, e2)
	return e1 .. e2
end

local function makeOp(tag, x, y)
	return op[tag](x, y)
end


return {
	binops = binops,
	unops = unops,
	logbinops = logbinops,
	cmpops = cmpops,
	makeOp = makeOp
}
