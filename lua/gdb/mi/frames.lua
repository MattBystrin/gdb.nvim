local M = {}
-- stack-list-frames

function M.get_stack()
end

function M.parse()
	local str = 'stack=[frame={level="0",addr="0x000055555555519a",func="some_func",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="24",arch="i386:x86-64"},frame={level="1",addr="0x000055555555527f",func="main",file="tests/c/test.c",fullname="/home/ronin/Develop/gdb.nvim/tests/c/test.c",line="43",arch="i386:x86-64"}]'
	for m in string.gmatch(str, 'frame={([^}]+)') do
		print(m)
	end
end

M.parse()
