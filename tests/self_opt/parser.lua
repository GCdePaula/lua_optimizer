_ENV["package"][ "path" ] = (_ENV["package"]["path"] .. ";./libs/?.lua")
_ENV["package"][ "cpath" ] = ("./libs/?/?.so;" .. _ENV["package"]["cpath"])
local v1 = _ENV["require"]("lpeg")
local v2, v3, v4, v5 = v1["S"], v1["R"], v1["P"], v1["V"]
local v6, v7, v8, v9, v10, v11, v12 = v1["C"], v1["Cc"], v1["Cg"], v1["Cf"], v1["Ct"], v1["Cmt"], v1["Cs"]
local v13
v13 = function()
	local v14 = v3("az", "AZ")
	local v15 = (v3("az", "AZ", "09") + v4("_"))
	local v16 = v3("09")
	local v17 = v3("09", "af", "AF")
	local v18 = (v16 ^ 1)
	local v19 = ((v4("0") * v2("xX")) * (v17 ^ 1))
	local v20 = (v18 + v19)
	local v21 = ((v4(".") * v18) + ((v18 * v4(".")) * (v16 ^ 0)))
	local v22 = ((v4(".") * v19) + ((v19 * v4(".")) * (v17 ^ 0)))
	local v23 = ((v2("Ee") * (v2("+-") ^ -1)) * v18)
	local v24 = ((v2("Pp") * (v2("+-") ^ -1)) * v18)
	local v25 = ((v21 * (v23 ^ -1)) + (v18 * v23))
	local v26 = ((v22 * (v24 ^ -1)) + (v19 * v24))
	local v27 = (v25 + v26)
	local v28 = ((((((((((((v4("a") / "\7") + (v4("b") / "\8")) + (v4("f") / "\12")) + (v4("n") / "\
")) + (v4("r") / "\13")) + (v4("t") / "\9")) + (v4("v") / "\11")) + (v4("n") / "\
")) + (v4("r") / "\
")) + (v4("\\") / "\\")) + (v4("\"") / "\"")) + (v4("'") / "'"))
	local v29 = ((v4("x") * v17) * v17)
	local v30 = (v16 * (v16 ^ -2))
	local v31 = ((((v4("u") * v4("{")) * v17) * (v17 ^ -2)) * v4("}"))
	local v32 = ((v4("\\") / "") * (((v28 + v29) + v30) + v31))
	local v33 = (v32 + v4(1))
	local v34 = (((v4("'") * v12(((v33 - v4("'")) ^ 0))) * v4("'")) + ((v4("\"") * v12(((v33 - v4("\"")) ^ 0))) * v4("\"")))
	local v41 = v11((((v4("[") * v6((v4("=") ^ 0))) * v4("[")) * (v4("\
") ^ -1)), function(v35, v36, v37)
		local v38, v39 = _ENV["string"]["find"](v35, _ENV["string"]["format"]("]%s]", v37), v36, true)
		local v40 = _ENV["string"]["sub"](v35, v36, (v38 - 1))
		return (v39 + 1), v40
	end)
	local v47 = v11((((v4("[") * v6((v4("=") ^ 0))) * v4("[")) * (v4("\
") ^ -1)), function(v42, v43, v44)
		local v45, v46 = _ENV["string"]["find"](v42, _ENV["string"]["format"]("]%s]", v44), v43, true)
		return (v46 + 1)
	end)
	local v48 = (v4("--") * ((1 - v2("\13\
\12")) ^ 0))
	local v49 = (v4("--") * v47)
	local v50 = (v49 + v48)
	local v51 = v2(" \
\9\13")
	local v52 = ((v51 + v50) ^ 0)
	local v53
	v53 = function(v54)
		return (v54 * v52)
	end
	local v55
	v55 = function(v56)
		return v53(v4(v56))
	end
	local v57 = v55(":")
	local v58 = v55(";")
	local v59 = v55("::")
	local v60 = v55(",")
	local v61 = v55(".")
	local v62 = v55("(")
	local v63 = v55(")")
	local v64 = v55("[")
	local v65 = v55("]")
	local v66 = v55("{")
	local v67 = v55("}")
	local v68 = v55("...")
	local v69 = v55("=")
	local v70 = (v60 + v58)
	local v71 = v55("<")
	local v72 = v55(">")
	local v73 = v53(v6("^"))
	local v74 = v53((((v6("not") + v6("#")) + (v4("-") / "u-")) + (v4("~") / "u~")))
	local v75 = v53(v6((v4("//") + v2("*/%"))))
	local v76 = v53(v6(v2("+-")))
	local v77 = v53(v6(".."))
	local v78 = v53((v6("<<") + v6(">>")))
	local v79 = v53(v6("&"))
	local v80 = v53(v6("~"))
	local v81 = v53(v6("|"))
	local v82 = v53((((((v6("<=") + v6(">=")) + v6("<")) + v6(">")) + v6("~=")) + v6("==")))
	local v83 = v53(v6("and"))
	local v84 = v53(v6("or"))
	local v85
	v85 = function(v86)
		return ((v4(v86) * (-v15)) * v52)
	end
	local v87 = v85("break")
	local v88 = v85("do")
	local v89 = v85("else")
	local v90 = v85("elseif")
	local v91 = v85("end")
	local v92 = v85("for")
	local v93 = v85("function")
	local v94 = v85("goto")
	local v95 = v85("if")
	local v96 = v85("in")
	local v97 = v85("local")
	local v98 = v85("repeat")
	local v99 = v85("return")
	local v100 = v85("then")
	local v101 = v85("until")
	local v102 = v85("while")
	local v103 = { [ "and" ] = true, [ "break" ] = true, [ "do" ] = true, [ "else" ] = true, [ "elseif" ] = true, [ "end" ] = true, [ "false" ] = true, [ "for" ] = true, [ "function" ] = true, [ "goto" ] = true, [ "if" ] = true, [ "in" ] = true, [ "local" ] = true, [ "nil" ] = true, [ "not" ] = true, [ "or" ] = true, [ "repeat" ] = true, [ "return" ] = true, [ "then" ] = true, [ "true" ] = true, [ "until" ] = true, [ "while" ] = true }
	local v104
	v104 = function(v105, v106)
		return v8(v106, v105)
	end
	local v107
	v107 = function(v108, v109)
		return v10((v109 * v8(v7(v108), "tag")))
	end
	local v110
	v110 = function(v111, v112, v113)
		return v9((v111 * (v8((v112 * v113)) ^ 0)), function(v114, v115, v116)
			return { tag = v115, lhs = v114, rhs = v116 }
		end)
	end
	local v117
	v117 = function(v118, v119)
		if (v119["tag"] == "FunctionCall") then
			v119[ "func" ] = v118
		else
			if (v119["tag"] == "MethodCall") then
				v119[ "receiver" ] = v118
			else
				v119[ "exp" ] = v118
			end
		end
		return v119
	end
	local v120
	v120 = function(v121, v122)
		return (v121 + v7(v122))
	end
	local v123
	v123 = function(v124, v125)
		v125[ "tag" ] = "AnonymousFunction"
		return { tag = "LocalAssign", vars = { { tag = "LocalVar", name = v124, attribute = false } }, exps = {  } }, { tag = "Assign", vars = { { tag = "Var", name = v124 } }, exps = { v125 } }
	end
	local v126
	v126 = function(v127, v128)
		if (v127["tag"] == "MethodDef") then
			_ENV["table"]["insert"](v128["params"], 1, { name = "self", tag = "LocalVar" })
			v127[ "tag" ] = "Indexation"
		end
		return { tag = "Assign", vars = { v127 }, exps = { v128 } }
	end
	local v129
	v129 = function(v130, v131)
		if (v130["tag"] == "Var") then
			v130[ "tag" ] = "VarExp"
		else
			if (v130["tag"] == "Indexation") then
				v130[ "tag" ] = "IndexationExp"
			end
		end
		return { tag = "Indexation", index = v131, exp = v130 }
	end
	local v132
	v132 = function(v133, ...)
		if (not v133) then
			return false
		else
			local v134 = v132(...)
			if v134 then
				if (v134["tag"] == "IfStatement") then
					local v135 = { tag = "Block" }
					v135[ "statements" ] = { head = v134, tail = {  } }
					v133[ "elseBody" ] = v135
				else
					v133[ "elseBody" ] = v134
				end
			else
				v133[ "elseBody" ] = false
			end
			return v133
		end
	end
	local v136
	v136 = function(v137, ...)
		if ((not v137) or (v137 == "")) then
			return {  }
		else
			return { head = v137, tail = v136(...) }
		end
	end
	local v138 = { "Chunk" }
	v138[ "LiteralString" ] = v53(v107("StringLiteral", v104("literal", (v34 + v41))))
	v138[ "Name" ] = v53(v11(((v14 + v4("_")) * (v15 ^ 0)), function(v139, v140, v141)
		return (not v103[v141]), v141
	end))
	v138[ "FloatNumeral" ] = v107("NumberLiteral", v104("literal", (v53(v6(v27)) / _ENV["tonumber"])))
	v138[ "IntegerNumeral" ] = v107("NumberLiteral", v104("literal", (v53(v6(v20)) / _ENV["tonumber"])))
	v138[ "Numeral" ] = (v5("FloatNumeral") + v5("IntegerNumeral"))
	v138[ "True" ] = v107("BoolLiteral", v104("literal", (v7(true) * v85("true"))))
	v138[ "False" ] = v107("BoolLiteral", v104("literal", (v7(false) * v85("false"))))
	v138[ "Nil" ] = v107("Nil", v85("nil"))
	v138[ "Ellipsis" ] = v107("Vararg", v68)
	v138[ "Chunk" ] = (v52 * v5("Block"))
	v138[ "Block" ] = v107("Block", v104("statements", (v8(((v5("Stat") ^ 0) * (v5("ReturnStat") ^ -1))) / v136)))
	v138[ "Stat" ] = ((((((((((((((v107("Nop", v58) + v107("LocalAssign", ((v97 * v104("vars", v10(v5("LocalVarList")))) * v104("exps", v10(((v69 * v5("ExpList")) ^ -1)))))) + v107("Assign", ((v104("vars", v5("VarList")) * v69) * v104("exps", v10(v5("ExpList")))))) + ((((v97 * v93) * v5("Name")) * v5("AnonymousFunction")) / v123)) + (((v93 * v5("FunctionName")) * v5("AnonymousFunction")) / v126)) + v5("FunctionCallStat")) + v107("Goto", (v94 * v104("label", v5("Name"))))) + v107("Break", v87)) + v107("Label", v104("label", v5("Label")))) + v107("Do", ((v88 * v104("body", v5("Block"))) * v91))) + v107("While", ((((v102 * v104("condition", v5("Exp"))) * v88) * v104("body", v5("Block"))) * v91))) + v107("Repeat", (((v98 * v104("body", v5("Block"))) * v101) * v104("condition", v5("Exp"))))) + v107("NumericFor", (((((((((v92 * v104("var", v5("Name"))) * v69) * v104("init", v5("Exp"))) * v60) * v104("limit", v5("Exp"))) * v104("step", v120((v60 * v5("Exp")), false))) * v88) * v104("body", v5("Block"))) * v91))) + v107("GenericFor", ((((((v92 * v104("vars", v10(v5("NameList")))) * v96) * v104("exps", v10(v5("ExpList")))) * v88) * v104("body", v5("Block"))) * v91))) + v5("IfStatement"))
	v138[ "ReturnStat" ] = v107("Return", ((v99 * v104("exps", v120(v10(v5("ExpList")), false))) * (v58 ^ -1)))
	v138[ "Label" ] = ((v59 * v5("Name")) * v59)
	v138[ "WrappedName" ] = v107("LocalVar", v104("name", v5("Name")))
	v138[ "NameList" ] = (v5("WrappedName") * ((v60 * v5("WrappedName")) ^ 0))
	v138[ "LocalVarList" ] = (v5("LocalVar") * ((v60 * v5("LocalVar")) ^ 0))
	v138[ "LocalVar" ] = v107("LocalVar", (v104("name", v5("Name")) * v104("attribute", v5("Attrib"))))
	v138[ "Attrib" ] = v120(((v71 * (v6("const") + v6("close"))) * v72), false)
	v138[ "FunctionName" ] = (v5("FunctionNameWithMethod") + v5("FunctionWithIndex"))
	v138[ "FunctionWithIndex" ] = v9((v107("Var", v104("name", v5("Name"))) * ((v61 * v107("StringLiteral", v104("literal", v5("Name")))) ^ 0)), v129)
	v138[ "FunctionNameWithMethod" ] = v107("MethodDef", ((v104("exp", (v5("FunctionWithIndex") / function(v142)
		if (v142["tag"] == "Var") then
			v142[ "tag" ] = "VarExp"
		else
			if (v142["tag"] == "Indexation") then
				v142[ "tag" ] = "IndexationExp"
			end
		end
		return v142
	end)) * v57) * v104("index", v107("StringLiteral", v104("literal", v5("Name"))))))
	v138[ "IfStatement" ] = ((((v107("IfStatement", (((v95 * v104("condition", v5("Exp"))) * v100) * v104("thenBody", v5("Block")))) * (v107("IfStatement", (((v90 * v104("condition", v5("Exp"))) * v100) * v104("thenBody", v5("Block")))) ^ 0)) * v120(v8((v89 * v5("Block"))), false)) * v91) / v132)
	v138[ "VarList" ] = v10((v5("Var") * ((v60 * v5("Var")) ^ 0)))
	v138[ "Var" ] = ((v9((v5("ExpPrefix") * v5("VarSuffix")), v117) / function(v143)
		if (v143["tag"] == "IndexationExp") then
			v143[ "tag" ] = "Indexation"
		end
		return v143
	end) + v107("Var", v104("name", v5("Name"))))
	v138[ "VarSuffix" ] = (((v5("CallSuffix") ^ 0) * v5("Indexation")) * (v5("VarSuffix") ^ -1))
	v138[ "ExpList" ] = (v5("Exp") * ((v60 * v5("Exp")) ^ 0))
	v138[ "Exp" ] = v5("OrExp")
	v138[ "PrimaryExp" ] = (((((((v5("Nil") + v5("False")) + v5("True")) + v5("Ellipsis")) + v5("Numeral")) + v5("LiteralString")) + v5("TableConstructor")) + (v93 * v5("AnonymousFunction")))
	v138[ "PostfixedExp" ] = (v5("PrimaryExp") + v9((v5("ExpPrefix") * ((v5("Indexation") + v5("CallSuffix")) ^ 0)), v117))
	v138[ "PotExp" ] = v110(v5("PostfixedExp"), v73, v5("UnaryExp"))
	v138[ "UnaryExp" ] = (((v74 * v5("PotExp")) / function(v144, v145)
		return { tag = v144, exp = v145 }
	end) + v5("PotExp"))
	v138[ "MulExp" ] = v110(v5("UnaryExp"), v75, v5("UnaryExp"))
	v138[ "AddExp" ] = v110(v5("MulExp"), v76, v5("MulExp"))
	v138[ "ConcatExp" ] = v110(v5("AddExp"), v77, v5("AddExp"))
	v138[ "BitshiftExp" ] = v110(v5("ConcatExp"), v78, v5("ConcatExp"))
	v138[ "BitandExp" ] = v110(v5("BitshiftExp"), v79, v5("BitshiftExp"))
	v138[ "BitxorExp" ] = v110(v5("BitandExp"), v80, v5("BitandExp"))
	v138[ "BitorExp" ] = v110(v5("BitxorExp"), v81, v5("BitxorExp"))
	v138[ "ComparisonExp" ] = ((((v5("BitorExp") * v82) * v5("BitorExp")) / function(v146, v147, v148)
		return { tag = v147, lhs = v146, rhs = v148 }
	end) + v5("BitorExp"))
	v138[ "AndExp" ] = v110(v5("ComparisonExp"), v83, v5("ComparisonExp"))
	v138[ "OrExp" ] = v110(v5("AndExp"), v84, v5("AndExp"))
	v138[ "ExpPrefix" ] = (v107("VarExp", v104("name", v5("Name"))) + ((v62 * v5("Exp")) * v63))
	v138[ "Indexation" ] = ((v61 * v107("IndexationExp", v104("index", v107("StringLiteral", v104("literal", v5("Name")))))) + ((v64 * v107("IndexationExp", v104("index", v5("Exp")))) * v65))
	v138[ "CallSuffix" ] = (v107("FunctionCall", v104("args", v5("Args"))) + v107("MethodCall", ((v57 * v104("method", v5("Name"))) * v104("args", v5("Args")))))
	v138[ "Args" ] = ((((v62 * v10((v5("ExpList") ^ -1))) * v63) + v10(v5("TableConstructor"))) + v10(v5("LiteralString")))
	v138[ "AnonymousFunction" ] = v107("AnonymousFunction", ((((v62 * v104("params", v10((v5("Parameters") ^ -1)))) * v63) * v104("body", v5("Block"))) * v91))
	v138[ "Parameters" ] = (v5("Ellipsis") + (v5("NameList") * ((v60 * v5("Ellipsis")) ^ -1)))
	v138[ "TableConstructor" ] = v107("TableConstructor", ((v66 * v104("fields", (v5("FieldList") ^ -1))) * v67))
	v138[ "FieldList" ] = v10(((v5("Field") * ((v70 * v5("Field")) ^ 0)) * (v70 ^ -1)))
	v138[ "Field" ] = ((v107("ExpAssign", ((((v64 * v104("exp", v5("Exp"))) * v65) * v69) * v104("value", v5("Exp")))) + v107("NameAssign", ((v104("name", v5("Name")) * v69) * v104("value", v5("Exp"))))) + v107("Exp", v104("value", v5("Exp"))))
	v138[ "FunctionCallStat" ] = (v9((v5("ExpPrefix") * v5("CallStatSuffix")), v117) / function(v149)
		if (v149["tag"] == "FunctionCall") then
			v149[ "tag" ] = "FunctionCallStat"
		else
			v149[ "tag" ] = "MethodCallStat"
		end
		return v149
	end)
	v138[ "CallStatSuffix" ] = (((v5("Indexation") ^ 0) * v5("CallSuffix")) * (v5("CallStatSuffix") ^ -1))
	return (v1["P"](v138) * -1)
end
local v150 = v13()
local v151
v151 = function(v152, v153)
	local v154 = v1["match"](v4(v150), v152)
	if v154 then
		return v154
	else
		_ENV["print"](_ENV["string"]["format"]("Failed to parse '%s'", v152))
	end
end
return { parse = v151 }