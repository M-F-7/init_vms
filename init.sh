#!/bin/bash


# -e if an error occur from a command, -u if a variable is undefined, -o pipefail if a pipe fail
# the script stop directly

set -euo pipefail

# link the stderr with a file to get all the erros in a file 
#TODO: exec 2>>errors.log

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
        sudo apt install "$package" -y \
            1>/dev/null \
            2> >(grep -v "apt does not have a stable CLI interface" >&2)


        echo "$package is correctly installed ✅"
}


########################SUDO################################
read -p "Want to add a user to sudoers?: [y/N]" sudo_updt

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

########################KEYBOARD################################
read -p "Want to put the keyboard to AZERTY in the VM settings?: [y/N]" keyboard_vm
if [[ "$keyboard_vm" == "y" || "$keyboard_vm" == "Y" || "$keyboard_vm" == "" ]]; then
        sudo dpkg-reconfigure keyboard-configuration
        sudo service keyboard-setup restart
        exit
fi
        
read -p "Want to put the keyboard to AZERTY in the current OS?: [y/N]" keyboard

if [[ "$keyboard" == "y" || "$keyboard" == "Y" || "$keyboard" == "" ]]; then
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"
    gsettings get org.gnome.desktop.input-sources sources
else
    echo -n "Actual version: "
    gsettings get org.gnome.desktop.input-sources sources
fi


########################CURL################################
if ! check_already_install curl; then
    read -p "Want to install curl: [y/N]" install_curl

    if [[ "$install_curl" == "y" || "$install_curl" == "Y" || "$install_curl" == "" ]]; then
        install_package curl
    else
        echo "Curl installation skipped ❌"
    fi
fi


########################TREE################################
if ! check_already_install tree; then
    read -p "Want to install tree: [y/N]" install_tree

    if [[ "$install_tree" == "y" || "$install_tree" == "Y" || "$install_tree" == "" ]]; then
        install_package tree
    else
        echo "Tree installation skipped ❌"
    fi
fi



########################GIT################################
if ! check_already_install git; then

    read -p "Want to install git: [y/N]" install_git

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
# if ! check_already_install ssh; then

  read -p "Want to add an ssh key: [y/N]" ssh_key

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
# fi 


########################DOCKER################################
if ! check_already_install docker.io; then
    read -p "Want to install docker: [y/N]" install_docker

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


########################K8s################################
#dpkg -s kubectl


########################ZSH################################
if ! check_already_install zsh; then

    read -p "Want to install zsh: [y/N]" install_zsh

    if [[ "$install_zsh" == "y" || "$install_zsh" == "Y" || "$install_zsh" == "" ]]; then
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            install_package zsh
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null
        fi

        #TODO
        if [ "$SHELL" != "$(which zsh)" ]; then
            chsh -s "$(which zsh)"
        fi
        cat alias.txt >> ~/.zshrc

    else
        echo "Zsh installation skipped ❌"
    fi
fi


########################CODE################################
if ! check_already_install code; then
    if ! check_already_install wget; then
        install_package wget
    fi
    if ! check_already_install gpg; then
        install_package gpg
    fi

    read -p "Want to install code: [y/N]" install_code

    if [[ "$install_code" == "y" || "$install_code" == "Y" || "$install_code" == "" ]]; then
        # Import de la clé Microsoft
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/ms_vscode.gpg > /dev/null
        # Ajout du dépôt officiel
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms_vscode.gpg] https://packages.microsoft.com/repos/code stable main" \
          | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt update
        install_package code
        code --version
    else
        echo "Code installation skipped ❌"
    fi
fi

########################NEW_FEATURE################################
# read -p "Want to install NEW_FEATURE: [y/N]" NEW_FEATURE

# if [[ "$NEW_FEATURE" == "y" || "$NEW_FEATURE" == "Y" || "$NEW_FEATURE" == "" ]]; then
#     install_package NEW_FEATURE
# else
#     echo "NEW_FEATURE installation skipped ❌"
# fi
