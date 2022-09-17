#define BOOT_SEG	0xffff0000
#define X86_CR0_PE	0x00000001
#define o32		.byte 0x66;

.code16
.text
	.globl _start
_start:
	movb $'X', %al	# character to print
	movb $0x0e, %ah	# \
	movb $0x00, %bh	#  } set registers to print char (used by interrupt)
	movb $0x07, %bl	# /
	int $0x10		# call the video interrup

# sleep for ~1s 
	movl $0x0fffffff, %edx
 loop:	
 	dec %edx
 	jnz loop

	# set video mode to text mode
	movb $0x00, %ah
	movb $0x03, %al
	int $0x10

	cli
 	lgdt gdt_ptr

	movl %cr0, %eax
	orl	$X86_CR0_PE, %eax
	movl %eax, %cr0

	movw	$code32start, %ax
	movw	%ax, %bp
	movl	%ecx, %eax
o32 cs	ljmp	*(%bp)

	/* 48-bit far pointer */
code32start:
	.long	_start32	/* offset */
	.word	0x10		/* segment */

idt_ptr:
	.word   0		/* limit */
	.long   0		/* base */

gdt_ptr:
	.word	0x1f		/* limit (31 bytes = 4 GDT entries - 1) */
	.long	gdt_rom	/* base */

	/* Some CPUs are picky about GDT alignment... */
	.align	16
.globl gdt_rom
gdt_rom:
	/*
	 * The GDT table ...
	 *
	 *	 Selector	Type
	 *	 0x00		NULL
	 *	 0x08		Unused
	 *	 0x10		32bit code
	 *	 0x18		32bit data/stack
	 */
	/* The NULL Desciptor - Mandatory */
	.word	0x0000		/* limit_low */
	.word	0x0000		/* base_low */
	.byte	0x00		/* base_middle */
	.byte	0x00		/* access */
	.byte	0x00		/* flags + limit_high */
	.byte	0x00		/* base_high */

	/* Unused Desciptor - (matches Linux) */
	.word	0x0000		/* limit_low */
	.word	0x0000		/* base_low */
	.byte	0x00		/* base_middle */
	.byte	0x00		/* access */
	.byte	0x00		/* flags + limit_high */
	.byte	0x00		/* base_high */

	/*
	 * The Code Segment Descriptor:
	 * - Base   = 0x00000000
	 * - Size   = 4GB
	 * - Access = Present, Ring 0, Exec (Code), Readable
	 * - Flags  = 4kB Granularity, 32-bit
	 */
	.word	0xffff		/* limit_low */
	.word	0x0000		/* base_low */
	.byte	0x00		/* base_middle */
	.byte	0x9b		/* access */
	.byte	0xcf		/* flags + limit_high */
	.byte	0x00		/* base_high */

	/*
	 * The Data Segment Descriptor:
	 * - Base   = 0x00000000
	 * - Size   = 4GB
	 * - Access = Present, Ring 0, Non-Exec (Data), Writable
	 * - Flags  = 4kB Granularity, 32-bit
	 */
	.word	0xffff		/* limit_low */
	.word	0x0000		/* base_low */
	.byte	0x00		/* base_middle */
	.byte	0x93		/* access */
	.byte	0xcf		/* flags + limit_high */
	.byte	0x00		/* base_high */
