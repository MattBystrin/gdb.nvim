describe('MI ->', function()
	--[[ it('breakpoints', function()
		local gdb = require('gdb.mi')
		local s = '=breakpoint-created,bkpt={number="1",type="breakpoint",\
		disp="keep",enabled="y",addr="0x00000000000011ca",func="main",\
		file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="33",thread-groups=["i1"],times="0",original-location="main"}\r'
		local bp = require('gdb.mi.bkpt')
		bp.init()
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

	it('breakpoints table', function()
		local s = '^done,BreakpointTable={nr_rows="2",nr_cols="6",hdr=[{width="7",alignment="-1",col_name="number",colhdr="Num"},{width="14",alignment="-1",col_name="type",colhdr="Type"},{width="4",alignment="-1",col_name="disp",colhdr="Disp"},{width="3",alignment="-1",col_name="enabled",colhdr="Enb"},{width="18",alignment="-1",col_name="addr",colhdr="Address"},{width="40",alignment="2",col_name="what",colhdr="What"}],body=[bkpt={number="1",type="breakpoint",disp="keep",enabled="y",addr="0x00005555555551c6",func="main",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="33",thread-groups=["i1"],times="1",original-location="main"},bkpt={number="2",type="breakpoint",disp="keep",enabled="y",addr="0x0000555555555196",func="some_func",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="24",thread-groups=["i1"],times="0",original-location="some_func"}]}\r'
		local bp = require('gdb.mi.bkpt')
		bp.init()
		bp.parse_list(s)
		assert.same({
			['/home/ronin/Develop/gdb.nvim/tests/c/test.c'] = {
				bps = { {
					en = true,
					line = 33,
					times = 1
				}, {
					en = true,
					line = 24,
					times = 0
				} }
			}
		}, bp.files)
	end)

	it('bkpt delete', function()
		local mes = '=breakpoint-deleted,id="4"\r'
	end)

	it('variables', function()
		local s = 'variables=[{name="item",\
		value="{name = 0x555555556008 \\"Resistor\\", price = 10.6}"},\
		{name="s",value="{item = {name = 0x555555556008 \\"Resistor\\", price = 10.6}, count = 1}"},\
		{name="ret",value="1431654544"},{name="i",value="21845"}]'
		local l = require('gdb.mi.locals')
		l.parse(s)
		-- print(vim.inspect(l.locals))
		-- print(l.locals)
		assert.same(
			{ {
			    children = { {
				children = {},
				name = "name",
				value = '0x555555556008 \\"Resistor\\"',
			      }, {
				children = {},
				name = "price",
				value = "10.6",
			      } },
			    name = "item",
			  }, {
			    children = { {
				children = { {
				    children = {},
				    name = "name",
				    value = '0x555555556008 \\"Resistor\\"',
				  }, {
				    children = {},
				    name = "price",
				    value = "10.6",
				  } },
				name = "item",
			      }, {
				children = {},
				name = "count",
				value = "1",
			      } },
			    name = "s",
			  }, {
			    children = {},
			    name = "ret",
			    value = "1431654544",
			  }, {
			    children = {},
			    name = "i",
			    value = "21845",
			  } }
			, l.locals)
	end)

	it('variables cpp', function()
		local l = require('gdb.mi.locals')
		local s = '^done,variables=[{name="fut",value="{<std::__basic_future<void>> = {<std::__future_base> = {<No data fields>}, _M_state = std::shared_ptr<std::__future_base::_State_baseV2> (use count 1, weak count 0) = {get() = 0x5555555752d0}}, <No data fields>}"},{name="j",value="10"}]\r'
		l.parse(s)
		assert.same(
		{} , l.locals)
	end)

	it('variables rust', function()
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
	end) ]]

	it('frame stop', function()
		local core = require'gdb.core'
		local frames = require'gdb.modules.frames'
		core.register_modules({"frames"})
		local str = {'*stopped,reason="breakpoint-hit",disp="keep",bkptno="1",\
		frame={addr="0x00005555555551c6",func="main",args=[],file="tests/c/test.c",\
		fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="33",arch="i386:x86-64"},thread-id="1",stopped-threads="all",core="0"\r'}
		core.mi_on_stdout(_, str)
		print(vim.inspect(frames))
		core.unregister_modules()
	end)
end)
