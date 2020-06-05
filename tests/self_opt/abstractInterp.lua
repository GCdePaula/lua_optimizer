local v1 = _ENV["require"]("lattice.element")
local v2 = _ENV["require"]("lattice.ops")
local v3 = _ENV["require"]("luaOps")
local v4
v4 = function()
	local v5 = { _edges = {  } }
	v5[ "addEdge" ] = function(v6, v7)
		v7:setExecutable()
		_ENV["table"]["insert"](v6["_edges"], v7)
	end
	v5[ "pop" ] = function(v8)
		return _ENV["table"]["remove"](v8["_edges"])
	end
	return v5
end
local v9 = {  }
local v10
v10 = function(v11, v12)
	return v9[v11["tag"]](v11, v12)
end
_ENV["setmetatable"](v9, { __index = function(v13)
	return function(v14, v15)
		local v16 = v14["tag"]
		if ((v3["binops"][v16] or v3["cmpops"][v16]) or v3["logbinops"][v16]) then
			local v17
			local v18
			if ((v16 == "^") or (v16 == "..")) then
				v17 = v10(v14["lhs"], v15)
				v18 = v10(v14["rhs"], v15)
			else
				v18 = v10(v14["rhs"], v15)
				v17 = v10(v14["lhs"], v15)
			end
			local v19 = v2[v16](v17, v18)
			v14[ "element" ] = v19
			return v19
		else
			if (v3["unops"][v16] or v3["unops"][v16]) then
				local v20 = v10(v14["exp"], v15)
				local v21 = v2[v16](v20)
				v14[ "element" ] = v21
				return v21
			else
				_ENV["error"](("Tag for prepare exp not implemented " .. v16))
			end
		end
	end
end })
v9[ "Nil" ] = function(v22, v23)
	local v24 = v1:InitWithNil()
	v22[ "element" ] = v24
	return v24
end
v9[ "StringLiteral" ] = function(v25, v26)
	local v27 = v1:InitWithString(v25["literal"])
	v25[ "element" ] = v27
	return v27
end
v9[ "NumberLiteral" ] = function(v28, v29)
	local v30 = v1:InitWithNumber(v28["literal"])
	v28[ "element" ] = v30
	return v30
end
v9[ "BoolLiteral" ] = function(v31, v32)
	local v33 = v1:InitWithBool(v31["literal"])
	v31[ "element" ] = v33
	return v33
end
v9[ "VarExp" ] = function(v34, v35)
	local v36 = v35:getVar(v34["name"])
	local v37 = v36:getElement()
	v34[ "element" ] = v37
	return v37
end
v9[ "IndexationExp" ] = function(v38, v39)
	v10(v38["exp"], v39)
	v10(v38["index"], v39)
	local v40 = v1:InitWithBottom()
	v38[ "element" ] = v40
	return v40
end
local v41
v41 = function(v42, v43, v44)
	v10(v44, v43)
	for v45, v46 in _ENV["ipairs"](v42["args"]) do
		v10(v46, v43)
	end
	local v47 = v1:InitWithBottom()
	v42[ "element" ] = v47
	return v47
end
v9[ "FunctionCall" ] = function(v48, v49)
	return v41(v48, v49, v48["func"])
end
v9[ "MethodCall" ] = function(v50, v51)
	return v41(v50, v51, v50["receiver"])
end
v9[ "TableConstructor" ] = function(v52, v53)
	local v54 = v52["fields"]
	for v55, v56 in _ENV["ipairs"](v54) do
		v10(v56["value"], v53)
		if (v56["tag"] == "ExpAssign") then
			v10(v56["exp"], v53)
		end
	end
	local v57 = v1:InitWithBottom()
	v52[ "element" ] = v57
	return v57
end
v9[ "AnonymousFunction" ] = function(v58, v59)
	local v60 = v1:InitWithFunc(v58["funcIndex"])
	v58[ "element" ] = v60
	return v60
end
v9[ "Vararg" ] = function(v61)
	local v62 = v1:InitWithBottom()
	v61[ "element" ] = v62
	return v62
end
local v63 = {  }
local v64
v64 = function(v65, v66)
	if (v65["tag"] == "EndNode") then
		return
	end
	local v67 = v65["inCell"]:updateWithInEdges(v65["inEdges"])
	if (v67 or (not v65["touched"])) then
		v65[ "touched" ] = true
		return v63[v65["tag"]](v65, v66)
	end
end
local v68
v68 = function(v69, v70)
	local v71 = false
	local v72, v73 = {  }, (# v69)
	for v74, v75 in _ENV["ipairs"](v69) do
		local v76 = v10(v75, v70)
		_ENV["table"]["insert"](v72, v76)
		if (v74 == v73) then
			local v77 = v75["tag"]
			if (((v77 == "FunctionCall") or (v77 == "MethodCall")) or (v77 == "Vararg")) then
				v71 = true
			end
		end
	end
	return v72, v71
end
v63[ "Assign" ] = function(v78, v79)
	local v80, v81 = v78["vars"], v78["exps"]
	local v82 = v78["inCell"]:copy()
	local v83, v84 = v68(v81, v82)
	for v85, v86 in _ENV["ipairs"](v80) do
		local v87 = v83[v85]
		if (v86["tag"] == "Var") then
			if v87 then
				v82:setElementToVar(v86["name"], v87)
			else
				if v84 then
					v82:setElementToVar(v86["name"], v1:InitWithBottom())
				else
					v82:setElementToVar(v86["name"], v1:InitWithNil())
				end
			end
		end
	end
	v78[ "outCell" ] = v82
	v79:addEdge(v78["outEdge"])
end
v63[ "LocalAssign" ] = function(v88, v89)
	local v90, v91 = v88["vars"], v88["exps"]
	local v92 = v88["inCell"]:copy()
	local v93, v94 = v68(v91, v92)
	for v95, v96 in _ENV["ipairs"](v90) do
		v92:addVar(v96["name"])
		local v97 = v93[v95]
		if v97 then
			v92:setElementToVar(v96["name"], v97)
		else
			if v94 then
				v92:setElementToVar(v96["name"], v1:InitWithBottom())
			else
				v92:setElementToVar(v96["name"], v1:InitWithNil())
			end
		end
	end
	v88[ "outCell" ] = v92
	v89:addEdge(v88["outEdge"])
end
v63[ "IfStatement" ] = function(v98, v99)
	local v100 = v98["condition"]
	local v101, v102 = v98["thenEdge"], v98["elseEdge"]
	local v103 = v98["inCell"]:copy()
	local v104 = v10(v100, v103)
	v98[ "outCell" ] = v103
	local v105, v106 = v104:test()
	if v105 then
		if v106 then
			v99:addEdge(v101)
		else
			v99:addEdge(v102)
		end
	else
		v99:addEdge(v101)
		v99:addEdge(v102)
	end
end
v63[ "GenericFor" ] = function(v107, v108)
	local v109, v110 = v107["vars"], v107["exps"]
	local v111, v112 = v107["loopEdge"], v107["continueEdge"]
	local v113 = v107["inCell"]:copy()
	for v114, v115 in _ENV["ipairs"](v110) do
		v10(v115, v113)
	end
	for v116, v117 in _ENV["ipairs"](v109) do
		v113:addVar(v117["name"])
		v113:setElementToVar(v117["name"], v1:InitWithBottom())
	end
	v107[ "outCell" ] = v113
	v108:addEdge(v111)
	v108:addEdge(v112)
end
v63[ "While" ] = function(v118, v119)
	local v120 = v118["condition"]
	local v121, v122 = v118["trueEdge"], v118["falseEdge"]
	local v123 = v118["inCell"]:copy()
	local v124 = v10(v120, v123)
	v118[ "outCell" ] = v123
	local v125, v126 = v124:test()
	if v125 then
		if v126 then
			v119:addEdge(v121)
		else
			v119:addEdge(v122)
		end
	else
		v119:addEdge(v121)
		v119:addEdge(v122)
	end
end
v63[ "Repeat" ] = function(v127, v128)
	local v129 = v127["condition"]
	local v130, v131 = v127["repeatEdge"], v127["continueEdge"]
	local v132 = v127["inCell"]:copy()
	local v133 = v10(v129, v132)
	v127[ "outCell" ] = v132
	local v134, v135 = v133:test()
	if v134 then
		if v135 then
			v128:addEdge(v131)
		else
			v128:addEdge(v130)
		end
	else
		v128:addEdge(v131)
		v128:addEdge(v130)
	end
end
local v136
v136 = function(v137, v138, v139)
	local v140 = v137["args"]
	local v141 = v137["inCell"]:copy()
	v10(v139, v141)
	for v142, v143 in _ENV["ipairs"](v140) do
		v10(v143, v141)
	end
	v137[ "outCell" ] = v141
	v138:addEdge(v137["outEdge"])
end
v63[ "FunctionCallStat" ] = function(v144, v145)
	v136(v144, v145, v144["func"])
end
v63[ "MethodCallStat" ] = function(v146, v147)
	v136(v146, v147, v146["receiver"])
end
v63[ "Break" ] = function(v148, v149)
	local v150 = v148["outEdge"]
	v149:addEdge(v150)
end
v63[ "Return" ] = function(v151)
	local v152 = v151["inCell"]:copy()
	local v153 = v151["exps"]
	if v153 then
		for v154, v155 in _ENV["ipairs"](v153) do
			v10(v155, v152)
		end
	end
	v151[ "outCell" ] = v152
end
v63[ "EndNode" ] = function()
end
v63[ "Block" ] = function()
	_ENV["error"]("process block!")
end
local v156
v156 = function(v157)
	local v158 = v4()
	local v159 = v157
	v157:setExecutable()
	repeat
		local v160 = v159:getToNode()
		v64(v160, v158)
		v159 = v158:pop()
	until (not v159)
end
return function(v161, v162)
	v156(v161)
	for v163, v164 in _ENV["ipairs"](v162) do
		local v165 = v164:getToNode()["inCell"]
		if v165 then
			v165:bottomAllVars()
			v156(v164)
		end
	end
end