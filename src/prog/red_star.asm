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
;crta kao sto stampac stampa, liniju po liniju
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

main:
	mov bx, 150+320*98	;offset = 0					bx = tacka_u_redu + 320*broj_reda
	mov al, 12	;red
	mov cx, 30	;190+320*98
	call fillVRAM
	mov bx, 150+320*99	;next row
	mov al, 12
	mov cx, 30	;190+320*99
	call fillVRAM
	
	mov bx, 150+320*100	;offset = 0
	mov al, 12	;red
	mov cx, 30	;190+320*100
	call fillVRAM	
	mov bx, 150+320*101	;offset = 0
	mov al, 12	;red
	mov cx, 30	;190+320*101
	call fillVRAM

	mov bx, 150+320*102	;offset = 0
	mov al, 15	;red
	mov cx, 30	;190+320*102
	call fillVRAM
	mov bx, 150+320*103	;next row
	mov al, 15
	mov cx, 30;	190+320*103
	call fillVRAM
	
	mov bx, 150+320*104	;offset = 0
	mov al, 15	;red
	mov cx, 30;	190+320*104
	call fillVRAM
	mov bx, 150+320*105	;next row
	mov al, 15
	mov cx, 30;	190+320*105
	call fillVRAM
	

jmp $
times 510-($-$$) db 0
dw 0xaa55
