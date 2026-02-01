#!/bin/bash


# -e if an error occur from a command, -u if a variable is undefined, -o pipefail if a pipe fail
# the script stop directly

set -euo pipefail

# link the stderr with a file to get all the erros in a file 
#TODO: exec 2>>errors.log

sudo apt update -y

#dpkg: -s get the info of the package, if none the package is uninstall
#command -v [COMMAND_NAME]: to get the path of the command name
install_package()
{
    local package="$1"
    if dpkg -s "$package" > /dev/null 2>&1; then
        echo "$package is already installed"
        dpkg -s "$package" | grep "Version"
    else
        # sudo apt update -y
        sudo apt install "$package" -y
        echo "$package is correctly installed ✅"
    fi
}



########################CURL################################
read -p "Want to install curl: [y/N]" install_curl

if [[ "$install_curl" == "y" || "$install_curl" == "Y" || "$install_curl" == "" ]]; then
    install_package curl
else
    echo "Curl installation skipped ❌"
fi


########################TREE################################
read -p "Want to install tree: [y/N]" install_tree

if [[ "$install_tree" == "y" || "$install_tree" == "Y" || "$install_tree" == "" ]]; then
    install_package tree
else
    echo "Tree installation skipped ❌"
fi



########################GIT################################
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

########################SSH################################
# read -p "Want to install code: [y/N]" install_code

# if [[ "$install_code" == "y" || "$install_code" == "Y" || "$install_code" == "" ]]; then
#     install_package code
# else
#     echo "Code installation skipped ❌"
# fi



########################DOCKER################################
read -p "Want to install docker: [y/N]" install_docker

if [[ "$install_docker" == "y" || "$install_docker" == "Y" || "$install_docker" == "" ]]; then

    install_package docker.io

    if docker info | grep "Username" 2>/dev/null; then

        docker_username=$(docker info 2>/dev/null | awk -F': ' '/Username/ {print $2}') # get only the username variable
        echo "Already connected as $docker_username"
    else
        #read: get an input, -ps (p for prompt, s for silence)
        read -p "Docker username: " docker_username
        read -p "Docker password: " -s docker_password

        #docker login [OPTIONS] [SERVER] 
        # docker login -u "$docker_username" -p "$docker_password" ## server default is dockerhub
        echo "$docker_password" | docker login -u "$docker_username" --password-stdin
    fi
else
    echo "Docker installation skipped ❌"
fi


########################K8s################################
#dpkg -s kubectl


########################ZSH################################
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



########################CODE################################
# read -p "Want to install code: [y/N]" install_code

# if [[ "$install_code" == "y" || "$install_code" == "Y" || "$install_code" == "" ]]; then
#     install_package code
# else
#     echo "Code installation skipped ❌"
# fi
