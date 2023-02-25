describe('test', function()
	--[[ it('bkpt', function()
		local bkpt_mod = require'gdb.modules.bkpts'

		print(vim.inspect(bkpt_mod))

		local str = '=breakpoint-created,bkpt={number="1",type="breakpoint",\
		disp="keep",enabled="y",addr="0x00000000000011ca",func="main",\
		file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",\
		line="33",thread-groups=["i1"],times="0",original-location="main"}\r'
		bkpt_mod:attach()

		local parsers = {unpack(bkpt_mod.parsers)}

		for _,v in ipairs(parsers) do
			print(vim.inspect(v))
			if str:match(v.pattern) then
				v.pfunc(str)
			end
		end

		print(vim.inspect(bkpt_mod.files))

		bkpt_mod:detach()
	end) ]]

	it('start debug', function()
		local gdb = require 'gdb'
		gdb.setup({
			modules = {
				frames = { kek = "kok" },
				kek = "kok",
			}
		})
		--gdb.debug_start()
		local config = require 'gdb.config'
		print(vim.inspect(config.modules))
		--gdb.debug_stop()
	end)

	--[[ it('modules iface', function()
		local kek = require'gdb.modules.iface':new()
		print(vim.inspect(kek))
		kek:attach()
	end) ]]

	it('modules load/unload', function()
		local core = require 'gdb.core'
		core.register_modules({
			"bkpts",
			"test",
		})
		core.unregister_modules()
	end)
end)
