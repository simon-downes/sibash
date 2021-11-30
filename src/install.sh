#!/bin/bash
#
# This file is part of the simon-downes/sibash package which is distributed under the MIT License.
# See LICENSE.md or go to https://github.com/simon-downes/sibash for full license details.
#
# Defines common/core functions used throughout the framework
#
# /HEADER

# Install APT packages with a spinner
# $1:  message to show before the spinner
# $2:n packages to install
function sb::install {

    local what packages

    what="$1"
    packages=${@:2}

    sb::spin "Installing ${what}..." "sudo apt-get install -y ${packages}"

}

# Install PHP 8.0 CLI and Composer
function sb::install_php {

    sb::header "Installing PHP 8:"

    sb::spin "Adding APT Repository..." "sudo add-apt-repository -yu ppa:ondrej/php"

    sb::install "Packages" php8.0-cli php8.0-common php8.0-curl php8.0-mbstring php8.0-mysql \
            php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-readline php8.0-sqlite3 php8.0-xml

    if [ $? -eq 0 ]; then
        sb::success "v$(php --version | head -n 1 | cut -d" " -f2) installed"
    else
        sb::fail
    fi

    echo ""
    sb::install_composer

}

# Install latest version of PHP Composer
function sb::install_composer {

    local current checksum

    sb::header "Installing Composer:"

    sb::spinner start "Version Check..."

    current=$(composer --version 2> /dev/null | cut -d" " -f3)

    if [ ! -z "${current}" ]; then
        current="Found v${current}"
    fi

    sb::spinner stop 0 "$current"

    sb::spin "Downloading..." "wget -O composer-installer.php https://getcomposer.org/installer"

    sb::spinner start "Verifying..."
    checksum=$(curl -fs https://composer.github.io/installer.sig)
    echo "${checksum} composer-installer.php" | sha384sum -c --status - >> $SB_LOG_FILE 2>&1
    sb::spinner stop $?

    sb::spinner start "Installing..."
    php composer-installer.php --quiet \
        && sudo mv composer.phar /usr/local/bin/composer
    sb::spinner stop $?

    # clean up
    rm -f composer-installer.php

    current=$(composer --version 2> /dev/null | cut -d" " -f3)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::fail
    fi

}

# Install latest version of AWS CLI v2
function sb::install_aws_cli {

    local current

    sb::header "Installing AWS CLI v2:"

    sb::spinner start "Version Check..."

    current=$(aws --version 2> /dev/null | cut -d" " -f1 | cut -d"/" -f2)

    if [ ! -z "${current}" ]; then
        current="Found v${current}"
    fi

    sb::spinner stop 0 "$current"

    sb::spin "Downloading..." "wget -O /tmp/aws-cli.zip https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip"

    sb::spin "Extracting..." "unzip -o /tmp/aws-cli.zip -d /tmp"

    sb::spin "Installing..." "sudo /tmp/aws/install --update"

    # clean up
    rm -f /tmp/aws-cli.zip > /dev/null 2>&1
    rm -rf /tmp/aws > /dev/null 2>&1

    current=$(aws --version 2> /dev/null | cut -d" " -f1 | cut -d"/" -f2)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::failed
    fi

}

# Install latest version of Terraform
function sb::install_terraform {

    local current latest desired arch

    sb::header "Installing Terraform:"

    sb::spinner start "Version Check..."

    # find latest terraform version
    latest=$(curl -fs https://api.github.com/repos/hashicorp/terraform/releases/latest | jq --raw-output '.tag_name' | cut -c 2-)

    # check if we already have terraform installed
    current=$(terraform version 2> /dev/null | head -n 1 | cut -d'v' -f2)

    sb::spinner stop 0 "${current:+"Current v${current} / "}${latest:+"Latest v${latest}"}"

    if [ "${current}" == "${latest}" ]; then
        sb::success "Latest version already installed"
        return
    fi

    # check system architecture, default to x86_64
    arch=amd64
    if [ $(uname -m) = "aarch64" ]; then
        arch=arm64
    fi

    sb::spin "Downloading..." "wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${latest}/terraform_${latest}_linux_${arch}.zip"

    sb::spin "Extracting..." "unzip -o /tmp/terraform.zip -d /tmp"

    sb::spin "Installing..." "sudo mv /tmp/terraform /usr/local/bin/terraform"

    # clean up
    rm -f /tmp/terraform.zip

    current=$(terraform version 2> /dev/null | head -n 1 | cut -d'v' -f2)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::failed
    fi

}

# Install Docker Enginer
function sb::install_docker {

    sb::header "Installing Docker Engine:"

    sb::spinner start "Adding APT Repository..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg \
        && echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sb::spinner stop $?

    sb::apt_update

    sb::install "Packages" docker-ce docker-ce-cli containerd.io

    sb::spin "Adding User to Docker Group" "sudo usermod -aG docker ${USER}"

}
