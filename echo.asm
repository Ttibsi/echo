format ELF64 executable
;; https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/

SYS_WRITE = 1
SYS_CLOSE = 3
SYS_SOCKET = 41
SYS_ACCEPT = 43
SYS_SENDTO = 44
SYS_RECVFROM = 45
SYS_BIND = 49
SYS_LISTEN = 50
SYS_EXIT = 60

STDIN = 0
STDOUT = 1
STDERR = 2

AF_INET = 2
SOCK_STREAM = 1

segment readable writeable executable

macro exit returncode {
    mov rax, SYS_EXIT
    mov rdi, returncode
    syscall
}

macro empty_buffer [buf] {
    mov rax, buf
    stosq
}

macro str_cmp buf, str {
    mov esi, buf
    mov edi, str
    xor eax, eax

    cmps dword [fs:esi],[edi]
    setnz al
}

macro run_call {
    syscall
    cmp rax,0
    jl .error
}

macro close_socket fd {
    mov rax, SYS_CLOSE
    mov rdi, fd
    syscall
}

_start: 
    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    run_call

    mov r12, rax ; server fd

    mov word [addr.sin_family], AF_INET
    mov word [addr.sin_port], 36895 ; htons(8080)36895 ; htons(8080)
    mov dword [addr.sin_addr], 0

    mov rax, SYS_BIND
    mov rdi, r12
    mov rsi, addr.sin_family
    mov rdx, addr_size
    run_call

    mov rax, SYS_LISTEN
    mov rdi, r12
    mov rsi, 8
    run_call

.loop:
    mov rax, SYS_ACCEPT
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    run_call

    mov r13, rax ; client fd

    mov rax, SYS_RECVFROM
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 256
    mov r10, 0
    mov r8, 0
    mov r9, 0
    run_call

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, buffer
    mov rdx, 256
    syscall

    mov rax, SYS_SENDTO
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 256
    mov r10, 0
    mov r8, 0
    mov r9, 0
    run_call

    str_cmp buffer, quit_str
    test rax, rax
    jz .quit

    empty_buffer buffer

    close_socket r13
    jne .loop

.quit:
    mov rax, SYS_SENDTO
    mov rdi, r13
    mov rsi, goodbye
    mov rdx, $-goodbye
    mov r10, 0
    mov r8, 0
    mov r9, 0
    run_call

    close_socket r13

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, goodbye
    mov rdx, $-goodbye
    run_call

    close_socket r12
    exit 0 
    ret

.error:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, error_msg
    mov rdx, 7
    syscall

    close_socket r12
    close_socket r13
    exit 1

segment readable writeable
struc servaddr_in {
    .sin_family dw 0
    .sin_port   dw 0
    .sin_addr   dd 0
    .sin_zero   dq 0
}

quit_str db "quit", 10, 0
goodbye db "Goodbye...", 10, 0
error_msg db "Error", 10, 0

buffer db 256 dup 0
addr servaddr_in
addr_size = $ - addr
