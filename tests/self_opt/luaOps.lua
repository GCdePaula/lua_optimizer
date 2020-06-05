local v1 = { [ "^" ] = true, [ "*" ] = true, [ "/" ] = true, [ "//" ] = true, [ "%" ] = true, [ "+" ] = true, [ "-" ] = true, [ "<<" ] = true, [ ">>" ] = true, [ "&" ] = true, [ "~" ] = true, [ "|" ] = true, [ ".." ] = true }
local v2 = { [ "not" ] = true, [ "#" ] = true, [ "u-" ] = true, [ "u~" ] = true }
local v3 = { [ "and" ] = true, [ "or" ] = true }
local v4 = { [ "<" ] = true, [ "<=" ] = true, [ ">" ] = true, [ ">=" ] = true, [ "==" ] = true, [ "~=" ] = true }
local v5 = {  }
v5[ "^" ] = function(v6, v7)
	return (v6 ^ v7)
end
v5[ "*" ] = function(v8, v9)
	return (v8 * v9)
end
v5[ "/" ] = function(v10, v11)
	return (v10 / v11)
end
v5[ "//" ] = function(v12, v13)
	return (v12 // v13)
end
v5[ "%" ] = function(v14, v15)
	return (v14 % v15)
end
v5[ "+" ] = function(v16, v17)
	return (v16 + v17)
end
v5[ "-" ] = function(v18, v19)
	return (v18 - v19)
end
v5[ "<<" ] = function(v20, v21)
	return (v20 << v21)
end
v5[ ">>" ] = function(v22, v23)
	return (v22 >> v23)
end
v5[ "&" ] = function(v24, v25)
	return (v24 & v25)
end
v5[ "~" ] = function(v26, v27)
	return (v26 ~ v27)
end
v5[ "|" ] = function(v28, v29)
	return (v28 | v29)
end
v5[ "not" ] = function(v30)
	return (not v30)
end
v5[ "#" ] = function(v31)
	return (# v31)
end
v5[ "u-" ] = function(v32)
	return (-v32)
end
v5[ "u~" ] = function(v33)
	return (~v33)
end
v5[ "and" ] = function(v34, v35)
	return (v34 and v35)
end
v5[ "or" ] = function(v36, v37)
	return (v36 or v37)
end
v5[ "<" ] = function(v38, v39)
	return (v38 < v39)
end
v5[ "<=" ] = function(v40, v41)
	return (v40 <= v41)
end
v5[ ">" ] = function(v42, v43)
	return (v42 > v43)
end
v5[ ">=" ] = function(v44, v45)
	return (v44 >= v45)
end
v5[ "==" ] = function(v46, v47)
	return (v46 == v47)
end
v5[ "~=" ] = function(v48, v49)
	return (v48 ~= v49)
end
v5[ ".." ] = function(v50, v51)
	return (v50 .. v51)
end
local v52
v52 = function(v53, v54, v55)
	return v5[v53](v54, v55)
end
return { binops = v1, unops = v2, logbinops = v3, cmpops = v4, makeOp = v52 }