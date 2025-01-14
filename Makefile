All:
	~/.opt/fasm/fasm echo.asm
	./echo

c:
	clang server.c -o server

clean:
	rm server echo
