local M = {}

M.locals = {}

function M.clear_locals()
	-- for v in pairs(M.locals) do 
	-- 	M.locals[v] = nil
	-- end
end

function M.parse(data)
	-- local vars = string.match(data, 'variables=%[([^%]]+)')
	-- log.info('found vars')
	-- if vars then 
	-- 	log.info('get vars ' .. vars)
	-- end
	print('Parsing')
	local str = 'variables=[{name="item",value="{name = 0x555555556008 \\"Resistor\\", price = 10.6}"},{name="s",value="{item = {name = 0x555555556008 \\"Resistor\\", price = 10.6}, count = 1}"},{name="ret",value="1431654544"},{name="i",value="21845"}]'
	for m in string.gmatch(str, '%b{}') do
		print(string.sub(m, 2, -2))
	end
end

M.parse()
