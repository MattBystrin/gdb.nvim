-- Module responsible for laungching and connecting to gdb-server
local M = {}

local log = require('gdb.log')

M.launch = function(args)
	M._chan = vim.fn.jobstart({'tail -f /dev/null'},{
		on_exit = function()
			log.info('remote shutdown')
		end
	})
end

M.launch()

return M
