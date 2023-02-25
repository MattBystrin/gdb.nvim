# Current status
Plugin is still under heavy development. It have only base functionality but
still can be usable in some cases (and actually I use it). Also want to
notice that it have been tested only on Debian with Neovim v0.7.2.

Now I'm working on documentation for modules development and polishing core API.
After that I'm planning to add support for remote debugging setup.

# Alternatives
- [termdebug](https://github.com/vim/vim/blob/master/runtime/pack/dist/opt/termdebug/plugin/termdebug.vim)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-gdb](https://github.com/sakhnik/nvim-gdb)

# History & motivation
Initially this plugin was developed for educational purposes. I wanted to learn
Lua, Neovim API and create a plugin for `gdb` which is:
- Fully written with lua, with no external dependencies
- Support easy setup for remote debugging
- Keep the core as small as possible
- Easily extensible

I've been debugging mostly C and C++ applications for a relatively long time.
Since I've migrated to Neovim, I tried to use termdebug and nvim-dap plugins.
Termdebug is cool, but written in vimscript and I find it really hard to extend.
DAP is so complicated and there is only one DAP-server for C/C++/Rust which is
part of VS\*\*\*\*. Maybe some time I'll force myself to write a gdb DAP, but
not now.

You can consider this plugin as a stripped-down version of termdebug.

# What's done
## Architecture
Plugin have a **core** - the main code base that handle the basics, like sending
MI commands to `gdb` and opening files where exection stopped. All other
functions will be implemented by things called **modules**.

Why?

- First of all, it is really suits for my style of development, I can focus on
  one little thing and done it good. Have a long break. Proceed to another with
  no worries that it will breaks previous work (at least in theory).

- Secondly, you can disable modules you don't need.

## Features
By now plugin can do:
- open up source file where the program execution stops,
- control program execution. 

After start it create 2 windows: source file and `gdb` terminal.

Also it provides functions for controlling programm execution.
```
require'gdb'.debug_start()
require'gdb'.debug_stop()     
require'gdb'.next()
require'gdb'.step()
require'gdb'.stop()
require'gdb'.finish()
require'gdb'.continue()
require'gdb'.exec_until() - until the line where your cursor stands
require'gdb'.jump()       - to the line where your cursor stands
```
You can map those to have more comfort debug.

# How to install
Use your favorite package manager in Neovim. I prefer
[packer.nvim](https://github.com/wbthomason/packer.nvim):
```
use 'MattBystrin/gdb.nvim'
```
If you want to run test (which is not complete yet), make sure you have
`plenary.nvim` installed.

# Configuration
There is not much to config at least now. You can only set the command that will
be invoked when debug started. An example:
```lua
require'gdb'.setup({
	command = {
		"gdb",
		"--cd", "<some dir>"
	}
})
```
You can also setup your gdb startup behavior using `.gdbinit` file. It won't
break things and it's suitable for storing project specific configuration.

# Future plans
I'm not planning to add support for any other debuggers. If you need to debug
apps written in different languages consider using
[nvim-dap](https://github.com/mfussenegger/nvim-dap).

- Add remote debug setup.
- Add *monitor* - extra window for programm output
- Add config for UI layout.
- Add breakpoint support.
- Add stackframe support.



# Inspiration & thanks

Thanks to Bram Moolenaar an author of
[termdebug](https://github.com/vim/vim/blob/master/runtime/pack/dist/opt/termdebug/plugin/termdebug.vim)
plugin!

Thanks to [TJ DeVries](https://github.com/tjdevries) an author of [vlog.nvim]()
and [plenary.nvim]() !
