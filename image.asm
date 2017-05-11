sseg segment stack
		dw 100h dup(?)
sseg ends
dseg	segment
filename	db	30
			db	0
			db	30 dup (0) 
filehandle	dw	0
savedfile	db	'newimage.bmp'
savedfileh	dw	0
header		db	54 dup(?)
palette		db 400h dup(?)
errormsg	db	'ERROR',10,13,'$'
readline	db	320 dup (?)
readline2	db	320 dup (?)
startst		db	'Welcome to my photoshop program, type the name of your image and then press ' ,10 ,13 ,'enter to print it!' ,10,13,'A maximum of 12 letters name is supported (including ".bmp")' ,10,13,'Those are the functions you can use:',10,13,'r-reverse screen',10,13,'u-upside down screen',10,13,'s-save image(saved image name-"newimage.bmp")',10,13,'d-enable/disable draw mode',10,13,'x-increase draw/erase size, z-decrease draw/erase size(draw mode)',10,13,'1-increase color number, 2-decrease color number(draw mode)',10,13,'t-taste color from current cursor position(draw mode)',10,13,'p-print original image again',10,13,'esc-exit',10,13,'$'
counter		dw	?
printcounter	db	0
savecounter		db	0
color	db	0
drawsize	db	2
counter2	db	?
counter3	db	?
tempcolor	db	?
tempx		dw	?
tempy		dw	?
mode		db	?
mouseinfo	dw	6 dup(?)
mousecounter	db	0
imwidth		dw	?
imheigt	dw	?
zeros		db	?
zero		db	3 dup(0)
			dseg ends
cseg	segment
assume cs:cseg ,ds:dseg, ss:sseg
openimage proc
	mov ah,3dh
	mov al,0
	mov dx,offset filename
	add dx,2
	int 21h
	jc showerror
	mov [filehandle],ax
	ret
showerror:
	mov dx,offset errormsg
	mov ah,9
	int 21h
	mov ah,1
	int 21h
	xor ah, ah
	mov al, 2
	int 10h
	exit1:
	mov ax, 4c00h
	int 21h
	ret
	endp openimage
readheader	proc
	mov ah,3fh
	mov bx,[filehandle]
	mov cx,54
	mov dx, offset header
	int 21h
	mov si,offset header
	add si,19
	mov ch,[si]
	dec si	
	mov cl,[si]
	mov [imwidth],cx
	add si,4
	mov cl,[si]
	mov ch,0
	mov [imheigt],cx
	mov ax,[imwidth]
	mov bl,4
	div bl
	cmp ah,1
	jz zero1
	cmp ah,2
	jz zero2
	cmp ah,3
	jz zero3
	mov zeros,0
	jmp cont
zero1:	mov zeros,3
		jmp cont
zero2:	mov zeros,2
		jmp cont
zero3:	mov zeros,1
cont:	ret
	endp readheader
readpallete	proc
	mov ah,3fh
	mov bx,[filehandle]
	mov cx,400h
	mov dx,offset palette
	int 21h
	ret
	endp readpallete
updatepal	proc
	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	mov si, offset palette
	mov cx,256                         
copy:mov al,[si+2]
	shr al,2
	out dx,al
	mov al,[si+1]
	shr al,2
	out dx,al
	mov al,[si]
	shr al,2
	out dx,al
	add si,4
	loop copy
	ret
	endp updatepal
draw	proc
	mov cx,[imheigt]
copyloop: push cx 
	mov ah,3fh
	mov bx,[filehandle]
	mov cx,[imwidth]
	cmp zeros,1
	jz zero1add
	cmp zeros, 2
	jz zero2add
	cmp zeros,3
	jz zero3add
	jmp noadd
zero1add:
	inc cx
	jmp noadd
zero2add:	
	add cx,2
	jmp noadd
zero3add:
		add cx,3
noadd:	
	mov dx, offset readline
	int 21h
	mov si, offset readline
	mov ah,0ch
	mov bh,0
	pop cx
	mov dx,cx
	push cx
	dec dx
	mov cx,0
	mov di,[imwidth]
	cmp zeros,1
	jz adddi1
	cmp zeros,2
	jz adddi2
	cmp zeros,3
	jz adddi3
	jmp draw1
adddi1: inc di
		jmp draw1
adddi2:	add di,2
		jmp draw1
adddi3:	add di,3		
draw1: mov al,[si]
	int 10h
	inc si
	inc cx
	dec di
	jnz draw1
	pop cx
	loop copyloop
	mov ah,42h
	mov al,0
	mov bx,[filehandle]
	xor cx,cx
	mov dx,436h
	int 21h
	mov mode,0
	ret
	endp draw
upsim	proc
	mov counter,0
	mov bh,0
bigloop:mov cx,0
	mov dx,counter
	mov ah,0dh
	mov si, offset readline
read1:int 10h
	mov [si],al
	inc si
	inc cx
	cmp cx,[imwidth]
	jnz read1
	mov cx,0
	mov dx,[imheigt]
	dec dx
	sub dx,counter
	mov si, offset readline2
read2:int 10h
	mov [si],al
	inc si
	inc cx
	cmp cx,[imwidth]
	jnz read2
	mov cx,0
	mov dx,counter
	mov si,offset readline2
	mov al,[si]
	mov ah,0ch
write1:	int 10h
	inc cx
	inc si
	mov al,[si]
	cmp cx,[imwidth]
	jnz write1
	mov cx,0
	mov dx,[imheigt]
	dec dx
	sub dx,counter
	mov si,offset readline
	mov al,[si]
write2:int 10h
	inc si
	mov al,[si]
	inc cx
	cmp cx,[imwidth]
	jnz write2
	inc counter
	mov bx,[imheigt]
	shr bx,1
	cmp counter,bx
	jnz bigloop
	cmp mode,2
	jz bothmode
	cmp mode,3
	jz wasboth
	cmp mode,1
	jz reup
	mov mode,1
	jmp retup
bothmode:	mov mode,3
jmp retup	
wasboth:	mov mode,2
jmp retup
reup:	mov mode,0
retup:ret
endp upsim
reverse	proc
	mov counter,0
	mov bh,0
rbigloop:mov cx,counter
	mov dx,0
	mov ah,0dh
	mov si, offset readline
rread1:int 10h
	mov [si],al
	inc si
	inc dx
	cmp dx,[imheigt]
	jnz rread1
	mov cx,[imwidth]
	dec cx
	sub cx,counter
	mov dx,0
	mov si, offset readline2
rread2:int 10h
	mov [si],al
	inc si
	inc dx
	cmp dx,[imheigt]
	jnz rread2
	mov cx,counter
	mov dx,0
	mov si,offset readline2
	mov al,[si]
	mov ah,0ch
rwrite1:	int 10h
	inc dx
	inc si
	mov al,[si]
	cmp dx,[imheigt]
	jnz rwrite1
	mov cx,[imwidth]
	dec cx
	sub cx,counter
	mov dx,0
	mov si,offset readline
	mov al,[si]
rwrite2:int 10h
	inc si
	mov al,[si]
	inc dx
	cmp dx,[imheigt]
	jnz rwrite2
	inc counter
	mov bx,[imwidth]
	shr bx,1
	cmp counter,bx
	jnz rbigloop
	cmp mode,1
	jz bothmode1
	cmp mode,3
	jz wasboth1
	cmp mode,2
	jz rere
	mov mode,2
	jmp retrev
bothmode1:	mov mode,3	
	jmp retrev
wasboth1:	mov mode,1
	jmp retrev
rere: mov mode,0
retrev:ret
endp reverse
createfile	proc
	mov ah,3ch
	mov cx,0
	mov dx,offset savedfile
	int 21h
	mov savedfileh,ax

ret
endp createfile
copytofile	proc	
	mov ah,40h
	mov bx,savedfileh
	mov cx,54
	mov dx, offset header
	int 21h
	mov ah,40h
	mov cx,400h
	mov dx, offset palette
	int 21h
	mov cx,[imheigt]
	mov counter,cx
copyline:	mov ah,0dh
	mov bh,0
	mov cx,0
	mov dx,counter
	dec dx
	mov si, offset readline
read3:	int 10h
	inc cx
	mov [si],al
	inc si
	cmp cx,[imwidth]
	jnz read3
	mov ah,40h
	mov bx,savedfileh
	mov cx,[imwidth]
	mov dx,offset readline
	int 21h
	cmp zeros,1
	jz movbl1
	cmp zeros,2
	jz movbl2
	cmp zeros,3
	jz movbl3
	jmp deccounter
movbl1:	mov bx,1
		jmp ifless320
movbl2:	mov bx,2
		jmp ifless320
movbl3:	mov bx,3	
ifless320:
	mov cx,bx
	mov ah,40h
	mov bx,savedfileh
	mov dx, offset zeros
	int 21h
deccounter:	dec counter
	jnz copyline
	mov ah,42h
	mov al,0
	mov bx,savedfileh
	mov cx,0
	mov dx,0
	int 21h
ret
endp copytofile
paintf	proc
mouseloop:
		mov ax,7
		mov cx,2
		mov dx,[imwidth]
		add dx,[imwidth]
		dec dx
		cmp [imwidth],320
		jnz adddx
		jmp contin
	adddx:	add dx,2
contin:		int 33h
		mov ax,8
		mov cx,0
		mov dx,[imheigt]
		int 33h
		cmp mousecounter,0
		jnz deltemp
		inc mousecounter
		jmp mousel
deltemp:mov si,offset mouseinfo
		mov ax,3
		int 33h
		shr cx,1
		cmp cx,[si]
		jnz noteq
		add si,2
		cmp dx,[si]
		jnz noteq
		jmp checkkeyp
noteq:	mov si,offset mouseinfo
		mov cx,[si]
		add si,2
		mov dx,[si]
		add si,2
		mov al,[si]
		mov bh,0
		mov ah,0ch
		int 10h
		add si,2
		dec cx
		mov al,[si]
		int 10h
		inc dx
		add si,2
		mov al,[si]
		int 10h
		inc cx
		add si,2
		mov al,[si]
		int 10h
mousel:	mov ax,3
		int 33h
		mov si,offset mouseinfo
		shr cx,1
		mov [si],cx
		add si,2
		mov [si],dx
		add si,2
		mov bh,0
		mov ah,0dh
		int 10h
		mov [si],al
		add si,2
		mov al,0
		mov ah,0ch
		int 10h
		dec cx
		mov ah,0dh
		int 10h
		mov [si],al
		add si,2
		mov al,color
		mov ah,0ch
		int 10h
		inc dx
		mov ah,0dh
		int 10h
		mov [si],al
		add si,2
		mov ah,0ch
		mov al,color
		int 10h
		inc cx
		mov ah,0dh
		int 10h
		mov [si],al
		mov al,color
		mov ah,0ch
		int 10h
checkkeyp:
		mov ax,3
		int 33h
		cmp bx,1
		jnz next9
		jmp drawdot
next9:	cmp bx,2
		jnz next10
		jmp erase
next10:	mov ah,0bh
		int 21h
		cmp al,0ffh
		jz next6
		jmp mouseloop
next6:	mov ah,0
		int 16h
	checkkey:
	cmp al,'1'
	jz colorup
	cmp al,'2'
	jz colordown
	cmp al,'z'
	jz smaller
	cmp al,'x'
	jz bigger
nextcmp:	cmp al,'t'
	jnz next2
	jmp taste
next2:	cmp al,'d'
	jnz next5
	jmp endfnc
next5:	jmp mouseloop
colorup: inc color
	jmp mouseloop
colordown: dec color
	jmp mouseloop
smaller:	cmp drawsize,2
		jnz next4
	jmp mouseloop
next4:	dec drawsize
	jmp mouseloop
bigger:	cmp drawsize,80
		jnz next3
		jmp mouseloop
	next3:
		inc drawsize
	jmp mouseloop
erase:
	mov ax,3h
	int 33h
	shr cx,1
	dec cx
	mov al,drawsize
	mov counter2,al
	mov counter3,al
	jmp erpoint
erloop:	dec cx
		dec counter2
		jz next8
		jmp erpoint
next8:	mov bl,drawsize
		mov counter2,bl
inccx:	inc cx
		dec bl
		jnz inccx
		inc dx
		dec counter3
		jnz erloop
	jmp mouseloop
erpoint:mov tempx,cx
	cmp cx,[imwidth]
	jnc erloop
	mov tempy,dx
	cmp dx,[imheigt]
	jnc erloop
	cmp mode,0
	jz erregu
	cmp mode,1
	jz erups
	cmp mode,2
	jz erreve
	cmp mode,3
	jz erboth
erregu:	mov cx,[imheigt]
	sub cx,dx
	dec cx
	mov dx,tempx
	jmp kefel
erups:	mov cx,dx
	mov dx,tempx
	jmp kefel
erreve:	mov cx,[imheigt]
	sub cx,dx
	mov dx,[imwidth]
	sub dx,tempx
	dec dx
	dec cx
	jmp kefel
erboth:	mov cx,dx
	mov dx,[imwidth]
	sub dx,tempx
	dec dx
	jmp kefel	
kefel:add dx,[imwidth]
	cmp zeros,1
	jz adddx1
	cmp zeros,2
	jz adddx2
	cmp zeros,3
	jz adddx3
	jmp deccx
adddx1:	inc dx
		jmp deccx
adddx2:	add dx,2
		jmp deccx
adddx3:	add dx,3
deccx:	dec cx
	jnz kefel
	mov bx, [filehandle]
	mov ah,42h
	mov al,0
	add dx,436h
	int 21h
	mov cx,1
	mov dx, offset tempcolor
	mov ah,3fh
	int 21h
	mov al,tempcolor
	mov ah,0ch
	mov bh,0
	mov dx,tempy
	mov cx,tempx
	int 10h
	jmp erloop
drawdot:
	mov ax,3h
	int 33h
	shr cx,1
	cmp cx,[imwidth]
	jnc jmpmouseloop
	cmp dx,[imheigt]
	jnc jmpmouseloop
	cmp cx,0
	jz jmpmouseloop
	cmp drawsize,3
	jnc bigth4
	mov si,offset mouseinfo
	add si,4
	mov cx,4
	mov al,color
loopm:	mov [si],al
		add si,2
		loop loopm
jmpmouseloop:	jmp mouseloop
bigth4:	mov ax,3h
	int 33h
	shr cx,1
	mov al,drawsize
	mov ah,0
	mov bl,2
	div bl
	mov ah,0
	add cx,ax
	cmp cx,[imwidth]
	jnc movcxwidth
	jmp conti3
movcxwidth:	mov cx,[imwidth]
	dec cx
	jmp conti3	
conti3:	cmp dx,ax
	jc movdx0
	jmp conti
movdx0:	mov dx,0
		jmp conti2
conti: sub dx,ax	
conti2:	mov bh,0
	mov al,color
	mov ah,0ch
	mov bl,drawsize
	mov counter3,0
	mov counter2,0
drawloop:
	int 10h
	dec cx
	inc counter3
	cmp cx,0
	jz nextlinewith0
	cmp counter3,bl
	jnz drawloop
	jmp nextline
nextlinewith0:	int 10h	
nextline:	inc dx
	cmp dx,[imheigt]
	jz jmpmouseloop
decloop:	inc cx
	dec counter3
	jnz decloop
	inc counter2
	cmp counter2,bl
	jnz drawloop
afterlines:	mov si,offset mouseinfo
	add si,4
	mov cx,4
	mov al,color
loopm1:	mov [si],al
		add si,2
		loop loopm1
jmpmoul:	jmp mouseloop
taste:	mov ax,3h
	int 33h
	shr cx,1
	dec dx
	dec cx
	mov bx,0
	mov ah,0dh
	int 10h
	mov color,al
	jmp mouseloop	
endfnc:	mov si,offset mouseinfo
		mov cx,[si]
		add si,2
		mov dx,[si]
		add si,2
		mov al,[si]
		mov bh,0
		mov ah,0ch
		int 10h
		add si,2
		dec cx
		mov al,[si]
		int 10h
		inc dx
		add si,2
		mov al,[si]
		int 10h
		inc cx
		add si,2
		mov al,[si]
		int 10h
		mov mousecounter,0
		mov dx,436h
		mov cx,0
		mov ah,42h
		mov bx,[filehandle]
		mov al,0
		int 21h	
	ret
endp paintf	
Begin:
		mov ax,dseg
		mov ds,ax
		mov cx,25
		mov ah,2
clean:	mov dl,10
		int 21h
		loop clean
		xor dx,dx
		int 10h
		mov ah,9
		mov dx, offset startst
		int 21h
		mov ah,0ah
		mov dx, offset filename
		int 21h
		mov si,offset filename
		inc si
		mov al,[si]
		inc si
		mov ah,0
		add si,ax
		mov [si],ah
		jmp print
input:	mov ah,7
		int 21h
		cmp al,'p'
		jz print
		cmp al,'u'
		jz switch
		cmp al, 'r'
		jz reversed
		cmp al,'s'
		jz savefile
		cmp al,'d'
		jz paint
		cmp al,27
		jz sof
		jnz input
print:	mov ax,13h
		int 10h
		cmp printcounter,0
		jnz printdir
		call openimage
		call readheader
		call readpallete
		inc printcounter
printdir:	call updatepal
		call draw
		jmp input
switch:	call upsim
		jmp input
reversed:call reverse
		jmp input
savefile: cmp savecounter,0
		jnz savedsec
		call createfile
		inc savecounter
	savedsec: call copytofile
		jmp input
paint:	call paintf
		jmp input
sof:	xor ah, ah
		mov al, 2
		int 10h
		exit:
	mov ax, 4c00h
	int 21h
	cseg ends
end Begin