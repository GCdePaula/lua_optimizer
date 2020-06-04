local v1 = _ENV["require"]("luaOps")
local v2 = _ENV["require"]("edge")
local v3 = _ENV["require"]("env")
local v4
v4 = function(v5, v6)
	for v7, v8 in _ENV["ipairs"](v6) do
		_ENV["table"]["insert"](v5, v8)
	end
	return v5
end
local v9
v9 = function(v10, v11)
	if v11 then
		v10[ "name" ] = v11
	else
	end
end
local v12
v12 = function(v13, v14)
	if v14 then
		v13[ "name" ] = v14
	else
	end
end
local v15
v15 = function(v16, v17)
	for v18, v19 in _ENV["ipairs"](v16) do
		v19:setToNode(v17)
	end
end
local v20
v20 = function()
	local v21 = { _loops = {  } }
	v21[ "startLoop" ] = function(v22)
		_ENV["table"]["insert"](v22["_loops"], {  })
	end
	v21[ "pushBreakEdge" ] = function(v23, v24)
		local v25 = v23["_loops"]
		local v26 = v25[(# v25)]
		_ENV["table"]["insert"](v26, v24)
	end
	v21[ "endLoop" ] = function(v27)
		return _ENV["table"]["remove"](v27["_loops"])
	end
	return v21
end
local v28 = {  }
local v29 = {  }
local v30
v30 = function(v31, v32, v33, v34)
	return v29[v31["tag"]](v31, v32, v33, v34)
end
local v35
v35 = function(v36, v37)
	return v28[v36["tag"]](v36, v37)
end
local v38
v38 = function(v39, v40, v41, v42)
	local v43 = v39["head"]
	if (not v43) then
		return v40
	end
	local v44 = v30(v43, v40, v41, v42)
	return v38(v39["tail"], v44, v41, v42)
end
_ENV["setmetatable"](v28, { __index = function(v45)
	return function(v46, v47)
		local v48 = v46["tag"]
		if ((v1["binops"][v48]orv1["cmpops"][v48])orv1["logbinops"][v48]) then
			v35(v46["lhs"], v47)
			v35(v46["rhs"], v47)
		else
			if v1["unops"][v48] then
				v35(v46["exp"], v47)
			else
				if ((((v48=="StringLiteral")or(v48=="NumberLiteral"))or(v48=="BoolLiteral"))or(v48=="Nil")) then
				else
				end
			end
		end
	end
end })
v28[ "IndexationExp" ] = function(v49, v50)
	v35(v49["index"], v50)
	v35(v49["exp"], v50)
end
v28[ "VarExp" ] = function(v51, v52)
	local v53 = v52:getVar(v51["name"])
	v12(v51, v53)
end
local v54
v54 = function(v55, v56, v57)
	v35(v57, v56)
	for v58, v59 in _ENV["ipairs"](v55["args"]) do
		v35(v59, v56)
	end
end
v28[ "FunctionCall" ] = function(v60, v61)
	return v54(v60, v61, v60["func"])
end
v28[ "MethodCall" ] = function(v62, v63)
	return v54(v62, v63, v62["receiver"])
end
v28[ "TableConstructor" ] = function(v64, v65)
	local v66 = v64["fields"]
	for v67, v68 in _ENV["ipairs"](v66) do
		v35(v68["value"], v65)
		if (v68["tag"]=="ExpAssign") then
			v35(v68["exp"], v65)
		end
	end
end
v28[ "AnonymousFunction" ] = function(v69, v70)
	local v71 = v2:InitStartEdge()
	local v72 = v3:Init(v70, v71, v69)
	local v73 = v20()
	local v74 = v69["params"]
	for v75, v76 in _ENV["ipairs"](v74) do
		if (v76["tag"]=="LocalVar") then
			local v77 = v72:newLocalVar(v76["name"])
			v74[v75][ "name" ] = v77
		else
		end
	end
	v69[ "funcIndex" ] = v72:getCurrentFunc():getIndex()
	local v78 = v38(v69["body"]["statements"], { v71 }, v72, v73)
	local v79 = { tag = "EndNode", inEdges = v78 }
	v15(v78, v79)
end
v28[ "Vararg" ] = function()
end
v29[ "Block" ] = function(v80, v81, v82, v83)
	local v84 = v82:startBlock()
	local v85 = v38(v80["statements"], v81, v82, v83)
	v82:endBlock(v84)
	return v85
end
v29[ "GenericFor" ] = function(v86, v87, v88, v89)
	local v90, v91, v92 = v86["vars"], v86["exps"], v86["body"]
	local v93 = v88:startBlock()
	v89:startLoop()
	for v94, v95 in _ENV["ipairs"](v91) do
		v35(v95, v88)
	end
	v86[ "inCell" ] = v88:newLatticeCell()
	for v96, v97 in _ENV["ipairs"](v90) do
		local v98 = v88:newLocalVar(v97["name"])
		v9(v97, v98)
	end
	v86[ "outCell" ] = v88:newLatticeCell()
	local v99, v100 = v2:InitWithFromNode(v86), v2:InitWithFromNode(v86)
	v86[ "loopEdge" ] = v99
	v86[ "continueEdge" ] = v100
	local v101 = v38(v92["statements"], { v99 }, v88, v89)
	v4(v87, v101)
	v15(v87, v86)
	v86[ "inEdges" ] = v87
	local v102 = v89:endLoop()
	_ENV["table"]["insert"](v102, v100)
	v88:endBlock(v93)
	return v102
end
v29[ "While" ] = function(v103, v104, v105, v106)
	local v107, v108 = v103["condition"], v103["body"]
	v106:startLoop()
	v35(v107, v105)
	v103[ "inCell" ] = v105:newLatticeCell()
	v103[ "outCell" ] = v105:newLatticeCell()
	local v109, v110 = v2:InitWithFromNode(v103), v2:InitWithFromNode(v103)
	v103[ "trueEdge" ] = v109
	v103[ "falseEdge" ] = v110
	local v111 = v30(v108, { v109 }, v105, v106)
	v4(v104, v111)
	v15(v104, v103)
	v103[ "inEdges" ] = v104
	local v112 = v106:endLoop()
	_ENV["table"]["insert"](v112, v110)
	return v112
end
v29[ "Repeat" ] = function(v113, v114, v115, v116)
	local v117, v118 = v113["condition"], v113["body"]
	v116:startLoop()
	v35(v117, v115)
	v113[ "inCell" ] = v115:newLatticeCell()
	v113[ "outCell" ] = v115:newLatticeCell()
	local v119, v120 = v2:InitWithFromNode(v113), v2:InitWithFromNode(v113)
	v113[ "repeatEdge" ] = v119
	v113[ "continueEdge" ] = v120
	_ENV["table"]["insert"](v114, v119)
	local v121 = v30(v118, v114, v115, v116)
	v15(v121, v113)
	v113[ "inEdges" ] = v121
	local v122 = v116:endLoop()
	_ENV["table"]["insert"](v122, v120)
	return v122
end
v29[ "IfStatement" ] = function(v123, v124, v125, v126)
	local v127, v128, v129 = v123["condition"], v123["thenBody"], v123["elseBody"]
	v15(v124, v123)
	v123[ "inEdges" ] = v124
	v35(v127, v125)
	v123[ "inCell" ] = v125:newLatticeCell()
	v123[ "outCell" ] = v125:newLatticeCell()
	local v130, v131 = v2:InitWithFromNode(v123), v2:InitWithFromNode(v123)
	v123[ "thenEdge" ], v123[ "elseEdge" ] = v130, v131
	local v132 = v30(v128, { v130 }, v125, v126)
	if v129 then
		local v133 = v30(v129, { v131 }, v125, v126)
		v4(v132, v133)
	else
	end
	return v132
end
v29[ "LocalAssign" ] = function(v134, v135, v136)
	v15(v135, v134)
	v134[ "inEdges" ] = v135
	local v137 = v2:InitWithFromNode(v134)
	v134[ "outEdge" ] = v137
	for v138, v139 in _ENV["ipairs"](v134["exps"]) do
		v35(v139, v136)
	end
	v134[ "inCell" ] = v136:newLatticeCell()
	for v140, v141 in _ENV["ipairs"](v134["vars"]) do
		local v142 = v136:newLocalVar(v141["name"])
		v9(v141, v142)
	end
	v134[ "outCell" ] = v136:newLatticeCell()
	return { v137 }
end
v29[ "Assign" ] = function(v143, v144, v145)
	v15(v144, v143)
	v143[ "inEdges" ] = v144
	local v146 = v2:InitWithFromNode(v143)
	v143[ "outEdge" ] = v146
	for v147, v148 in _ENV["ipairs"](v143["vars"]) do
		if (v148["tag"]=="Var") then
			local v149 = v145:getVar(v148["name"])
			v9(v148, v149)
		else
		end
	end
	for v152, v153 in _ENV["ipairs"](v143["exps"]) do
		v35(v153, v145)
	end
	v143[ "inCell" ] = v145:newLatticeCell()
	v143[ "outCell" ] = v145:newLatticeCell()
	return { v146 }
end
local v154
v154 = function(v155, v156, v157, v158)
	v15(v156, v155)
	v155[ "inEdges" ] = v156
	v35(v158, v157)
	for v159, v160 in _ENV["ipairs"](v155["args"]) do
		v35(v160, v157)
	end
	v155[ "inCell" ] = v157:newLatticeCell()
	v155[ "outCell" ] = v157:newLatticeCell()
	local v161 = v2:InitWithFromNode(v155)
	v155[ "outEdge" ] = v161
	return { v161 }
end
v29[ "FunctionCallStat" ] = function(v162, v163, v164)
	return v154(v162, v163, v164, v162["func"])
end
v29[ "MethodCallStat" ] = function(v165, v166, v167)
	return v154(v165, v166, v167, v165["receiver"])
end
v29[ "Break" ] = function(v168, v169, v170, v171)
	v15(v169, v168)
	v168[ "inEdges" ] = v169
	v168[ "inCell" ] = v170:newLatticeCell()
	local v172 = v2:InitWithFromNode(v168)
	v168[ "outEdge" ] = v172
	v171:pushBreakEdge(v172)
	return {  }
end
v29[ "Return" ] = function(v173, v174, v175)
	v15(v174, v173)
	v173[ "inEdges" ] = v174
	v173[ "inCell" ] = v175:newLatticeCell()
	local v176 = v173["exps"]
	if v176 then
		for v177, v178 in _ENV["ipairs"](v176) do
			v35(v178, v175)
		end
	end
	v173[ "outEdge" ] = false
	return {  }
end
v29[ "Nop" ] = function(v179, v180)
	return v180
end
return function(v181)
	local v182 = v3:Init()
	local v183 = v20()
	local v184 = v2:InitStartEdge()
	local v185 = v38(v181["statements"], { v184 }, v182, v183)
	local v186 = { tag = "EndNode", inEdges = v185 }
	v15(v185, v186)
	local v187 = v182:getFuncs()
	local v188 = {  }
	for v189, v190 in _ENV["ipairs"](v187) do
		_ENV["table"]["insert"](v188, v190:getStartEdge())
	end
	return v184, v188
end