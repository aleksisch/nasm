locals @@
.model tiny
.code
.386
org 100h

pass_len equ 19

start:
	call GetPassword
	mov cx, 00
	cmp cx, pass_len
	ja cxLess
	mov cx, pass_len

	cxLess:
	mov di, offset password
	mov si, offset buff
	
	call strcmp
	je Equal

	call Failed
	jmp EndStart

	Equal:
		call Success

	EndStart:
		mov ax, 4c00h
		int 21h

Success proc
	push cs
	pop ds
	mov ah, 09h
	mov al, 00h
	mov dx, offset Msg
	int 21h
	ret
	Msg db "Great Job$"
	endp
	

Failed proc
	push cs
	pop ds
	mov ah, 09h
	mov al, 00h
	mov dx, offset Message
	int 21h
	ret
	Message db "You're not welcome here$"
	endp
	
strcmp proc
	cld
	@@Search:
		dec cx
		cmp cx, 0
		je @@zero
		
		cmpsb
		jne @@end

		jmp @@Search

	@@zero:
		cmpsb

	@@end:
		ret
	endp

GetPassword proc
	mov di, offset buff
    @@Loop:

    	mov ah, 01h
    	int 21h
    	cmp al, 0dh
    	je @@End

    	stosb
    	jmp @@Loop

    @@End:
    	sub di, offset buff
    	mov cx, di
    ret
	endp

Password db "top secret password"
filename db "input.txt"
Buff db 0

end start		
