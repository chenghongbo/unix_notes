## About ROM
[link here](https://askubuntu.com/questions/173248/where-is-the-bootloader-stored-in-rom-ram-or-elsewhere)
>
ROM is a separate chip from the RAM. It does not require power to retain its contents, and originally could not be modified by any means, but came hard wired from the factory. Later PROM, or Programmable Read Only Memory replaced true ROM. These chips came blank from the factory, and could be written to once using a special procedure that essentially burned out bits of the chip causing their state to change. This was then replaced with EPROM, or Eraseable Programmable Memory. These chips had a little window on them and if you shined ultraviolet light into them, could be erased, allowing them to be programmed again. These were then replaced with EEPROM, or Electrically Erasable Programmable Memory. These chips have a special software procedure to erase them so they can be reprogrammed. ROM generally is still used to refer to all of these types generically.
>
The motherboard has some type of ROM chip that holds the firmware, which in PC parlance is usually called the BIOS, or Basic Input Output System, though it is being replaced these days with EFI firmware. This is the software that the CPU first starts executing at power on. All firmware performs initialization of the hardware, typically provides some diagnostic output, and provides a way for the user to configure the hardware, then locates and loads the boot loader, which in turn locates and loads the OS.
>
With PC BIOS, it simply loads and executes the first sector off the disk it decides to boot from, which typically is the first hard disk detected. By convention the first sector of a hard disk, called the Master Boot Record, contains a DOS partition table listing the locations of the partitions on the disk, and and leaves some space for the boot loader. Ubuntu uses the GRUB boot loader, which places enough code in the MBR to load and execute /boot/grub/core.img. Normally a copy of this file is placed in the sectors following the MBR, but before the first partition, and that is actually what the MBR loads, since finding the location of /boot/grub/core.img is too difficult to do properly in the very limited space available in the MBR.
>
The grub core image contains the base grub code, plus any modules needed to access /boot/grub so that it can load additional modules there, and the grub config file that describes what operating systems can be booted, and where they can be found.
>
The EFI firmware used on Intel Macs and becoming available as a replacement to BIOS on most recent PC motherboards requires a dedicated partition that holds boot loader files, and the firmware is smart enough to find those files and load one instead of just loading and executing whatever is in the first sector of the disk.

## how to disable fastboot (excerpt from link ii)
>Q2) How do I disable 'fastboot' for my commercial device?

>A2) Personally, I would like to see commercial devices leave 'fastboot' enabled.  It goes in the spirit of Android Open Source Project where end users and developers have access to the source code to allow them to modify it and upgrade their device over usb using 'fastboot'.  However, if OEMs or network providers want to lock down 'fastboot' it can be done by disabling the keypad and usb driver in bootloader.  This can be customized in the following files:
repo init -u git://github.com/LineageOS/android.git -b lineage-15.0


	lk/app/aboot/fastboot.c

	lk/app/aboot/aboot.c

## helpful links
1. [The Bootloader – Understanding, Modifying, Building and Installing](https://javigon.com/2012/08/27/the-bootloader-understanding-modifying-building-and-installing/)
2. [Aurora blog: (L)ittle (K)ernel based Android bootloader](https://www.codeaurora.org/blogs/little-kernel-based-android-bootloader)
3. [Booting Android: bootloaders, fastboot and boot images](https://www.slideshare.net/chrissimmonds/android-bootslides20)