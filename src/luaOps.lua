local binops = {
	['^']=true,
	['*']=true, ['/']=true, ['//']=true, ['%']=true,
	['+']=true, ['-']=true,
	['<<']=true, ['>>']=true,
	['&']=true, ['~']=true, ['|']=true
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

return {
	binops = binops,
	unops = unops,
	logbinops = logbinops,
	cmpops = cmpops
}
