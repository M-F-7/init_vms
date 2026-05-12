#!/bin/bash


# -e if an error occur from a command, -u if a variable is undefined, -o pipefail if a pipe fail
# the script stop directly

set -euo pipefail

# link the stderr with a file to get all the erros in a file 
#TODO: exec 2>>errors.log

# package_manager=$1

########################SUDO################################
read -p "⌛ Want to add a user to sudoers?: [y/N] " sudo_updt

if [[ "$sudo_updt" == "y" || "$sudo_updt" == "Y" || "$sudo_updt" == "" ]]; then
    echo "Need the sudo Password ​🦸🏻​"
    su -c '
    export PATH=/usr/sbin:/sbin:$PATH
    read -p "User name to add to sudoers: " username
    usermod -aG sudo "$username"
    echo "$username ALL=(ALL:ALL) ALL" | EDITOR="tee -a" visudo
    '
else
    echo "Must be root to execute the script if you dont wanna add the user to sudoers ❌"
fi

sudo apt update -y

#dpkg: -s get the info of the package, if none the package is uninstall
#command -v [COMMAND_NAME]: to get the path of the command name

check_already_install() {
    local package="$1"

    if dpkg -s "$package" > /dev/null 2>&1; then
        echo "$package is already installed"
        dpkg -s "$package" | grep "Version" || true
        return 0
    else
        return 1
    fi
}

install_package()
{
        local package="$1"

        # sudo apt update -y
        # eval "$package_manager" "$package"
        sudo apt install "$package" -y \
            1>/dev/null \
            2> >(grep -v "apt does not have a stable CLI interface" >&2)


        echo "$package is correctly installed ✅"
}


########################KEYBOARD################################
read -p "⌛ Want to put the keyboard to AZERTY in the VM settings?: [y/N] " keyboard_vm
if [[ "$keyboard_vm" == "y" || "$keyboard_vm" == "Y" || "$keyboard_vm" == "" ]]; then
        sudo dpkg-reconfigure keyboard-configuration
        sudo service keyboard-setup restart
        exit
fi
        
read -p "⌛ Want to put the keyboard to AZERTY in the current OS?: [y/N] " keyboard

if [[ "$keyboard" == "y" || "$keyboard" == "Y" || "$keyboard" == "" ]]; then
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"
    gsettings get org.gnome.desktop.input-sources sources
else
    echo -n "Actual version: "
    gsettings get org.gnome.desktop.input-sources sources
fi


########################CURL################################
if ! check_already_install curl; then
    read -p "⌛ Want to install curl: [y/N] " install_curl

    if [[ "$install_curl" == "y" || "$install_curl" == "Y" || "$install_curl" == "" ]]; then
        install_package curl
    else
        echo "Curl installation skipped ❌"
    fi
fi


########################TREE################################
if ! check_already_install tree; then
    read -p "⌛ Want to install tree: [y/N] " install_tree

    if [[ "$install_tree" == "y" || "$install_tree" == "Y" || "$install_tree" == "" ]]; then
        install_package tree
    else
        echo "Tree installation skipped ❌"
    fi
fi

########################GIT################################
if ! check_already_install git; then

    read -p "⌛ Want to install git: [y/N] " install_git

    if [[ "$install_git" == "y" || "$install_git" == "Y" || "$install_git" == "" ]]; then
        install_package git

        #read: get an input, -ps (p for prompt, s for silence)
        read -p "Git username: " git_username
        read -p "Git mail: " git_mail

        git config --global user.name "$git_username"
        git config --global user.email "$git_mail"

    else
        echo "Git installation skipped ❌"
    fi
fi


########################MAKE################################
if ! check_already_install make; then
    read -p "Want to install MAKE: [y/N] " install_make

    if [[ "$install_make" == "y" || "$install_make" == "Y" || "$install_make" == "" ]]; then
        install_package make
    else
        echo "MAKE installation skipped ❌"
    fi
fi


########################NPM################################
if ! check_already_install npm; then
    read -p "Want to install npm: [y/N] " npm

    if [[ "$npm" == "y" || "$npm" == "Y" || "$npm" == "" ]]; then
        echo "It can take some time to install nodejs and npm, be patient... ⌛" 
        install_package nodejs
        install_package npm
    else
        echo "npm installation skipped ❌"
    fi
fi


########################CARGO################################
if cargo --version > /dev/null 2>&1; then
    echo "CARGO is already installed"
    cargo --version
else
    read -p "Want to install CARGO: [y/N] " CARGO

    if [[ "$CARGO" == "y" || "$CARGO" == "Y" || "$CARGO" == "" ]]; then
        curl https://sh.rustup.rs -sSf | sh -s -- -y 1> /dev/null 2>&1
        source "$HOME/.cargo/env"
        echo "CARGO is correctly installed ✅"
    else
        echo "CARGO installation skipped ❌"
    fi
fi


########################GO################################
if ! check_already_install golang; then
    read -p "Want to install GO: [y/N] " GO

    if [[ "$GO" == "y" || "$GO" == "Y" || "$GO" == "" ]]; then
        install_package golang
    else
        echo "GO installation skipped ❌"
    fi
fi


########################PIP################################
if ! check_already_install python3-pip; then
    read -p "Want to install PIP: [y/N] " PIP

    if [[ "$PIP" == "y" || "$PIP" == "Y" || "$PIP" == "" ]]; then
        install_package python3-pip
    else
        echo "PIP installation skipped ❌"
    fi
fi


########################PIPX################################
if ! check_already_install pipx; then
    read -p "Want to install PIPX: [y/N] " PIPX

    if [[ "$PIPX" == "y" || "$PIPX" == "Y" || "$PIPX" == "" ]]; then
        install_package pipx
    else
        echo "PIPX installation skipped ❌"
    fi
fi

########################SSH################################
if ! check_already_install ssh; then

  read -p "⌛ Want to add an ssh key: [y/N] " ssh_key

    #working only with the default path for the ssh key
  if [[ "$ssh_key" == "y" || "$ssh_key" == "Y" || "$ssh_key" == "" ]]; then
      read -p "Need an email for the ssh key: " ssh_mail
      ssh-keygen -t ed25519 -C "$ssh_mail"
      eval "$(ssh-agent -s)"
      ssh-add ~/.ssh/id_ed25519
      echo -n "🗝️​ Public ssh key: "
      cat ~/.ssh/id_ed25519.pub
      echo ""
      echo "1) Go to GitHub Settings"
      echo "2) Navigate to SSH and GPG keys > New SSH Key"
      echo "3) Go to GitHub Settings"
      echo "4) Paste the copied key into the \"Key\" field and give it a title"
      echo "5) Click Add SSH Key."
      read -p "⌛ When you have finished with the precedent steps, you can press any to continue ⌛" 
      # ssh -T git@github.com
      ssh_output=$(ssh -T git@github.com || true)
      echo "$ssh_output"
  else
      echo "Ssh key not generated ❌"
  fi
fi 


########################DOCKER################################
if ! check_already_install docker.io; then
    read -p "⌛ Want to install docker: [y/N] " install_docker

    if [[ "$install_docker" == "y" || "$install_docker" == "Y" || "$install_docker" == "" ]]; then

        install_package docker.io
        sudo usermod -aG docker "$USER"
        echo "Need the sudo Password ​🦸🏻​"
        result=$(su - "$USER" -c "docker info 2>/dev/null | grep Username || true")
        if [ -n "$result" ]; then

            docker_username=$(docker info 2>/dev/null | awk -F': ' '/Username/ {print $2}') # get only the username variable
            echo "Already connected as $docker_username"
        else
            #read: get an input, -ps (p for prompt, s for silence)
            read -p "Docker username: " docker_username
            read -p "Docker password: " -s docker_password
            echo ""

            #docker login [OPTIONS] [SERVER] 
            # docker login -u "$docker_username" -p "$docker_password" ## server default is dockerhub
            # echo "$docker_password" | docker login -u "$docker_username" --password-stdin
            if echo "$docker_password" | docker login -u "$docker_username" --password-stdin; then
                echo "Login réussi✅"
                rm ~/.docker/config.json
            else
                echo "Login échoué, mais le script continue❌"
            fi
            # echo "$docker_password" | docker login -u "$docker_username" --password-stdin || echo "login failed ❌"
        fi
    else
        echo "Docker installation skipped ❌"
    fi
fi


########################CODE################################
if ! check_already_install code; then 
    read -p "⌛ Want to install code: [y/N] " install_code
    if [[ "$install_code" == "y" || "$install_code" == "Y" || "$install_code" == "" ]]; then
        if ! check_already_install wget; then
            install_package wget
        fi
        if ! check_already_install gpg; then
            install_package gpg
        fi
        # Import de la clé Microsoft
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/ms_vscode.gpg > /dev/null
        # Ajout du dépôt officiel
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms_vscode.gpg] https://packages.microsoft.com/repos/code stable main" \
          | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update -y > /dev/null
        install_package code
        # code --version | head -n 1
    else
        echo "Code installation skipped ❌"
    fi
fi


########################ZSH################################
if ! check_already_install zsh; then

    read -p "⌛ Want to install zsh: [y/N] (need git and curl installed) " install_zsh

    if [[ "$install_zsh" == "y" || "$install_zsh" == "Y" || "$install_zsh" == "" ]]; then
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            install_package zsh > /dev/null 2>&1
            # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null
            RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1
        fi
        # Add custom PATH after oh-my-zsh is installed
        if ! grep -q 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"' >> "$HOME/.zshrc"
        fi
        read -p "⌛ Want to add aliases in the .zshrc? : [y/N] " zsh_sc
        if [[ "$zsh_sc" == "y" || "$zsh_sc" == "Y" || "$zsh_sc" == "" ]]; then
            if [ -f alias.txt ]; then
                cat alias.txt >> ~/.zshrc
            else
                echo "Need a file \'alias.txt\' in the current directory"
            fi

        fi
        
        if [ "$SHELL" != "$(which zsh)" ]; then
            read -p "⌛ Want to switch to a zsh shell? : [y/N] " zsh_shell
            if [[ "$zsh_shell" == "y" || "$zsh_shell" == "Y" || "$zsh_shell" == "" ]]; then
                echo "Need User session password"
                chsh -s "$(which zsh)"
                # exec zsh #terminate the script, need to be the last command
            fi
        fi

    else
        echo "Zsh installation skipped ❌"
    fi
fi

########################CMAKE################################
if ! check_already_install cmake; then
    read -p "Want to install CMAKE: [y/N] " install_cmake

    if [[ "$install_cmake" == "y" || "$install_cmake" == "Y" || "$install_cmake" == "" ]]; then
        install_package cmake
        
    else
        echo "CMAKE installation skipped ❌"
    fi
fi

# #######################K8S################################
# dpkg -s kubectl
# read -p "Want to install NEW_FEATURE: [y/N] " install_k8s

# if [[ "$install_k8s" == "y" || "$install_k8s" == "Y" || "$install_k8s" == "" ]]; then
#     install_package NEW_FEATURE
# else
#     echo "NEW_FEATURE installation skipped ❌"
# fi

########################OPENCODE################################ 
if opencode --version > /dev/null 2>&1; then #TOFIX: il se print pas
    echo "OPENCODE is already installed"
    opencode --version
else
    read -p "Want to install opencode: [y/N] " opencode

    if [[ "$opencode" == "y" || "$opencode" == "Y" || "$opencode" == "" ]]; then
        curl -fsSL https://opencode.ai/install | bash > /dev/null 2>&1
            # Add opencode to PATH
        echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.zshrc
        # source ~/.zshrc
        echo "OPENCODE is correctly installed ✅"
    else
        echo "opencode installation skipped ❌"
    fi
fi


########################NVIM################################
if nvim --version > /dev/null 2>&1; then
    echo "NVIM is already installed"
    nvim --version | head -n 1
else
    read -p "Want to install nvim: [y/N] " nvim

    if [[ "$nvim" == "y" || "$nvim" == "Y" || "$nvim" == "" ]]; then
        echo "It can take some time to install nvim, be patient... ⌛"
        rm -rf neovim
        git clone https://github.com/neovim/neovim.git > /dev/null 2>&1
        cd neovim > /dev/null 2>&1
        make CMAKE_BUILD_TYPE=RelWithDebInfo > /dev/null 2>&1
        sudo make install > /dev/null 2>&1
        echo "NVIM is correctly installed ✅"
        cd ..
        rm -rf neovim
    else
        echo "nvim installation skipped ❌"
    fi
fi



########################TMUX################################
if tmux -V > /dev/null 2>&1; then
    echo "TMUX is already installed"
    tmux -V
else
    read -p "Want to install tmux: [y/N] " tmux

    if [[ "$tmux" == "y" || "$tmux" == "Y" || "$tmux" == "" ]]; then
        rm -rf tmux
        git clone https://github.com/tmux/tmux.git > /dev/null 2>&1
        cd tmux
        install_package autoconf
        install_package libtool
        install_package automake
        install_package pkg-config
        install_package libevent-dev
        install_package yacc #byacc
        install_package ncurses-dev
        sh autogen.sh > /dev/null 2>&1
        ./configure && make > /dev/null 2>&1
        sudo make install > /dev/null 2>&1        
        echo "tmux is correctly installed ✅"
        cd ..
        rm -rf tmux
    else
        echo "tmux installation skipped ❌"
    fi
fi



########################SUPERFILE################################
if superfile --version > /dev/null 2>&1; then
    echo "SUPERFILE is already installed"
    superfile --version
else
    read -p "Want to install superfile: [y/N] " superfile
    
    if [[ "$superfile" == "y" || "$superfile" == "Y" || "$superfile" == "" ]]; then
        rm -rf superfile
        # bash -c "$(curl -sLo- https://superfile.dev/install.sh)" > /dev/null
        git clone https://github.com/yorukot/superfile.git --depth=1 > /dev/null 2>&1
        cd superfile
        ./build.sh > /dev/null 2>&1
            sudo mv ./bin/spf /usr/local/bin/spf
            sudo ln -sf /usr/local/bin/spf /usr/local/bin/superfile
        echo "SUPERFILE is correctly installed ✅"
        cd ..
        rm -rf superfile
    else
        echo "superfile installation skipped ❌"
    fi
fi


########################BRANCHLET################################
if branchlet --version > /dev/null 2>&1; then
    echo "BRANCHLET is already installed"
    branchlet --version
else
    read -p "Want to install branchlet: [y/N] " branchlet

    if [[ "$branchlet" == "y" || "$branchlet" == "Y" || "$branchlet" == "" ]]; then
        sudo npm install -g branchlet > /dev/null
        # Add branchlet to PATH
        # echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
        # source ~/.zshrc
        echo "BRANCHLET is correctly installed ✅"
    else
        echo "branchlet installation skipped ❌"
    fi
fi


########################PKGTOP################################
if pkgtop -v > /dev/null 2>&1; then
    echo "PKGTOP is already installed"
    pkgtop -v
else
    read -p "Want to install PKGTOP: [y/N] (go required)" PKGTOP

    if [[ "$PKGTOP" == "y" || "$PKGTOP" == "Y" || "$PKGTOP" == "" ]]; then
        rm -rf pkgtop
        git clone https://github.com/orhun/pkgtop.git > /dev/null 2>&1 
        cd pkgtop/
        # git clone https://aur.archlinux.org/pkgtop.git > /dev/null && cd pkgtop/ 
        go build cmd/pkgtop.go > /dev/null 2>&1
        sudo mv pkgtop /usr/local/bin/
        echo "PKGTOP is correctly installed ✅"
        cd ..
        rm -rf pkgtop
    else
        echo "PKGTOP installation skipped ❌"
    fi
fi


########################TAPROOM################################
# read -p "Want to install NEW_FEATURE: [y/N] " NEW_FEATURE

# if [[ "$NEW_FEATURE" == "y" || "$NEW_FEATURE" == "Y" || "$NEW_FEATURE" == "" ]]; then
#     install_package NEW_FEATURE
# else
#     echo "NEW_FEATURE installation skipped ❌"
# fi


########################STORMY################################
if stormy --version > /dev/null 2>&1; then
    echo "STORMY is already installed"
    stormy --version
else
    read -p "Want to install STORMY: [y/N] (go required)" STORMY

    if [[ "$STORMY" == "y" || "$STORMY" == "Y" || "$STORMY" == "" ]]; then
        rm -rf stormy
        git clone https://github.com/ashish0kumar/stormy.git > /dev/null 2>&1
        cd stormy

        # Build the application
        go build > /dev/null 2>&1

        # Move to a directory in your PATH
        sudo mv stormy /usr/local/bin/
        echo "STORMY is correctly installed ✅"
        cd ..
        rm -rf stormy
    else
        echo "STORMY installation skipped ❌"
    fi
fi


########################SMASSH################################
if smassh --version > /dev/null 2>&1; then
    echo "SMASSH is already installed"
    smassh --version
else
    read -p "Want to install SMASSH: [y/N] " SMASSH

    if [[ "$SMASSH" == "y" || "$SMASSH" == "Y" || "$SMASSH" == "" ]]; then
        pipx install smassh > /dev/null 2>&1
        echo "SMASSH is correctly installed ✅"
    else
        echo "SMASSH installation skipped ❌"
    fi
fi

########################JRNL################################
if jrnl --version > /dev/null 2>&1; then
    echo "JRNL is already installed"
    jrnl --version
else
    read -p "Want to install JRNL: [y/N] " JRNL

    if [[ "$JRNL" == "y" || "$JRNL" == "Y" || "$JRNL" == "" ]]; then
        pipx install jrnl > /dev/null 2>&1
        echo "JRNL is correctly installed ✅"
    else
        echo "JRNL installation skipped ❌"
    fi
fi


########################NAVI################################
# read -p "Want to install NAVI: [y/N] " NAVI

# if [[ "$NAVI" == "y" || "$NAVI" == "Y" || "$NAVI" == "" ]]; then
#     install_package NAVI
# else
#     echo "NAVI installation skipped ❌"
# fi


########################EDEXUI################################
if ls ~/.local/bin/edex-ui > /dev/null 2>&1; then
    echo "EDEXUI is already installed"
    #./squashfs-root/AppRun --version
else
    read -p "Want to install EDEXUI: [y/N] " EDEXUI

    if [[ "$EDEXUI" == "y" || "$EDEXUI" == "Y" || "$EDEXUI" == "" ]]; then
        # Add universe repository if not present FOR UBUNTU (for debian 13 it's not needed because it's already in the sources.list)
        
        # if ! grep -q "universe" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
            # echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) universe" | sudo tee -a /etc/apt/sources.list.d/universe.list > /dev/null
            # sudo apt update -y > /dev/null
        # fi
        # install_package libfuse2t64
        # install_package rsync
        # install_package build-essential
        # rm -rf edex-ui
        # git clone https://github.com/GitSquared/edex-ui.git && cd edex-ui
        #depend de l' OS (ici pour Debian (>= 13) and Ubuntu (>= 24.04):
        #more info https://github.com/AppImage/AppImageKit/wiki/FUSE
        echo "It can take some time to install EDEXUI, be patient... ⌛"
        # npm install --ignore-scripts > /dev/null
        # npm run build-linux
        # ./eDEX-UI.AppImage --appimage-extract 
        # sudo chown root:root squashfs-root/chrome-sandbox
        # sudo chmod 4755 squashfs-root/chrome-sandbox
        # mv squashfs-root ~/
        # curl -L -o edex-ui.AppImage \
        # https://github.com/GitSquared/edex-ui/releases/download/v2.2.8/eDEX-UI-Linux-x86_64.AppImage > /dev/null 2>&1
        export PLAT=$(uname -m)

        curl -L -o edex-ui.AppImage \
        "https://github.com/GitSquared/edex-ui/releases/download/v2.2.8/eDEX-UI-Linux-${PLAT}.AppImage"
        chmod +x edex-ui.AppImage
        mv edex-ui.AppImage ~/.local/bin/edex-ui
        echo "EDEXUI is correctly installed ✅"
        #./squashfs-root/AppRun
    else
        echo "EDEXUI installation skipped ❌"
    fi
fi


########################KIND################################
if kind version > /dev/null 2>&1; then
    echo "KIND is already installed"
    kind version
else
    read -p "Want to install KIND: [y/N] " KIND

    if [[ "$KIND" == "y" || "$KIND" == "Y" || "$KIND" == "" ]]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 > /dev/null
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
        echo "KIND is correctly installed ✅"
    else
        echo "KIND installation skipped ❌"
    fi
fi

########################KUBECTL################################
if kubectl version --client > /dev/null 2>&1; then
    echo "KUBECTL is already installed"
    kubectl version --client
else
    read -p "Want to install KUBECTL: [y/N] " KUBECTL

    if [[ "$KUBECTL" == "y" || "$KUBECTL" == "Y" || "$KUBECTL" == "" ]]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
        echo "KUBECTL is correctly installed ✅"    
    else
        echo "KUBECTL installation skipped ❌"
    fi
fi



########################NEW_FEATURE################################
# read -p "Want to install NEW_FEATURE: [y/N] " NEW_FEATURE

# if [[ "$NEW_FEATURE" == "y" || "$NEW_FEATURE" == "Y" || "$NEW_FEATURE" == "" ]]; then
#     install_package NEW_FEATURE
# else
#     echo "NEW_FEATURE installation skipped ❌"
# fi

exec zsh #terminate the script, need to be the last command
