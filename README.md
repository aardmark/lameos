[See](https://wiki.osdev.org/Category:Babystep)

objdump -Mintel -m i8086  -b binary -D  build/bootloader.bin 
objdump -Mintel -m i8086  -b binary --adjust-vma=0x7c00  -D  build/bootloader.bin 
