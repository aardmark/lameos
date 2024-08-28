output_dir = ../build

$(output_dir)/bootloader.bin: bootloader.asm
	nasm -f bin -o $(output_dir)/bootloader.bin bootloader.asm 

.PHONY: clean

clean:
	rm -f $(output_dir)/bootloader.bin
