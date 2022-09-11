local M = {}
local api = vim.api
local log = require('gdb.log')
-- require mi send
function M.create()
	M.files = {}
	-- log.info('created bp buf', M.buf)	
	log.debug('init bp')
	vim.fn.sign_define('GDBBP', {
		text = '⬤',
	})
	-- api.nvim_create_augroup('GDB', {clear = true})
	M.autocmd = api.nvim_create_autocmd('BufReadPost',{
		-- group = 'GDB',
		callback = function(args)
			local file = vim.fn.fnamemodify(args.file, ':p')
			local buf = args.buf
			log.debug('file acmd:', file, 'buf:', buf)
			log.debug(M.files)
			if not M.files[file] then
				log.debug('file dont have bp')
				return
			end
			M.files[file].buf = buf
			for _,v in ipairs(M.files[file].bps) do
				-- Just wrapper can get rid of it
				-- Check if sign needs to be placed
				if not v.sign then
					v.sign = M.place_sign(args.buf, v.line)
				end
			end
		end
	})
	log.debug('autocmd num:', M.autocmd)
end

function M.place_sign(buf, lnum)
	log.debug('placing sign')
	local id = vim.fn.sign_place(0, 'GDBBP', 'GDBBP', buf, {
		lnum = lnum,
	 	priority = 2
	})
	return id
end

function M.delete_sign(id)
	if not M[id] then return end
	vim.fn.sign_unplace('GDBPC', {
		buffer = M[id].buf,
		id = id
	})
	M[id] = nil
end


function M.parse(str)
	if not str then return end
	log.trace('breakpoint event')
	-- Can be created modified and deleted
	local file = string.match(str, 'fullname=(%b"")')
	if not file then return end
	file = string.sub(file, 2, -2)
	local line = string.match(str, 'line=(%b"")')
	line = tonumber(string.sub(line, 2, -2))
	local id = string.match(str, 'number=(%b"")')
	id = tonumber(string.sub(id, 2, -2))
	local en = string.match(str, 'enabled=(%b"")') == '"y"'
	local times = string.match(str, 'times=(%b"")')
	times = tonumber(string.sub(times, 2, -2))
	log.debug('f: ', file, ', l:', line, 'id:', id, 'e:', en)
	if not M.files[file] then
		M.files[file] = {}
		M.files[file].bps = {}
	end
	-- Note about modified hit in br
	if not M.files[file].bps[id] and id then
		M.files[file].bps[id] = {}
	end
	local bp = M.files[file].bps[id]
	bp.line = line
	bp.en = en
	bp.times = times
	if M.files[file].buf and not bp.sign then
		bp.sign = M.place_sign(M.files[file].buf, line)
	end
	log.debug('bps', M.files)
end

function M.clean()
	vim.fn.sign_unplace('GDBBP')
	vim.fn.sign_undefine('GDBBP')
	api.nvim_del_autocmd(M.autocmd)
	M.files = nil
	log.debug(M.files)
end

return M
