watch:
	ls **/*.zig | entr -csr 'zig build run'

run:
	zig build run

build:
	zig build

clean:
	rm -rf zig-out .zig-cache
