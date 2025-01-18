#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

int main() {
    int s = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
        .sin_port = htons(8080),
        .sin_addr.s_addr = INADDR_ANY
    };

    bind(s, (struct sockaddr *)&addr, sizeof(addr));
    listen(s, 8);

    while (1) {
        char buffer[265] = {0};
        int client_fd = accept(s, 0, 0);

        recv(client_fd, buffer, 256, 0);
        printf("%s", buffer);
        send(client_fd, buffer, 256, 0);

        if (strncmp(buffer, "quit", 4) == 0) {
            send(client_fd, "Goodbye...\n", 11, 0);
            close(client_fd);
            break;
        } else {
            close(client_fd);
        }
    }

    printf("Goodbye...\n");
    close(s);
    return 0;
}
