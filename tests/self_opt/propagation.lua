local v1 = _ENV["require"]("luaOps")
local v2 = {  }
local v3
v3 = function(v4)
	local v5, v6, v7 = v4["element"]:getConstant()
	if v5 then
		v4[ "tag" ] = v7
		v4[ "literal" ] = v6
	else
	end
end
_ENV["setmetatable"](v2, { __index = function(v8)
	return function(v9)
		local v10 = v9["tag"]
		if (v1["binops"][v10]orv1["cmpops"][v10]) then
			v3(v9["lhs"])
			v3(v9["rhs"])
		else
			if v1["unops"][v10] then
				v3(v9["exp"])
			else
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
		if (v35["tag"]=="ExpAssign") then
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
		if (v39and(not v39["visited"])) then
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
		local v52
		local v53
		if v51 then
			v52 = v47["thenEdge"]
			v53 = v47["thenBody"]
		else
		end
		v47[ "tag" ] = "Do"
		v47[ "body" ] = v53
		v37(v52)
	else
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
v36[ "While" ] = function(v58)
	local v59 = v58["condition"]
	v3(v59)
	local v60 = v59["element"]
	local v61, v62 = v60:test()
	if v61 then
		if v62 then
			return v37(v58["trueEdge"])
		else
		end
	else
	end
end
v36[ "Repeat" ] = function(v63)
	local v64 = v63["condition"]
	v3(v64)
	local v65 = v64["element"]
	local v66, v67 = v65:test()
	if v66 then
		if v67 then
			v63[ "tag" ] = "Do"
			return v37(v63["continueEdge"])
		else
		end
	else
	end
end
v36[ "FunctionCallStat" ] = function(v68)
	local v69, v70 = v68["func"], v68["args"]
	v3(v69)
	for v71, v72 in _ENV["ipairs"](v70) do
		v3(v72)
	end
	v37(v68["outEdge"])
end
v36[ "MethodCallStat" ] = function(v73)
	local v74, v75 = v73["receiver"], v73["args"]
	v3(v74)
	for v76, v77 in _ENV["ipairs"](v75) do
		v3(v77)
	end
	v37(v73["outEdge"])
end
v36[ "Break" ] = function(v78)
	v37(v78["outEdge"])
end
v36[ "Return" ] = function(v79)
	local v80 = v79["exps"]
	if v80 then
		for v81, v82 in _ENV["ipairs"](v80) do
			v3(v82)
		end
	end
end
v36[ "EndNode" ] = function()
end
local v83
v83 = function(v84, v85)
	v37(v84)
	for v86, v87 in _ENV["ipairs"](v85) do
		v37(v87)
	end
end
return v83