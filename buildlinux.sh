#!/bin/sh

if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e image/BuenOS.flp ]
then
	echo "Creating new floppy image..."
	mkdosfs -C image/BuenOS.flp 1440 || exit
fi

echo "Compiling bootloader..."

nasm -O0 -f bin -o bootload.bin bootload.asm || exit

echo "Compiling kernel..."

nasm -O0 -f as86 -o kernel.o kernel.asm || exit
cd api
for i in *.c
do
	bcc -c -ansi $i || exit
done
cd ..

ld86 -d -o kernel.bin kernel.o ./api/*.o || exit

rm -f *.o
cd api
rm -f *.o
cd ..

echo "Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=./bootload.bin of=./image/BuenOS.flp || exit


echo "Copying BuenOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat image/BuenOS.flp tmp-loop && cp kernel.bin tmp-loop/

cp programs/*.bin tmp-loop

sleep 0.2

umount tmp-loop || exit

rm -rf tmp-loop

echo 'Done!'

