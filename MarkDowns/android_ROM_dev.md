
# Some Basics About Above Terms

## Kernel :
A kernel is critical component of the Android and all operating systems. 

It can be seen as a sort of bridge between the applications and the actual hardware of a device. Android devices use the Linux kernel, but it's not the exact same kernel other Linux-based operating systems use. 

There's a lot of Android specific code built in, and Google's Android kernel maintainers have their work cut out for them. OEMs have to contribute as well, because they need to develop hardware drivers for the parts they're using for the kernel version they're using. This is why it takes a while for independent Android developers and hackers to port new versions to older devices and get everything working. Drivers written to work with the Gingerbread kernel on a phone won't necessarily work with the Ice Cream Sandwich kernel. And that's important, because one of the kernel's main functions is to control the hardware. It's a whole lot of source code, with more options while building it than you can imagine, but in the end it's just the intermediary between the hardware and the software. So basically if any instruction is given to mobile it first gives the command to kernel for the particular task execution.

## Bootloader :
The bootloader is code that is executed before any Operating System starts to run. Bootloaders basically package the instructions to boot operating system kernel and most of them also have their own debugging or modification environment. Think of the bootloader as a security checkpoint for all those partitions. Because if you’re able to swap out what’s on those partitions, you’re able to break things if you don’t know what you’re doing. So basically it commands the kernel of your device to Boot the Device properly without any issues. So careful with bootloader since it can mess things very badly.

## Recovery :
Recovery is defined in simple terms as a source of backup. Whenever your phone firmware is corrupted, the recovery does the job in helping you to restore or repair your faulty or buggy firmware into working condition. It is also used for flashing the Rom’s , kernel and many more things.

## Radio

The lowest part of software layer is the radio: this is the very first thing that runs, just before the bootloader. It control all wireless communication like GSM Antenna, GPS etc.

These are main parts of Android Operating System.

Now has we know what is Android and What it contains lets move to the Next major step. That is Android Rom Development from Source. But before starting this we need some Initial Setup and development Enviroment .


# dev workstation setup

## ubuntu 16.04 (64bit required)

### install dependency packages:
```shell
sudo apt install -y bc bison build-essential curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev 
```

### install jdk. 
depend on your taget android release, you may need different version of jdk
```
sudo apt install openjdk-8-jdk  fastboot adb
```

### download repo tool

```
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
```

# download source code 
depends on which source code repo you want to build, you need to sync from different repos
and it takes a LOOOONG time to sync

for lineage code base, branch 14.1.
```
cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b cm-14.1
repo sync
## loooooooooooooooooooooong wait
```

## device specific kernel/dev/vendor files

you need to sync from repo if your device is supported
or you'll need to extract it from your phone

