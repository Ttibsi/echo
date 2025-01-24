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
SYS_SETSOCKOPT = 54
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
    mov edi, buffer
    mov ecx, 256
    xor eax, eax
    rep stosb
}

macro str_cmp buf, str {
    mov esi, buf
    mov edi, str
    xor eax, eax

    cmps dword [fs:esi],[edi]
    setnz al
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
    syscall

    mov r12, rax ; server fd

    mov word [addr.sin_family], AF_INET
    mov word [addr.sin_port], 36895 ; htons(8080)36895 ; htons(8080)
    mov dword [addr.sin_addr], 0

    mov rax, SYS_BIND
    mov rdi, r12
    mov rsi, addr.sin_family
    mov rdx, addr_size
    syscall

    mov rax, SYS_LISTEN
    mov rdi, r12
    mov rsi, 8
    syscall

.loop:
    mov rax, SYS_ACCEPT
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    syscall

    mov r13, rax ; client fd

    mov rax, SYS_RECVFROM
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 256
    mov r10, 0
    mov r8, 0
    mov r9, 0
    syscall

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
    syscall

    str_cmp buffer, quit_str
    test rax, rax
    jz .quit

    empty_buffer buffer
    close_socket r13
    jmp .loop

.quit:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, goodbye
    mov rdx, goodbye_size
    syscall

    mov rax, SYS_SENDTO
    mov rdi, r13
    mov rsi, goodbye
    mov rdx, goodbye_size
    mov r10, 0
    mov r8, 0
    mov r9, 0
    syscall

    close_socket r13
    close_socket r12
    exit 0 
    ret

segment readable writeable
struc servaddr_in {
    .sin_family dw 0
    .sin_port   dw 0
    .sin_addr   dd 0
    .sin_zero   dq 0
}

quit_str db "quit", 10, 0
goodbye db 27, "[36mGoodbye...", 27, "[0m", 10, 0
goodbye_size = $ - goodbye
error_msg db "Error", 10, 0

buffer db 256 dup 0
addr servaddr_in
addr_size = $ - addr
