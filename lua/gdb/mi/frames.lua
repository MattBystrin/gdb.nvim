local M = {}
-- -stack-list-frames

function M.get_stack()
end

function M.parse(str)
	local frames = {}
	for m in str:gmatch('frame=(%b{})') do
		local level = tonumber(m:match('level="([^"]+)')) + 1
		if not level then return end
		frames[level] = {}
		local frame = frames[level]
		frame.addr = m:match('addr="([^"]+)')
		frame.func = m:match('func="([^"]+)')
		frame.file = m:match('file="([^"]+)')
		frame.full = m:match('fullname="([^"]+)')
		frame.line = tonumber(m:match('line="([^"]+)'))
	end
	M.frames = frames
end

function M.select_frame()
end

return M
