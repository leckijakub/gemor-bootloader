.PHONY: boot.bin

boot.bin: boot.S boot_protected.S
# https://www.codeproject.com/Articles/664165/Writing-a-boot-loader-in-Assembly-and-C-Part
	gcc -c -g -Os -ffreestanding -Wall -Werror boot.S -o boot.o
	gcc -c -g -Os -ffreestanding -Wall -Werror boot_protected.S -o boot_protected.o
	ld -static -Tboot.ld -nostdlib --nmagic -o boot.elf boot.o boot_protected.o
	objcopy -O binary boot.elf boot.bin

clean:
	rm -rf boot.bin boot.elf boot.f

run: boot.bin
	qemu-system-x86_64 boot.bin &

debug: boot.bin
	qemu-system-x86_64 -s -S boot.bin &
# 	after starting qemu start gdb and connect to port 1234 using
# 	`(gdb) target remote localhost:1234`
# 	to stop at the beginning of our code execution add break point at 0x7c00
# 	`(gdb) br *0x7c00`

# 	dumbs the binary content in hex and assembly instructions (16-bits)
dump: boot.bin
	objdump -D -b binary -mi386 -Maddr16,data16,intel boot.bin
