format ELF64 executable
;; https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/

SYS_WRITE = 1
SYS_EXIT = 60

STDIN = 0
STDOUT = 1
STDERR = 2

_start: 
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, hello
    mov rdx, hello_size
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
    ret

hello db "Hello world",0xA
hello_size = $-hello

