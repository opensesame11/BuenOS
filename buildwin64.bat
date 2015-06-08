@echo off

echo Compiling bootloader...

	nasm -O0 -f bin -o bootload.bin bootload.asm
if ERRORLEVEL 1 goto error


echo Compiling kernel...

	nasm -O0 -f elf kernel.asm -o kernel.o
if ERRORLEVEL 1 goto error
cd api
	for %%i IN (*.c) DO gcc -c %%i
if ERRORLEVEL 1 goto error
cd ..
	ld -T NUL kernel.o .\api\*.o -o kernel.tmp
if ERRORLEVEL 1 goto error
	objcopy -O binary kernel.tmp kernel.bin

for /R %%i IN (*.o) DO del %%i
del kernel.tmp

echo Adding bootsector to disk image...

	msdos partcopy bootload.bin 0 200 ./image/BuenOS.flp 0
if ERRORLEVEL 1 goto error


echo Mounting disk image...

	imdisk -a -f ./image/BuenOS.flp -s 1440K -m B:
if ERRORLEVEL 1 goto error


echo Copying kernel and applications to disk image...

	copy kernel.bin B:\
	copy programs\*.bin B:\


echo Dismounting disk image...

	imdisk -D -m B:
echo Done!
goto done

:error
echo An error has occured while assembling BuenOS

:done