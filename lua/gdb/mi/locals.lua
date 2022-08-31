local M = {}

M.locals = {}

function M.clear_locals()
	for v in pairs(M.locals) do 
		M.locals[v] = nil
	end
end

function M.parse(data)
	local vars = string.match(data, 'variables=%[([^%]]+)')
	log.info('found vars')
	if vars then 
		log.info('get vars ' .. vars)
	end
end

return M
