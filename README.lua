-- Decompiled by Krnl

local v_u_1 = {}
local v_u_2 = {}
local v_u_3 = {}
function v_u_1.make_getS(_, p4)
	local v_u_5 = p4
	return function()
		-- upvalues: (ref) v_u_5
		if not v_u_5 then
			return nil
		end
		local v6 = v_u_5
		v_u_5 = nil
		return v6
	end
end
function v_u_1.make_getF(_, p_u_7)
	local v_u_8 = 1
	return function()
		-- upvalues: (copy) p_u_7, (ref) v_u_8
		local v9 = p_u_7:sub(v_u_8, v_u_8 + 512 - 1)
		local v10 = #p_u_7 + 1
		local v11 = v_u_8 + 512
		v_u_8 = math.min(v10, v11)
		return v9
	end
end
function v_u_1.init(_, p12, p13)
	if p12 then
		local v14 = {
			["reader"] = p12,
			["data"] = p13 or "",
			["name"] = name
		}
		if p13 and p13 ~= "" then
			v14.n = #p13
		else
			v14.n = 0
		end
		v14.p = 0
		return v14
	end
end
function v_u_1.fill(_, p15)
	local v16 = p15.reader()
	p15.data = v16
	if not v16 or v16 == "" then
		return "EOZ"
	end
	p15.n = #v16 - 1
	p15.p = 1
	return string.sub(v16, 1, 1)
end
function v_u_1.zgetc(p17, p18)
	local v19 = p18.n
	local v20 = p18.p + 1
	if v19 <= 0 then
		return p17:fill(p18)
	end
	p18.n = v19 - 1
	p18.p = v20
	local v21 = p18.data
	return string.sub(v21, v20, v20)
end
v_u_2.RESERVED = "TK_AND and\nTK_BREAK break\nTK_DO do\nTK_ELSE else\nTK_ELSEIF elseif\nTK_END end\nTK_FALSE false\nTK_FOR for\nTK_FUNCTION function\nTK_IF if\nTK_IN in\nTK_LOCAL local\nTK_NIL nil\nTK_NOT not\nTK_OR or\nTK_REPEAT repeat\nTK_RETURN return\nTK_THEN then\nTK_TRUE true\nTK_UNTIL until\nTK_WHILE while\nTK_CONCAT ..\nTK_DOTS ...\nTK_EQ ==\nTK_GE >=\nTK_LE <=\nTK_NE ~=\nTK_NAME <name>\nTK_NUMBER <number>\nTK_STRING <string>\nTK_EOS <eof>"
v_u_2.MAXSRC = 80
v_u_2.MAX_INT = 2147483645
v_u_2.LUA_QS = "\'%s\'"
v_u_2.LUA_COMPAT_LSTR = 1
function v_u_2.init(p22)
	local v23 = {}
	local v24 = {}
	for v25 in string.gmatch(p22.RESERVED, "[^\n]+") do
		local _, _, v26, v27 = string.find(v25, "(%S+)%s+(%S+)")
		v23[v26] = v27
		v24[v27] = v26
	end
	p22.tokens = v23
	p22.enums = v24
end
function v_u_2.chunkid(_, p28, p29)
	local v30 = string.sub(p28, 1, 1)
	if v30 == "=" then
		return string.sub(p28, 2, p29)
	end
	if v30 == "@" then
		local v31 = string.sub(p28, 2)
		local v32 = p29 - 7
		local v33 = #v31
		local v34 = ""
		if v32 < v33 then
			local v35 = v33 + 1 - v32
			v31 = string.sub(v31, v35)
			v34 = v34 .. "..."
		end
		return v34 .. v31
	end
	local v36 = string.find(p28, "[\n\r]")
	local v37 = v36 and v36 - 1 or #p28
	local v38 = p29 - 16
	if v38 < v37 then
		v37 = v38
	end
	local v39 = "[string \""
	local v40
	if v37 < #p28 then
		v40 = v39 .. string.sub(p28, 1, v37) .. "..."
	else
		v40 = v39 .. p28
	end
	return v40 .. "\"]"
end
function v_u_2.token2str(p41, _, p42)
	if string.sub(p42, 1, 3) == "TK_" then
		return p41.tokens[p42]
	elseif string.find(p42, "%c") then
		return string.format("char(%d)", string.byte(p42))
	else
		return p42
	end
end
function v_u_2.lexerror(p_u_43, p44, p45, p46)
	local function v49(p47, p48)
		-- upvalues: (copy) p_u_43
		if p48 == "TK_NAME" or (p48 == "TK_STRING" or p48 == "TK_NUMBER") then
			return p47.buff
		else
			return p_u_43:token2str(p47, p48)
		end
	end
	local v50 = p_u_43:chunkid(p44.source, p_u_43.MAXSRC)
	local v51 = string.format("%s:%d: %s", v50, p44.linenumber, p45)
	if p46 then
		v51 = string.format("%s near " .. p_u_43.LUA_QS, v51, v49(p44, p46))
	end
	error(v51)
end
function v_u_2.syntaxerror(p52, p53, p54)
	p52:lexerror(p53, p54, p53.t.token)
end
function v_u_2.currIsNewline(_, p55)
	return p55.current == "\n" and true or p55.current == "\r"
end
function v_u_2.inclinenumber(p56, p57)
	local v58 = p57.current
	p56:nextc(p57)
	if p56:currIsNewline(p57) and p57.current ~= v58 then
		p56:nextc(p57)
	end
	p57.linenumber = p57.linenumber + 1
	if p57.linenumber >= p56.MAX_INT then
		p56:syntaxerror(p57, "chunk has too many lines")
	end
end
function v_u_2.setinput(p59, p60, p61, p62, p63)
	local v64 = p61 or {}
	if not v64.lookahead then
		v64.lookahead = {}
	end
	if not v64.t then
		v64.t = {}
	end
	v64.decpoint = "."
	v64.L = p60
	v64.lookahead.token = "TK_EOS"
	v64.z = p62
	v64.fs = nil
	v64.linenumber = 1
	v64.lastline = 1
	v64.source = p63
	p59:nextc(v64)
end
function v_u_2.check_next(p65, p66, p67)
	if not string.find(p67, p66.current, 1, 1) then
		return false
	end
	p65:save_and_next(p66)
	return true
end
function v_u_2.next(p68, p69)
	p69.lastline = p69.linenumber
	if p69.lookahead.token == "TK_EOS" then
		p69.t.token = p68:llex(p69, p69.t)
	else
		p69.t.seminfo = p69.lookahead.seminfo
		p69.t.token = p69.lookahead.token
		p69.lookahead.token = "TK_EOS"
	end
end
function v_u_2.lookahead(p70, p71)
	p71.lookahead.token = p70:llex(p71, p71.lookahead)
end
function v_u_2.nextc(_, p72)
	-- upvalues: (copy) v_u_1
	local v73 = v_u_1:zgetc(p72.z)
	p72.current = v73
	return v73
end
function v_u_2.save(_, p74, p75)
	p74.buff = p74.buff .. p75
end
function v_u_2.save_and_next(p76, p77)
	p76:save(p77, p77.current)
	return p76:nextc(p77)
end
function v_u_2.str2d(_, p78)
	return tonumber(p78) or (string.lower((string.sub(p78, 1, 2))) == "0x" and tonumber(p78, 16) or nil)
end
function v_u_2.buffreplace(_, p79, p80, p81)
	local v82 = p79.buff
	local v83 = ""
	for v84 = 1, #v82 do
		local v85 = string.sub(v82, v84, v84)
		if v85 == p80 then
			v85 = p81
		end
		v83 = v83 .. v85
	end
	p79.buff = v83
end
function v_u_2.trydecpoint(p86, p87, p88)
	p86:buffreplace(p87, p87.decpoint, p87.decpoint)
	local v89 = p86:str2d(p87.buff)
	p88.seminfo = v89
	if not v89 then
		p86:buffreplace(p87, p87.decpoint, ".")
		p86:lexerror(p87, "malformed number", "TK_NUMBER")
	end
end
function v_u_2.read_numeral(p90, p91, p92)
	repeat
		p90:save_and_next(p91)
	until string.find(p91.current, "%D") and p91.current ~= "."
	if p90:check_next(p91, "Ee") then
		p90:check_next(p91, "+-")
	end
	while string.find(p91.current, "^%w$") or p91.current == "_" do
		p90:save_and_next(p91)
	end
	p90:buffreplace(p91, ".", p91.decpoint)
	local v93 = p90:str2d(p91.buff)
	p92.seminfo = v93
	if not v93 then
		p90:trydecpoint(p91, p92)
	end
end
function v_u_2.skip_sep(p94, p95)
	local v96 = p95.current
	p94:save_and_next(p95)
	local v97 = 0
	while p95.current == "=" do
		p94:save_and_next(p95)
		v97 = v97 + 1
	end
	return p95.current == v96 and v97 and v97 or -v97 - 1
end
function v_u_2.read_long_string(p98, p99, p100, p101)
	local v102 = 0
	p98:save_and_next(p99)
	if p98:currIsNewline(p99) then
		p98:inclinenumber(p99)
	end
	while true do
		while true do
			local v103 = p99.current
			if v103 == "EOZ" then
				break
			end
			if v103 == "[" then
				if p98.LUA_COMPAT_LSTR and p98:skip_sep(p99) == p101 then
					p98:save_and_next(p99)
					v102 = v102 + 1
					if p98.LUA_COMPAT_LSTR == 1 and p101 == 0 then
						p98:lexerror(p99, "nesting of [[...]] is deprecated", "[")
					end
				end
			elseif v103 == "]" then
				if p98:skip_sep(p99) == p101 then
					p98:save_and_next(p99)
					if p98.LUA_COMPAT_LSTR and p98.LUA_COMPAT_LSTR == 2 then
						local v104 = v102 - 1
						if p101 == 0 then
							local _ = 0 <= v104
						end
					end
					if p100 then
						local v105 = 3 + p101
						local v106 = p99.buff
						local v107 = -v105
						p100.seminfo = string.sub(v106, v105, v107)
					end
					return
				end
			elseif p98:currIsNewline(p99) then
				p98:save(p99, "\n")
				p98:inclinenumber(p99)
				if not p100 then
					p99.buff = ""
				end
			elseif p100 then
				p98:save_and_next(p99)
			else
				p98:nextc(p99)
			end
		end
		p98:lexerror(p99, p100 and "unfinished long string" or "unfinished long comment", "TK_EOS")
	end
end
function v_u_2.read_string(p108, p109, p110, p111)
	p108:save_and_next(p109)
	while p109.current ~= p110 do
		local v112 = p109.current
		if v112 == "EOZ" then
			p108:lexerror(p109, "unfinished string", "TK_EOS")
		elseif p108:currIsNewline(p109) then
			p108:lexerror(p109, "unfinished string", "TK_STRING")
		elseif v112 == "\\" then
			local v113 = p108:nextc(p109)
			if p108:currIsNewline(p109) then
				p108:save(p109, "\n")
				p108:inclinenumber(p109)
			elseif v113 ~= "EOZ" then
				local v114 = string.find("abfnrtv", v113, 1, 1)
				if v114 then
					p108:save(p109, (string.sub("\7\8\f\n\r\t\11", v114, v114)))
					p108:nextc(p109)
				elseif string.find(v113, "%d") then
					local v115 = 0
					local v116 = 0
					repeat
						v115 = 10 * v115 + p109.current
						p108:nextc(p109)
						v116 = v116 + 1
					until v116 >= 3 or not string.find(p109.current, "%d")
					if v115 > 255 then
						p108:lexerror(p109, "escape sequence too large", "TK_STRING")
					end
					p108:save(p109, (string.char(v115)))
				else
					p108:save_and_next(p109)
				end
			end
		else
			p108:save_and_next(p109)
		end
	end
	p108:save_and_next(p109)
	local v117 = p109.buff
	p111.seminfo = string.sub(v117, 2, -2)
end
function v_u_2.llex(p118, p119, p120)
	p119.buff = ""
	while true do
		while true do
			local v121 = p119.current
			if not p118:currIsNewline(p119) then
				break
			end
			p118:inclinenumber(p119)
		end
		if v121 == "-" then
			if p118:nextc(p119) ~= "-" then
				return "-"
			end
			local v122
			if p118:nextc(p119) == "[" then
				v122 = p118:skip_sep(p119)
				p119.buff = ""
			else
				v122 = -1
			end
			if v122 >= 0 then
				p118:read_long_string(p119, nil, v122)
				p119.buff = ""
			else
				while not p118:currIsNewline(p119) and p119.current ~= "EOZ" do
					p118:nextc(p119)
				end
			end
		elseif v121 == "[" then
			local v123 = p118:skip_sep(p119)
			if v123 >= 0 then
				p118:read_long_string(p119, p120, v123)
				return "TK_STRING"
			end
			if v123 == -1 then
				return "["
			end
			p118:lexerror(p119, "invalid long string delimiter", "TK_STRING")
		else
			if v121 == "=" then
				if p118:nextc(p119) ~= "=" then
					return "="
				end
				p118:nextc(p119)
				return "TK_EQ"
			end
			if v121 == "<" then
				if p118:nextc(p119) ~= "=" then
					return "<"
				end
				p118:nextc(p119)
				return "TK_LE"
			end
			if v121 == ">" then
				if p118:nextc(p119) ~= "=" then
					return ">"
				end
				p118:nextc(p119)
				return "TK_GE"
			end
			if v121 == "~" then
				if p118:nextc(p119) ~= "=" then
					return "~"
				end
				p118:nextc(p119)
				return "TK_NE"
			end
			if v121 == "\"" or v121 == "\'" then
				p118:read_string(p119, v121, p120)
				return "TK_STRING"
			end
			if v121 == "." then
				local v124 = p118:save_and_next(p119)
				if p118:check_next(p119, ".") then
					return p118:check_next(p119, ".") and "TK_DOTS" or "TK_CONCAT"
				end
				if not string.find(v124, "%d") then
					return "."
				end
				p118:read_numeral(p119, p120)
				return "TK_NUMBER"
			end
			if v121 == "EOZ" then
				return "TK_EOS"
			end
			if not string.find(v121, "%s") then
				if string.find(v121, "%d") then
					p118:read_numeral(p119, p120)
					return "TK_NUMBER"
				end
				if not string.find(v121, "[_%a]") then
					p118:nextc(p119)
					return v121
				end
				repeat
					local v125 = p118:save_and_next(p119)
				until v125 == "EOZ" or not string.find(v125, "[_%w]")
				local v126 = p119.buff
				local v127 = p118.enums[v126]
				if v127 then
					return v127
				end
				p120.seminfo = v126
				return "TK_NAME"
			end
			p118:nextc(p119)
		end
	end
end
v_u_3.OpMode = {
	["iABC"] = 0,
	["iABx"] = 1,
	["iAsBx"] = 2
}
v_u_3.SIZE_C = 9
v_u_3.SIZE_B = 9
v_u_3.SIZE_Bx = v_u_3.SIZE_C + v_u_3.SIZE_B
v_u_3.SIZE_A = 8
v_u_3.SIZE_OP = 6
v_u_3.POS_OP = 0
v_u_3.POS_A = v_u_3.POS_OP + v_u_3.SIZE_OP
v_u_3.POS_C = v_u_3.POS_A + v_u_3.SIZE_A
v_u_3.POS_B = v_u_3.POS_C + v_u_3.SIZE_C
v_u_3.POS_Bx = v_u_3.POS_C
local v128 = v_u_3.SIZE_Bx
v_u_3.MAXARG_Bx = math.ldexp(1, v128) - 1
local v129 = v_u_3.MAXARG_Bx / 2
v_u_3.MAXARG_sBx = math.floor(v129)
local v130 = v_u_3.SIZE_A
v_u_3.MAXARG_A = math.ldexp(1, v130) - 1
local v131 = v_u_3.SIZE_B
v_u_3.MAXARG_B = math.ldexp(1, v131) - 1
local v132 = v_u_3.SIZE_C
v_u_3.MAXARG_C = math.ldexp(1, v132) - 1
function v_u_3.GET_OPCODE(p133, p134)
	return p133.ROpCode[p134.OP]
end
function v_u_3.SET_OPCODE(p135, p136, p137)
	p136.OP = p135.OpCode[p137]
end
function v_u_3.GETARG_A(_, p138)
	return p138.A
end
function v_u_3.SETARG_A(_, p139, p140)
	p139.A = p140
end
function v_u_3.GETARG_B(_, p141)
	return p141.B
end
function v_u_3.SETARG_B(_, p142, p143)
	p142.B = p143
end
function v_u_3.GETARG_C(_, p144)
	return p144.C
end
function v_u_3.SETARG_C(_, p145, p146)
	p145.C = p146
end
function v_u_3.GETARG_Bx(_, p147)
	return p147.Bx
end
function v_u_3.SETARG_Bx(_, p148, p149)
	p148.Bx = p149
end
function v_u_3.GETARG_sBx(p150, p151)
	return p151.Bx - p150.MAXARG_sBx
end
function v_u_3.SETARG_sBx(p152, p153, p154)
	p153.Bx = p154 + p152.MAXARG_sBx
end
function v_u_3.CREATE_ABC(p155, p156, p157, p158, p159)
	return {
		["OP"] = p155.OpCode[p156],
		["A"] = p157,
		["B"] = p158,
		["C"] = p159
	}
end
function v_u_3.CREATE_ABx(p160, p161, p162, p163)
	return {
		["OP"] = p160.OpCode[p161],
		["A"] = p162,
		["Bx"] = p163
	}
end
function v_u_3.CREATE_Inst(p164, p165)
	local v166 = p165 % 64
	local v167 = (p165 - v166) / 64
	local v168 = v167 % 256
	return p164:CREATE_ABx(v166, v168, (v167 - v168) / 256)
end
function v_u_3.Instruction(_, p169)
	if p169.Bx then
		p169.C = p169.Bx % 512
		p169.B = (p169.Bx - p169.C) / 512
	end
	local v170 = p169.A * 64 + p169.OP
	local v171 = v170 % 256
	local v172 = p169.C * 64 + (v170 - v171) / 256
	local v173 = v172 % 256
	local v174 = p169.B * 128 + (v172 - v173) / 256
	local v175 = v174 % 256
	local v176 = (v174 - v175) / 256
	return string.char(v171, v173, v175, v176)
end
function v_u_3.DecodeInst(p177, p178)
	local v179 = string.byte
	local v180 = {}
	local v181 = v179(p178, 1)
	local v182 = v181 % 64
	v180.OP = v182
	local v183 = v179(p178, 2) * 4 + (v181 - v182) / 64
	local v184 = v183 % 256
	v180.A = v184
	local v185 = v179(p178, 3) * 4 + (v183 - v184) / 256
	local v186 = v185 % 512
	v180.C = v186
	v180.B = v179(p178, 4) * 2 + (v185 - v186) / 512
	local v187 = p177.OpMode
	local v188 = p177.opmodes[v182 + 1]
	local v189 = string.sub(v188, 7, 7)
	if v187[tonumber(v189)] ~= "iABC" then
		v180.Bx = v180.B * 512 + v180.C
	end
	return v180
end
local v190 = v_u_3.SIZE_B - 1
v_u_3.BITRK = math.ldexp(1, v190)
function v_u_3.ISK(p191, p192)
	return p191.BITRK <= p192
end
function v_u_3.INDEXK(p193, _)
	return x - p193.BITRK
end
v_u_3.MAXINDEXRK = v_u_3.BITRK - 1
function v_u_3.RKASK(p194, p195)
	return p195 + p194.BITRK
end
v_u_3.NO_REG = v_u_3.MAXARG_A
v_u_3.opnames = {}
v_u_3.OpCode = {}
v_u_3.ROpCode = {}
local v196 = 0
local v_u_197 = {}
local v_u_198 = {}
local v_u_199 = {}
for v200 in string.gmatch("MOVE LOADK LOADBOOL LOADNIL GETUPVAL\nGETGLOBAL GETTABLE SETGLOBAL SETUPVAL SETTABLE\nNEWTABLE SELF ADD SUB MUL\nDIV MOD POW UNM NOT\nLEN CONCAT JMP EQ LT\nLE TEST TESTSET CALL TAILCALL\nRETURN FORLOOP FORPREP TFORLOOP SETLIST\nCLOSE CLOSURE VARARG\n", "%S+") do
	local v201 = "OP_" .. v200
	v_u_3.opnames[v196] = v200
	v_u_3.OpCode[v201] = v196
	v_u_3.ROpCode[v196] = v201
	v196 = v196 + 1
end
v_u_3.NUM_OPCODES = v196
v_u_3.OpArgMask = {
	["OpArgN"] = 0,
	["OpArgU"] = 1,
	["OpArgR"] = 2,
	["OpArgK"] = 3
}
function v_u_3.getOpMode(p202, p203)
	return p202.opmodes[p202.OpCode[p203]] % 4
end
function v_u_3.getBMode(p204, p205)
	local v206 = p204.opmodes[p204.OpCode[p205]] / 16
	return math.floor(v206) % 4
end
function v_u_3.getCMode(p207, p208)
	local v209 = p207.opmodes[p207.OpCode[p208]] / 4
	return math.floor(v209) % 4
end
function v_u_3.testAMode(p210, p211)
	local v212 = p210.opmodes[p210.OpCode[p211]] / 64
	return math.floor(v212) % 2
end
function v_u_3.testTMode(p213, p214)
	local v215 = p213.opmodes[p213.OpCode[p214]] / 128
	return math.floor(v215)
end
v_u_3.LFIELDS_PER_FLUSH = 50
v_u_3.opmodes = {
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABx,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABx,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	0 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABx,
	0 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	0 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgR * 4 + v_u_3.OpMode.iABC,
	0 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iAsBx,
	128 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	128 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	128 + v_u_3.OpArgMask.OpArgK * 16 + v_u_3.OpArgMask.OpArgK * 4 + v_u_3.OpMode.iABC,
	192 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	192 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	0 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iAsBx,
	64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iAsBx,
	128 + v_u_3.OpArgMask.OpArgN * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	0 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgU * 4 + v_u_3.OpMode.iABC,
	0 + v_u_3.OpArgMask.OpArgN * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABx,
	64 + v_u_3.OpArgMask.OpArgU * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC
}
v_u_3.opmodes[0] = 64 + v_u_3.OpArgMask.OpArgR * 16 + v_u_3.OpArgMask.OpArgN * 4 + v_u_3.OpMode.iABC
v_u_197.LUA_SIGNATURE = "\27Lua"
v_u_197.LUA_TNUMBER = 3
v_u_197.LUA_TSTRING = 4
v_u_197.LUA_TNIL = 0
v_u_197.LUA_TBOOLEAN = 1
v_u_197.LUA_TNONE = -1
v_u_197.LUAC_VERSION = 81
v_u_197.LUAC_FORMAT = 0
v_u_197.LUAC_HEADERSIZE = 12
function v_u_197.make_setS(_)
	return function(p216, p217)
		if not p216 then
			return 0
		end
		p217.data = p217.data .. p216
		return 0
	end, {
		["data"] = ""
	}
end
function v_u_197.make_setF(_, p218)
	local v219 = {
		["h"] = io.open(p218, "wb")
	}
	if v219.h then
		return function(p220, p221)
			if not p221.h then
				return 0
			end
			if p220 then
				if p221.h:write(p220) then
					return 0
				end
			elseif p221.h:close() then
				return 0
			end
			return 1
		end, v219
	else
		return nil
	end
end
function v_u_197.ttype(p222, p223)
	local v224 = p223.value
	local v225 = type(v224)
	if v225 == "number" then
		return p222.LUA_TNUMBER
	elseif v225 == "string" then
		return p222.LUA_TSTRING
	elseif v225 == "nil" then
		return p222.LUA_TNIL
	elseif v225 == "boolean" then
		return p222.LUA_TBOOLEAN
	else
		return p222.LUA_TNONE
	end
end
function v_u_197.from_double(_, p226)
	local v227
	if p226 < 0 then
		p226 = -p226
		v227 = 1
	else
		v227 
