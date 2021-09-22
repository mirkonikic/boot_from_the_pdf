org 0x7c00

mov ah, 0x00	;postavljam video mode
mov al, 0x13	;na VGA (8x8 320x200) 256 color mode
int 0x10

;mode 0x13:
;	0-319 x && 0-119 y
;	svaki piksel predstavlja 8 bits
;memorija potrebna za 0x13 mode se sastoji od 320 piksela u sirini * 200 piksela u visini * 1 byte za svaki piksel = 64 000 bajtova
;	SEGMENT:OFFSET za VGA memoriju 0xA000:0x0000 do 0xFFFF (64kB)

;prvi nacin je da upisem piksel po piksel koristeci cx i dx registre
;drugi je popunjavanjem VGA segmenta memorije 0xA000:0x0000 - 0xFFFF

mov cx, 1	;init cx
mov dx, 1	;init dx

mov ax, 0xa000	;init za ds i es
mov ds, ax	;data segment -> video memoriju
mov es, ax	;extra segment -> video memoriju

;nacrtaj piksel
;ax - accumulator, za i/o i aritmeticke instrukcije
;bx - base register, jedini koji moze biti koriscen kod indirektnog adresiranja
;cs - count register, brojac kod petlji
;dx - data register, kod i/o instrukcija

jmp main	;skoci na main odmah, da ne bi izvrsio sve procedure

;svaka linija sadrzi 320 pixela
;ako popunim od bx offseta, cx pixela bojom al
;mocicu da crtam po ekranu
fillVRAM:	;al - color; bx - offset to 0xFFFF -> 2B -> 16bit -> bx
	mov byte ds:[bx], al	
	inc bx
	cmp bx, cx
	jne fillVRAM
	ret

;Bresenham Algorithm mozda
drawLine:

drawPixel:		;draws pixel x=cx, y=dx
	mov ah, 0x0C	;draw pixel
	mov al, 12	;boja crvena
	int 0x10
	ret

main:
	mov bx, 10	;offset = 0
	mov al, 12	;red
	mov cx, 40
	call fillVRAM
	mov bx, 330	;next row
	mov al, 14
	mov cx, 360
	call fillVRAM
			

jmp $
times 510-($-$$) db 0
dw 0xaa55
