local M = {}
local log = require'gdb.log'
local ui = require'gdb.ui'

local function default_stop_handler(file, line, _)
	ui.open_file(file, line)
end

local function default_error_handler(msg)
	vim.api.nvim_echo({ { msg } }, true, {})
end

M.parsers = {}
M.stop_handlers = {}

local function mi_parse(str)
	log.debug("data in parse: ", str)
	if str:find('^*stopped') then
		local reason = str:match('reason="([^"]+)')
		local file = str:match('fullname="([^"]+)')
		local line = tonumber(str:match('line="([^"]+)'))
		default_stop_handler(file, line, reason)
		for _, handler in ipairs(M.stop_handlers) do
			handler(str)
		end
		return
	end
	if str:find('^%^error') then
		local msg = str:match('msg="([^,$]+)"')
		default_error_handler(msg)
		return
	end
	if str:find('^=thread%-selected') then
		local file = str:match('fullname="([^"]+)')
		local line = tonumber(str:match('line="([^"]+)'))
		default_stop_handler(file, line)
	end
	for _, p in ipairs(M.parsers) do
		if str:find(p.pattern) then
			p.handler(str)
		end
	end
end

local midata = ""
function M.mi_on_stdout(_, data) -- Exported for tests
	if not data then return end
	log.debug("data in callback", data)
	-- Here 'raw' data have to be assmebled to analyse it line by line
	for _,v in ipairs(data) do
		if v:find("\r") then
			mi_parse(midata .. v:gsub("\r",""))
			midata = ""
		else
			midata = midata .. v
		end
	end
end

function M.launch()
	log.debug('creating mi job')
	M.mchan = vim.fn.jobstart("tail -f /dev/null #mijob", {
		pty = true,
		on_stdout = M.mi_on_stdout
	})
	log.debug("mi chan: ", M.mchan)
	if not M.mchan then
		return nil
	end
	return vim.api.nvim_get_chan_info(M.mchan)['pty']
end

function M.get_pty()
	return vim.api.nvim_get_chan_info(M.mchan)['pty']
end

function M.cleanup()
	M.parsers = {}
	M.stop_handlers = {}
end


return M
