#/sbin/sh
version=1.0
echo "INFO:the script must be run as recovery mode"
#check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "ERROR:This script must be run as root" 1>&2
   exit 1
fi
#check init.rc file 
if [ ! -f /system/etc/init/hw/init.rc ]; then
   echo "ERROR:init.rc file not found" 1>&2
   echo "ERROR:please check /system mount point" 1>&2
   exit 1
fi
# verify and patch init.rc
hash=3578167607f3079863579e8ec71d4b57c14e32075b74cd562d261ec6afccff492904bbf172cc25b741b323ac143facbddfbd1e9899055621d0e7a6a7fe64b120
if [ $(sha512sum -b /system/etc/init/hw/init.rc) = "$hash" ];then
    echo "INFO:init.rc sha512sum is correct"
    echo "INFO:patching init.rc"
    sed -i '/restorecon --recursive --skip-ce \/data/i\ mkdir \/cache\/sdcardmirror 0755' /system/etc/init/hw/init.rc
    sed -i '/restorecon --recursive --skip-ce \/data/i\ exec - root root -- \/system\/bin\/mount --bind \/cache\/sdcardmirror \/data\/media\/0' /system/etc/init/hw/init.rc
    sed -i '/restorecon --recursive --skip-ce \/data/a\ exec - root root -- \/system\/bin\/umount \/data\/media\/0' /system/etc/init/hw/init.rc
    echo "INFO:init.rc file patched"
    exit 0
else
    echo "ERROR:init.rc file sha512sum error" 1>&2
    echo "ERROR:The file may have been modified" 1>&2
    exit 1
fi
