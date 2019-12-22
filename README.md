generates patches for game boy (color) games.

the finished products are already available in the `ips/` folder.

the only dependency is lua, i think. you'll probably want git for setting up
the submodules, though.

```
git clone https://github.com/jangler/lgbtasm.git
git submodule init
git submodule update
```

```
usage: lua gen.lua <outfile> <bankfile> <asmfile>...
```

you can add more patches by adding new files in the `asm/` folder, using the
same format as the existing files. lgbtasm is intentionally strict about
formatting; see <https://github.com/jangler/lgbtasm#usage> for details.

note that only the code specific to this project is unlicensed / public domain.
the submodules lgbtasm and lua-struct are MIT-licensed, and their copyight
notices must be preserved whenever they are distributed.
