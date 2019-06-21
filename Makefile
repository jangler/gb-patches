LUA=luajit
OUTDIR=ips/

build:
	mkdir -p $(OUTDIR) && $(LUA) gen.lua asm/* $(OUTDIR)

clean:
	rm -rd $(OUTDIR)
