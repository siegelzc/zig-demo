.PHONY: default clean

default: goodbye

clean:
	rm -rf goodbye goodbye.dSYM

../zig-out/include/*:
../zig-out/lib/libmymessage.a:
	zig build install

goodbye: goodbye.c ../zig-out/lib/libmymessage.a ../zig-out/include/*
	cc -g -L../zig-out/lib -lmymessage -o goodbye goodbye.c
