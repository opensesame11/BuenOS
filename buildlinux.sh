#!/bin/sh

if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi

if [ ! -e image ]
then
	mkdir image
fi

if [ ! -e image/BuenOS.flp ]
then
	echo "Creating new floppy image..."
	mkdosfs -C image/BuenOS.flp 1440 || exit
fi

echo "\nCompiling bootloader..."

nasm -O0 -f bin -o bootload.bin bootload.asm || exit

echo "\nCompiling kernel..."

nasm -O0 -f as86 -o kernel.o kernel.asm || exit
cd api
for i in *.c
do
	bcc -0 -c -ansi $i || exit
done
cd ..

ld86 -d -o kernel.bin kernel.o ./api/*.o || exit

echo "\nCompiling programs..."

cp ./api/buenosapi.h ./programs/buenosapi.h
cd programs
rm -f *.bin
nasm -O0 -f as86 -o buenosapi.o buenosapi.l || exit
echo "buenosapi.l Compiled\n"
for i in *.asm
do
	nasm -O0 -f as86 $i -o ${i%.*}.o || exit
	echo "$i Compiled"
	ld86 -d ${i%.*}.o buenosapi.o -o ${i%.*}.tmp || exit
	echo "${i%.*}.o and buenosapi.o Linked"
	dd if=${i%.*}.tmp bs=1024 skip=32 of=${i%.*}.bin || exit
	echo
done
for i in *.c
do
	bcc -c -ansi $i -o ${i%.*}.o || exit
	echo "$i Compiled"
	ld86 -d ${i%.*}.o buenosapi.o -o ${i%.*}.tmp  || exit
	echo "${i%.*}.o and buenosapi.o Linked"
	dd if=${i%.*}.tmp bs=1024 skip=32 of=${i%.*}.bin || exit
	echo
done

rm -f *.o *.tmp *.bcc
cd ..
rm -f *.o
cd api
rm -f *.o
cd ..

echo "\nAdding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=./bootload.bin of=./image/BuenOS.flp || exit


echo "\nCopying BuenOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat image/BuenOS.flp tmp-loop

rm -f tmp-loop/*.*
cp kernel.bin tmp-loop/
cp programs/*.bin tmp-loop/
cp ./LICENSE.txt tmp-loop/

sleep 0.2

umount tmp-loop || exit

rm -rf tmp-loop

echo '\nDone!'

