.section .text.start
.code32
.globl _start32
.type _start32, @function

print_string:
.string "Hello from the PROTECTED mode!"
print_string_end:
_start32:
    # init printing variables
    movl $0x0, %ebx                 # char index
    movl $0x0, %edx                 # video memory char index (one char takes two bytes in text mode)
    movl $print_string_end, %ecx    # 
    sub $print_string, %ecx         # string size
    movb $0x0f, %ah                 # char color
print_next:
    mov print_string(%ebx), %al
	movw %ax, 0xB8000(%edx)
    inc %ebx
    add $2, %edx
    cmpl %ecx, %ebx
    jne print_next

inf_loop:
	jmp inf_loop
