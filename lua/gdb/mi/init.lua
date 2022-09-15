local M = {}

local api = vim.api

local log = require('gdb.log')
local bps = require('gdb.mi.breakpoints')
local loc = require('gdb.mi.locals')
local exp = require('gdb.mi.expressions')
local frm = require('gdb.mi.frames')
-- local thr = require('gdb.mi.threads') -- Future plans

local ui = require('gdb.ui')

function M.create()
	log.debug('creating mi')
	M.chan = vim.fn.jobstart("tail -f /dev/null #mijob", {
		pty = true,
		on_exit = function()
			log.debug('mi exit')
		end,
		on_stdout = function(_, data)
			if data then M.handle(data) end
		end
	})
	log.debug("mi chan: ", M.chan)
	bps.create()
end

function M.get_pty()
	if M.chan then return api.nvim_get_chan_info(M.chan)['pty'] end
end

function M.stop()
	bps.clean()
	local ret = vim.fn.jobstop(M.chan)
	log.debug('mi ret: ', ret)
	return ret
end

function M.send(data)
	api.nvim_chan_send(M.chan, data.args .. '\n')
end

function M.handle(data) -- Note: data is a table 
	log.trace('data received: ', data)
	local parse = {
	{ pattern = '=breakpoint', parser = bps.parse,      event = 'bps' },
	{ pattern = '*stopped',    parser = frm.parse_stop, event = 'stop'},
	{ pattern = 'variables=',  parser = loc.parse,      event = 'var'},
	{ pattern = 'done,value',  parser = exp.parse,      event = 'expr'},
	{ pattern = 'done,stack',  parser = frm.parse,      event = 'frm'}
	}
	for _, str in ipairs(data) do
		for _,v in ipairs(parse) do
			if str:find(v.pattern) then
				local ret = v.parser(str)
				if ret then
					local updates = {}
					updates[v.event] = v.parser(str)
					ui.notify(updates)
				end
			end
		end
		-- Do not forget to refactor pc sign
	end
end

return M
