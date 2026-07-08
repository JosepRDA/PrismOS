TARGET   	:= bungos
CC 		 	:= x86_64-elf-gcc
WARNINGS 	:= -Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
               -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
               -Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
               -Wconversion -Wstrict-prototypes
CFLAGS 	 	:= -std=gnu23 -g -O2 -pipe $(WARNINGS)
LDFLAGS 	:= -nostdlib \
			   -nostartfiles \
               -static \
               -Wl,-m,elf_x86_64 \
               -Wl,-z,max-page-size=0x1000 \
               -Wl,--gc-sections \
               -Wl,-T,linker.ld
PROJDIRS    := src
INCLUDEDIR  := include
SRCFILES 	:= $(shell find $(PROJDIRS) -type f -name "*.c")
CFLAGS   	+= -mcmodel=kernel -fno-PIC -fno-lto -ffreestanding \
			   -ffunction-sections -fdata-sections -mno-red-zone \
			   -fno-stack-check -fno-stack-protector -MMD -MP -I$(INCLUDEDIR)
OBJFILES 	:= $(patsubst %.c,%.o,$(SRCFILES))
DEPFILES 	:= $(patsubst %.c,%.d,$(SRCFILES))
-include $(DEPFILES)

all: $(OBJFILES)
	$(CC)  $(CFLAGS) $(LDFLAGS) $(OBJFILES) -o $(TARGET)

# rule telling make how to make the object files
# $< -> c files; $@ -> target (.o)
%.o: %.c 
	$(CC) $(CFLAGS) -c $< -o $@

compdb:
	bear --output compile_commands.json -- $(MAKE) clean all

clean:
	-@$(RM) $(wildcard $(OBJFILES) $(DEPFILES) $(TARGET) compile_commands.json image.*)

# download limine deps
limine:
	curl -L https://github.com/Limine-Bootloader/Limine/releases/latest/download/limine-binary.tar.gz | gunzip | tar -xf -

iso:
	# Build "limine" utility.
	make -C limine-binary
	# Create a directory which will be our ISO root.
	mkdir -p iso_root
	# Copy the relevant files over.
	mkdir -p iso_root/boot
	cp -v bungos iso_root/boot/
	mkdir -p iso_root/boot/limine
	cp -v limine.conf limine-binary/limine-bios.sys limine-binary/limine-bios-cd.bin \
		  limine-binary/limine-uefi-cd.bin iso_root/boot/limine/
	# Create the EFI boot tree and copy Limine's EFI executables over.
	mkdir -p iso_root/EFI/BOOT
	cp -v limine-binary/BOOTX64.EFI iso_root/EFI/BOOT/
	cp -v limine-binary/BOOTIA32.EFI iso_root/EFI/BOOT/
	# Create the bootable ISO.
	xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
			-no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
			-apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
			-efi-boot-part --efi-boot-image --protective-msdos-label \
			iso_root -o image.iso
	# Install Limine stage 1 and 2 for legacy BIOS boot.
	./limine-binary/limine bios-install image.iso
	# Create an empty zeroed-out 64MiB image file.
	dd if=/dev/zero bs=1M count=0 seek=64 of=image.hdd
	# Create a partition table.
	PATH=$PATH:/usr/sbin:/sbin sgdisk image.hdd -n 1:2048 -t 1:ef00 -m 1
	# Build "limine" utility.
	make -C limine-binary
	# Install the Limine BIOS stages onto the image.
	./limine-binary/limine bios-install image.hdd
	# Format the image as fat32.
	mformat -i image.hdd@@1M
	# Make relevant subdirectories.
	mmd -i image.hdd@@1M ::/EFI ::/EFI/BOOT ::/boot ::/boot/limine
	# Copy over the relevant files.
	mcopy -i image.hdd@@1M bungos ::/boot
	mcopy -i image.hdd@@1M limine.conf limine-binary/limine-bios.sys ::/boot/limine
	mcopy -i image.hdd@@1M limine-binary/BOOTX64.EFI ::/EFI/BOOT
	mcopy -i image.hdd@@1M limine-binary/BOOTIA32.EFI ::/EFI/BOOT

# rule to facilitate booting into emulator
qemu:
	qemu-system-x86_64 -cdrom image.iso -m 512M

# debugging
print:
	@echo SRCFILES=$(SRCFILES)
	@echo OBJFILES=$(OBJFILES)

.PHONY: all clean print compdb iso qemu
