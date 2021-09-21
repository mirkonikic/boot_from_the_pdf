	mov ah, 0x0e
	mov bl, 0
	mov bh, 32	;up delimiter
	mov cl, -31	;down delimiter
	mov al, 'A'	;set the first letter
	int 0x10
	
loop:
	test bl, 1	;uporedi dal je bl paran ili ne
	jz even		;ako jeste idi gore
	jnz odd		;ako nije idi dole

even:
	add al, bh	
	jmp back

odd:
	add al, cl

back:
	int 0x10	;ispisi sta imas sad
	
	inc bl		;uvecaj counter register
	cmp al, 'z'	;uporedi al sa 'z'

	je exit;	;ako jeste idi na exit
	jmp loop;	;ako nije loop again

			;number is odd if lsb is 1, else if its 0 than its even

exit:
	mov al, 0xA
	int 0x10

	mov al, 0xD
	int 0x10

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
