loop:
	;mov ah, 0x0b
	;mov bh, 0
	;mov bl, 0x3f
	;int 0x10

	mov ah, 0x0e

	mov al, 'M'
	int 0x10

	mov al, 'i'
	int 0x10

	mov al, 'r'
	int 0x10

	mov al, 'k'
	int 0x10

	mov al, 'o'
	int 0x10

	

	jmp $

times 510-($-$$) db 0
dw 0xaa55
