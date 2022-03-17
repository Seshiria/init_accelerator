#/sbin/sh
version=2.0
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
if [ grep -q "sdcardmirror" /system/etc/init/hw/init.rc ];then
    echo "INFO:patching init.rc"
    sed -i '/restorecon --recursive --skip-ce \/data/i\ mkdir \/cache\/sdcardmirror 0755' /system/etc/init/hw/init.rc
    sed -i '/restorecon --recursive --skip-ce \/data/i\ exec - root root -- \/system\/bin\/mount --bind \/cache\/sdcardmirror \/data\/media\/0' /system/etc/init/hw/init.rc
    sed -i '/restorecon --recursive --skip-ce \/data/a\ exec - root root -- \/system\/bin\/umount \/data\/media\/0' /system/etc/init/hw/init.rc
    echo "INFO:init.rc file patched"
    exit 0
else
    echo "ERROR:The file have been modified" 1>&2
    exit 1
fi
