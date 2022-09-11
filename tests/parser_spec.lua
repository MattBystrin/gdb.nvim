describe('MI ->', function()
	it('breakpoints', function()
		local gdb = require('gdb.mi')
		local s = '=breakpoint-created,bkpt={number="1",type="breakpoint",disp="keep",enabled="y",addr="0x00000000000011ca",func="main",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="33",thread-groups=["i1"],times="0",original-location="main"}\r'
		local bp = require('gdb.mi.breakpoints')
		bp.create()
		gdb.handle({s})
		assert.same({
			['/home/ronin/Develop/gdb.nvim/tests/c/test.c'] = {
				bps = {{
					en = true,
					line = 33,
					times = 0
				}}
			}
		}, bp.files)
	end)

	it('variables', function()
		local s = 'variables=[{name="item",value="{name = 0x555555556008 \\"Resistor\\", price = 10.6}"},{name="s",value="{item = {name = 0x555555556008 \\"Resistor\\", price = 10.6}, count = 1}"},{name="ret",value="1431654544"},{name="i",value="21845"}]'
		local l = require('gdb.mi.locals')
		l.parse(s)
		assert.same({
			item = {
				name = '0x555555556008 \\"Resistor\\"',
				price = '10.6'
			},
			s = {
				count = '1',
				item = {
					name = '0x555555556008 \\"Resistor\\"',
					price = '10.6'
				},
			},
			ret = '1431654544', i = '21845'
		}, l.locals)
	end)

	it('frames', function()
		local str = 'stack=[frame={level="0",addr="0x000055555555519a",func="some_func",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="24",arch="i386:x86-64"},frame={level="1",addr="0x000055555555527f",func="main",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="43",arch="i386:x86-64"}]'
		local f = require('gdb.mi.frames')
		f.parse(str)
		assert.same({
			{
				addr = '0x000055555555519a',
				func = 'some_func',
				file = 'tests/c/test.c',
				full = '/home/ronin/Develop/gdb.nvim/tests/c/test.c',
				line = 24
			},
			{
				addr = '0x000055555555527f',
				func = 'main',
				file = 'tests/c/test.c',
				full = '/home/ronin/Develop/gdb.nvim/tests/c/test.c',
				line = 43
			}
		}, f.frames)
	end)
end)
