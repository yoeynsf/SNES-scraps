superfamiconv -D -F -R -i gfx/chr0.png -t output/chr/chr0.chr -p output/pal/chr0.pal -v
superfamiconv -D -F -R -i gfx/chr1.png -t output/chr/chr1.chr -p output/pal/chr1.pal -v
superfamiconv -D -F -R -i gfx/chr2.png -t output/chr/chr2.chr -p output/pal/chr2.pal -v
superfamiconv -D -F -R -i gfx/chr3.png -t output/chr/chr3.chr -p output/pal/chr3.pal -v

ca65 -g src/spc/spc.asm -o output/spc.o
ld65 -C spc.cfg --dbgfile output/spc.dbg output/spc.o -o src/spc/driver.bin

ca65 --cpu 65816 -g header.asm -o output/funny.o
ld65 -m map.txt -C lorom256k.cfg --dbgfile output/funny.dbg output/funny.o -o output/funny.sfc
pause