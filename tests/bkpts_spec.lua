local function parse_mock(str, mod)
	for _,p in ipairs(mod:parsers()) do
		if str:find(p.pattern) then
			p.handler(str)
			return
		end
	end
end

describe('breakpoints module ->', function()

local mod = require'gdb.modules.bkpts'

it('breakpoint created', function()
	mod:on_attach()
	local str = '=breakpoint-created,bkpt={number="2",type="breakpoint",disp="keep",enabled="y",addr="0x000000000000119a",func="some_func",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="24",thread-groups=["i1"],times="0",original-location="some_func"}'
	local str2 = '=breakpoint-created,bkpt={number="3",type="breakpoint",disp="keep",enabled="y",addr="0x000000000000119a",func="some_func",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="36",thread-groups=["i1"],times="0",original-location="some_func"}'
	parse_mock(str, mod)
	parse_mock(str2, mod)
	P(mod.files)
	P(mod.bps)
	mod.bps[2] = nil
	print("Deleted")
	collectgarbage()
	P(mod.files)
	P(mod.bps)
	mod:on_detach()
	P(mod.files)
	P(mod.bps)
end)

-- it('breakpoint modified', function()
-- 	mod:on_attach()
-- 	local str = '=breakpoint-modified,bkpt={number="1",type="breakpoint",disp="keep",enabled="y",addr="0x00005555555551ca",func="main",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="33",thread-groups=["i1"],times="1",original-location="main"}\r'
-- 	parse_mock(str, mod)
-- 	assert.same({
-- 		["/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c"] = {
-- 			bps = {
-- 				[1] = {
-- 					en = true,
-- 					line = 33,
-- 					hits = 1
-- 				}
-- 			}
-- 		}
-- 	}, mod.files)
-- 	mod:on_detach()
-- end)

-- it('breakpoint deleted', function()
-- 	local str = '=breakpoint-deleted,id="1"\r'
-- 	parse_mock(str, mod)
-- 	assert.same({}, {})
-- end)
-- it('breakpoint list', function()
-- 	local str = '^done,BreakpointTable={nr_rows="2",nr_cols="6",hdr=[{width="7",alignment="-1",col_name="number",colhdr="Num"},{width="14",alignment="-1",col_name="type",colhdr="Type"},{width="4",alignment="-1",col_name="disp",colhdr="Disp"},{width="3",alignment="-1",col_name="enabled",colhdr="Enb"},{width="18",alignment="-1",col_name="addr",colhdr="Address"},{width="40",alignment="2",col_name="what",colhdr="What"}],body=[bkpt={number="2",type="breakpoint",disp="keep",enabled="y",addr="0x000055555555519a",func="some_func",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="24",thread-groups=["i1"],times="0",original-location="some_func"},bkpt={number="3",type="breakpoint",disp="keep",enabled="y",addr="0x00005555555551ca",func="main",file="tests/intgr/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/intgr/c/test.c",line="33",thread-groups=["i1"],times="0",original-location="main"}]}\r'
-- 	parse_mock(str, mod)
-- 	assert.same({}, {})
-- end)
mod:on_detach()

end)
