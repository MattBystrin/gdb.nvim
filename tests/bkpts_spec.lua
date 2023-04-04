local function parse_mock(str, mod)
	for _,p in ipairs(mod:parsers()) do
		if str:find(p.pattern) then
			p.handler(str)
			return
		end
	end
end

describe('breakpoints module parsers ->', function()

local mod = require'gdb.modules.bkpts'

mod:on_attach()

it('created', function()
	local str = '=breakpoint-created,bkpt={number="2",type="breakpoint",disp="keep",enabled="y",addr="0x000000000000119a",func="some_func",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="24",thread-groups=["i1"],times="0",original-location="some_func"}'
	local str2 = '=breakpoint-created,bkpt={number="3",type="breakpoint",disp="keep",enabled="y",addr="0x000000000000119a",func="some_func",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="36",thread-groups=["i1"],times="0",original-location="some_func"}'
	parse_mock(str, mod)
	parse_mock(str2, mod)
	assert.same(mod.bkpts,
	{
		[2] = {
			addr = "0x000000000000119a",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 0,
			line = 24,
			type = "breakpoint"
		},
		[3] = {
			addr = "0x000000000000119a",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 0,
			line = 36,
			type = "breakpoint"
		}
	})
end)

it('modified', function()
	local str = '=breakpoint-modified,bkpt={number="5",type="dprintf",disp="keep",enabled="y",addr="0x0000555555555224",func="main",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="44",thread-groups=["i1"],times="1",script={"printf \\"Hello\\""},original-location="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c:44"}\r'
	local str2 = '=breakpoint-modified,bkpt={number="2",type="breakpoint",disp="keep",enabled="y",addr="0x000055555555519a",func="some_func",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="24",thread-groups=["i1"],times="4",original-location="some_func"}\r'
	parse_mock(str, mod)
	parse_mock(str2, mod)
	assert.same(mod.bkpts,
	{
		[2] = {
			addr = "0x000055555555519a",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 4,
			line = 24,
			type = "breakpoint"
		},
		[3] = {
			addr = "0x000000000000119a",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 0,
			line = 36,
			type = "breakpoint"
		},
		[5] = {
			addr = "0x0000555555555224",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 1,
			line = 44,
			type = "dprintf"
		}
	})
end)

it('deleted', function()
	local str = '=breakpoint-deleted,id="3"\r'
	parse_mock(str, mod)
	assert.same(mod.bkpts,
	{
		[2] = {
			addr = "0x000055555555519a",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 4,
			line = 24,
			type = "breakpoint"
		},
		[5] = {
			addr = "0x0000555555555224",
			en = true,
			file = "/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",
			hits = 1,
			line = 44,
			type = "dprintf"
		}
	})
end)
end) -- describe end

describe('bkpts mod integration ->', function()
local gdb = require'gdb'
gdb.setup({
	command = {"gdb"},
	modules = { bkpts = { } }
})
gdb.debug_start()
it('creation', function()
	gdb.bkpt()
end)
it('deletion', function()
	gdb.bkpt()
end)
gdb.debug_stop()
end) -- describe end

