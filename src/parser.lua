local lpeg = require "lpeg"

local S, R, P, V = lpeg.S, lpeg.R, lpeg.P, lpeg.V
local C, Cc, Cg, Cf, Ct, Cmt = lpeg.C, lpeg.Cc, lpeg.Cg, lpeg.Cf, lpeg.Ct, lpeg.Cmt

local function createLuaGrammar()
	local asciiletter = R("az","AZ")
	local alphanum = R("az","AZ","09") + P"_"

	local digit = R("09")
	local hex_digit = R("09", "af", "AF")

	-- Numeric patterns
	local dec_int = digit^1
	local hex_int = P"0" * S"xX" * hex_digit^1
	local integer = dec_int + hex_int

	local dec_fract = P(".") * dec_int + dec_int * P(".") * digit^0
	local hex_fract = P(".") * hex_int + hex_int * P(".") * hex_digit^0
	local dec_exp = S"Ee" * S"+-"^-1 * dec_int
	local hex_exp = S"Pp" * S"+-"^-1 * dec_int
	local dec_float = dec_fract * dec_exp^-1 + dec_int * dec_exp
	local hex_float = hex_fract * hex_exp^-1 + hex_int * hex_exp
	local float = dec_float + hex_float
	--

	-- String patterns
	local c_escape = S"abfnrtv\\\'\"" -- What comes after a '\'
	local hex_escape = P'x' * hex_digit * hex_digit
	local dec_escape = digit * digit^-2
	local unicode_escape = P'u' * P'{' * hex_digit * hex_digit^-2 * P'}'
	local escape = P"\\" * (c_escape + hex_escape + dec_escape + unicode_escape)
	local char_escape = escape + P(1)

	local short_string = P"'" * C((char_escape - P("'"))^0) * P("'")
		+ P'"' * C((char_escape - P('"'))^0) * P('"')

	local long_string = Cmt(P"[" * C(P"="^0) * P"[" * P"\n"^-1,
		function (subject, i, equals)
			local begins, ends = string.find(subject, string.format("]%s]", equals), i, true)
			local capture = string.sub(subject, i, begins-1)
			return ends + 1, capture
		end)

	local long_string_no_capture = Cmt(P"[" * C(P"="^0) * P"[" * P"\n"^-1,
		function (subject, i, equals)
			local _, ends = string.find(subject, string.format("]%s]", equals), i, true)
			return ends + 1
		end)
	--

	-- Comments
	local singleline_comment = P'--' * (1 - S'\r\n\f')^0
	local multiline_comment = P'--' * long_string_no_capture --long_string
	local comment = multiline_comment + singleline_comment
	--

	-- Spaces
	local space = S" \n\t\r"
	local spaces = (space + comment)^0

	local function makeTerminal(patt)
		return patt * spaces
	end

	local function symbol(literal)
		return makeTerminal(P(literal))
	end
	--

	-- Symbols
	local colon = symbol":"
	local semicolon = symbol";"
	local doublecolon = symbol"::"
	local comma = symbol","
	local dot = symbol"."
	local open_paren = symbol"("
	local close_paren = symbol")"
	local open_square = symbol"["
	local close_square = symbol"]"
	local open_curly = symbol"{"
	local close_curly = symbol"}"
	local ellipsis = symbol"..."
	local equal = symbol"="
	local fieldsep = comma + semicolon
	local open_angle = symbol"<"
	local close_angle = symbol">"
	--

	-- Operators
	local pot_op = makeTerminal(C"^")
	local unary_op = makeTerminal(C"not" + C"#" + (P"-"/"u-") + (P"~" / "u~"))
	local mul_op = makeTerminal(C(P"//" + S"*/%"))
	local add_op = makeTerminal(C(S"+-"))
	local concat_op = makeTerminal(C"..")
	local bitshift_op = makeTerminal(C"<<" + C">>")
	local bitand_op = makeTerminal(C"&")
	local bitxor_op = makeTerminal(C"~")
	local bitor_op = makeTerminal(C"|")
	local comparison_op = makeTerminal(C"<=" + C">=" + C"<" + C">" + C"~=" + C"==")
	local and_op = makeTerminal(C"and")
	local or_op = makeTerminal(C"or")
	--

	-- Reserved Words
	local function Rw (w)
		return P(w) * (-alphanum) * spaces
	end

	local Break = Rw"break"
	local Do = Rw"do"
	local Else = Rw"else"
	local Elseif = Rw"elseif"
	local End = Rw"end"
	local For = Rw"for"
	local Function = Rw"function"
	local Goto = Rw"goto"
	local If = Rw"if"
	local In = Rw"in"
	local Local = Rw"local"
	local Repeat = Rw"repeat"
	local Return = Rw"return"
	local Then = Rw"then"
	local Until = Rw"until"
	local While = Rw"while"

	local reserved_words = {
		["and"] = true,
		["break"] = true,
		["do"] = true,
		["else"] = true,
		["elseif"] = true,
		["end"] = true,
		["false"] = true,
		["for"] = true,
		["function"] = true,
		["goto"] = true,
		["if"] = true,
		["in"] = true,
		["local"] = true,
		["nil"] = true,
		["not"] = true,
		["or"] = true,
		["repeat"] = true,
		["return"] = true,
		["then"] = true,
		["true"] = true,
		["until"] = true,
		["while"] = true,
	}
	--

	-- AST-related functions

	-- Tag
	local function tagP(name, patt)
		return Cg(patt, name)
	end

	local function tagWrap(tag, patt)
		return Ct(patt * Cg(Cc(tag), 'tag'))
	end

	local function foldBinExp(lhs, op, rhs)
		return Cf(lhs * Cg(op * rhs)^0,
			function (v1, o, v2)
				return {tag=o, lhs=v1, rhs=v2}
			end)
	end

	local function nestExpression(a, b)
		if b.tag == 'FunctionCall' then
			b.func = a
		elseif b.tag == 'MethodCall' then
			b.receiver = a
		else
			b.exp = a
		end
		return b
	end

	local function optional(patt, default)
		-- return the values captured by `patt' if it matches, else return
		-- `default'
		return patt + Cc(default)
	end

	local function localFunctionDesugar(name, func)
		func.tag = 'AnonymousFunction'
		return {
				tag  = 'LocalAssign',
				vars = {
					{tag='LocalVar', name=name, attribute=false}
				},
				exps = {}
			},
			{
				tag  = 'Assign',
				vars = {
					{tag='Var', name=name}
				},
				exps = {func}
			}
	end

	local function globalFunctionDesugar(var, func)
		if var.tag == 'MethodDef' then
			table.insert(func.params, 1, 'self')
			var.tag = 'Indexation'
		end
		return
		{
			tag  = 'Assign',
			vars = {var},
			exps = {func}
		}
	end

	local function nestFunctionDefinition(a, b)
		if a.tag == 'Var' then a.tag = 'VarExp' end -- minor hack
		return {tag='Indexation', index=b, exp=a}
	end

	local function nestIf(a, b)
		if b then
			a.elseBody = b
			b.topIf = a.topIf or a
			a.topIf = nil
			return b
		else
			a.elseBody = false
			return a
		end
	end

	local function getTopIf(c)
		if c.topIf then
			local p = c.topIf
			c.topIf = nil
			return p
		else
			return c
		end
	end

	local function nestStats(a, b)
		a.tail = b
		b.topStat = a.topStat or a
		a.topStat = nil
		return b
	end

	local function getTopStat(last)
		local top = last.topStat
		if top then
			last.topStat = nil
			return top
		else
			return last
		end
	end

	-- Grammar rules
	local rules = {"Chunk"}

	-- Terminals
	rules.LiteralString = makeTerminal(
    tagWrap("StringLiteral", tagP("literal", short_string + long_string))
  ) -- already produces captures

	rules.Name = makeTerminal(
		Cmt((asciiletter + P'_') * alphanum^0,
			function (_, _, name)
				return not reserved_words[name], name
			end)
	)

	rules.FloatNumeral = tagWrap('NumberLiteral', tagP('literal', makeTerminal(C(float)) / tonumber))
	rules.IntegerNumeral = tagWrap('NumberLiteral', tagP('literal', makeTerminal(C(integer)) / tonumber))
	rules.Numeral = V"FloatNumeral" + V"IntegerNumeral"

	rules.True = tagWrap('BoolLiteral', tagP('literal', Cc(true) * Rw"true"))
	rules.False = tagWrap('BoolLiteral', tagP('literal', Cc(false) * Rw"false"))

	rules.Nil = tagWrap('Nil', Rw"nil")
	rules.Ellipsis = tagWrap('Vararg', ellipsis)
	--

	rules.Chunk = spaces * V"Block"
	rules.Block = tagWrap('Block', tagP('statements', Cf(
		tagWrap('Cons', tagP('head', V"Stat"))^0 * tagWrap('Cons', tagP('head', V"ReturnStat"))^-1
			* Cc({tag='EmptyList'}), nestStats) / getTopStat
	))

	-- Statement
	rules.Stat =
		-- Empty statement
		tagWrap('Nop', semicolon)

		-- Local assign
		+ tagWrap('LocalAssign',
				Local *
				tagP('vars', Ct(V"LocalVarList")) *
				tagP('exps', Ct((equal * V"ExpList")^-1))
			)

		-- Assign
		+ tagWrap('Assign', tagP('vars', V"VarList") * equal * tagP('exps', Ct(V"ExpList")))

		-- Local function declaration. Transforms to 'local f; f = function ...'
		+ Local * Function * V"Name" * V"AnonymousFunction" / localFunctionDesugar

		-- Global function declaration. Transforms to 'f = function ...'
		+ Function * V"FunctionName" * V"AnonymousFunction" / globalFunctionDesugar

		-- Function call statement
		+ V"FunctionCallStat"

		-- GOTO, break, label
		+ tagWrap('Goto', Goto * tagP('label', V"Name"))
		+ tagWrap('Break', Break)
		+ tagWrap('Label', tagP('label', V"Label"))

		-- Do blocks
		+ tagWrap('Do', Do * tagP('body', V"Block") * End)

		-- While loop
		+ tagWrap('While', While * tagP('condition', V"Exp") * Do * tagP('body', V"Block") * End)

		-- Repeat until loop
		+ tagWrap('Repeat', Repeat * tagP('body', V"Block") * Until * tagP('condition', V"Exp"))

		-- Numeric for
		+ tagWrap("NumericFor",
			For
			* tagP('var', V"Name")
			* equal * tagP('init', V"Exp")
			* comma * tagP('limit', V"Exp")
			* tagP('step', optional(comma * V"Exp", false))
			* Do * tagP('body', V"Block") * End
		)

		-- Generic For
		+ tagWrap("GenericFor",
			For
			* tagP('vars', Ct(V"NameList"))
			* In * tagP('exps', Ct(V"ExpList"))
			* Do * tagP('body', V"Block") * End
		)

		+ V"IfStatement"
		--

	rules.ReturnStat = tagWrap('Return',
		Return * tagP('exps', optional(Ct(V"ExpList"), false)) * semicolon^-1
	)

	rules.Label = doublecolon * V"Name" * doublecolon
	rules.NameList = V"Name" * (comma * V"Name")^0
	rules.LocalVarList = V"LocalVar" * (comma * V"LocalVar")^0
	rules.LocalVar = tagWrap('LocalVar', tagP('name', V"Name") * tagP('attribute', V"Attrib"))

	-- we could follow the grammar and allow Name attributes, but
	-- it's so much easier to hardcode this in the parser while
	-- there are not too many attributes (vanilla lua also does
	-- this, see lparser.c)
	rules.Attrib = optional(open_angle * (C"const" + C"close")  * close_angle, false)


	rules.FunctionName = V"FunctionNameWithMethod" + V"FunctionWithIndex" -- Order is important

	-- Function with indexation in name 'a.b'
	rules.FunctionWithIndex = Cf(
		-- first var
		tagWrap('Var', tagP('name', V"Name"))
		-- many indexes
		* (dot * tagWrap('StringLiteral', tagP('literal', V"Name")))^0,
		-- nest indexes
		nestFunctionDefinition
	)

	-- Functions ending in ':methodName'
	rules.FunctionNameWithMethod = tagWrap('MethodDef',
		tagP('exp', V"FunctionWithIndex" / function(a) if a.tag == 'Var' then a.tag = 'VarExp' end return a end)
		* colon * tagP('index', tagWrap('StringLiteral', tagP('literal', V"Name")))
	)


	rules.IfStatement = Cf(
		-- Topmost if
		tagWrap('IfStatement', If * tagP('condition', V"Exp") * Then * tagP('thenBody', V"Block"))

		-- Followed by zero or more elseif
		* (tagWrap('IfStatement', Elseif * tagP('condition', V"Exp") * Then * tagP('thenBody', V"Block")))^0

		-- Followed optionally by an else
		* optional(Cg(Else * V"Block"), false) * End,

		-- Nest elseifs into else body. It can be thought of this transformation:
		-- 'if a then elseif b then end' -> 'if a then else if b then end end'.
		-- However we need to return the topmost if statement. That is done through
		-- saving the top and propagating it throughout the fold, then returning it
		-- in 'getTopIf'
		nestIf) / getTopIf

	rules.VarList = Ct(V"Var" * (comma * V"Var")^0)
	rules.Var = Cf(V"ExpPrefix" * V"VarSuffix", nestExpression)
		+ tagWrap('Var', tagP('name', V"Name"))
	rules.VarSuffix = (V"CallSuffix")^0 * (V"Indexation" / function(i) i.tag = 'Indexation' return i end) * (V"VarSuffix")^-1


	rules.ExpList = V"Exp" * (comma * V"Exp")^0
	rules.Exp = V"OrExp"

	rules.PrimaryExp = V"Nil"
		+ V"False"
		+ V"True"
		+ V"Ellipsis"
		+ V"Numeral"
		+ V"LiteralString"
		+ V"TableConstructor"
		+ Function * V"AnonymousFunction"

	rules.PostfixedExp = V"PrimaryExp"
		+ Cf(V"ExpPrefix" * (V"Indexation" + V"CallSuffix")^0, nestExpression)

	rules.PotExp = foldBinExp(V"PostfixedExp", pot_op, V"UnaryExp")
	rules.UnaryExp = (unary_op * V"PotExp" / function (opName, exp) return {tag=opName, exp=exp} end)
		+ V"PotExp"

	rules.MulExp = foldBinExp(V"UnaryExp", mul_op, V"UnaryExp")
	rules.AddExp = foldBinExp(V"MulExp", add_op,  V"MulExp")
	rules.ConcatExp = foldBinExp(V"AddExp", concat_op, V"AddExp")
	rules.BitshiftExp = foldBinExp(V"ConcatExp", bitshift_op, V"ConcatExp")
	rules.BitandExp = foldBinExp(V"BitshiftExp", bitand_op, V"BitshiftExp")
	rules.BitxorExp = foldBinExp(V"BitandExp", bitxor_op, V"BitandExp")
	rules.BitorExp = foldBinExp(V"BitxorExp", bitor_op, V"BitxorExp")
	rules.ComparisonExp = (V"BitorExp" * comparison_op * V"BitorExp" / function (exp1, opName, exp2)
        return {tag=opName, lhs=exp1, rhs=exp2} end)
		+ V"BitorExp"
	rules.AndExp = foldBinExp(V"ComparisonExp", and_op, V"ComparisonExp")
	rules.OrExp = foldBinExp(V"AndExp", or_op, V"AndExp")

	rules.ExpPrefix = tagWrap('VarExp', tagP('name', V"Name"))
		+ open_paren * V"Exp" * close_paren

	rules.Indexation = dot * tagWrap('IndexationExp', tagP('index', tagWrap('StringLiteral', tagP('literal', V"Name"))))
		+ open_square * tagWrap('IndexationExp', tagP('index', V"Exp")) * close_square

	rules.CallSuffix = tagWrap("FunctionCall", tagP('args', V"Args"))
		+ tagWrap("MethodCall", colon * tagP('method', V"Name") * tagP('args', V"Args"))

	rules.Args = open_paren * Ct(V"ExpList"^-1) * close_paren
		+ V"TableConstructor"
		+ V"LiteralString"

	rules.AnonymousFunction = tagWrap('AnonymousFunction',
		open_paren * tagP('params', Ct(V"Parameters"^-1)) * close_paren * tagP('body', V"Block") * End
	)
	rules.Parameters = V"Ellipsis"
		+ V"NameList" * (comma * V"Ellipsis")^-1

	rules.TableConstructor = tagWrap("TableConstructor", open_curly * V"FieldList"^-1 * close_curly)
	rules.FieldList = V"Field" * (fieldsep * V"Field")^0 * fieldsep^-1
	rules.Field = tagWrap("ExpAssign", open_square * V"Exp" * close_square * equal * V"Exp")
		+ tagWrap("NameAssign", V"Name" * equal * V"Exp")
		+ tagWrap("Exp", V"Exp")

	rules.FunctionCallStat = Cf(V"ExpPrefix" * V"CallStatSuffix", nestExpression)

	rules.CallStatSuffix = (V"Indexation"^0 * V"CallSuffix" * (V"CallStatSuffix")^-1)


	return lpeg.P(rules) * -1
end


local grammar = createLuaGrammar()

-- Parser/Evaluator
local function parse(s, _)
	local t = lpeg.match(P(grammar), s)
	if t then
		return t
	else print(string.format("Failed to parse '%s'", s))
	end
end

return {parse = parse}
--[[

check Reserved words, spaces after rw

--]]


