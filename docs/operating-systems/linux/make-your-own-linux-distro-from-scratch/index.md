# Make your own Linux Distro From scratch

I'll call my distro name as: TiniLinux

Welcome to TiniLinux, we will make a Linux Distro from scratch

## Theory

To make a very tiny and simple Linux distro, we're going to need:

* Kernel
* User Space (in this case we use BusyBox)
* Bootloader (in this case we use Grub)

```
              ┌────────────────────┐                     
              │     Power On       │                     
              │                    │                     
              └─────────┬──────────┘                     
                        │                                
                        │                                
              ┌─────────▼──────────┐                     
              │     BIOS/UEFI      │                     
              │                    │                     
              │       (POST)       │                     
              └─────────┬──────────┘                     
                        │                                
                        │                                
              ┌─────────▼──────────┐                     
              │    Boot Device     │                     
              │                    │                     
              │  Hard Disk/CD/USB  │                     
              └─────────┬──────────┘                     
                        │                                
                        │                                
              ┌─────────▼──────────┐                     
              │  Boot Loader(GRUB) │                     
              │                    │                     
              │  Load kernel and   │                     
              │  initramfs to RAM  │                     
              └──────────┬─────────┘                     
                         │                               
                         │                               
              ┌──────────▼─────────┐                     
              │       Kernel       │                     
              │                    │                     
              │ Execute /sbin/init │                     
              └──────────┬─────────┘                     
                         │                               
           (Live boot)   │  (Boot from Hard disk)        
           ┌─────────────┴──────────────┐                
           │                            │                
┌──────────▼─────────┐       ┌──────────▼─────────┐      
│   Init (initramfs) │       │  Init (initramfs)  │      
│                    │       │  Mount Real rootfs │      
│   Execute RunLevel │       │  from hard disk    │      
│      programs      │       │  then switch_root  │      
│                    │       │  exec /sbin/init   │      
└────────────────────┘       └──────────┬─────────┘      
                                        │                
                                        │                
                             ┌──────────▼─────────┐      
                             │        Init        │      
                             │                    │      
                             │   Execute RunLevel │      
                             │      programs      │      
                             └──────────┬─────────┘      
                                        │                
                                        │                
                             ┌──────────▼─────────┐      
                             │  Systemd / OpenRC  │      
                             │                    │      
                             │   Execute System   │      
                             │   Daemon programs  │      
                             └────────────────────┘      
                                                         
(Drew with https://asciiflow.com/)
```

This applies to real world Linux distro as well (Debian, Ubuntu, Fedora,...)

## Steps

!!! note "This page is a WIP, check back later for more contents"

Here is a guide how to make a simple Linux Distro from scratch.

1. [Setup Environment](1-setup-env.md)  
2. [Compile the kernel](2-kernel.md)  
3. [Compile Busybox](3-busybox.md)  
4. [Creating the initial ram filesystem (initramfs)](4-initramfs.md)  
5. [Configuring the bootloader](5-bootloader.md)  
6. [Package manager](6-package-manager.md)  
7. [Docker](7-docker.md)  
8. [Install to hard drive](8-install-to-hard-drive.md)  
99. [Appendix](99-appendix.md)  

## References

* [https://www.youtube.com/watch?v=QlzoegSuIzg](https://www.youtube.com/watch?v=QlzoegSuIzg)
* [https://medium.com/@ThyCrow/compiling-the-linux-kernel-and-creating-a-bootable-iso-from-it-6afb8d23ba22](https://medium.com/@ThyCrow/compiling-the-linux-kernel-and-creating-a-bootable-iso-from-it-6afb8d23ba22)
* [https://medium.com/@GlobularOne/how-to-make-a-minimal-linux-distribution-from-source-code-5ff9b48dfc2](https://medium.com/@GlobularOne/how-to-make-a-minimal-linux-distribution-from-source-code-5ff9b48dfc2)
* [https://gist.github.com/m13253/e4c3e3a56a23623d2e7e6796678b9e58](https://gist.github.com/m13253/e4c3e3a56a23623d2e7e6796678b9e58)
* [https://kmahyyg.medium.com/tiny-image-dropbear-with-busybox-6f5b65a44dfb](https://kmahyyg.medium.com/tiny-image-dropbear-with-busybox-6f5b65a44dfb)
* [https://github.com/vmware/open-vm-tools/issues/696#issuecomment-1812710977](https://github.com/vmware/open-vm-tools/issues/696#issuecomment-1812710977)
[http://wiki.loverpi.com/faq:sbc:libre-aml-s805x-minimal-rootfs](http://wiki.loverpi.com/faq:sbc:libre-aml-s805x-minimal-rootfs)
* [https://dariodip.medium.com/understanding-linux-containers-a-simple-recipe-7c24cc1137b4](https://dariodip.medium.com/understanding-linux-containers-a-simple-recipe-7c24cc1137b4)
