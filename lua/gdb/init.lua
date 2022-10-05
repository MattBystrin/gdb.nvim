local M = {}

function M.setup()
	print('Gdb setup func')
end

function M.next()
	vim.api.nvim_echo({{'next'}}, false, {})
end

function M.step()
	vim.api.nvim_echo({{'step'}}, false, {})
end

function M.continue()
	vim.api.nvim_echo({{'continue'}}, false, {})
end

function M.toggle_breakpoint()
	vim.api.nvim_echo({{'toggle bp'}}, false, {})
end

function M.finish()
	vim.api.nvim_echo({{'finish'}}, false, {})
end

function M.set_condition()
	vim.api.nvim_echo({{'condition'}}, false, {})
end

return M
