generates patches for game boy (color) games.

building requires git (sort of), lua, and make. the makefile uses luajit by
default; if you want to use puc-rio lua or another implementation, you will
need to edit the makefile accordingly.

```
git clone https://github.com/jangler/lgbtasm.git
git submodule init
git submodule update
make 
```

you can add more patches by adding new files in the `asm/` folder, using the
same format as the existing files. lgbtasm is intentionally strict about
formatting; see <https://github.com/jangler/lgbtasm#usage> for details.

note that only the code specific to this project is unlicensed / public domain.
the submodules lgbtasm and lua-struct are MIT-licensed, and their copyight
notices must be preserved whenever they are distributed.
