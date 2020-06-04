local v1 = _ENV["require"]("luaOps")
local v2
v2 = function(v3)
	return (("("..v3)..")")
end
local v4 = {  }
local v5 = {  }
local v6
v6 = function(v7, v8, v9)
	if v7["visited"] then
		return v5[v7["tag"]](v7, v8, v9)
	end
end
local v10
v10 = function(v11, v12, v13)
	local v14 = v11["head"]
	while v14 do
		v6(v14, v12, v13)
		v11 = v11["tail"]
		v14 = v11["head"]
	end
end
local v15
v15 = function(v16, v17)
	return v4[v16["tag"]](v16, v17)
end
_ENV["setmetatable"](v4, { __index = function(v18)
	return function(v19, v20)
		local v21 = v19["tag"]
		local v22
		if (v21=="u-") then
			v22 = ("-"..v15(v19["exp"], v20))
		else
			if (v21=="u~") then
				v22 = ("~"..v15(v19["exp"], v20))
			else
				if ((v1["binops"][v21]orv1["logbinops"][v21])orv1["cmpops"][v21]) then
					local v23 = v19["lhs"]
					local v24 = v19["rhs"]
					v22 = ((v15(v23, v20)..v21)..v15(v24, v20))
				else
					if v1["unops"][v21] then
						v22 = ((v21.." ")..v15(v19["exp"], v20))
					else
					end
				end
			end
		end
		return v2(v22)
	end
end })
v4[ "NumberLiteral" ] = function(v25)
	return _ENV["tostring"](v25["literal"])
end
v4[ "BoolLiteral" ] = function(v26)
	return _ENV["tostring"](v26["literal"])
end
v4[ "StringLiteral" ] = function(v27)
	return _ENV["string"]["format"]("%q", v27["literal"])
end
v4[ "Nil" ] = function()
	return "nil"
end
v4[ "VarExp" ] = function(v28)
	return v28["name"]
end
v4[ "IndexationExp" ] = function(v29, v30)
	local v31, v32 = v29["index"], v29["exp"]
	local v33 = v15(v31, v30)
	local v34 = v15(v32, v30)
	return (((v34.."[")..v33).."]")
end
v4[ "FunctionCall" ] = function(v35, v36)
	local v37 = v15(v35["func"], v36)
	local v38 = {  }
	for v39, v40 in _ENV["ipairs"](v35["args"]) do
		_ENV["table"]["insert"](v38, v15(v40, v36))
	end
	local v41 = _ENV["table"]["concat"](v38, ", ")
	return (((v37.."(")..v41)..")")
end
v4[ "MethodCall" ] = function(v42, v43)
	local v44 = v42["method"]
	local v45 = v15(v42["receiver"], v43)
	local v46 = {  }
	for v47, v48 in _ENV["ipairs"](v42["args"]) do
		_ENV["table"]["insert"](v46, v15(v48, v43))
	end
	local v49 = _ENV["table"]["concat"](v46, ", ")
	return (((((v45..":")..v44).."(")..v49)..")")
end
v4[ "TableConstructor" ] = function(v50, v51)
	local v52 = {  }
	for v53, v54 in _ENV["ipairs"](v50["fields"]) do
		local v55 = v15(v54["value"], v51)
		local v56
		local v57 = v54["tag"]
		if (v57=="ExpAssign") then
			v56 = ((("[ "..v15(v54["exp"], v51)).." ]").." = ")
		else
			if (v57=="NameAssign") then
				v56 = (v54["name"].." = ")
			else
			end
		end
		_ENV["table"]["insert"](v52, (v56..v55))
	end
	return (("{ ".._ENV["table"]["concat"](v52, ", ")).." }")
end
v4[ "AnonymousFunction" ] = function(v58, v59)
	local v60 = {  }
	local v61 = {  }
	for v62, v63 in _ENV["ipairs"](v58["params"]) do
		if (v63["tag"]=="LocalVar") then
			_ENV["table"]["insert"](v61, v63["name"])
		else
		end
	end
	_ENV["table"]["insert"](v60, (("function(".._ENV["table"]["concat"](v61, ", "))..")"))
	v10(v58["body"]["statements"], v60, ("\\t"..v59))
	_ENV["table"]["insert"](v60, (v59.."end"))
	return _ENV["table"]["concat"](v60, "\\n")
end
v4[ "Vararg" ] = function()
	return "..."
end
v5[ "Assign" ] = function(v64, v65, v66)
	local v67, v68 = v64["vars"], v64["exps"]
	local v69 = {  }
	for v70, v71 in _ENV["ipairs"](v67) do
		if (v71["tag"]=="Var") then
			_ENV["table"]["insert"](v69, v71["name"])
		else
		end
	end
	local v74 = {  }
	for v75, v76 in _ENV["ipairs"](v68) do
		_ENV["table"]["insert"](v74, v15(v76, v66))
	end
	_ENV["table"]["insert"](v65, (((v66.._ENV["table"]["concat"](v69, ", ")).." = ").._ENV["table"]["concat"](v74, ", ")))
end
v5[ "LocalAssign" ] = function(v77, v78, v79)
	local v80, v81 = v77["vars"], v77["exps"]
	local v82 = {  }
	for v83, v84 in _ENV["ipairs"](v80) do
		_ENV["table"]["insert"](v82, v84["name"])
	end
	if ((# v81)~=0) then
		local v85 = {  }
		for v86, v87 in _ENV["ipairs"](v81) do
			_ENV["table"]["insert"](v85, v15(v87, v79))
		end
		_ENV["table"]["insert"](v78, ((((v79.."local ").._ENV["table"]["concat"](v82, ", ")).." = ").._ENV["table"]["concat"](v85, ", ")))
	else
	end
end
v5[ "IfStatement" ] = function(v88, v89, v90)
	local v91 = v88["condition"]
	local v92, v93 = v88["thenBody"], v88["elseBody"]
	_ENV["table"]["insert"](v89, (((v90.."if ")..v15(v91, v90)).." then"))
	v10(v92["statements"], v89, ("\\t"..v90))
	if v93 then
		_ENV["table"]["insert"](v89, (v90.."else"))
		v10(v93["statements"], v89, ("\\t"..v90))
	end
	_ENV["table"]["insert"](v89, (v90.."end"))
end
v5[ "GenericFor" ] = function(v94, v95, v96)
	local v97, v98, v99 = v94["vars"], v94["exps"], v94["body"]
	local v100 = {  }
	for v101, v102 in _ENV["ipairs"](v97) do
		_ENV["table"]["insert"](v100, v102["name"])
	end
	local v103 = {  }
	for v104, v105 in _ENV["ipairs"](v98) do
		_ENV["table"]["insert"](v103, v15(v105, v96))
	end
	local v106 = _ENV["table"]["concat"](v100, ", ")
	local v107 = _ENV["table"]["concat"](v103, ", ")
	_ENV["table"]["insert"](v95, (((((v96.."for ")..v106).." in ")..v107).." do"))
	v10(v99["statements"], v95, ("\\t"..v96))
	_ENV["table"]["insert"](v95, (v96.."end"))
end
v5[ "While" ] = function(v108, v109, v110)
	local v111, v112 = v108["condition"], v108["body"]
	_ENV["table"]["insert"](v109, (((v110.."while ")..v15(v111, v110)).." do"))
	v10(v112["statements"], v109, ("\\t"..v110))
	_ENV["table"]["insert"](v109, (v110.."end"))
end
v5[ "Repeat" ] = function(v113, v114, v115)
	local v116, v117 = v113["condition"], v113["body"]
	_ENV["table"]["insert"](v114, (v115.."repeat"))
	v10(v117["statements"], v114, ("\\t"..v115))
	_ENV["table"]["insert"](v114, ((v115.."until ")..v15(v116, v115)))
end
v5[ "Do" ] = function(v118, v119, v120)
	_ENV["table"]["insert"](v119, (v120.."do"))
	v10(v118["body"]["statements"], v119, ("\\t"..v120))
	_ENV["table"]["insert"](v119, (v120.."end"))
end
v5[ "FunctionCallStat" ] = function(v121, v122, v123)
	local v124, v125 = v121["func"], v121["args"]
	local v126 = v15(v124, v123)
	local v127 = {  }
	for v128, v129 in _ENV["ipairs"](v125) do
		_ENV["table"]["insert"](v127, v15(v129, v123))
	end
	_ENV["table"]["insert"](v122, ((((v123..v126).."(").._ENV["table"]["concat"](v127, ", "))..")"))
end
v5[ "MethodCallStat" ] = function(v130, v131, v132)
	local v133, v134, v135 = v130["receiver"], v130["method"], v130["args"]
	local v136 = v15(v133, v132)
	local v137 = {  }
	for v138, v139 in _ENV["ipairs"](v135) do
		_ENV["table"]["insert"](v137, v15(v139, v132))
	end
	_ENV["table"]["insert"](v131, ((((((v132..v136)..":")..v134).."(").._ENV["table"]["concat"](v137, ", "))..")"))
end
v5[ "Break" ] = function(v140, v141, v142)
	_ENV["table"]["insert"](v141, (v142.."break"))
end
v5[ "Return" ] = function(v143, v144, v145)
	local v146 = v143["exps"]
	if v146 then
		local v147 = {  }
		for v148, v149 in _ENV["ipairs"](v146) do
			_ENV["table"]["insert"](v147, v15(v149, v145))
		end
		_ENV["table"]["insert"](v144, ((v145.."return ").._ENV["table"]["concat"](v147, ", ")))
	else
	end
end
v5[ "Nop" ] = function()
end
local v150
v150 = function(v151)
	local v152 = {  }
	v10(v151["statements"], v152, "")
	return _ENV["table"]["concat"](v152, "\\n")
end
return v150