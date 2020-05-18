SECTION .data
counter     dw 0
tmp_byte    db "0"
msg         db "Hello, world!", 0xa, "%d", 0xa, "%b", 0xa,"%b", 0xa, 0x0
string      db "I %s %x %d %% %c%b", 0xa, 0x0
len         equ $ - msg
mes		    db "love", 0
buff_size   equ 512

SECTION .bss
tmp_string  resb 64 
buff 	    resb buff_size

SECTION .text
global _start           
_start:              

    mov rsi, msg
    xor rax, rax
    mov ax, 32
    push rax
    mov ax, 16
    push rax
    mov ax, 11
    push rax
    call printf
    sub rsp, rsi	
    mov eax, 1
    mov ebx, 0
    int 0x80


;=======================================================
;	Input: 		push in stack all arguments in reverse order
;				rsi - ptr to string
;	
;   Destroy: rdi, rdx, rsi, rax, r15, rcx, r14
;
;=======================================================
printf:
	push rbp
	mov rbp, rsp
	xor r14, r14					;counter
	.Loop:

		cmp byte [rsi], byte 0x0 	;EOL
			je .End
		cmp byte [rsi], '%'			;Argument
			jne .Print_char
		
		add r14, 8
		mov r15, rsp				;current variable
		add r15, r14
		mov r15, [r15]
		push rsi
		call GetArgs
		pop rsi
		inc rsi
		inc rsi
		jmp .Loop
		
		.Print_char:
			push rsi
			mov dl, [rsi]
			call PrintChar
			pop rsi
			inc rsi
			jmp .Loop
	.End:
	call PrintAllBuff

	leave
	mov rsi, r14
	ret

;=======================================================
;	Input: 		r15 - argument
;	
;   Destroy: rdi, rdx, rsi, rax, r15, rcx
;
;=======================================================
GetArgs:
	inc rsi
	cmp byte [rsi], 'd'
		je .dec
	cmp byte [rsi], 'x'
		je .hex
	cmp byte [rsi], 'o'
		je .oct
	cmp byte [rsi], 'b'
		je .bin
	cmp byte [rsi], 's'
		je .str
	cmp byte [rsi], 'c'
		je .chr
	cmp byte [rsi], '%'
		je .percent

	.dec:
		call GetDec
		ret
	.hex:
		call GetHex
		ret
	.oct:
		call GetOct
		ret
	.bin:
		call GetBin
		ret
	.str:
		call GetStr
		ret
	.chr:
		mov rdx, r15
		call PrintChar
		ret
	.percent:
		dec r14
		mov dl, '%'
		call PrintChar
		ret

;---------------------------------------------------------
;	Input:   r15
;
;   Destroy: rdi, rdx, rsi, rax, r15, rcx
;---------------------------------------------------------
GetDec:
	mov r9, 10

	mov rdi, tmp_string
	cmp r15, 0
		je .zero
	.Loop:
		cmp r15, 0
			je .print
		xor rdx, rdx
		mov rax, r15
		div r9
		add dl, '0'
		mov byte [rdi], dl
		inc rdi
		mov r15, rax
		jmp .Loop

	.zero:
		mov rdi, '0'
		call PrintChar
		jmp .end

	.print:
		mov r15, tmp_string
		.Output:
			dec rdi
			cmp rdi, r15
				jb .end
			mov dl, byte[rdi]
			push rdi
			call PrintChar
			pop rdi
			jmp .Output

	.end:
		ret



;---------------------------------------------------------
;		Input:  dl - char
;
;		Destroy: rdi, rdx, rsi, rax
;---------------------------------------------------------
PrintChar:
	mov [tmp_byte], dl

	mov rsi, tmp_byte
	mov rax, 1
	mov rdi, 0
	mov rdx, 1
	call print_buff
	ret

;---------------------	------------------------------------
;	Input: 	r15
;
;   Destroy: rdi, rdx, rsi, rax, r15, rcx
;---------------------------------------------------------
GetHex:
	mov dl, '0'
	call PrintChar
	mov dl, 'x'
	call PrintChar
	mov cl, 4
	call Print2Pwr
	ret

;---------------------------------------------------------
;	Input: 	r15
;
;   Destroy: rdi, rdx, rsi, rax, r15, rcx
;---------------------------------------------------------
GetOct:
	mov dl, '0'
	call PrintChar
	mov dl, 'o'
	call PrintChar
	mov cl, 3
	call Print2Pwr
	ret
;---------------------------------------------------------
;	Input: 	r15
;
;   Destroy: rdi, rdx, rsi, rax, r15, rcx
;---------------------------------------------------------
GetBin:
	mov dl, '0'
	call PrintChar
	mov dl, 'b'
	call PrintChar
	mov cl, 1
	call Print2Pwr
	ret

;---------------------------------------------------------
;	Input: 	r15 - ptr to str
;
;	Destroy: rdi, rdx, rax, rsi
;---------------------------------------------------------
GetStr:
	mov rdi, r15
	call strlen
	mov rax, 1
	mov rdi, 0
	mov rdx, rcx
	mov rsi, r15
	call print_buff
	ret
	



;=================================
;Arg:		rdi - ptr to mem (receive)
;
;Return: 	cx - strlen
;
;Reset: 	di to end of line
;			al
;=================================
	
strlen:
	cld

	mov rcx, 0FFFFh
	mov al, 00h

	repne scasb

	inc rcx
	sub rcx, 0FFFFh
	neg rcx

	ret


;=================================
;Arg:		r15 - number to print
;			cl  - power of two system
;
;Destroy: rdi, rdx, rsi, rax, r15, rcx
;=================================
Print2Pwr:
	mov rdi, tmp_string
	cmp r15, 0
		je .zero
	.Loop:
		cmp r15, 0
			je .print
		mov rax, r15
		shr r15, cl
		shl r15, cl
		sub rax, r15
		add al, '0'
		cmp al, '9'
			jbe .eq
		add al, 'a' - 10 - '0'
		.eq:
		mov byte [rdi], al
		inc rdi
		shr r15, cl
		jmp .Loop

	.zero:
		mov rdi, '0'
		call print_buff
		jmp .end

	.print:
		mov r15, tmp_string
		.Output:
			dec rdi
			cmp rdi, r15
				jb .end
			mov dl, byte[rdi]
			push rdi
			call PrintChar
			pop rdi
			jmp .Output

	.end:
		ret


print_buff:
	cmp word [counter], (buff_size / 2)
		jb .Next 
	call PrintAllBuff
	.Next:
		mov rcx, rdx
		mov rdi, buff
		add di, [counter]
		rep movsb
		add word [counter], dx
		ret

PrintAllBuff:
	mov dx, word [counter]
	mov rax, 1
	mov rdi, 0
	mov rsi, buff
	syscall
	mov word [counter], 0
	ret