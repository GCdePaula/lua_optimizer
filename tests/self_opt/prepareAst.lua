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
		v10[ "tag" ] = "Indexation"
		v10[ "index" ] = { tag = "StringLiteral", literal = v10["name"] }
		v10[ "exp" ] = { tag = "VarExp", name = "_ENV" }
	end
end
local v12
v12 = function(v13, v14)
	if v14 then
		v13[ "name" ] = v14
	else
		v13[ "tag" ] = "IndexationExp"
		v13[ "index" ] = { tag = "StringLiteral", literal = v13["name"] }
		v13[ "exp" ] = { tag = "VarExp", name = "_ENV" }
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
		if ((v1["binops"][v48] or v1["cmpops"][v48]) or v1["logbinops"][v48]) then
			v35(v46["lhs"], v47)
			v35(v46["rhs"], v47)
		else
			if v1["unops"][v48] then
				v35(v46["exp"], v47)
			else
				if ((((v48 == "StringLiteral") or (v48 == "NumberLiteral")) or (v48 == "BoolLiteral")) or (v48 == "Nil")) then
				else
					_ENV["error"](("Tag for prepare exp not implemented " .. v48))
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
		if (v68["tag"] == "ExpAssign") then
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
		if (v76["tag"] == "LocalVar") then
			local v77 = v72:newLocalVar(v76["name"])
			v74[v75][ "name" ] = v77
		else
			v70:addVararg()
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
v29[ "NumericFor" ] = function(v103, v104, v105, v106)
	local v107, v108, v109, v110, v111 = v103["var"], v103["init"], v103["limit"], v103["step"], v103["body"]
	local v112 = v105:startBlock()
	v106:startLoop()
	v35(v108, v105)
	v35(v109, v105)
	if v110 then
		v35(v109, v105)
	end
	v103[ "inCell" ] = v105:newLatticeCell()
	local v113 = v105:newLocalVar(v107["name"])
	v9(v107, v113)
	v103[ "outCell" ] = v105:newLatticeCell()
	local v114, v115 = v2:InitWithFromNode(v103), v2:InitWithFromNode(v103)
	v103[ "loopEdge" ] = v114
	v103[ "continueEdge" ] = v115
	local v116 = v38(v111["statements"], { v114 }, v105, v106)
	v4(v104, v116)
	v15(v104, v103)
	v103[ "inEdges" ] = v104
	local v117 = v106:endLoop()
	_ENV["table"]["insert"](v117, v115)
	v105:endBlock(v112)
	return v117
end
v29[ "While" ] = function(v118, v119, v120, v121)
	local v122, v123 = v118["condition"], v118["body"]
	v121:startLoop()
	v35(v122, v120)
	v118[ "inCell" ] = v120:newLatticeCell()
	v118[ "outCell" ] = v120:newLatticeCell()
	local v124, v125 = v2:InitWithFromNode(v118), v2:InitWithFromNode(v118)
	v118[ "trueEdge" ] = v124
	v118[ "falseEdge" ] = v125
	local v126 = v30(v123, { v124 }, v120, v121)
	v4(v119, v126)
	v15(v119, v118)
	v118[ "inEdges" ] = v119
	local v127 = v121:endLoop()
	_ENV["table"]["insert"](v127, v125)
	return v127
end
v29[ "Repeat" ] = function(v128, v129, v130, v131)
	local v132, v133 = v128["condition"], v128["body"]
	v131:startLoop()
	v35(v132, v130)
	v128[ "inCell" ] = v130:newLatticeCell()
	v128[ "outCell" ] = v130:newLatticeCell()
	local v134, v135 = v2:InitWithFromNode(v128), v2:InitWithFromNode(v128)
	v128[ "repeatEdge" ] = v134
	v128[ "continueEdge" ] = v135
	_ENV["table"]["insert"](v129, v134)
	local v136 = v30(v133, v129, v130, v131)
	v15(v136, v128)
	v128[ "inEdges" ] = v136
	local v137 = v131:endLoop()
	_ENV["table"]["insert"](v137, v135)
	return v137
end
v29[ "IfStatement" ] = function(v138, v139, v140, v141)
	local v142, v143, v144 = v138["condition"], v138["thenBody"], v138["elseBody"]
	v15(v139, v138)
	v138[ "inEdges" ] = v139
	v35(v142, v140)
	v138[ "inCell" ] = v140:newLatticeCell()
	v138[ "outCell" ] = v140:newLatticeCell()
	local v145, v146 = v2:InitWithFromNode(v138), v2:InitWithFromNode(v138)
	v138[ "thenEdge" ], v138[ "elseEdge" ] = v145, v146
	local v147 = v30(v143, { v145 }, v140, v141)
	if v144 then
		local v148 = v30(v144, { v146 }, v140, v141)
		v4(v147, v148)
	else
		_ENV["table"]["insert"](v147, v146)
	end
	return v147
end
v29[ "LocalAssign" ] = function(v149, v150, v151)
	v15(v150, v149)
	v149[ "inEdges" ] = v150
	local v152 = v2:InitWithFromNode(v149)
	v149[ "outEdge" ] = v152
	for v153, v154 in _ENV["ipairs"](v149["exps"]) do
		v35(v154, v151)
	end
	v149[ "inCell" ] = v151:newLatticeCell()
	for v155, v156 in _ENV["ipairs"](v149["vars"]) do
		local v157 = v151:newLocalVar(v156["name"])
		v9(v156, v157)
	end
	v149[ "outCell" ] = v151:newLatticeCell()
	return { v152 }
end
v29[ "Assign" ] = function(v158, v159, v160)
	v15(v159, v158)
	v158[ "inEdges" ] = v159
	local v161 = v2:InitWithFromNode(v158)
	v158[ "outEdge" ] = v161
	for v162, v163 in _ENV["ipairs"](v158["vars"]) do
		if (v163["tag"] == "Var") then
			local v164 = v160:getVar(v163["name"])
			v9(v163, v164)
		else
			local v165 = v163["index"]
			local v166 = v163["exp"]
			v35(v165, v160)
			v35(v166, v160)
		end
	end
	for v167, v168 in _ENV["ipairs"](v158["exps"]) do
		v35(v168, v160)
	end
	v158[ "inCell" ] = v160:newLatticeCell()
	v158[ "outCell" ] = v160:newLatticeCell()
	return { v161 }
end
local v169
v169 = function(v170, v171, v172, v173)
	v15(v171, v170)
	v170[ "inEdges" ] = v171
	v35(v173, v172)
	for v174, v175 in _ENV["ipairs"](v170["args"]) do
		v35(v175, v172)
	end
	v170[ "inCell" ] = v172:newLatticeCell()
	v170[ "outCell" ] = v172:newLatticeCell()
	local v176 = v2:InitWithFromNode(v170)
	v170[ "outEdge" ] = v176
	return { v176 }
end
v29[ "FunctionCallStat" ] = function(v177, v178, v179)
	return v169(v177, v178, v179, v177["func"])
end
v29[ "MethodCallStat" ] = function(v180, v181, v182)
	return v169(v180, v181, v182, v180["receiver"])
end
v29[ "Break" ] = function(v183, v184, v185, v186)
	v15(v184, v183)
	v183[ "inEdges" ] = v184
	v183[ "inCell" ] = v185:newLatticeCell()
	local v187 = v2:InitWithFromNode(v183)
	v183[ "outEdge" ] = v187
	v186:pushBreakEdge(v187)
	return {  }
end
v29[ "Return" ] = function(v188, v189, v190)
	v15(v189, v188)
	v188[ "inEdges" ] = v189
	v188[ "inCell" ] = v190:newLatticeCell()
	local v191 = v188["exps"]
	if v191 then
		for v192, v193 in _ENV["ipairs"](v191) do
			v35(v193, v190)
		end
	end
	v188[ "outEdge" ] = false
	return {  }
end
v29[ "Nop" ] = function(v194, v195)
	return v195
end
return function(v196)
	local v197 = v3:Init()
	local v198 = v20()
	local v199 = v2:InitStartEdge()
	local v200 = v38(v196["statements"], { v199 }, v197, v198)
	local v201 = { tag = "EndNode", inEdges = v200 }
	v15(v200, v201)
	local v202 = v197:getFuncs()
	local v203 = {  }
	for v204, v205 in _ENV["ipairs"](v202) do
		_ENV["table"]["insert"](v203, v205:getStartEdge())
	end
	return v199, v203
end