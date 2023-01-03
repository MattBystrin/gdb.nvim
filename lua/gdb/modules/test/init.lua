local M = require'gdb.modules.iface':new()
M.name = 'test'

local log = require'gdb.log'

function M:attach()
	log.debug('test attach override')
end

return M
