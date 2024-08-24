[Repo](https://github.com/F4LCn/falcon-os)


objdump -Mintel -m i8086  -b binary -D  build/bootloader.bin 
objdump -Mintel -m i8086  -b binary --adjust-vma=0x7c00  -D  build/bootloader.bin 

make -B all
qemu-system-x86_64 -blockdev driver=file,node-name=f0,filename=build/bootloader.bin -device floppy,drive=f0
