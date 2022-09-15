describe('MI ->', function()
	it('breakpoints', function()
		local gdb = require('gdb.mi')
		local s = '=breakpoint-created,bkpt={number="1",type="breakpoint",\
		disp="keep",enabled="y",addr="0x00000000000011ca",func="main",\
		file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="33",thread-groups=["i1"],times="0",original-location="main"}\r'
		local bp = require('gdb.mi.breakpoints')
		bp.create()
		gdb.handle({ s })
		assert.same({
			['/home/ronin/Develop/gdb.nvim/tests/c/test.c'] = {
				bps = { {
					en = true,
					line = 33,
					times = 0
				} }
			}
		}, bp.files)
	end)

	it('variables', function()
		local s = 'variables=[{name="item",\
		value="{name = 0x555555556008 \\"Resistor\\", price = 10.6}"},\
		{name="s",value="{item = {name = 0x555555556008 \\"Resistor\\", price = 10.6}, count = 1}"},\
		{name="ret",value="1431654544"},{name="i",value="21845"}]'
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
		local str = 'stack=[frame={level="0",addr="0x000055555555519a",\
		func="some_func",file="tests/c/test.c",\
		fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="24",arch="i386:x86-64"},frame={level="1",addr="0x000055555555527f",\
		func="main",file="tests/c/test.c",\
		fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="43",\
		arch="i386:x86-64"}]'
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

	it('stopped', function()
		local str = '*stopped,reason="breakpoint-hit",disp="keep",bkptno="1",\
		frame={addr="0x00005555555551c6",func="main",args=[],file="tests/c/test.c",\
		fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="33",arch="i386:x86-64"},thread-id="1",stopped-threads="all",core="0"\r'
		local f = require('gdb.mi.frames')
		f.parse_stop(str)
		--assert.same({}, f.curr)
	end)

	it('frame changed', function()
		local str = '=thread-selected,id="1",frame={level="1",addr="0x0000555555555278",\
		func="main",args=[],file="tests/c/test.c",\
		fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="43",arch="i386:x86-64"}\r'
		local f = require('gdb.mi.frames')
	end)

	it('threads', function() -- Make multithread example
		local str = '^done,threads=[{id="1",target-id="process 4157",name="test",\
		frame={level="0",addr="0x00005555555551c6",func="main",args=[],file="tests/c/test.c",\
		fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="33",arch="i386:x86-64"},\
		state="stopped",core="2"}],current-thread-id="1"\r'
		local t = require('gdb.mi.threads')
		t.parse(str)
	end)

end)
