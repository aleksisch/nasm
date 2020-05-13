SECTION .data
buff_size   equ 20
buff        times buff_size db 0
password    db "Sosat", 0xa
len         equ $ - password
strE        db 0, "Succesful!!", 0xa, 0
strEsize    equ $ - strE
strNE       db "Failed", 0xa, 0
strNEsize   equ $ - strNE


SECTION .text
global _start           
_start:              

    mov rax, 0
    mov rdi, 0
    mov rsi, buff
    mov rdx, 5 * buff_size
    syscall

    mov rax, 1
    mov rdi, 0
    mov rsi, buff
    mov rdi, password
    mov rcx, len
    call strcmp
        je .Equal
    
    mov rsi, strNE
    mov rdx, strNEsize
    jmp .End

    .Equal:
    mov rsi, strE
    mov rdx, strEsize
    
    .End:    
        mov rax, 1
        mov rdi, 0
        syscall

        mov eax, 1
        mov ebx, 0
        int 0x80



;=================================
;Arg:       rdi - ptr to mem 
;           rsi - ptr to mem 
;           rcx - size of string
;Reset:     ax
;=================================
    
strcmp:
    
    cld
    .Search:
        cmp rcx, 0
            je .end
        dec rcx
        cmp byte [rdi], 0xa
            je .zero
        cmp byte [rsi], 0xa
        je .zero

        cmpsb
        jne .end
        
        jmp .Search

    .zero:
        cmpsb
    .end:
        ret
