local v1 = _ENV["require"]("lattice.element")
local v2 = {  }
v2[ "^" ] = function(v3, v4)
	local v5, v6 = v3:getNumber()
	local v7, v8 = v4:getNumber()
	if (v5 and v7) then
		return v1:InitWithNumber((v6 ^ v8))
	else
		return v1:InitWithBottom()
	end
end
v2[ ".." ] = function(v9, v10)
	local v11, v12 = v9:getString()
	local v13, v14 = v10:getString()
	if (v11 and v13) then
		return v1:InitWithString((v12 .. v14))
	else
		return v1:InitWithBottom()
	end
end
v2[ "*" ] = function(v15, v16)
	local v17, v18 = v15:getNumber()
	local v19, v20 = v16:getNumber()
	if (v17 and v19) then
		return v1:InitWithNumber((v18 * v20))
	else
		return v1:InitWithBottom()
	end
end
v2[ "/" ] = function(v21, v22)
	local v23, v24 = v21:getNumber()
	local v25, v26 = v22:getNumber()
	if (v23 and v25) then
		return v1:InitWithNumber((v24 / v26))
	else
		return v1:InitWithBottom()
	end
end
v2[ "//" ] = function(v27, v28)
	local v29, v30 = v27:getNumber()
	local v31, v32 = v28:getNumber()
	if (v29 and v31) then
		return v1:InitWithNumber((v30 // v32))
	else
		return v1:InitWithBottom()
	end
end
v2[ "%" ] = function(v33, v34)
	local v35, v36 = v33:getNumber()
	local v37, v38 = v34:getNumber()
	if (v35 and v37) then
		return v1:InitWithNumber((v36 % v38))
	else
		return v1:InitWithBottom()
	end
end
v2[ "+" ] = function(v39, v40)
	local v41, v42 = v39:getNumber()
	local v43, v44 = v40:getNumber()
	if (v41 and v43) then
		return v1:InitWithNumber((v42 + v44))
	else
		return v1:InitWithBottom()
	end
end
v2[ "-" ] = function(v45, v46)
	local v47, v48 = v45:getNumber()
	local v49, v50 = v46:getNumber()
	if (v47 and v49) then
		return v1:InitWithNumber((v48 - v50))
	else
		return v1:InitWithBottom()
	end
end
v2[ "<<" ] = function(v51, v52)
	local v53, v54 = v51:getNumber()
	local v55, v56 = v52:getNumber()
	if (v53 and v55) then
		return v1:InitWithNumber((v54 << v56))
	else
		return v1:InitWithBottom()
	end
end
v2[ ">>" ] = function(v57, v58)
	local v59, v60 = v57:getNumber()
	local v61, v62 = v58:getNumber()
	if (v59 and v61) then
		return v1:InitWithNumber((v60 >> v62))
	else
		return v1:InitWithBottom()
	end
end
v2[ "&" ] = function(v63, v64)
	local v65, v66 = v63:getNumber()
	local v67, v68 = v64:getNumber()
	if (v65 and v67) then
		return v1:InitWithNumber((v66 & v68))
	else
		return v1:InitWithBottom()
	end
end
v2[ "~" ] = function(v69, v70)
	local v71, v72 = v69:getNumber()
	local v73, v74 = v70:getNumber()
	if (v71 and v73) then
		return v1:InitWithNumber((v72 ~ v74))
	else
		return v1:InitWithBottom()
	end
end
v2[ "|" ] = function(v75, v76)
	local v77, v78 = v75:getNumber()
	local v79, v80 = v76:getNumber()
	if (v77 and v79) then
		return v1:InitWithNumber((v78 | v80))
	else
		return v1:InitWithBottom()
	end
end
v2[ "not" ] = function(v81)
	local v82 = v81:isNil()
	local v83, v84 = v81:getBool()
	if v82 then
		return v1:InitWithBool(true)
	else
		if v83 then
			return v1:InitWithBool((not v84))
		else
			if v81:isBottom() then
				return v1:InitWithBottom()
			else
				return v1:InitWithBool(false)
			end
		end
	end
end
v2[ "#" ] = function()
	return v1:InitWithBottom()
end
v2[ "u-" ] = function(v85)
	local v86, v87 = v85:getNumber()
	if v86 then
		return v1:InitWithNumber((-v87))
	else
		return v1:InitWithBottom()
	end
end
v2[ "u~" ] = function(v88)
	local v89, v90 = v88:getNumber()
	if v89 then
		return v1:InitWithNumber((~v90))
	else
		return v1:InitWithBottom()
	end
end
v2[ "and" ] = function(v91, v92)
	local v93, v94 = v91:test()
	if (not v93) then
		return v1:InitWithBottom()
	else
		if (not v94) then
			return v91:copy()
		else
			return v92:copy()
		end
	end
end
v2[ "or" ] = function(v95, v96)
	local v97, v98 = v95:test()
	if (not v97) then
		return v1:InitWithBottom()
	else
		if v98 then
			return v95:copy()
		else
			return v96:copy()
		end
	end
end
v2[ "<" ] = function(v99, v100)
	local v101, v102 = v99:getNumber()
	local v103, v104 = v100:getNumber()
	if (v101 and v103) then
		return v1:InitWithBool((v102 < v104))
	else
		return v1:InitWithBottom()
	end
end
v2[ "<=" ] = function(v105, v106)
	local v107, v108 = v105:getNumber()
	local v109, v110 = v106:getNumber()
	if (v107 and v109) then
		return v1:InitWithBool((v108 <= v110))
	else
		return v1:InitWithBottom()
	end
end
v2[ ">" ] = function(v111, v112)
	local v113, v114 = v111:getNumber()
	local v115, v116 = v112:getNumber()
	if (v113 and v115) then
		return v1:InitWithBool((v114 > v116))
	else
		return v1:InitWithBottom()
	end
end
v2[ ">=" ] = function(v117, v118)
	local v119, v120 = v117:getNumber()
	local v121, v122 = v118:getNumber()
	if (v119 and v121) then
		return v1:InitWithBool((v120 >= v122))
	else
		return v1:InitWithBottom()
	end
end
v2[ "==" ] = function(v123, v124)
	if (((v123:isBottom() or v124:isBottom()) or v123:isTop()) or v124:isTop()) then
		return v1:InitWithBottom()
	else
		return v1:InitWithBool(v123:compare(v124))
	end
end
v2[ "~=" ] = function(v125, v126)
	if (((v125:isBottom() or v126:isBottom()) or v125:isTop()) or v126:isTop()) then
		return v1:InitWithBottom()
	else
		return v1:InitWithBool((not v125:compare(v126)))
	end
end
return v2