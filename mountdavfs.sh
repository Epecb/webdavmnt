#!/usr/bin/env bash

davfshost=(
"https://webdav.4shared.com"
"https://webdav.yandex.ru"
)

HELP="Usage:
$0 <ProviderFirstChar> m
$0 <ProviderFirstChar> u

ProviderFirstChar:
$(printf '%s\n' "${davfshost[@]}" )

m - mount
u - umount

Example:
$0 4shared m
"
pwdnow=$(pwd)
cd ~
homenow=$(pwd)
cd $pwdnow
secretdir=$homenow"/secret"
providerhost=''
provdir=''
temp=''
if [[ -z $1 || -z $2 ]]; then
    echo "$HELP"
    exit
fi
for i in ${davfshost[@]}; do
    temp=$(echo $i|grep -io "$1[^.]*")
    if [ $? != 1 ]; then
        providerhost=$i
        provdir=$homenow"/webdav/$temp"
        break
    fi
done
if [ -z $providerhost ]; then
   echo -e "$HELP"
fi

if [ "$2" = "m" ]; then
    echo "mounting"
    if ! [ -d $provdir ]; then
        echo 'No directory $provdir'
        mkdir -p $provdir
        echo 'created'
    fi
    sudo mount.davfs -o uid=$(whoami),rw $providerhost $provdir
    if [ $? -eq 0 ]; then
        if ! [ -d $secretdir ]; then
            echo 'No directory ~/secret'
            mkdir -p $secretdir
            echo 'created'
        fi
        encfs $provdir/folder/ $secretdir
    fi
fi

if [ "$2" = "u" ]; then
    echo "umounting"
    fusermount -u $secretdir
    if [ $? -eq 0 ]; then
        echo "unmount"
        sudo umount $provdir
    fi
fi
