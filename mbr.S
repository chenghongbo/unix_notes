/*
copy right info removed due to display issues - Nov. 2011
*/

.file "mbr.S"

#include 
#include

/*
* Memory layout:
*
* 0x07C00 -> 0x07DFF BIOS loads us here (at 31k)
* 0x07E00 -> 0x17BFC our stack (to 95k)
*
* 0x07A00 -> 0x07BFF we relocate to here (at 30k5)
*
* 0x07C00 -> 0x07DFF we load PBR here (at 31k)
*
* The BIOS loads us at physical address 0x07C00. We use a long jmp to
* normalise our address to seg:offset 07C0:0000. We then relocate to
* 0x07A00, seg:offset 07A0:0000.
*
* We use a long jmp to normalise our address to seg:offset 07A0:0000
* We set the stack to start at 07C0:FFFC (grows down on i386)
* The partition boot record (PBR) loads /boot at seg:offset 4000:0000
*/

		/*
		汇编语言基础知识:
		
		AT&T 汇编风格
		命令 源地址,目的地址
		寄存器名称前使用%,如%ax
		直接数前使用$
		内存地址表示方式：segment-override:signed-offset(base,index,scale)

		mov $1, %eax (将数字1存入eax寄存器）

		--------------------------------------------------------------------------
		INTEL 汇编风格
		命令 目的地址，源地址
		直接使用寄存器名称，如ax
		直接使用数字（不加$)

		mov eax, 1 (将数字1存入eax寄存器）

		更多差别，可参考 http://asm.sourceforge.net/articles/linasm.html#Syntax

		*/

		/*

		PC X86启动时内存分布情况：

		Low Memory (the first MiB)
		---------------------------------------------------------------------------------------------------------------------------------------
		| start	     | end	        | size	                  | type	                             |     description                        |
		---------------------------------------------------------------------------------------------------------------------------------------
		|0x00000000	 | 0x000003FF	| 1 KiB	                  | RAM - partially unusable (see above) | Real Mode IVT (Interrupt Vector Table) |
		|0x00000400	 | 0x000004FF	| 256 bytes	              | RAM - partially unusable (see above) | BDA (BIOS data area)                   |
		|0x00000500	 | 0x00007BFF	| almost 30 KiB	          | RAM (guaranteed free for use)	     | Conventional memory                    |  
		|0x00007C00  | 0x00007DFF	| 512 bytes	              | RAM - partially unusable (see above) | Your OS BootSector                     |
		|0x00007E00	 | 0x0007FFFF	| 480.5 KiB	              | RAM (guaranteed free for use)	     | Conventional memory                    |
		|0x00080000	 | 0x0009FBFF	| ~120 KiB,dep. EBDA size | RAM (free for use, if it exists)	 | Conventional memory                    |
		|0x0009FC00  | 0x0009FFFF	| 1 KiB	                  | RAM (unusable)	                     | EBDA (Extended BIOS Data Area)         |
		|0x000A0000	 | 0x000FFFFF	| 384 KiB	              | various (unusable)	                 | Video memory, ROM Area                 |
		---------------------------------------------------------------------------------------------------------------------------------------

		*/
#define BOOTSEG 0x7c0 /* segment where we are loaded */
#define BOOTRELOCSEG 0x7a0 /* segment where we relocate to */
#define BOOTSTACKOFF 0xfffc /* stack starts here, grows down */
#define PARTSZ 16 /* each partition table entry is 16 bytes */

#define CHAR_LBA_READ '.'
#define CHAR_CHS_READ ';'
#define CHAR_CHS_FORCE '!'
#define CHAR_SHIFT_SEEN 0x07 /* Use BEL */

#define MBR_FLAGS_FORCE_CHS 0x0001

#ifdef DEBUG
#define CHAR_S 'S' /* started */
#define CHAR_R 'R' /* relocated */
#define CHAR_L 'L' /* looking for bootable partition */
#define CHAR_B 'B' /* loading boot */
#define CHAR_G 'G' /* jumping to boot */

#define DBGMSG(c) movb $c, %al; call Lchr
#else /* !DEBUG */
#define DBGMSG(c)
#endif /* !DEBUG */

		/* Clobbers %al - maybe more */
#define putc(c) movb $c, %al; call Lchr

		/* Clobbers %esi - maybe more */
#define puts(s) movw $s, %si; call Lmessage

.text
.code16  /* PC启动时处于实模式，16位 */

.globl start  /* 程序入口，如同C语言中的main() */
start:

		/* Adjust %cs to be right */
		/* ljmp syntax: ljmp $segment,$offset
		* after this %cs will be $BOOTSEG(0x07c0),
		* %IP will be whichever address the following 1: local label has
		* $1f means (the address of) a local label named "1" in forward
		* direction (f)
		*/

		/* here is what I got when asked in openbsd misc maillist about "$1f"  */

		/* from brynet#gmail.com (thanks!)

		One of the first things an MBR does is do a long jump from where the BIOS
		loaded it.

		The thing is, often you can't trust the BIOS to do the right thing, the x86 in
		16-bit real mode uses segmented memory, so you may be at 0000:07C0 or 7C00:0000
		depending on the implementation. If you read the comment higher up you'll see
		they perform a long jump to "normalize" the Code Segment to 07C0, offset 0.

		0000:07C0 and 7C00:0000 technically resolve to the same address, but enforcing
		segment:offset (cs:ip) just makes things consistent.

		The references to ":1" is a local label, used for relative addressing, 'f'
		meaning forward and 'b' meaning backward.

		http://sourceware.org/binutils/docs/as/Symbol-Names.html

		Most MBR's are OS-independent, they relocate, parse partition table, load the
		PBR/VBR to 7C00 and perform a ljmp to it.

		Hope that helps,
		-Bryan.

		*/

ljmp $BOOTSEG, $1f

1:
		/* Set up stack */
		/* means to set %ss and %sp register,
		which, combined, points to the top of the stack */

movw %cs, %ax
		/* %ax is now 0x7c0*/

		/*
		* We don't need to disable and re-enable interrupts around the
		* the load of ss and sp.
		*
		* From 80386 Programmer's Reference Manual:
		* "A MOV into SS inhibits all interrupts until after the execution
		* of the next instruction (which is presumably a MOV into eSP)"
		*
		* According to Hamarsoft's 86BUGS list (which is distributed with
		* Ralph Brown's Interrupt List), some early 8086/88 processors
		* failed to disable interrupts following a load into a segment
		* register, but this was fixed with later steppings.
		*
		* Accordingly, this code will fail on very early 8086/88s, but
		* nick@ will just have to live with it. Others will note that
		* we require an 80386 (or compatible) or above processor, anyway.
		*/
		/* cli */
movw %ax, %ss

		/* %ss is now 0x7c0*/
movw $BOOTSTACKOFF, %sp

		/* %sp registre is now 0xfffc, now the top of the stack is 07c0:fffc  */
		/* sti */ /* XXX not necessary; see above */

		/* Set up data segment */
movw %ax, %ds
DBGMSG(CHAR_S)

		/*
		* On the PC architecture, the boot record (originally on a floppy
		* disk) is loaded at 0000:7C00 (hex) and execution starts at the
		* beginning.
		*
		* When hard disk support was added, a scheme to partition disks into
		* four separate partitions was used, to allow multiple operating
		* systems to be installed on the one disk. The boot sectors of the
		* operating systems on each partition would of course expect to be
		* loaded at 0000:7C00.
		*
		* The first sector of the hard disk is the master boot record (MBR).
		* It is this which defines the partitions and says which one is
		* bootable. Of course, the BIOS loads the MBR at 0000:7C00, the
		* same location where the MBR needs to load the partition boot
		* record (PBR, called biosboot in OpenBSD).
		*
		* Therefore, the MBR needs to relocate itself before loading the PBR.
		*
		* Make it so.
		*/
		
		/*
		 * Instruction movsb is a string movement operation, 
		 * It is to Move byte at address DS:(E)SI to address ES:(E)DI
		 * So is movsw, movsd, but 2 bytes/ 4 bytes at a time, instead of one byte
	
		 * mov instruction cannot be used to move data from one MEMORY location
		 * to another MEMORY location. That is what the movs instruction is for.

		movsb指令执行时，ds:si 指向源地址 es:di指向目的地址
		cld 指令的作用是设置flag寄存器DF位为0，这样每次重复指令完成时di si均+1，否则-1
		rep 重复执行指定指令，直至%cx 或 %ecx寄存器的值为0 （每次重复完成%cx值减1）
		*/
	
movw $BOOTRELOCSEG, %ax
	/* you cannot move a immediate number to a segment register (such as es/ds/cs/ss etc.)
	   so you have to move that number to a general purpose register, then from that general
	   purpose register to a segment register.

	   %ax is now 0x7a0, then es will be set to this value.

	   %ds has been set to 0x7c0
	 */
movw %ax, %es
xorw %si, %si
xorw %di, %di

	/*  before the movsb instruction starts, 
	    source address is:      ds:si  0x7c0:0000
	    destination address is: es:si  0x7a0:0000
	

	 */
movw $0x200, %cx /* Bytes in MBR, relocate it all  0x200H = 512 D*/
cld
rep
movsb

		/* Jump to relocated self */
ljmp $BOOTRELOCSEG, $reloc

		/* MBR已经将把自己挪到了0x07A00 -> 0x07BFF， 把0x07C00 -> 0x07DFF的内存地址腾出来了。
		 * 接下来要把PBR（biosboot)加载到0x07C00 -> 0x07DFF地址去。
		 * 要想加载PBR，先要找到磁盘，然后找到磁盘上的活动分区，然后将此分区的第一个扇区（即PBR）的内容
		 * 加载上去
		 */

reloc:
DBGMSG(CHAR_R)

		/* Set up %es and %ds */
pushw %ds
popw %es 		/* next boot is at the same place as we were loaded */
pushw %cs
popw %ds 		/* and %ds is at the %cs */

#ifdef SERIAL
		/* Initialize the serial port to 9600 baud, 8N1.*/
xorw %ax, %ax
movb $0xe3, %ax
movw $SERIAL, %dx
int $0x14
#endif

		/*
		* If the SHIFT key is held down on entry, force CHS read
		*/

		/*
		* BIOS call "INT 0x16 Get Keyboard Shift Flags
		* Call with %ah = 0x02
		* Return:
		* %al = shift flags
		* %ah - undefined by many BIOSes
		*/
movb $0x02, %ah
int $0x16
testb $0x3, %al /* Either shift key down? */
jz no_shift

putc(CHAR_SHIFT_SEEN) /* Signal that shift key was seen */

orb $MBR_FLAGS_FORCE_CHS, flags

no_shift:
		/* BIOS passes us drive number in %dl
		*
		* XXX - This is not always true. We currently check if %dl
		* points to a HD, and if not we complain, and set it to point
		* to the first HDD. Note, this is not 100% correct, since
		* there is a possibility that you boot from HD #2, and still
		* get (%dl &amp;amp;amp;amp;amp; 0x80) == 0x00, these type of systems will lose.
		*/
testb $0x80, %dl
jnz drive_ok

		/* MBR on floppy or old BIOS
		* Note: MBR (this code) should never be on a floppy. It does
		* not belong there, so %dl should never be 0x00.
		*
		* Here we simply complain (should we?), and then hardcode the
		* boot drive to 0x80.
		*/
puts(efdmbr)

		/* If we are passed bogus data, set it to HD #1
		*/
movb $0x80, %dl

drive_ok:
		/* Find the first active partition.
		* Note: this should be the only active partition. We currently
		* don't check for that.
		*/
movw $pt, %si

movw $NDOSPART, %cx

find_active:
DBGMSG(CHAR_L)
movb (%si), %al

cmpb $DOSACTIVE, %al
je found

addw $PARTSZ, %si
loop find_active

		/* No bootable partition */
no_part:
movw $enoboot, %si

err_stop:
call Lmessage

stay_stopped:
sti 		/* Ensure Ctl-Alt-Del will work */
hlt 		/* (don't require power cycle) */
			/* Just to make sure */
jmp stay_stopped

found:
		/*
		* Found bootable partition
		*/

DBGMSG(CHAR_B)

		/* Store the drive number (from %dl) in decimal */
movb %dl, %al
andb $0x0F, %al
addb $'0', %al
movb %al, drive_num

		/*
		* Store the partition number, in decimal.
		*
		* We started with cx = 4; if found we want part '0'
		* cx = 3; part '1'
		* cx = 2; part '2'
		* cx = 1; part '3'
		*
		* We'll come into this with no other values for cl.
		*/
movb $'0'+4, %al
subb %cl, %al
movb %al, part_num

		/*
		* Tell operator what partition we're trying to boot.
		*
		* Using drive X, partition Y
		* - this used to be printed out after successfully loading the
		* partition boot record; we now print it out before
		*/
pushw %si
movw $info, %si
testb $MBR_FLAGS_FORCE_CHS, flags
jnz 1f
incw %si
1:
call Lmessage
popw %si

		/*
		* Partition table entry format:
		*
		* 0x00 BYTE boot indicator (0x80 = active, 0x00 = inactive)
		* 0x01 BYTE start head
		* 0x02 WORD start cylinder, sector
		* 0x04 BYTE system type (0xA6 = OpenBSD)
		* 0x05 BYTE end head
		* 0x06 WORD end cylinder, sector
		* 0x08 LONG start LBA sector
		* 0x0C LONG number of sectors in partition
		*
		* In the case of a partition that extends beyond the 8GB boundary,
		* the LBA values will be correct, the CHS values will have their
		* maximums (typically (C,H,S) = (1023,255,63)).
		*
		* %ds:%si points to the active partition table entry.
		*/

		/* We will load the partition boot sector (biosboot) where we
		* were originally loaded. We'll check to make sure something
		* valid comes in. So that we don't find ourselves, zero out
		* the signature at the end.
		*/
movw $0, %es:signature(,1)

		/*
		* Have we been instructed to ignore LBA?
		*/
testb $MBR_FLAGS_FORCE_CHS, flags
jnz do_chs

		/*
		* We will use the LBA sector number if we have LBA support,
		* so find out.
		*/

		/*
		* BIOS call "INT 0x13 Extensions Installation Check"
		* Call with %ah = 0x41
		* %bx = 0x55AA
		* %dl = drive (0x80 for 1st hd, 0x81 for 2nd, etc)
		* Return:
		* carry set: failure
		* %ah = error code (0x01, invalid func)
		* carry clear: success
		* %bx = 0xAA55 (must verify)
		* %ah = major version of extensions
		* %al (internal use)
		* %cx = capabilities bitmap
		* 0x0001 - extnd disk access funcs
		* 0x0002 - rem. drive ctrl funcs
		* 0x0004 - EDD functions with EBP
		* %dx (extension version?)
		*/

movb %dl, (%si) /* Store drive here temporarily */
		/* (This call trashes %dl) */
		/*
		* XXX This is actually the correct
		* place to store this. The 0x80
		* value used to indicate the
		* active partition is by intention
		* the same as the BIOS drive value
		* for the first hard disk (0x80).
		* At one point, 0x81 would go here
		* for the second hard disk; the
		* 0x80 value is often used as a
		* bit flag for testing, rather
		* than an exact byte value.
		*/
movw $0x55AA, %bx
movb $0x41, %ah
int $0x13

movb (%si), %dl /* Get back drive number */

jc do_chs /* Did the command work? Jump if not */
cmpw $0xAA55, %bx /* Check that bl, bh exchanged */
jne do_chs /* If not, don't have EDD extensions */
testb $0x01, %cl /* And do we have "read" available? */
jz do_chs /* Again, use CHS if not */

do_lba:
		/*
		* BIOS call "INT 0x13 Extensions Extended Read"
		* Call with %ah = 0x42
		* %dl = drive (0x80 for 1st hd, 0x81 for 2nd, etc)
		* %ds:%si = segment:offset of command packet
		* Return:
		* carry set: failure
		* %ah = error code (0x01, invalid func)
		* command packet's sector count field set
		* to the number of sectors successfully
		* transferred
		* carry clear: success
		* %ah = 0 (success)
		* Command Packet:
		* 0x0000 BYTE packet size (0x10 or 0x18)
		* 0x0001 BYTE reserved (should be 0)
		* 0x0002 WORD sectors to transfer (max 127)
		* 0x0004 DWORD seg:offset of transfer buffer
		* 0x0008 QWORD starting sector number
		*/
movb $CHAR_LBA_READ, %al
call Lchr

		/* Load LBA sector number from active partition table entry */
movl 8(%si), %ecx
movl %ecx, lba_sector

pushw %si /* We'll need %si later */

movb $0x42, %ah
movw $lba_command, %si
int $0x13

popw %si /* (get back %si) flags unchanged */

jnc booting_os /* If it worked, run the pbr we got */

		/*
		* LBA read failed, fall through to try CHS read
		*/

do_chs:
		/*
		* BIOS call "INT 0x13 Function 0x2" to read sectors from disk into
		* memory
		* Call with %ah = 0x2
		* %al = number of sectors
		* %ch = cylinder &amp;amp;amp;amp;amp; 0xFF
		* %cl = sector (0-63) | rest of cylinder bits
		* %dh = head
		* %dl = drive (0x80 for hard disk)
		* %es:%bx = segment:offset of buffer
		* Return:
		* carry set: failure
		* %ah = err code
		* %al = number of sectors transferred
		* carry clear: success
		* %al = 0x0 OR number of sectors transferred
		* (depends on BIOS!)
		* (according to Ralph Brown Int List)
		*/
movb $CHAR_CHS_READ, %al
call Lchr

/* Load values from active partition table entry */
movb 1(%si), %dh /* head */
movw 2(%si), %cx /* sect, cyl */
movw $0x201, %ax /* function and number of blocks */
xorw %bx, %bx /* put it at %es:0 */
int $0x13
jnc booting_os

read_error:
movw $eread, %si
jmp err_stop

booting_os:
puts(crlf)
DBGMSG(CHAR_G)

		/*
		* Make sure the pbr we loaded has a valid signature at the end.
		* This also ensures that something did load where we were expecting
		* it, as there's still a copy of our code there...
		*/
cmpw $DOSMBR_SIGNATURE, %es:signature(,1)
jne missing_os

		/* jump to the new code (%ds:%si is at the right point) */
ljmp $0, $BOOTSEG << 4
		/* not reached */

missing_os:
movw $enoos, %si
jmp err_stop

		/*
		* Display string
		*/
Lmessage:
pushw %ax
cld
1:
lodsb /* %al = *%si++ */
testb %al, %al
jz 1f
call Lchr
jmp 1b

		/*
		* Lchr: write the error message in %ds:%si to console
		*/
Lchr:
pushw %ax

#ifdef SERIAL
pushw %dx
movb $0x01, %ah
movw SERIAL, %dx
int $0x14
popw %dx
#else
pushw %bx
movb $0x0e, %ah
movw $1, %bx
int $0x10
popw %bx
#endif
1: popw %ax
ret

		/* command packet for LBA read of boot sector */
lba_command:
.byte 0x10 /* size of command packet */
.byte 0x00 /* reserved */
.word 0x0001 /* sectors to transfer, just 1 */
.word 0 /* target buffer, offset */
.word BOOTSEG /* target buffer, segment */
lba_sector:
.long 0, 0 /* sector number */

		/* Info messages */
info: .ascii "!Using drive "
drive_num:
.byte 'X'
.ascii ", partition "
part_num:
.asciz "Y"

		/* Error messages */
efdmbr: .asciz "MBR on floppy or old BIOS\r\n"
eread: .asciz "\r\nRead error\r\n"
enoos: .asciz "No O/S\r\n"
enoboot: .ascii "No active partition" /* runs into crlf... */
crlf: .asciz "\r\n"

endofcode:
nop

		/* We're going to store a flags word here */

. = 0x1b4
flags:
.word 0x0000
.ascii "Ox" /* Indicate that the two bytes */
		/* before us are the flags word */

		/* (MBR) NT disk signature offset */
. = 0x1b8
.space 4, 0

		/* partition table */
		/* flag, head, sec, cyl, type, ehead, esect, ecyl, start, len */
. = DOSPARTOFF 		/* starting address of partition table */
pt:
.byte 0x0,0,0,0,0,0,0,0
.long 0,0
.byte 0x0,0,0,0,0,0,0,0
.long 0,0
.byte 0x0,0,0,0,0,0,0,0
.long 0,0
.byte DOSACTIVE,0,1,0,DOSPTYP_OPENBSD,255,255,255
.long 0,0x7FFFFFFF
		/* the last 2 bytes in the sector 0 contain the signature */
. = 0x1fe
signature:
.short DOSMBR_SIGNATURE
. = 0x200
