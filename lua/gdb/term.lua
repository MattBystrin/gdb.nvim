local M = {}
local log = require'gdb.log'
local api = vim.api

local base_args = {
	"-q",
	"-iex", "set pagination off",
	"-iex", "set mi-async on",
	"-iex", "set breakpoint pending on"
}

function M.init(command, pty, proc)
	log.debug("creating term")
	-- Add some arguments that need to properly start
	for _, v in ipairs(base_args) do
		table.insert(command, v)
	end
	if pty then
		table.insert(command, "-iex")
		table.insert(command, "new-ui mi " .. pty)
	end
	local tmp = api.nvim_get_current_buf() -- Save buffer
	M.buf = api.nvim_create_buf(true, false)
	api.nvim_set_current_buf(M.buf)
	M.chan = vim.fn.termopen(command, {
		on_exit = function()
			log.debug('gdb exit')
			api.nvim_buf_delete(M.buf, {force = true})
		end
	})
	api.nvim_set_current_buf(tmp) -- Restore buffer
	log.debug("gdb buf: ", M.buf, ", chan: ", M.chan)

	return M.buf
end

function M.cleanup()
	local ret = vim.fn.jobstop(M.chan)
	log.debug('term ret: ', ret)
	return ret
end

return M
