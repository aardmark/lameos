bootloader:
	$(MAKE) -C bootloader

emu: bootloader
	qemu-system-x86_64 -blockdev driver=file,node-name=f0,filename=build/bootloader.bin -device floppy,drive=f0

clean:
	$(MAKE) -C bootloader clean

.PHONY: emu bootloader clean
