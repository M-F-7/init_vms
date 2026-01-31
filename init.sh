#!/bin/bash
#❌✅⏳


# -e if an error occur from a command, -u if a variable is undefined, -o pipefail if a pipe fail
# the script stop directly

set -euo pipefail

# link the stderr with a file to get all the erros in a file 
exec 2>>erros.log


#dpkg: -s get the info of the package, if none the package is uninstall
#command -v [COMMAND_NAME]: to get the path of the command name
install_package()
{
    local package = $"1"
    if dpkg -s "$package" > /dev/null 2>&1; then
        echo "$package is already installed"
        dpkg -s "$package" | grep "Version"
    else
        sudo apt update -y
        sudo apt install "$package" -y
        echo "$package is correctly installed ✅"
    fi
}



########################GIT################################
read -p "Want to install git: [y/N]" install_git

if [[ "$install_git" == "y" || "$install_git" == "Y" || "$install_git" == "" ]]; then
    install_package git > /dev/null

    #read: get an input, -ps (p for prompt, s for silence)
    read -p "Git username: " git_username
    read -ps "Git password: " git_password

    git config --global user.name "$git_username"
    git config --global user.email "$git_password"

else
    echo "Git installation skipped ❌"
fi


########################DOCKER################################
read -p "Want to install docker: [y/N]" install_docker

if [[ "$install_docker" == "y" || "$install_docker" == "Y" || "$install_docker" == "" ]]; then

    install_package docker > /dev/null

    if docker info | grep "Username" 2>/dev/null; then

        docker_username=$(docker info 2>/dev/null | awk -F': ' '/Username/ {print $2}') # get only the username variable
        echo "Already connected as $docker_username"
    else
        #read: get an input, -ps (p for prompt, s for silence)
        read -p "Docker username: " docker_username
        read -ps "Docker password: " docker_password

        #docker login [OPTIONS] [SERVER] 
        docker login -u "$docker_username" -p "$docker_password" ## server default is dockerhub
    fi
else
    echo "Docker installation skipped ❌"
fi


########################K8s################################
#dpkg -s kubectl


########################ZSH################################
read -p "Want to install git: [y/N]" install_zsh

if [[ "$install_zsh" == "y" || "$install_zsh" == "Y" || "$install_zsh" == "" ]]; then
    install_package zsh > /dev/null
    #config
    < alias.txt >> ~/.zshrc

else
    echo "Zsh installation skipped ❌"
fi



########################CURL################################
read -p "Want to install curl: [y/N]" install_curl

if [[ "$install_curl" == "y" || "$install_curl" == "Y" || "$install_curl" == "" ]]; then
    install_package curl > /dev/null
else
    echo "Curl installation skipped ❌"
fi


########################TREE################################
read -p "Want to install tree: [y/N]" install_tree

if [[ "$install_tree" == "y" || "$install_tree" == "Y" || "$install_tree" == "" ]]; then
    install_package tree > /dev/null
else
    echo "Tree installation skipped ❌"
fi



########################CODE################################
read -p "Want to install code: [y/N]" install_code

if [[ "$install_code" == "y" || "$install_code" == "Y" || "$install_code" == "" ]]; then
    install_package code > /dev/null
else
    echo "Code installation skipped ❌"
fi
