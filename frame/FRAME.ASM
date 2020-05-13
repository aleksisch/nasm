locals @@
.model tiny
.code
.386
org 100h

DEFAULT_WIDTH 		equ 80
DEFAULT_HEIGHT	 	equ 25
SCRREN_MID			equ (DEFAULT_WIDTH * (DEFAULT_HEIGHT / 2) + DEFAULT_WIDTH / 2) * 2;middle of screen
DEF_COLOUR			equ 4eh							;colour of frame
MULTIPLY			equ 03h							;multiply CX
DEF_REPEAT			equ 07h		 					;draw x times
FIRST 				equ 00h 						;indent in frame
DEF_SHADOW			equ 78h							;color of shadow

start:
	call GetArgs
	mov cx, first
	mov ax, [Middle]
	xor dx, dx
	mov dl, [Repeat]
	mov si, [TypeFrame]
	call DrawFrame

	mov bx, MsgPointer
	mov si, Middle

	call print

	mov ax, 4c00h
	int 21h

NumOfArgs 	dw 0
StartX 		db 12
StartY 		db 40
Middle 		dw SCRREN_MID
Repeat 		db DEF_REPEAT
TypeFrame	dw offset Type0
MsgPointer  dw offset Msg

;==================================================
;0)right and left
;1)up and down ascii code
;2)left up corner ascii code 
;3)left down corner ascii code
;4)right up corner ascii code
;5)right down corner ascii code
;6)colour of background
;7)colour of shadow
;8)Fill center
;==================================================
;		   0  	 1	   2	 3     4     5    6    7	8
Type0 db 0bah, 0cdh, 0c9h, 0c8h, 0bbh, 0bch, 4eh, 78h,	' '
Type1 db 036h, 0cdh, 0c9h, 0c8h, 0bbh, 0bch, 4eh, 78h,	' '
Type2 db 0bah, 0cdh, 0c9h, 0c8h, 0bbh, 0bch, 4eh, 78h,	' '

Msg db 100,  "Text to screen", 0dh


;=================================================
;Arg: 		di - read from there
;Return:	di = di + number of spaces
;			
;=================================================

SkipSpace proc
	@@SkipSpace:
		cmp byte ptr[di], ' '
			jne @@EndSkip
		inc di
		jmp @@SkipSpace
	@@EndSkip:
		ret 
		endp



;=================================================
;Arg: 		bx - ptr to variables
;			di - read from there
;Return:	di = di + number of readed bytes
;			
;=================================================

GetInt proc

	call SkipSpace

	mov cl, [di]
	cmp cl, 58
		ja @@End
	cmp cl, 48
		jb @@End

	mov byte ptr[bx], 0
	@@Loop:
		mov cl, [di]

		cmp cl, 58
			ja @@End
		cmp cl, 48
			jb @@End

		mov ax, 10
		mul byte ptr [bx]
		mov byte ptr [bx], al

		sub cl, '0'
		add byte ptr[bx], cl
		inc di
		jmp @@Loop

	@@End:
		ret
	endp

;=================================================
;Arg: 		bx - ptr to variable
;			di - read from there
;Return:	di = di + number of readed bytes
;			
;=================================================
GetChar proc
	call SkipSpace
	mov al, [di]
	mov byte ptr[bx], al
	inc di
	ret
	endp

;==================================================
;Read required arguments from PSP
;
;Destroy:  			ah, al, bx, di, cl
;==================================================
Type db 04h
GetArgs proc

	mov di, 81h

	mov bx, offset Type
	call GetInt

	mov bx, offset StartX
	call GetInt

	mov bx, offset StartY
	call GetInt

	mov ax, 160
	mul byte ptr [StartY]
	mov cl, byte ptr StartX
	xor ch, ch
	add ax, cx
	add ax, cx
	mov word ptr [Middle], ax

	mov bx, offset Repeat
	call GetInt	

	cmp byte ptr [Type], 4
		je @@Ret

	cmp byte ptr [Type], 0
		je @@t0
	cmp byte ptr [Type], 1
		je @@t1
	cmp byte ptr [Type], 2
		je @@t2
	cmp byte ptr [Type], 3
		je @@t3

	@@t0:
		mov TypeFrame, offset Type0
		jmp @@Ret

	@@t1:
		mov TypeFrame, offset Type1
		jmp @@Ret

	@@t2:
		mov TypeFrame, offset Type2
		jmp @@GetStr

	@@t3:
		mov TypeFrame, offset Type0
		mov bx, offset Type0
		mov cx, 0
		@@Loop:
			call GetChar
			inc bx
			inc cx
			cmp cx, 6
				jb @@Loop

		mov cx, 0

		@@Colour:
			push cx
			call GetInt
			pop cx
			inc bx
			inc cx
			cmp cx, 2
				jb @@Colour

		call GetChar
		jmp @@GetStr

	@@GetStr:
		mov word ptr MsgPointer, di
	@@Ret:
		ret

	endp

;==================================================
;Params: 	 		cx << 8 + dx millis
;Destroy:  			ah, al
;==================================================
Pause: 	
	mov ah, 86h
	mov al, 0000h
	int 15h 
	mov cx, di
	ret


;==================================================
;Return:  			bx = DEFAULT_WIDTH * 2 * cx
;					ax = multiply * 2 * cx
;					si = Middle
;					di = Middle
;==================================================
InitReg:
	mov si, Middle
	mov di, Middle	

	xor ax, ax
	mov al, 2 * DEFAULT_WIDTH
	mul cx 			;ax = DEFAULT_WIDTH * 2 * cx

	mov bx, ax

	xor ax, ax
	mov al, multiply * 2
	mul cx

	ret

;======================================
;Draw Frame
;Input: 	ax - Middle of screen
;			bx - Colour of frame
;			cx - first size of frame
;			dx - Number of repeat
;			di - Colour of shadow
;
;Destroy all register
;======================================
DrawFrame 		proc
	
	jmp @@Skip
	@@Middle dw ?
	@@Repeat dw ?
	@@Type   dw ?

	@@Skip:
	mov word ptr [@@Middle], ax
	mov word ptr [@@Repeat], dx
	mov word ptr [@@Type],   si

	mov bx, 0b800h
	mov es, bx	

	@@Loop:

		inc cx

		call InitReg

		sub si, bx		;si = center - cx * DEFAULT_WIDTH * 2
		add di, bx		;di = center + cx * DEFAULT_WIDTH * 2

		mov dx, si

		add dx, ax
		sub si, ax
		sub di, ax

		push cx
		push @@Type
		call GraphUpDown
		pop cx

		call InitReg

		sub si, bx									;si = center - (cx - 1) * DEFAULT_WIDTH * 2
		sub di, bx									;di = center - (cx - 1) * DEFAULT_WIDTH * 2
		add di, 2 * DEFAULT_WIDTH
		add si, 2 * DEFAULT_WIDTH

		add bx, @@Middle							;bx = DEFAULT_WIDTH * 2 * cx + center
		
		add di, ax									
		sub si, ax
		
		push cx
		
		push @@Type
		call DrawMiddle

		mov cx, 0001h
		mov dx, 8480h
		call Pause
		pop cx

		cmp cx, @@Repeat
			jne @@Loop
		ret
		endp

;===================================================
;
;Params: 		si - left up coord
;				di - left down coord
;				dx - right up coord (stop)
;				Type of frame in stack
;
;Destroy: 		all register
;
;===================================================
GraphUpDown proc

	mov bp, sp
	add bp, 2
	mov bp, [bp]

	mov bx, di
	add bx, 2 * (DEFAULT_WIDTH + 1)

	mov ah, [bp + 6]					;colour of background
	mov al, [bp + 2]
	mov word ptr es:[si], ax

	mov al, [bp + 3]
	mov word ptr es:[di], ax						;left down corner

	mov al, [bp + 1]

	xor cx, cx
	mov ch, [bp + 7]

	@@print:

		add di, 2
		add si, 2
		add bx, 2

		mov word ptr es:[si], ax
		mov word ptr es:[di], ax
		
		mov word ptr es:[bx], cx
	
		cmp si, dx
			jb @@print

	mov al, [bp + 4]
	mov word ptr es:[si], ax		;right up corner 

	mov al, [bp + 5]
	mov word ptr es:[di], ax		;right down corner

	ret 2
	endp

;===================================================
;
;Params: 		si - left coord
;				di - right Coord	
;				bx - right down coord (stop)
;				ax - Colour
;				dx - Shadow
;				cx - Type of frame
;
;Destroy: 		si, di, bx, ax, dx
;
;===================================================

DrawMiddle 		proc
	
	mov bp, sp
	add bp, 2
	mov bp, [bp]

	xor cx, cx
	mov ah, [bp + 6]
	mov ch, [bp + 7]

	@@print:
		mov al, [bp]
		mov word ptr es:[si], ax
		mov word ptr es:[di], ax

		add di, 2
		mov word ptr es:[di], cx
		sub di, 2

		push si
		add si, 2
		fill:
			mov al, [bp + 8]
			mov word ptr es:[si], ax

			add si, 2
			cmp si, di
				jb fill

		pop si

		add di, 2 * DEFAULT_WIDTH
		add si, 2 * DEFAULT_WIDTH
		
		cmp di, bx  
			jb @@print

	add di, 2
	mov word ptr es:[di], cx
	ret 2
	endp

;=================================
;Arg:		di - ptr to mem (receive)
;
;Return: 	cx - strlen
;
;Reset: 	di to end of line
;			al
;=================================
	
strlen proc
	mov cx, 0
	mov al, 0dh
	@@st:
		inc cx
		scasb
		cmp byte ptr [di], al
			je @@End
		jmp @@st
	@@End:
		ret
	endp
;==================================================
;Print text to screen
;
;Input:			bx - Pointer to string
;				si - Coord of start Text
;
;Destroy:		dx	, es
;
;==================================================

print  	proc
	mov dx, 0b800h
	mov es, dx
	mov di, bx
	call strlen
	shr cx, 2
	shl cx, 1
	sub si, cx
	sub si, cx

	@@Loop:
		mov byte ptr ah, [bx]
		mov byte ptr es:[si], ah
		add si, 2
		inc bx
		cmp byte ptr [bx], 00h
			je @@End
		cmp byte ptr [bx], 0dh
			je @@End
		jmp @@Loop
	@@End:
		ret
	endp		

end start