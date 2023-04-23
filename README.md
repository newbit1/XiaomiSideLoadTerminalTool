# Xiaomi SideLoad Terminal Tool (xsltt)
### [NewBit @ xda-developers](https://forum.xda-developers.com/m/newbit.1350876)

### Description
Xiaomi SideLoad Terminal Tool\
Read and Write your Partitions\
In Xiomi Recovery 5.0\
This Tool is fully inspirate from the Xiaomi Sideload Tool.\
It inherits technically the same functions.

### Inspiration
Xiaomi Sideload Read Flash on Locked bootloader from ROM-Provider

### Notes
* Minimal Bash Version 4.3 is needed
* xsltt doesn't (can not) check your Recovery version
* make your terminal window as wide as possible, the partitons menu can be quite huge
* ADB Versions higher than `Version 33.0.3-8952118` made trouble when reading hugh files

## Functions
### ADB Mode
* Read the partition structure from your device while in ADB mode
	* `adb shell ls -al $(adb shell toybox find /dev/block/platform -type d -name by-name)`
* Optional: Looks for the rawpartitions.txt file
* Saves the partition structure in partitions.txt for later use
* Reboot your device directly into Sideload Mode

### Sideload Mode
* Displays all available partitions from rawpartitions.txt
	* displays present backups in green
	* (un)select partition(s)
* Read selected partition(s) `adb pull $REMOTE $LOCAL`
	* saves it in backup folder
* Write/Flash selected partition(s) `adb push $LOCAL $REMOTE`
	* loads the partion file from backup folder and flash it to your devices partition
* Reboot your device

### No ADB Connection Possible
* If you cannot get your device ADB enabled, you can put your raw partition structure
	in the rawpartitions.txt file. The script tries to gather a useful partition structure
	out of it, and saves it as partitions.txt

<details>
<summary><b>rawpartitions.txt Structure</b></summary>

```
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 3rdmodem -> /dev/block/mmcblk0p43
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 3rdmodemnvm -> /dev/block/mmcblk0p14
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 3rdmodemnvmbkp -> /dev/block/mmcblk0p15
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 bootfail_info -> /dev/block/mmcblk0p49
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 cache -> /dev/block/mmcblk0p44
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 cust -> /dev/block/mmcblk0p53
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 dfx -> /dev/block/mmcblk0p42
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 dto -> /dev/block/mmcblk0p35
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 dts -> /dev/block/mmcblk0p34
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 erecovery_kernel -> /dev/block/mmcblk0p22
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 erecovery_ramdisk -> /dev/block/mmcblk0p23
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 erecovery_vbmeta -> /dev/block/mmcblk0p37
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 erecovery_vendor -> /dev/block/mmcblk0p24
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 fastboot -> /dev/block/mmcblk0p5
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 frp -> /dev/block/mmcblk0p4
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 fw_hifi -> /dev/block/mmcblk0p29
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 fw_lpm3 -> /dev/block/mmcblk0p3
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 hisitest0 -> /dev/block/mmcblk0p46
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 hisitest1 -> /dev/block/mmcblk0p47
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 hisitest2 -> /dev/block/mmcblk0p57
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 kernel -> /dev/block/mmcblk0p30
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 misc -> /dev/block/mmcblk0p20
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modem -> /dev/block/mmcblk0p39
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modem_dsp -> /dev/block/mmcblk0p40
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modem_dtb -> /dev/block/mmcblk0p41
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modem_om -> /dev/block/mmcblk0p18
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modemnvm_backup -> /dev/block/mmcblk0p10
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 modemnvm_factory -> /dev/block/mmcblk0p6
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modemnvm_img -> /dev/block/mmcblk0p11
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modemnvm_system -> /dev/block/mmcblk0p12
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 modemnvm_update -> /dev/block/mmcblk0p21
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 nvme -> /dev/block/mmcblk0p7
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 odm -> /dev/block/mmcblk0p45
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 oeminfo -> /dev/block/mmcblk0p8
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 patch -> /dev/block/mmcblk0p48
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 persist -> /dev/block/mmcblk0p16
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 product -> /dev/block/mmcblk0p56
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 ramdisk -> /dev/block/mmcblk0p31
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 recovery_ramdisk -> /dev/block/mmcblk0p32
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 recovery_vbmeta -> /dev/block/mmcblk0p36
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 recovery_vendor -> /dev/block/mmcblk0p33
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 reserved1 -> /dev/block/mmcblk0p17
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 reserved2 -> /dev/block/mmcblk0p25
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 reserved3 -> /dev/block/mmcblk0p51
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 rrecord -> /dev/block/mmcblk0p50
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 secure_storage -> /dev/block/mmcblk0p13
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 sensorhub -> /dev/block/mmcblk0p28
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 splash -> /dev/block/mmcblk0p9
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 splash2 -> /dev/block/mmcblk0p19
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 system -> /dev/block/mmcblk0p52
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 teeos -> /dev/block/mmcblk0p26
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 trustfirmware -> /dev/block/mmcblk0p27
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 userdata -> /dev/block/mmcblk0p58
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 vbmeta -> /dev/block/mmcblk0p38
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 vendor -> /dev/block/mmcblk0p55
lrwxrwxrwx 1 root root   21 2023-02-23 00:17 version -> /dev/block/mmcblk0p54
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 vrl -> /dev/block/mmcblk0p1
lrwxrwxrwx 1 root root   20 2023-02-23 00:17 vrl_backup -> /dev/block/mmcblk0p2
```
</details>

<details>
<summary><b>partitions.txt Structure</b></summary>

```
ALIGN_TO_128K_1 /dev/block/sdd1
ALIGN_TO_128K_2 /dev/block/sdf1
abl /dev/block/sde8
ablbak /dev/block/sde24
aop /dev/block/sde1
aopbak /dev/block/sde17
apdp /dev/block/sde35
bluetooth /dev/block/sde5
bluetoothbak /dev/block/sde21
boot /dev/block/sde51
bootbak /dev/block/sde55
cache /dev/block/sda13
catecontentfv /dev/block/sde49
catefv /dev/block/sde48
cateloader /dev/block/sde41
cdt /dev/block/sdd2
cmnlib /dev/block/sde11
cmnlib64 /dev/block/sde12
cmnlib64bak /dev/block/sde28
cmnlibbak /dev/block/sde27
cust /dev/block/sda7
ddr /dev/block/sdd3
devcfg /dev/block/sde13
devcfgbak /dev/block/sde29
devinfo /dev/block/sde33
dip /dev/block/sde34
dsp /dev/block/sde9
dspbak /dev/block/sde25
dtbo /dev/block/sde52
dtbobak /dev/block/sde54
exaid /dev/block/sda14
ffu /dev/block/sda16
frp /dev/block/sda5
fsc /dev/block/sdf5
fsg /dev/block/sdf4
gsort /dev/block/sda15
hyp /dev/block/sde3
hypbak /dev/block/sde19
imagefv /dev/block/sde15
imagefvbak /dev/block/sde31
keymaster /dev/block/sde10
keymasterbak /dev/block/sde26
keystore /dev/block/sda4
limits /dev/block/sde38
logdump /dev/block/sde42
logfs /dev/block/sde40
mdtp /dev/block/sde7
mdtpbak /dev/block/sde23
mdtpsecapp /dev/block/sde6
mdtpsecappbak /dev/block/sde22
metadata /dev/block/sda12
minidump /dev/block/sda6
misc /dev/block/sda3
modem /dev/block/sde4
modembak /dev/block/sde20
modemst1 /dev/block/sdf2
modemst2 /dev/block/sdf3
multiimgoem /dev/block/sde44
multiimgqti /dev/block/sde45
persist /dev/block/sda2
qupfw /dev/block/sde14
qupfwbak /dev/block/sde30
recovery /dev/block/sda8
recoverybak /dev/block/sda9
secdata /dev/block/sde47
splash /dev/block/sde37
spunvm /dev/block/sde36
ssd /dev/block/sda1
storsec /dev/block/sde43
super /dev/block/sda17
toolsfv /dev/block/sde39
tz /dev/block/sde2
tzbak /dev/block/sde18
uefisecapp /dev/block/sde16
uefisecappbak /dev/block/sde32
uefivarstore /dev/block/sde46
userdata /dev/block/sda18
vbmeta /dev/block/sde50
vbmeta_system /dev/block/sda10
vbmeta_systembak /dev/block/sda11
vbmetabak /dev/block/sde53
xbl /dev/block/sdb1
xbl_config /dev/block/sdb2
xbl_configbak /dev/block/sdc2
xblbak /dev/block/sdc1
```
</details>

### Software Test Point / EDL Mode
## Warning - Disclaimer
Use at your own risk, you can soft brick your device.
Read all your partitions, perhaps except super.img and userdata.img,
and make a solid copy of all your backup files.

If you manipulate your backup files xbl.bin and xblbak.bin,
ie. replace the first bytes 512 bytes with 00.
And write these files back to your device, this will break your xloader, the chain of trust.
Your device will boot into EDL Mode 9008. If you have the proper tools
and firehose files, you can perform quite some handy tasks with it now.
To leave EDL Mode, you must flash the original xbl.bin and xblbak.bin from backup copy
back to your device an reboot.

### Change Logs
#### [April 2023]
* [General] - published initial version

### Credits
* [Xiaomi Sideload Tool @ ROM-Provider](https://romprovider.com/xiaomi-sideload-tool/)
* [Bash Menu @ satnur](https://unix.stackexchange.com/users/502665/satnur)
	* [Arrow key/Enter menu](https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu)
* [ADB and Fastboot Sniffer](https://github.com/newbit1/ADB-and-Fastboot-Sniffer)
* [AOSP Online Android SDK Platform-tools](https://androidsdkmanager.azurewebsites.net/Platformtools)