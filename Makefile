All: c asm

asm:
	~/.opt/fasm/fasm echo.asm

c:
	clang server.c -o server

clean:
	rm server echo
