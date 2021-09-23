[bits 16]
[org 0x7c00]	;konvencija gde se nalazi boot loader u memoriji

mov ah, 0x00	;postavljam video mode
mov al, 0x13	;na VGA (8x8 320x200) 256 color mode
int 0x10

;mode 0x13:
;	0-319 x && 0-119 y
;	svaki piksel predstavlja 8 bits
;memorija potrebna za 0x13 mode se sastoji od 320 piksela u sirini * 200 piksela u visini * 1 byte za svaki piksel = 64 000 bajtova
;	SEGMENT:OFFSET za VGA memoriju 0xA000:0x0000 do 0xB000:0xFFFF (64kB)

mov ax, 0xa000	;init za ds i es
mov ds, ax	;data segment -> vRAM

xor ax, ax	;postavi na 0
mov es, ax	;data
mov ss, ax	;stack segment se nalazi na 7c00:0000
;inicijalizuj stack pointer

jmp main	;skoci na main odmah, da ne bi izvrsio sve procedure


;odatle znaci da je bx+320*y(red koji zelim) => bx-ti piksel u y redu koji zelim
;pa mogu da crtam npr kao 3i red 5i piksel boje al, duzine cx=(bx+320*y)+duzina
fillVRAM:	;al - color; bx - offset do 0xFFFF -> 2B -> 16bit -> bx
	push cx		;da ne bi posle ove funkcije sacuvao vrednost bx na cx, pa posle bude zeljena_duzina+320...
	add cx, bx	;podesi offset da bi mogao da uporedjujes sa bx -> 			cx = 5, -> cx = bx(piksel u memoriji) + 5 (offset)
loopVRAM:
	mov byte ds:[bx], al
	inc bx
	cmp bx, cx
	jne loopVRAM
	pop cx		;skidam cx sa stack-a
	ret

drawLine:	;tek treba da napravim proceduru: Bresenham mozda, (cx, dx) -> (si, di)
drawPixel:		;draws pixel x=cx, y=dx
	mov ah, 0x0C	;draw pixel
	mov al, 12	;boja crvena
	int 0x10
	ret

pcursor:	;dh=line	dl=column	bh=displayPageNumber
	mov ah, 0x02
	int 0x10
	ret

strprint:
	mov ah, 0x13
	mov al, 1
	xor bh, bh
	mov bl, 14
	int 0x10
	ret

chprint:	;bl=boja; al=slovo; cx=brojslova; bh=bckg
	mov ah, 0x0e
	mov bl, 14
	int 0x10
	ret

;shift ulevo cini isto sto i mnozenje sa 2
;0001 = 1; 0010 = 2; 0100 = 4; 1000 = 8

main:
;drawBorders
	mov al, 15	;top and bottom borders
	mov cx, 2176
	mov bx, 0+320*199
	call fillVRAM

;drawHeaderLine
	mov bx, 0+320*12
	mov al, 14
	mov cx, 320
	call fillVRAM

;Write a character at cursor position
	;mov al, 0x41
	;call chprint

;Write a string
	mov bp, logo
	mov cx, logo_len
	mov dx, 0x000f ;00=0ti red		320 = 20*16 = a0 = 10*16 ali su slova 8x8
	call strprint

;Move cursor
		

;Variables
logo db " Mirkov CV "
logo_len equ $-logo

jmp $			;nemoj da izvrsavas dalje
times 510-($-$$) db 0
dw 0xaa55
