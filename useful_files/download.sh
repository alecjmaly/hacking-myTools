#!/bin/bash

## remove all current files
rm -rf /opt/hacking-myTools/useful_files/files/*


##  download linux
# files
cat /opt/hacking-myTools/useful_files/util/_files_to_download_linux.txt | xargs wget -N -P /opt/hacking-myTools/useful_files/files/linux
# mkdir /opt/hacking-myTools/useful_files/files/linux/github 2>/dev/null
# cat /opt/hacking-myTools/useful_files/util/_github_linux.txt | xargs -I{} sh -c "cd /opt/hacking-myTools/useful_files/files/linux/github; git clone {}"


##  download windows
# files
cat /opt/hacking-myTools/useful_files/util/_files_to_download_windows.txt | xargs wget -N -P /opt/hacking-myTools/useful_files/files/windows
# github
mkdir /opt/hacking-myTools/useful_files/files/windows/github 2>/dev/null
cat /opt/hacking-myTools/useful_files/util/_github_windows.txt | xargs -I{} sh -c "cd /opt/hacking-myTools/useful_files/files/windows/github; git clone {}"



##  download all
# files
cat /opt/hacking-myTools/useful_files/util/_files_to_download_all.txt | xargs wget -N -P /opt/hacking-myTools/useful_files/files/all
# github
mkdir /opt/hacking-myTools/useful_files/files/all 2>/dev/null
mkdir /opt/hacking-myTools/useful_files/files/all/github 2>/dev/null
cat /opt/hacking-myTools/useful_files/util/_github_all.txt | xargs -I{} sh -c "cd /opt/hacking-myTools/useful_files/files/all/github; git clone {}"
