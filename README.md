# android init.rc patch

**请阅读完全文再进行操作！！！**

## 背景和原理

Android系统在每次启动的过程中，会默认重设/data/下所有文件的selinux context，而用户的内置储存卡/sdcard/其实是链接到/data/media/0，Android默认并没有跳过/data/media/0的restorecon。（这部分请参阅aosp项目init相关的实现）

这样的后果就是如果用户或者app在内置储存放置太多文件（比如常见的wechat、telegram都会缓存媒体文件在/sdcard/android/Packagename/下）， 会导致开机时候浪费大量的时间在reset selinux context上。

这个脚本的唯一做的事情就是修补init.rc文件，在post-fs-data事件中``restorecon --recursive --skip-ce /data``之前，用一个空文件夹覆盖/data/media/0，用来跳过/data/media/0的restorecon，等restorecon完成后，还原对/data/media/0的修改。

## 使用前你需要注意的事情

* **因为直接操作了system分区，这个补丁会破坏系统的ota**

* **这个补丁只能解决因为/sdcard太多文件导致的开机缓慢。**

* **这个补丁仅为临时解决方案**

* **虽然理论上不会导致数据丢失，但是作者不对任何后果负责，请自行斟酌。**

## 使用方法

### 测试环境

Android 11 ，lineageos18.1，magisk24.1，twrp3.6.0

**为了安全期间，操作前请确保存有当前系统版本的刷机包**

### 使用方法

**因为脚本需要修改init.rc文件，请在刷机后/系统升级后再执行脚本，每次刷新系统后都需要执行一次。**

1. 请下载本项目中``patch.sh``并传送到Android手机上，选择一个可以在recovery下访问的位置，比如/sdcard/或者/data/。

2. 进入recovery环境，比如是twrp，请点开挂载选项，然后挂载system分区。

3. 确认system挂载后，可以用twrp的终端或者adb shell直接执行``sh patch.sh``

4. 脚本提示完成即可重启进入系统。

5. 如果需要还原修改，请重新刷入当前系统。
### 救砖

如果修补了init.rc文件导致系统无法开机，请回到recovery模式，重新刷入当前系统包。

### 进阶

脚本修改的目标文件是：``/system/etc/init/hw/init.rc``，如果系统维护人员没修过，应该是会和aosp官方提供的文件是一样。

## 额外信息

android issue：[https://issuetracker.google.com/issues/210063917](https://issuetracker.google.com/issues/210063917)

init.rc重置/data/所有文件的selinux context ：[https://cs.android.com/android/_/android/platform/system/core/+/refs/tags/android-11.0.0_r48:rootdir/init.rc;drc=109a140f6cf20ba0aa1f517999c690f6f4281b42;l=770](https://cs.android.com/android/_/android/platform/system/core/+/refs/tags/android-11.0.0_r48:rootdir/init.rc;drc=109a140f6cf20ba0aa1f517999c690f6f4281b42;l=770)

## 后记

其实我也不清楚为社么aosp官方不跳过/data/media/0目录的restorecon，因为理论上/data/media/0上存在的文件，都是系统selinux起作用之后才创建的，也不存在会有selinux context不对的情况（人为修改的另说）。
