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

mov bp, 0x7c00
xor ax, ax	;postavi ax na 0
mov es, ax	;data
mov ss, ax	;stack segment se nalazi na 7c00:0000
mov sp, bp
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

;drawLine:	;tek treba da napravim proceduru: Bresenham mozda, (cx, dx) -> (si, di)
;drawPixel:		;draws pixel x=cx, y=dx
;	mov ah, 0x0C	;draw pixel
;	mov al, 12	;boja crvena
;	int 0x10
;	ret

resetcursor:
	mov dx, 0x0000
	mov ah, 0x02
	int 0x10
	ret

setcursor:
	mov ah, 2
	mov dx, 0x1201
	int 0x10
	ret

strprint:
	mov ah, 0x13
	mov al, 1
	xor bh, bh
	int 0x10
	ret

chprint:	;bl=boja; al=slovo; cx=brojslova; bh=bckg
	mov ah, 0x0a
	mov bl, 15
	mov cx, 1
	int 0x10
	ret

;shift ulevo cini isto sto i mnozenje sa 2
;0001 = 1; 0010 = 2; 0100 = 4; 1000 = 8

apress:
;ispisi education: muzicka, treca i FON
	mov bp, opta
	mov al, 0xA
optprint:	
	mov bx, 8+320*150
	mov cx, 304
	call fillVRAM

	mov bl, al
	mov cx, l_opt
	call strprint

	mov al, 15
	mov bx, 8+320*158
	mov cx, 304
	call fillVRAM

	jmp read_loop
bpress:
;Ispisi achvmnts: fudbalx10, takmicenja, CEH...gitara, klavir i polja informatike
	mov al, 0x9
	mov bp, optb
	jmp optprint
cpress:
;Ispisi projects: Github, sve sto si radio
	mov al, 0xC
	mov bp, optc
	jmp optprint

epresson:
	mov ah, 2
	mov dx, 0x0201
	int 0x10
	mov bp, wrte
	mov cx, 4
	mov bl, 12
	call strprint
	call setcursor
	jmp write_loop

enterpress:
	call resetcursor
	jmp write_loop

;Mozda i ne treba, ima mesta na ekranu da se ispise tekst...
readexit:
;Ispisi na dnu strane e - back i kad kliknu posalji ih na main
	mov ah, 00
	int 0x16
	cmp al, 'e'
	je main
	jmp readexit

logoprint:	
	mov bx, 0x000e
	mov bp, logo
	mov cx, logo_len
	mov dx, 0x010f ;00=0ti red		320 = 20*16 = a0 = 10*16 ali su slova 8x8
	call strprint
	ret	

menuprint:
	mov bx, 0x000f
	mov bp, menu
	mov cx, 5
	mov dx, 0x0201
	call strprint
	ret

main:
;drawBorders
	mov al, 15	;gornji i donji borders
	mov cx, 304
	mov bx, 8+320*192
	call fillVRAM

	mov bx, 8+320*8
	call fillVRAM

;drawHeaderLine
	mov bx, 8+320*20
	mov al, 14
	mov cx, 304
	call fillVRAM

;Write a logo string 'Mirkov CV'
	call logoprint
	call menuprint

;Write options a, b, c, d
	mov bx, 0x000f
	mov dx, 0x0402
	mov bp, prompt
	mov cx, 7
	call strprint

	mov dx, 0x0602
	mov bp, acone
	mov cx, 10
	call strprint

	mov dx, 0x0802
	mov bp, actwo
	mov cx, 10
	call strprint
	
	mov dx, 0x0a02
	mov bp, acthree
	mov cx, 10
	call strprint	

	mov dx, 0x0c02
	mov bp, acwrite
	mov cx, 9
	call strprint

;Ocekuj klik korisnika, u zavisnosti od a, b, c ili d obrisi displej, ispisi logo i ispisi kratak tekst o tome
;Read input char, glavni loop ovde
read_loop:
;set cursor below
	call setcursor
	
	mov ah, 00
	int 0x16
	cmp al, 'a'
	je apress
	cmp al, 'b'
	je bpress
	cmp al, 'c'
	je cpress
;AKO JE ESC IDI U WRITE LOOP
	cmp al, 0x1b
	je epresson
	jmp read_loop

write_loop:
	mov ah, 00
	int 0x16
	cmp al, 0x1b
	je main

;nek bude kao text editor
;potreban je update cursor
;	-kad se predje x_max ili y_max on predje u nov red
;	-kad se klikne enter ode u nov red
;	-kad se kliknu strelice, on poveca ili smanji dl i dh i postavi kursor
;	-inicijalizuje kursor da trepce

	call chprint
	jmp write_loop

;TODO:
;-if enter is pressed -> beginning of next row
;-if arrows are pressed -> move left/right/up/down
;-if it goes further than x ili y, than go back
;-try to use strprint instead chprint so you dont need to control cursor
;-clean up the code, make it smaller so it fits 512
;-write 1 sentence for each option

;Variables
var dw " "
menu db "menu:"
wrte db "WrTE:"
logo db " Mirkov CV "
logo_len equ $-logo
prompt db "Choose:"
acone db "a)eduction"
actwo db "b)achvmnts"
acthree db "c)projcets"
acwrite db "esc)write"

opta db "a: aaaaaaaaaaaaaaaaaaaaaaaaaa"
optb db "b: bbbbbbbbbbbbbbbbbbbbbbbbbb"
optc db "c: cccccccccccccccccccccccccc"
l_opt equ $-optc

jmp $			;nemoj da izvrsavas dalje
times 510-($-$$) db 0
dw 0xaa55
