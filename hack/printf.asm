SECTION .data
buff_size   equ 512
buff        resb buff_size
password    db "SosiHui", 0x0
len         equ $ - msg


SECTION .text
global _start           
_start:              

    mov rax, 0
    mov rdi, 0
    mov rsi, buff
    mov rdx, buff_size
    syscall



    mov rax, 1
    mov rdi, 0
    mov rsi, msg
    mov rdx, 10
    syscall
    
    mov eax, 1
    mov ebx, 0
    int 0x80



;=================================
;Arg:       di - ptr to mem 
;           si - ptr to mem 
;
;Reset:     ax
;=================================
    
strcmp:

    cld
    .Search:
        cmp byte ptr [di], 00h
        je .zero
        cmp byte ptr [si], 00h
        je .zero

        cmpsb
        jne .end
        
        jmp .Search

    .zero:
        cmpsb
    .end:
        ret