local M = {}

local fn = vim.fn
local api = vim.api

local log = require('gdb.log')
local bps = require('gdb.mi.breakpoints')

local function read_callback(args)
	local file = fn.fnamemodify(args.file, ':p')
	local buf = args.buf
	log.debug('file acmd:', file, 'buf:', buf)
	if not bps.files[file] then
		log.debug('file dont have bp')
		return
	end
	-- Render all bps necessary only if buffer opened for
	-- the first time. 
	bps.files[file].buf = buf
	-- Feels like it can be optimized
	for _,v in ipairs(bps.files[file].bps) do
		-- Just wrapper can get rid of it
		-- Check if sign needs to be placed
		-- or replaced in case of type change
		if not v.sign then
			v.sign = M.place_bp(args.buf, v.line)
		end
	end
end

function M.init(options)
	-- Create breakpoints sign and pc sign
	fn.sign_define('GdbPC', { text = '', linehl = 'StatusLine' })
	fn.sign_define('GdbBP', { text = '⬤' })
	-- api.nvim_create_augroup('Gdb', {clear = true})
	M._autocmd = api.nvim_create_autocmd('BufReadPost',{
		-- group = 'Gdb',
		-- pattern = {'*.c', '*.h', '*.cpp', '*.hpp', '*.rs'},
		callback = read_callback
	})
	M._pc = {}
	M._bps = {}
end

function M.place_bp(buf, lnum)
	return fn.sign_place(0, 'GdbBP', 'GdbBP', buf, {
		lnum = lnum,
	 	priority = 2
	})
end

function M.remove_bp(id)
	return vim.fn.sign_unplace('GdbBP', {
		id = id
	})
end

-- File or buf ???
function M.update_pc(buf, lnum)
       log.debug('updating pc')
       if M._pc.buf and M._pc.id then
	       fn.sign_unplace('GdbPC')
       end
       M._pc.buf = buf
       M._pc.id = fn.sign_place(0, 'GdbPC', 'GdbPC', buf, {
               lnum = lnum,
               priority = 0
       })
end

function M.cleanup()
	M._pc = nil
	M._bps = nil
	fn.sign_unplace('GdbPC')
	fn.sign_undefine('GdbPC')
	fn.sign_unplace('GdbBP')
	fn.sign_undefine('GdbBP')
	api.nvim_del_autocmd(M._autocmd)
end

return M
