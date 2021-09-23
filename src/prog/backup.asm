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

;shift ulevo cini isto sto i mnozenje sa 2
;0001 = 1; 0010 = 2; 0100 = 4; 1000 = 8

main:
	;postoji 320 piksela u jednom redu
	;postoji 200 redova
	;znaci da je 0-319 prvi red
	;sledi da je 320-639 drugi red itd.
	;odatle znaci da je bx+320*y(red koji zelim) => bx-ti piksel u y redu koji zelim
	;pa mogu da crtam npr kao 3i red 5i piksel boje al, duzine cx=(bx+320*y)+duzina
	
	; ----      ----		;bx=1 cx=4 -> bx+=8 cx=4
	; -----    -----		;bx=1 cx=5 -> bx=5 cx=5...
	; ------  ------
	; -- -------- --
	; --  ------  --
	; --   ----   --
	; --    --    --
	; --          --
	; --          --

	mov al, 15	;boja bela	

	mov bx, 1+320*1	;linija 1 -> 1
	mov cx, 4
	call fillVRAM
	add bx, 10
	call fillVRAM

	mov bx, 1+320*2	;linija 2 -> 1
	mov cx, 5
	call fillVRAM
	add bx, 8
	call fillVRAM

	mov bx, 1+320*3	;linija 3 -> 1
	mov cx, 6
	call fillVRAM
	add bx, 6
	call fillVRAM
	
	mov bx, 1+320*4	;linija 4 -> 1
	mov cx, 8
	call fillVRAM
	add bx, 2
	call fillVRAM

	mov bx, 1+320*5	;linija 5 -> 1
	mov cx, 18
	call fillVRAM

jmp $			;nemoj da izvrsavas dalje
times 510-($-$$) db 0
dw 0xaa55
