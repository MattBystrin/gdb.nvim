local M = {}

-- Get current thread
-- Select thread
-- Parse info about threads
M.parse = function(str)
	local curr = str:match('current-thread-id="([^"]+)')
	local threads = str:match('threads=%b[]')
	-- Getting threads info
	for v in threads:gmatch('%b{}') do
		--print(v)
	end
end

return M
