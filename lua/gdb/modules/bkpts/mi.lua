local M = {}

function M.parse_internal(str, tbl)
	local file = str:match('fullname="([^"]+)')
	local line = tonumber(str:match('line="([^"]+)'))
	local id = tonumber(str:match('number="([^"]+)'))
	local hits = tonumber(str:match('times="([^"]+)'))
	local en = str:match('enabled="([^"]+)') == 'y'
	local cond = str:match('cond="([^"]+)')
	local addr = str:match('addr="([^"]+)')
	local type = str:match('type="([^"]+)')

	if not id then return end

	tbl[id] = tbl[id] or {}
	tbl[id].file = file
	tbl[id].line = line
	tbl[id].en = en
	tbl[id].hits = hits
	tbl[id].cond = cond
	tbl[id].addr = addr
	tbl[id].type = type

	return tbl[id]
end

return M
