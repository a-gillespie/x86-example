	.model small
	
	.stack 256
	
	.data
	
	startaddr		dw	0a000h
	colour			db	1
	counter			dw	0
	specx			dw	130
	specy			dw	100
	mode			db	1
	direction		db	1
	updown			db	1
	currentshape	db	1
	
	.code

PlaceBlock macro x,y,len,colr
	mov ax, x					;specify length of sides of block
	mov bx, y
	mov cx, len
	mov dl, colr
	call Draw_block_helper
	endm
	
PlaceDiamond macro x,y,len,colr
	mov ax, x					;specify length of sides of block
	mov bx, y
	mov cx, len
	mov dl, colr
	call Draw_diamond_helper
	endm
	
start:
	mov ax, @data
	mov ds, ax

refresh:	
	mov ah, 00
	mov al, 19
	int 10h
	mov es, startaddr
	jmp get_time

draw_diamond:
	mov cx, 70					;specify length of sides of block
	concentric_diamonds:
		push ax
		push bx
		push dx
		mov ax, specx				;ax = x center
		mov bx, cx				;bx = length of sides
		push cx
		mov cx, specy				;cx = y center
		mov dl, colour
		call DrawDiamond
		pop cx
		pop dx
		pop bx
		pop ax
		loop concentric_diamonds
jmp check_buffer
	
draw_block:
	mov cx, 50					;specify length of sides of block
	concentric_squares:
		push ax
		push bx
		push dx
		mov ax, specx				;ax = x center
		mov bx, cx				;bx = length of sides
		push cx
		mov cx, specy				;cx = y center
		mov dl, colour
		call DrawSquare
		pop cx
		pop dx
		pop bx
		pop ax
		loop concentric_squares
jmp check_buffer

check_buffer:
	mov ah, 01h
	int 16h
	jz get_time
gotkey:
	mov ah, 00h
	int 16h
	cmp al, 1bh
	jz finish
	cmp al, 32h
	jz ml_jump_helper
	jmp get_time
	
finish:
	mov ah, 00
	mov al, 03
	int 10h
	mov ah, 04ch
	mov al, 00
	int 21h

keypress:
	mov ah, 00h
	int 16h
	cmp al, 1bh				;check for ESC keypress
	jz finish				;exit if ESC
	cmp al, 31h
	jz returntoanim			;return to animation
	jmp keypress

returntoanim:	
	mov ah, 00
	mov al, 03
	int 10h
	mov ah, 00
	mov al, 19
	int 10h
	
get_time:
	mov ah, 0
	int 1ah
	mov cx, counter
	shr dx, 2
	cmp cx, dx
	jnz do_stuff
	jmp get_time

ml_jump_helper:
jmp Mona_lisa
	
do_stuff:
	mov counter, dx
	cmp mode, 1
	jnz nextmode
	
	inc colour
	checkrightborder:
	cmp specx, 280
	jnz checkleftborder
	mov direction, 0
	checkleftborder:
	cmp specx, 40
	jnz checktopborder
	mov direction, 1

	checktopborder:
	cmp specy, 40
	jnz checklowborder
	mov updown, 0
	checklowborder:
	cmp specy, 160
	jnz checktravel
	mov updown, 1
	
	checktravel:
	cmp direction, 1
	jnz goleft
	goright:
	add specx, 2
	jmp checkupdowntravel
	goleft:
	sub specx, 2
	
	checkupdowntravel:
	cmp updown, 1
	jnz godown
	goup:
	sub	specy, 2
	jmp checkshape
	godown:
	add specy, 2
	
	checkshape:
	cmp currentshape, 1
	jnz shape1
	mov currentshape, 0
	mov es, startaddr
	jmp draw_block
	
	shape1:
	mov currentshape, 1
	mov es, startaddr
	jmp draw_diamond
	
	nextmode:
	jmp Mona_lisa

Mona_Lisa:
	mov ah, 00
	mov al, 03
	int 10h
	mov ah, 00
	mov al, 19
	int 10h
	
	frame:
	mov di, 3285
	mov al, 6
	mov cx, 180
	left_outer:
		mov es:[di], al
		add di, 320
		loop left_outer
	mov cx, 150
	bottom_outer:
		mov es:[di], al
		inc di
		loop bottom_outer
	mov cx, 180
	right_outer:
		mov es:[di], al
		sub di, 320
		loop right_outer
	mov cx, 150
	top_outer:
		mov es:[di], al
		dec di
		loop top_outer
	mov di, 4890			;inner border start
	mov cx, 170
	left_inner:
		mov es:[di], al
		add di, 320
		loop left_inner
	mov cx, 140
	bottom_inner:
		mov es:[di], al
		inc di
		loop bottom_inner
	mov cx, 170
	right_inner:
		mov es:[di], al
		sub di, 320
		loop right_inner
	mov cx, 140
	top_inner:
		mov es:[di], al
		dec di
		loop top_inner
	mov di, 3606			;border connectors
	mov cx, 4
	diag1:
		mov es:[di], al
		add di, 321
		loop diag1
	mov di, 59751
	mov cx, 4
	diag2:
		mov es:[di], al
		add di, 321
		loop diag2
	mov di, 3754
	mov cx, 4
	diag3:
		mov es:[di], al
		add di, 319
		loop diag3
	mov di, 59609
	mov cx, 4
	diag4:
		mov es:[di], al
		add di, 319
		loop diag4
	mov di, 3015			;strings
	mov al, 31				;white
	mov cx, 10
	hangar1:
		mov es:[di], al
		sub di, 319
		loop hangar1
	mov di, 3065
	mov cx, 10
	hangar2:
		mov es:[di], al
		sub di, 321
		loop hangar2
		
	background:
	PlaceBlock 123,136,64,42		;dirt
	PlaceBlock 214,121,30,42
	PlaceBlock 115,80,48,2			;greenery
	PlaceBlock 203,80,52,2
	PlaceBlock 103,110,24,2
	PlaceBlock 222,105,14,2
	PlaceBlock 111,36,40,14			;sky
	PlaceBlock 151,36,40,14
	PlaceBlock 191,36,40,14
	PlaceBlock 209,36,40,14
	PlaceBlock 209,57,18,14
	PlaceBlock 98,53,14,2			;grass detail
	PlaceBlock 134,89,12,1			;water
	PlaceBlock 123,94,12,1
	figure:
	PlaceBlock 148,156,56,17		;figure
	PlaceBlock 113,169,29,17
	PlaceBlock 147,116,27,17
	PlaceBlock 161,79,48,17
	PlaceBlock 183,125,45,17
	PlaceBlock 201,159,49,17
	PlaceBlock 208,131,18,17
	PlaceBlock 167,73,59,186		;hair
	PlaceBlock 167,53,46,186
	PlaceBlock 192,91,22,186
	PlaceBlock 198,111,16,186
	PlaceBlock 170,91,28,89			;neck
	PlaceBlock 156,114,28,89
	PlaceBlock 179,110,20,89
	PlaceBlock 146,103,10,186
	PlaceBlock 163,61,38,90			;face
	PlaceBlock 163,52,29,90
	PlaceBlock 163,76,25,90
	PlaceBlock 160,36,4,90
	PlaceDiamond 151,59,12,88		;features
	PlaceDiamond 170,59,12,88
	PlaceBlock 151,53,12,90
	PlaceBlock 170,53,12,90
	PlaceBlock 127,171,24,20		;right sleeve
	PlaceBlock 152,176,15,90		;hand
	PlaceBlock 135,173,21,90
	PlaceBlock 167,178,12,20		;left sleeve
	PlaceBlock 179,178,12,20
	PlaceBlock 193,177,14,20
	jmp keypress
		

Draw_block_helper:
	concentric_squares2:
		push ax
		push cx
		push bx
		pop cx
		pop bx				;bx = length of sides
		push cx
		push bx
		call DrawSquare
		pop bx
		pop cx
		push cx
		push bx
		pop cx
		pop bx
		pop ax
		loop concentric_squares2
	ret
	
Draw_diamond_helper:
	concentric_diamonds2:
		push ax
		push cx
		push bx
		pop cx
		pop bx				;bx = length of sides
		push cx
		push bx
		call DrawDiamond
		pop bx
		pop cx
		push cx
		push bx
		pop cx
		pop bx
		pop ax
		loop concentric_diamonds2
	ret
		
DrawSquare:					;(x,y) = (ax, cx), len = bx
	mov di, 0
	push bx
	shr bx, 1
	sub cx, bx				;y start = center y - (len/2)
	sq_multiply_y:
		add di, 320
	loop sq_multiply_y
	sub ax, bx
	pop bx
	add di, ax				;x start = center x - (len/2)
	mov al, dl
tl_tr:						;topleft to topright line
	mov cx, bx
	tl_tr_plot:
		mov es:[di], al
		inc di
	loop tl_tr_plot
tr_br:						;topright to bottom right line
	mov cx, bx
	tr_br_plot:
		mov es:[di], al
		add di, 320
	loop tr_br_plot
br_bl:						;bottom right to bottom left line
	mov cx, bx
	br_bl_plot:
		mov es:[di], al
		dec di
	loop br_bl_plot
bl_tl:						;bottom left to topleft line
	mov cx, bx
	bl_tl_plot:
		mov es:[di], al
		sub di, 320
	loop bl_tl_plot
	ret

DrawDiamond:				;(x,y) = (ax, cx), len = bx
	mov di, 0
	shr bx, 1
	dia_multiply_y:
		add di, 320
	loop dia_multiply_y
	sub ax, bx
	add di, ax				;x start = center x - (len/2)
	mov al, dl
left_top:					;left to topright line
	mov cx, bx
	cmp cx, 0
	jnz dia_continue		;fill the center pixel last
	mov es:[di], al
	jmp exit_diamond
	dia_continue:
	lt_plot:
		mov es:[di], al
		sub di, 319
	loop lt_plot
top_right:					;top to right line
	mov cx, bx
	tr_plot:
		mov es:[di], al
		add di, 321
	loop tr_plot
right_bottom:				;right to bottom line
	mov cx, bx
	rb_plot:
		mov es:[di], al
		add di, 319
	loop rb_plot
bottom_left:				;bottom to left line
	mov cx, bx
	bt_plot:
		mov es:[di], al
		sub di, 321
	loop bt_plot
exit_diamond:
	ret
	
	end start