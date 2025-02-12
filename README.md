# echo
A simple echo server implemented in both C and assembly

A Makefile is provided to wrap compiler commands. Clang is required for the C
implementation, and [fasm](https://flatassembler.net/) is required for the
assembly version.

In another terminal for either version, run the following command to send
some text to the server:

```console
echo "hello" | netcat localhost 8080
```

using the text `quit` instead will shutdown the server
