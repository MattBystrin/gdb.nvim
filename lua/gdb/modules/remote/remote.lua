-- Module responsible for launching specific gdb-servers
-- for example when you debugging MCU
local M = require 'gdb.modules':new()

local log = require('gdb.log')

function M:attach()
	M.chan = vim.fn.jobstart({'tail -f /dev/null'},{
		on_exit = function()
			log.info('remote shutdown')
		end
	})
end

function M:detach()
	vim.fn.jobstop(self.chan)
end

return M
