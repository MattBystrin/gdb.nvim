local M = {}

local api = vim.api

local log = require('gdb.log')
local bps = require('gdb.mi.bkpt')
local loc = require('gdb.mi.locals')
local exp = require('gdb.mi.expr')
local frm = require('gdb.mi.frames')
-- local thr = require('gdb.mi.threads') -- Future plans

local ui = require('gdb.ui')

local function launch(handle)
	log.debug('creating mi job')
	M.chan = vim.fn.jobstart("tail -f /dev/null #mijob", {
		pty = true,
		on_exit = function()
			log.debug('mi exit')
		end,
		on_stdout = function(_, data)
			if data then handle(data) end
		end
	})
	log.debug("mi chan: ", M.chan)
	if not M.chan then return nil end
	return vim.api.nvim_get_chan_info(M.chan)['pty']
end

M.send = function(data)
	if not data then return end
	vim.api.nvim_chan_send(M.chan, data .. '\n')
end

function M.init()
	bps.init()
	return launch(M.handle)
end

function M.cleanup()
	vim.fn.jobstop(M.chan)
	bps.clean()
end

function M.handle(data) -- Note: data is a table 
	log.trace('data received: ', data)
	local function pstop(str)
		M.send('-stack-list-variables --skip-unavailable 1')
		return frm.parse_stop(str)
	end
	local function memchange(str)
		print("Memory changed")
		M.send('-stack-list-variables --skip-unavailable 1')
	end
	local parse = {
	{ pattern = '=breakpoint', parser = bps.parse,      event = 'bps' },
	{ pattern = '*stopped',    parser = pstop,          event = 'stop'},
	{ pattern = 'variables=',  parser = loc.parse,      event = 'var'},
	{ pattern = 'done,value',  parser = exp.parse,      event = 'expr'},
	{ pattern = 'memory',  parser = memchange, event = 'none'},
	{ pattern = 'done,stack',  parser = frm.parse,      event = 'frm'} }
	for _, str in ipairs(data) do
		for _,v in ipairs(parse) do
			if str:find(v.pattern) then
				local ret = v.parser(str)
				if ret then
					local updates = {}
					updates[v.event] = v.parser(str)
					ui.notify(updates)
				end
				break
			end
		end
	end
end

return M
