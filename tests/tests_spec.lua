describe('gdb', function()
	it('require', function()
		print(vim.inspect({}))
		-- require('gdb')
	end)
end)

describe('MI parser ->', function()
	it('breakpoints', function()
		local gdb = require('gdb.mi')
		local s = '=breakpoint-created,bkpt={number="1",type="breakpoint",disp="keep",enabled="y",addr="0x00000000000011ca",func="main",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="33",thread-groups=["i1"],times="0",original-location="main"}\r'
		local bp = require('gdb.mi.breakpoints')
		bp.create()
		gdb.handle({s})
		assert.same(bp.files, {
			['/home/ronin/Develop/gdb.nvim/tests/c/test.c'] = {
				bps = {{
					en = true,
					line = 33,
					times = 0
				}}
			}
		})
	end)

	it('expressions', function()
		assert.equals(1,2)
	end)
end)
