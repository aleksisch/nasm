locals @@
.model tiny
.code
.386
org 100h

start:
	call Test1
	sub ax, dx
	call Test2
	sub ax, dx


	mov dx, di
	mov ah, 09h
	int 21h

	mov ax, 4c00h
	int 21h


Test1:
	in ax, 40h
	mov dx, ax
	in ax, 40h
	ret
	mov cx, 1
	rep1:
		mov si, offset Sec
		mov al, 'd'
		mov di, offset Msg
		call strrchr
		dec cx
		cmp cx, 0	
			jne rep1
	in ax, 40h
	ret

Test2:
	in ax, 40h
	mov dx, ax
	mov cx, 10
	rep2:
		mov si, offset Sec
		mov al, 'd'
		mov di, offset Msg
		push cx
		call strrchr2
		pop cx
		dec cx
		cmp cx, 0
			jne rep2
	in ax, 40h
	ret


;=================================
;Arg:		di - pointer to string
;			al - ascii code
;			cx - max size of memory
;
;Return: 	di - ptr to byte
;
;Destroy:   cx
;=================================

memchr:

	cld
	repne scasb
	dec di
	
	ret

;=================================
;Arg:		di - ptr to mem
;			cx - number of byte
;			al - value
;Return: 	di - ptr to str
;
;Destroy:   cx
;=================================

memset:
	cld
	rep stosb
	ret

;=================================
;Arg:		di - ptr to mem (receive)
;			si - ptr to mem (transmit)
;			cx - number of byte
;			al - value
;
;Return: 	di - ptr to str
;
;Destroy:   cx, si
;=================================
		
memcpy:
	cld
	rep movsb 
	ret

;=================================
;Arg:		di - ptr to mem (receive)
;
;Return: 	cx - strlen
;
;Destroy: 	di,al
;=================================
	
strlen:
	cld

	mov cx, 0FFFFh
	mov al, 00h

	repne scasb

	inc cx
	sub cx, 0FFFFh
	neg cx

	ret

;=================================
;Arg:		di - ptr to mem (receive)
;			si - ptr to mem
;			cx - max size to cmp
;Return: 	si cmp with di, result in flag
;
;Destroy:   cx, si, di
;=================================

memcmp:
	cld
	repe cmpsb
	ret

;=================================
;Arg:		di - ptr to mem (receive)
;			al - char
;Return: 	di - memory ptr
;
;Destroy:   ax
;=================================

strchr proc
	cld
	mov ah, al
	@@Search:
		lodsb 
		cmp al, 00h
			je @@end
		cmp ah, al
			jne @@Search
	dec di
	ret
	endp

;=================================
;Arg:		si - ptr to mem (receive)
;			al - char
;Return: 	si - memory ptr
;
;Destroy:   ax, di
;=================================

strrchr proc
	cld
	mov ah, al
	@@Loop:
		lodsb
		cmp al, 00h
			je @@end
		cmp ah, al
			je @@Dec
		jmp @@Loop

	@@end:
		mov si, di
		dec si
		ret

	@@Dec:
		mov di, si
		jmp @@Loop
	endp

;=================================
;Arg:		di - ptr to mem (receive)
;			al - char
;Return: 	si - memory ptr
;Destroy: 	cx, di, ax
;=================================

strrchr2:
	mov ah, al
	call strlen
	mov al, ah
	std
	repne scasb
	inc di
	ret

;=================================
;Arg:		di - ptr to mem (receive)
;			si - ptr to mem (transmit)
;
;Destroy: 	cx, si, di
;=================================
	
strcpy proc
	
	cld
	@@Copy:
		cmp byte ptr si, 00h
			je @@end
		movsb
		jmp @@Copy
	@@end:
	ret
	endp

;=================================
;Arg:		di - ptr to mem 
;			si - ptr to mem 
;
;Destroy:	si, di
;Return:    result in flags
;=================================
	
strcmp proc

	cld
	@@Search:
		cmp byte ptr [di], 00h
		je @@zero
		cmp byte ptr [si], 00h
		je @@zero

		cmpsb
		jne @@end
		
		jmp @@Search

	@@zero:
		cmpsb
	@@end:
		ret
	endp

Msg db "aellodfdfdfdfzo$", 00h
Sec db "aellsssdsdsdszo$", 00h
Buff db 256 dup(0)

end start		