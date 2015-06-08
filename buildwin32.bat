@echo off

echo Assembling bootloader...
nasm -O0 -f bin -o bootload.bin bootload.asm

echo Assembling kernel...
nasm -O0 -f bin -o kernel.bin kernel.asm

echo Adding bootsector to disk image...
partcopy bootload.bin 0 200 ./image/BuenOS.flp 0

echo Mounting disk image...
imdisk -a -f ./image/BuenOS.flp -s 1440K -m B:

echo Copying kernel and applications to disk image...
copy kernel.bin B:\
copy programs\*.bin B:\

echo Dismounting disk image...
imdisk -D -m B:

echo Done!