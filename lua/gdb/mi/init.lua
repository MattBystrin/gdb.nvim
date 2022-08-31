local M = {}

local log = require('gdb.log')
local pc = require('gdb.mi.stepline')
local bp = require('gdb.mi.breakpoints')

local api = vim.api

function M.create()
	log.debug('creating mi')
	M.chan = vim.fn.jobstart("tail -f /dev/null #debug_mi", {
		pty = true,
		on_exit = function()
			log.debug('mi exit')
		end,
		on_stdout = function(_, data)
			if data then
				M.handle(data)
			end
		end
	})
	log.debug("mi chan: ", M.chan)
	pc.init()
	bp.create()
end

function M.get_pty()
	if M.chan then
		return api.nvim_get_chan_info(M.chan)['pty']
	end
end

function M.stop()
	pc.cleanup()
	bp.clean()
	local ret = vim.fn.jobstop(M.chan)
	log.debug('mi ret: ', ret)
	return ret
end

function M.write(data)
	api.nvim_chan_send(M.chan, data.args .. '\n')
end

function M.handle(data) -- Note: data is a table 
	log.trace('data received: ', data)
	for _, str in ipairs(data) do
		if string.find(str, '=breakpoint') then
			bp.parse(str)
		elseif string.find(str, '*stopped') then
			pc.parse(str)
		elseif string.find(str, 'variables=') then
			-- var_event(i)
		elseif string.find(str, 'done,value') then
			-- Evaluate
		elseif string.find(str, 'done,stack') then
			-- Frame handle
		end
	end
end

return M
