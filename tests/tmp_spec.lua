describe('test', function()
	it('error msg parser', function()
		local msg = 'msg="No line 53 in file \\"/home/ronin/Develop/gdb.nvim/t,ests/intgr/c/test.c\\".", errcode="5"'
		local msg2 = 'msg="No line 53 in file \\"/home/ronin/Develop/gdb.nvim/t,ests/intgr/c/test.c\\"."'
		local pattern = 'msg="(.+)"'
		print(msg:match(pattern))
		print(msg2:match(pattern))
	end)
end)
