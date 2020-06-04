local v1 = _ENV["require"]("lpeg")
local v2, v3, v4, v5 = v1["S"], v1["R"], v1["P"], v1["V"]
local v6, v7, v8, v9, v10, v11 = v1["C"], v1["Cc"], v1["Cg"], v1["Cf"], v1["Ct"], v1["Cmt"]
local v12
v12 = function()
	local v13 = v3("az", "AZ")
	local v14 = (v3("az", "AZ", "09")+v4("_"))
	local v15 = v3("09")
	local v16 = v3("09", "af", "AF")
	local v17 = (v15^1)
	local v18 = ((v4("0")*v2("xX"))*(v16^1))
	local v19 = (v17+v18)
	local v20 = ((v4(".")*v17)+((v17*v4("."))*(v15^0)))
	local v21 = ((v4(".")*v18)+((v18*v4("."))*(v16^0)))
	local v22 = ((v2("Ee")*(v2("+-")^-1))*v17)
	local v23 = ((v2("Pp")*(v2("+-")^-1))*v17)
	local v24 = ((v20*(v22^-1))+(v17*v22))
	local v25 = ((v21*(v23^-1))+(v18*v23))
	local v26 = (v24+v25)
	local v27 = v2("abfnrtv\\\\\\'\\\"")
	local v28 = ((v4("x")*v16)*v16)
	local v29 = (v15*(v15^-2))
	local v30 = ((((v4("u")*v4("{"))*v16)*(v16^-2))*v4("}"))
	local v31 = (v4("\\\\")*(((v27+v28)+v29)+v30))
	local v32 = (v31+v4(1))
	local v33 = (((v4("'")*v6(((v32-v4("'"))^0)))*v4("'"))+((v4("\"")*v6(((v32-v4("\""))^0)))*v4("\"")))
	local v40 = v11((((v4("[")*v6((v4("=")^0)))*v4("["))*(v4("\\n")^-1)), function(v34, v35, v36)
		local v37, v38 = _ENV["string"]["find"](v34, _ENV["string"]["format"]("]%s]", v36), v35, true)
		local v39 = _ENV["string"]["sub"](v34, v35, (v37-1))
		return (v38+1), v39
	end)
	local v46 = v11((((v4("[")*v6((v4("=")^0)))*v4("["))*(v4("\\n")^-1)), function(v41, v42, v43)
		local v44, v45 = _ENV["string"]["find"](v41, _ENV["string"]["format"]("]%s]", v43), v42, true)
		return (v45+1)
	end)
	local v47 = (v4("--")*((1-v2("\\r\\n\\f"))^0))
	local v48 = (v4("--")*v46)
	local v49 = (v48+v47)
	local v50 = v2(" \\n\\t\\r")
	local v51 = ((v50+v49)^0)
	local v52
	v52 = function(v53)
		return (v53*v51)
	end
	local v54
	v54 = function(v55)
		return v52(v4(v55))
	end
	local v56 = v54(":")
	local v57 = v54(";")
	local v58 = v54("::")
	local v59 = v54(",")
	local v60 = v54(".")
	local v61 = v54("(")
	local v62 = v54(")")
	local v63 = v54("[")
	local v64 = v54("]")
	local v65 = v54("{")
	local v66 = v54("}")
	local v67 = v54("...")
	local v68 = v54("=")
	local v69 = (v59+v57)
	local v70 = v54("<")
	local v71 = v54(">")
	local v72 = v52(v6("^"))
	local v73 = v52((((v6("not")+v6("#"))+(v4("-")/"u-"))+(v4("~")/"u~")))
	local v74 = v52(v6((v4("//")+v2("*/%"))))
	local v75 = v52(v6(v2("+-")))
	local v76 = v52(v6(".."))
	local v77 = v52((v6("<<")+v6(">>")))
	local v78 = v52(v6("&"))
	local v79 = v52(v6("~"))
	local v80 = v52(v6("|"))
	local v81 = v52((((((v6("<=")+v6(">="))+v6("<"))+v6(">"))+v6("~="))+v6("==")))
	local v82 = v52(v6("and"))
	local v83 = v52(v6("or"))
	local v84
	v84 = function(v85)
		return ((v4(v85)*(-v14))*v51)
	end
	local v86 = v84("break")
	local v87 = v84("do")
	local v88 = v84("else")
	local v89 = v84("elseif")
	local v90 = v84("end")
	local v91 = v84("for")
	local v92 = v84("function")
	local v93 = v84("goto")
	local v94 = v84("if")
	local v95 = v84("in")
	local v96 = v84("local")
	local v97 = v84("repeat")
	local v98 = v84("return")
	local v99 = v84("then")
	local v100 = v84("until")
	local v101 = v84("while")
	local v102 = { [ "and" ] = true, [ "break" ] = true, [ "do" ] = true, [ "else" ] = true, [ "elseif" ] = true, [ "end" ] = true, [ "false" ] = true, [ "for" ] = true, [ "function" ] = true, [ "goto" ] = true, [ "if" ] = true, [ "in" ] = true, [ "local" ] = true, [ "nil" ] = true, [ "not" ] = true, [ "or" ] = true, [ "repeat" ] = true, [ "return" ] = true, [ "then" ] = true, [ "true" ] = true, [ "until" ] = true, [ "while" ] = true }
	local v103
	v103 = function(v104, v105)
		return v8(v105, v104)
	end
	local v106
	v106 = function(v107, v108)
		return v10((v108*v8(v7(v107), "tag")))
	end
	local v109
	v109 = function(v110, v111, v112)
		return v9((v110*(v8((v111*v112))^0)), function(v113, v114, v115)
			return { tag = v114, lhs = v113, rhs = v115 }
		end)
	end
	local v116
	v116 = function(v117, v118)
		if (v118["tag"]=="FunctionCall") then
			v118[ "func" ] = v117
		else
			if (v118["tag"]=="MethodCall") then
				v118[ "receiver" ] = v117
			else
			end
		end
		return v118
	end
	local v119
	v119 = function(v120, v121)
		return (v120+v7(v121))
	end
	local v122
	v122 = function(v123, v124)
		v124[ "tag" ] = "AnonymousFunction"
		return { tag = "LocalAssign", vars = { { tag = "LocalVar", name = v123, attribute = false } }, exps = {  } }, { tag = "Assign", vars = { { tag = "Var", name = v123 } }, exps = { v124 } }
	end
	local v125
	v125 = function(v126, v127)
		if (v126["tag"]=="MethodDef") then
			_ENV["table"]["insert"](v127["params"], 1, { name = "self", tag = "LocalVar" })
			v126[ "tag" ] = "Indexation"
		end
		return { tag = "Assign", vars = { v126 }, exps = { v127 } }
	end
	local v128
	v128 = function(v129, v130)
		if (v129["tag"]=="Var") then
			v129[ "tag" ] = "VarExp"
		else
			if (v129["tag"]=="Indexation") then
				v129[ "tag" ] = "IndexationExp"
			end
		end
		return { tag = "Indexation", index = v130, exp = v129 }
	end
	local v131
	v131 = function(v132, ...)
		if (not v132) then
			return false
		else
		end
	end
	local v135
	v135 = function(v136, ...)
		if ((not v136)or(v136=="")) then
			return {  }
		else
		end
	end
	local v137 = { "Chunk" }
	v137[ "LiteralString" ] = v52(v106("StringLiteral", v103("literal", (v33+v40))))
	v137[ "Name" ] = v52(v11(((v13+v4("_"))*(v14^0)), function(v138, v139, v140)
		return (not v102[v140]), v140
	end))
	v137[ "FloatNumeral" ] = v106("NumberLiteral", v103("literal", (v52(v6(v26))/_ENV["tonumber"])))
	v137[ "IntegerNumeral" ] = v106("NumberLiteral", v103("literal", (v52(v6(v19))/_ENV["tonumber"])))
	v137[ "Numeral" ] = (v5("FloatNumeral")+v5("IntegerNumeral"))
	v137[ "True" ] = v106("BoolLiteral", v103("literal", (v7(true)*v84("true"))))
	v137[ "False" ] = v106("BoolLiteral", v103("literal", (v7(false)*v84("false"))))
	v137[ "Nil" ] = v106("Nil", v84("nil"))
	v137[ "Ellipsis" ] = v106("Vararg", v67)
	v137[ "Chunk" ] = (v51*v5("Block"))
	v137[ "Block" ] = v106("Block", v103("statements", (v8(((v5("Stat")^0)*(v5("ReturnStat")^-1)))/v135)))
	v137[ "Stat" ] = ((((((((((((((v106("Nop", v57)+v106("LocalAssign", ((v96*v103("vars", v10(v5("LocalVarList"))))*v103("exps", v10(((v68*v5("ExpList"))^-1))))))+v106("Assign", ((v103("vars", v5("VarList"))*v68)*v103("exps", v10(v5("ExpList"))))))+((((v96*v92)*v5("Name"))*v5("AnonymousFunction"))/v122))+(((v92*v5("FunctionName"))*v5("AnonymousFunction"))/v125))+v5("FunctionCallStat"))+v106("Goto", (v93*v103("label", v5("Name")))))+v106("Break", v86))+v106("Label", v103("label", v5("Label"))))+v106("Do", ((v87*v103("body", v5("Block")))*v90)))+v106("While", ((((v101*v103("condition", v5("Exp")))*v87)*v103("body", v5("Block")))*v90)))+v106("Repeat", (((v97*v103("body", v5("Block")))*v100)*v103("condition", v5("Exp")))))+v106("NumericFor", (((((((((v91*v103("var", v5("Name")))*v68)*v103("init", v5("Exp")))*v59)*v103("limit", v5("Exp")))*v103("step", v119((v59*v5("Exp")), false)))*v87)*v103("body", v5("Block")))*v90)))+v106("GenericFor", ((((((v91*v103("vars", v10(v5("NameList"))))*v95)*v103("exps", v10(v5("ExpList"))))*v87)*v103("body", v5("Block")))*v90)))+v5("IfStatement"))
	v137[ "ReturnStat" ] = v106("Return", ((v98*v103("exps", v119(v10(v5("ExpList")), false)))*(v57^-1)))
	v137[ "Label" ] = ((v58*v5("Name"))*v58)
	v137[ "WrappedName" ] = v106("LocalVar", v103("name", v5("Name")))
	v137[ "NameList" ] = (v5("WrappedName")*((v59*v5("WrappedName"))^0))
	v137[ "LocalVarList" ] = (v5("LocalVar")*((v59*v5("LocalVar"))^0))
	v137[ "LocalVar" ] = v106("LocalVar", (v103("name", v5("Name"))*v103("attribute", v5("Attrib"))))
	v137[ "Attrib" ] = v119(((v70*(v6("const")+v6("close")))*v71), false)
	v137[ "FunctionName" ] = (v5("FunctionNameWithMethod")+v5("FunctionWithIndex"))
	v137[ "FunctionWithIndex" ] = v9((v106("Var", v103("name", v5("Name")))*((v60*v106("StringLiteral", v103("literal", v5("Name"))))^0)), v128)
	v137[ "FunctionNameWithMethod" ] = v106("MethodDef", ((v103("exp", (v5("FunctionWithIndex")/function(v141)
		if (v141["tag"]=="Var") then
			v141[ "tag" ] = "VarExp"
		else
			if (v141["tag"]=="Indexation") then
				v141[ "tag" ] = "IndexationExp"
			end
		end
		return v141
	end))*v56)*v103("index", v106("StringLiteral", v103("literal", v5("Name"))))))
	v137[ "IfStatement" ] = ((((v106("IfStatement", (((v94*v103("condition", v5("Exp")))*v99)*v103("thenBody", v5("Block"))))*(v106("IfStatement", (((v89*v103("condition", v5("Exp")))*v99)*v103("thenBody", v5("Block"))))^0))*v119(v8((v88*v5("Block"))), false))*v90)/v131)
	v137[ "VarList" ] = v10((v5("Var")*((v59*v5("Var"))^0)))
	v137[ "Var" ] = ((v9((v5("ExpPrefix")*v5("VarSuffix")), v116)/function(v142)
		if (v142["tag"]=="IndexationExp") then
			v142[ "tag" ] = "Indexation"
		end
		return v142
	end)+v106("Var", v103("name", v5("Name"))))
	v137[ "VarSuffix" ] = (((v5("CallSuffix")^0)*v5("Indexation"))*(v5("VarSuffix")^-1))
	v137[ "ExpList" ] = (v5("Exp")*((v59*v5("Exp"))^0))
	v137[ "Exp" ] = v5("OrExp")
	v137[ "PrimaryExp" ] = (((((((v5("Nil")+v5("False"))+v5("True"))+v5("Ellipsis"))+v5("Numeral"))+v5("LiteralString"))+v5("TableConstructor"))+(v92*v5("AnonymousFunction")))
	v137[ "PostfixedExp" ] = (v5("PrimaryExp")+v9((v5("ExpPrefix")*((v5("Indexation")+v5("CallSuffix"))^0)), v116))
	v137[ "PotExp" ] = v109(v5("PostfixedExp"), v72, v5("UnaryExp"))
	v137[ "UnaryExp" ] = (((v73*v5("PotExp"))/function(v143, v144)
		return { tag = v143, exp = v144 }
	end)+v5("PotExp"))
	v137[ "MulExp" ] = v109(v5("UnaryExp"), v74, v5("UnaryExp"))
	v137[ "AddExp" ] = v109(v5("MulExp"), v75, v5("MulExp"))
	v137[ "ConcatExp" ] = v109(v5("AddExp"), v76, v5("AddExp"))
	v137[ "BitshiftExp" ] = v109(v5("ConcatExp"), v77, v5("ConcatExp"))
	v137[ "BitandExp" ] = v109(v5("BitshiftExp"), v78, v5("BitshiftExp"))
	v137[ "BitxorExp" ] = v109(v5("BitandExp"), v79, v5("BitandExp"))
	v137[ "BitorExp" ] = v109(v5("BitxorExp"), v80, v5("BitxorExp"))
	v137[ "ComparisonExp" ] = ((((v5("BitorExp")*v81)*v5("BitorExp"))/function(v145, v146, v147)
		return { tag = v146, lhs = v145, rhs = v147 }
	end)+v5("BitorExp"))
	v137[ "AndExp" ] = v109(v5("ComparisonExp"), v82, v5("ComparisonExp"))
	v137[ "OrExp" ] = v109(v5("AndExp"), v83, v5("AndExp"))
	v137[ "ExpPrefix" ] = (v106("VarExp", v103("name", v5("Name")))+((v61*v5("Exp"))*v62))
	v137[ "Indexation" ] = ((v60*v106("IndexationExp", v103("index", v106("StringLiteral", v103("literal", v5("Name"))))))+((v63*v106("IndexationExp", v103("index", v5("Exp"))))*v64))
	v137[ "CallSuffix" ] = (v106("FunctionCall", v103("args", v5("Args")))+v106("MethodCall", ((v56*v103("method", v5("Name")))*v103("args", v5("Args")))))
	v137[ "Args" ] = ((((v61*v10((v5("ExpList")^-1)))*v62)+v10(v5("TableConstructor")))+v10(v5("LiteralString")))
	v137[ "AnonymousFunction" ] = v106("AnonymousFunction", ((((v61*v103("params", v10((v5("Parameters")^-1))))*v62)*v103("body", v5("Block")))*v90))
	v137[ "Parameters" ] = (v5("Ellipsis")+(v5("NameList")*((v59*v5("Ellipsis"))^-1)))
	v137[ "TableConstructor" ] = v106("TableConstructor", ((v65*v103("fields", (v5("FieldList")^-1)))*v66))
	v137[ "FieldList" ] = v10(((v5("Field")*((v69*v5("Field"))^0))*(v69^-1)))
	v137[ "Field" ] = ((v106("ExpAssign", ((((v63*v103("exp", v5("Exp")))*v64)*v68)*v103("value", v5("Exp"))))+v106("NameAssign", ((v103("name", v5("Name"))*v68)*v103("value", v5("Exp")))))+v106("Exp", v103("value", v5("Exp"))))
	v137[ "FunctionCallStat" ] = (v9((v5("ExpPrefix")*v5("CallStatSuffix")), v116)/function(v148)
		if (v148["tag"]=="FunctionCall") then
			v148[ "tag" ] = "FunctionCallStat"
		else
		end
		return v148
	end)
	v137[ "CallStatSuffix" ] = (((v5("Indexation")^0)*v5("CallSuffix"))*(v5("CallStatSuffix")^-1))
	return (v1["P"](v137)*-1)
end
local v149 = v12()
local v150
v150 = function(v151, v152)
	local v153 = v1["match"](v4(v149), v151)
	if v153 then
		return v153
	else
	end
end
return { parse = v150 }