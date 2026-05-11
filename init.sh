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

########################NPM################################
if ! check_already_install npm; then
    read -p "Want to install npm: [y/N] " npm

    if [[ "$npm" == "y" || "$npm" == "Y" || "$npm" == "" ]]; then
        echo "It can take some time to install nodejs and npm, be patient... ⌛" #TOFIX il se print pas
        install_package nodejs
        install_package npm
    else
        echo "npm installation skipped ❌"
    fi
fi


########################CARGO################################
read -p "Want to install CARGO: [y/N] " CARGO

if [[ "$CARGO" == "y" || "$CARGO" == "Y" || "$CARGO" == "" ]]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y > /dev/null #TOFIX il se cach pas
    source "$HOME/.cargo/env"
else
    echo "CARGO installation skipped ❌"
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
if ! check_already_install pip; then
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
        sudo apt update
        install_package code
        code --version | head -n 1
    else
        echo "Code installation skipped ❌"
    fi
fi


########################ZSH################################
if ! check_already_install zsh; then

    read -p "⌛ Want to install zsh: [y/N] (need git and curl installed) " install_zsh

    if [[ "$install_zsh" == "y" || "$install_zsh" == "Y" || "$install_zsh" == "" ]]; then
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            install_package zsh
            # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null
            RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null
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

########################MAKE################################
read -p "Want to install MAKE: [y/N] " install_make

if [[ "$install_make" == "y" || "$install_make" == "Y" || "$install_make" == "" ]]; then
    install_package make
else
    echo "MAKE installation skipped ❌"
fi

########################CMAKE################################
read -p "Want to install CMAKE: [y/N] " install_cmake

if [[ "$install_cmake" == "y" || "$install_cmake" == "Y" || "$install_cmake" == "" ]]; then
    install_package cmake
else
    echo "CMAKE installation skipped ❌"
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
read -p "Want to install opencode: [y/N] " opencode

if [[ "$opencode" == "y" || "$opencode" == "Y" || "$opencode" == "" ]]; then
    curl -fsSL https://opencode.ai/install | bash
else
    echo "opencode installation skipped ❌"
fi
 

########################NVIM################################
read -p "Want to install nvim: [y/N] " nvim

if [[ "$nvim" == "y" || "$nvim" == "Y" || "$nvim" == "" ]]; then
    rm -rf neovim
    git clone https://github.com/neovim/neovim.git && cd neovim
    make CMAKE_BUILD_TYPE=RelWithDebInfo    
    sudo make install
else
    echo "nvim installation skipped ❌"
fi



########################TMUX################################
read -p "Want to install tmux: [y/N] " tmux

if [[ "$tmux" == "y" || "$tmux" == "Y" || "$tmux" == "" ]]; then
    rm -rf tmux
    git clone https://github.com/tmux/tmux.git
    cd tmux
    ./configure
    make
    sudo make install
else
    echo "tmux installation skipped ❌"
fi



########################SUPERFILE################################
read -p "Want to install superfile: [y/N] " superfile

if [[ "$superfile" == "y" || "$superfile" == "Y" || "$superfile" == "" ]]; then
    bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
else
    echo "superfile installation skipped ❌"
fi



########################BRANCHLET################################
read -p "Want to install branchlet: [y/N] " branchlet

if [[ "$branchlet" == "y" || "$branchlet" == "Y" || "$branchlet" == "" ]]; then
    npm install -g branchlet
else
    echo "branchlet installation skipped ❌"
fi



########################PKGTOP################################
read -p "Want to install PKGTOP: [y/N] " PKGTOP

if [[ "$PKGTOP" == "y" || "$PKGTOP" == "Y" || "$PKGTOP" == "" ]]; then
    git clone https://aur.archlinux.org/pkgtop.git && cd pkgtop/
    go build cmd/pkgtop.go
    sudo mv pkgtop /usr/local/bin/
else
    echo "PKGTOP installation skipped ❌"
fi



########################TAPROOM################################
# read -p "Want to install NEW_FEATURE: [y/N] " NEW_FEATURE

# if [[ "$NEW_FEATURE" == "y" || "$NEW_FEATURE" == "Y" || "$NEW_FEATURE" == "" ]]; then
#     install_package NEW_FEATURE
# else
#     echo "NEW_FEATURE installation skipped ❌"
# fi


########################STORMY################################
read -p "Want to install STORMY: [y/N] " STORMY

if [[ "$STORMY" == "y" || "$STORMY" == "Y" || "$STORMY" == "" ]]; then
    rm -rf stormy
    git clone https://github.com/ashish0kumar/stormy.git
    cd stormy

    # Build the application
    go build

    # Move to a directory in your PATH
    sudo mv stormy /usr/local/bin/
else
    echo "STORMY installation skipped ❌"
fi


########################SMASSH################################
read -p "Want to install SMASSH: [y/N] " SMASSH

if [[ "$SMASSH" == "y" || "$SMASSH" == "Y" || "$SMASSH" == "" ]]; then
    pip install smassh
else
    echo "SMASSH installation skipped ❌"
fi


########################JRNL################################
read -p "Want to install JRNL: [y/N] " JRNL

if [[ "$JRNL" == "y" || "$JRNL" == "Y" || "$JRNL" == "" ]]; then
    pipx install jrnl
else
    echo "JRNL installation skipped ❌"
fi



########################NAVI################################
# read -p "Want to install NAVI: [y/N] " NAVI

# if [[ "$NAVI" == "y" || "$NAVI" == "Y" || "$NAVI" == "" ]]; then
#     install_package NAVI
# else
#     echo "NAVI installation skipped ❌"
# fi


########################EDEXUI################################
read -p "Want to install EDEXUI: [y/N] " EDEXUI

if [[ "$EDEXUI" == "y" || "$EDEXUI" == "Y" || "$EDEXUI" == "" ]]; then
    sudo add-apt-repository universe                  
    sudo apt install libfuse2t64
    rm -rf edex-ui
    git clone https://github.com/GitSquared/edex-ui.git && cd edex-ui
    #depend de l' OS (ici pour Debian (>= 13) and Ubuntu (>= 24.04):
    #more info https://github.com/AppImage/AppImageKit/wiki/FUSE
    npm run build-linux
    # ./eDEX-UI.AppImage --appimage-extract 
    sudo chown root:root squashfs-root/chrome-sandbox
    sudo chmod 4755 squashfs-root/chrome-sandbox
    mv squashfs-root ~/
    #./squashfs-root/AppRun
else
    echo "EDEXUI installation skipped ❌"
fi



########################KIND################################
read -p "Want to install KIND: [y/N] " KIND

if [[ "$KIND" == "y" || "$KIND" == "Y" || "$KIND" == "" ]]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
else
    echo "KIND installation skipped ❌"
fi


########################KUBECTL################################
read -p "Want to install KUBECTL: [y/N] " KUBECTL

if [[ "$KUBECTL" == "y" || "$tree --version
npm -v
cargo -V
go version
pip --version
pipx --version
git --version
ssh -V
docker --version
code --version | head -n 1
zsh --version
make --version
opencode --version
nvim --version | head -n 1
tmux -V
# taproom --version
superfile --version
branchlet --version
pkgtop -v
stormy --version
smassh --version
jrnl --version
# navi --version
ls ~/squashfs-root/edex-ui || echo "EDEXUI version not found"
kubectl version --client
kind versionKUBECTL" == "Y" || "$KUBECTL" == "" ]]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/    
else
    echo "KUBECTL installation skipped ❌"
fi

########################NEW_FEATURE################################
# read -p "Want to install NEW_FEATURE: [y/N] " NEW_FEATURE

# if [[ "$NEW_FEATURE" == "y" || "$NEW_FEATURE" == "Y" || "$NEW_FEATURE" == "" ]]; then
#     install_package NEW_FEATURE
# else
#     echo "NEW_FEATURE installation skipped ❌"
# fi




########################ASSERT################################
curl -V
tree --version
npm -v
cargo -V
go version
pip --version
pipx --version
git --version
ssh -V
docker --version
code --version | head -n 1
zsh --version
make --version
opencode --version
nvim --version | head -n 1
tmux -V
# taproom --version
superfile --version
branchlet --version
pkgtop -v
stormy --version
smassh --version
jrnl --version
# navi --version
ls ~/squashfs-root/edex-ui || echo "EDEXUI version not found"
kubectl version --client
kind version