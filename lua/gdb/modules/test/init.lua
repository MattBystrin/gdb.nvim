local M = require'gdb.modules.iface':new()
M.name = 'test'

local log = require'gdb.log'

function M:on_attach(cfg)
	log.debug('Test module on_attach')
	for k,v in pairs(cfg) do
		log.debug(k .. " = " .. v)
	end
end

function M:on_detach()
	log.debug('Test module on_detach')
end

return M
