local v1 = _ENV["require"]("luaOps")
local v2 = {  }
local v3
v3 = function(v4)
	local v5, v6, v7 = v4["element"]:getConstant()
	if v5 then
		v4[ "tag" ] = v7
		v4[ "literal" ] = v6
	else
		v2[v4["tag"]](v4)
	end
end
_ENV["setmetatable"](v2, { __index = function(v8)
	return function(v9)
		local v10 = v9["tag"]
		if (v1["binops"][v10] or v1["cmpops"][v10]) then
			v3(v9["lhs"])
			v3(v9["rhs"])
		else
			if v1["unops"][v10] then
				v3(v9["exp"])
			else
				_ENV["error"](("Tag for prepare exp not implemented " .. v10))
			end
		end
	end
end })
v2[ "and" ] = function(v11)
	local v12, v13 = v11["lhs"], v11["rhs"]
	v3(v12)
	local v14, v15 = v12["element"]:test()
	if v14 then
		if (not v15) then
			for v16, v17 in _ENV["pairs"](v12) do
				v11[ v16 ] = v17
			end
			return
		end
	else
		v3(v13)
	end
end
v2[ "or" ] = function(v18)
	local v19, v20 = v18["lhs"], v18["rhs"]
	v3(v19)
	local v21, v22 = v19["element"]:test()
	if v21 then
		if v22 then
			for v23, v24 in _ENV["pairs"](v19) do
				v18[ v23 ] = v24
			end
			return
		end
	else
		v3(v20)
	end
end
v2[ "VarExp" ] = function()
end
v2[ "IndexationExp" ] = function(v25)
	v3(v25["exp"])
	v3(v25["index"])
end
v2[ "FunctionCall" ] = function(v26)
	v3(v26["func"])
	for v27, v28 in _ENV["ipairs"](v26["args"]) do
		v3(v28)
	end
end
v2[ "MethodCall" ] = function(v29)
	v3(v29["receiver"])
	for v30, v31 in _ENV["ipairs"](v29["args"]) do
		v3(v31)
	end
end
v2[ "TableConstructor" ] = function(v32)
	local v33 = v32["fields"]
	for v34, v35 in _ENV["ipairs"](v33) do
		v3(v35["value"])
		if (v35["tag"] == "ExpAssign") then
			v3(v35["exp"])
		end
	end
end
v2[ "AnonymousFunction" ] = function()
end
v2[ "Vararg" ] = function()
end
local v36 = {  }
local v37
v37 = function(v38)
	if v38:isExecutable() then
		local v39 = v38:getToNode()
		if (v39 and (not v39["visited"])) then
			v39[ "visited" ] = true
			return v36[v39["tag"]](v39)
		end
	end
end
local v40
v40 = function(v41)
	local v42 = v41["exps"]
	for v43, v44 in _ENV["ipairs"](v42) do
		v3(v44)
	end
	v37(v41["outEdge"])
end
v36[ "Assign" ] = function(v45)
	v40(v45)
end
v36[ "LocalAssign" ] = function(v46)
	v40(v46)
end
v36[ "IfStatement" ] = function(v47)
	local v48 = v47["condition"]
	v3(v48)
	local v49 = v48["element"]
	local v50, v51 = v49:test()
	if v50 then
		if v51 then
			local v52 = v47["thenBody"]
			v47[ "tag" ] = "Do"
			v47[ "body" ] = v52
			v37(v47["thenEdge"])
		else
			local v53 = v47["elseBody"]
			if v53 then
				v47[ "tag" ] = "Do"
				v47[ "body" ] = v53
				v37(v47["elseEdge"])
			else
				v47[ "tag" ] = "Nop"
			end
		end
	else
		v37(v47["thenEdge"])
		v37(v47["elseEdge"])
	end
end
v36[ "GenericFor" ] = function(v54)
	local v55 = v54["exps"]
	for v56, v57 in _ENV["ipairs"](v55) do
		v3(v57)
	end
	v37(v54["loopEdge"])
	v37(v54["continueEdge"])
end
v36[ "NumericFor" ] = function(v58)
	local v59, v60, v61 = v58["init"], v58["limit"], v58["step"]
	v3(v59)
	v3(v60)
	if v61 then
		v3(v61)
	end
	v37(v58["loopEdge"])
	v37(v58["continueEdge"])
end
v36[ "While" ] = function(v62)
	local v63 = v62["condition"]
	v3(v63)
	local v64 = v63["element"]
	local v65, v66 = v64:test()
	if v65 then
		if v66 then
			return v37(v62["trueEdge"])
		else
			v62[ "tag" ] = "Nop"
			return v37(v62["falseEdge"])
		end
	else
		v37(v62["trueEdge"])
		v37(v62["falseEdge"])
	end
end
v36[ "Repeat" ] = function(v67)
	local v68 = v67["condition"]
	v3(v68)
	local v69 = v68["element"]
	local v70, v71 = v69:test()
	if v70 then
		if v71 then
			v67[ "tag" ] = "Do"
			return v37(v67["continueEdge"])
		else
		end
	else
		v37(v67["continueEdge"])
		v37(v67["repeatEdge"])
	end
end
v36[ "FunctionCallStat" ] = function(v72)
	local v73, v74 = v72["func"], v72["args"]
	v3(v73)
	for v75, v76 in _ENV["ipairs"](v74) do
		v3(v76)
	end
	v37(v72["outEdge"])
end
v36[ "MethodCallStat" ] = function(v77)
	local v78, v79 = v77["receiver"], v77["args"]
	v3(v78)
	for v80, v81 in _ENV["ipairs"](v79) do
		v3(v81)
	end
	v37(v77["outEdge"])
end
v36[ "Break" ] = function(v82)
	v37(v82["outEdge"])
end
v36[ "Return" ] = function(v83)
	local v84 = v83["exps"]
	if v84 then
		for v85, v86 in _ENV["ipairs"](v84) do
			v3(v86)
		end
	end
end
v36[ "EndNode" ] = function()
end
local v87
v87 = function(v88, v89)
	v37(v88)
	for v90, v91 in _ENV["ipairs"](v89) do
		v37(v91)
	end
end
return v87