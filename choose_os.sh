#!/bin/sh

read -p "What OS do you want to choose:
"1-Debian"
"2-Alpine"
"3-MACOS"
" os_verison


case "$os_verison" in
    1|DEBIAN|debian)
        chmod +x init_debian.sh
        ./init_debian.sh "sudo apt"
        ;;

    2|ALPINE|alpine)
        apk add bash
        chmod +x init_alpine.sh 
        ./init_alpine.sh "sudo apk add"
        ;;

    3|macos|MACOS)
        chmod +x init_macos.sh 
        bash ./init_macos.sh "brew"
        ;;
esac
