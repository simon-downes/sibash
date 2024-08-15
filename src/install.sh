
# TODO: Install Dart Sass
# TODO: Install AWS CLI Session Manager Plugin:
#       https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
# TODO: Install Poetry (Python)

# Install APT packages with a spinner
# $1:  message to show before the spinner
# $2:n packages to install
function sb::install {

    local what packages

    what="$1"
    packages=${@:2}

    if [ -z "$what" ]; then
        echo "Nothing specified to install!"
        echo "Available options:"
        echo " - everything"
        echo " - common - handy stuff"
        echo " - php - 8.1"
        echo " - composer - latest version of php package manager"
        echo " - aws_cli"
        echo " - aws_vault"
        echo " - terraform - latest version"
        echo " - docker"
        echo " - hugo"
        echo " - caddy - lateste version of caddy webserver"
        echo " - sass - dart sass binary"
        return
    fi

    sb::spin "Installing ${what}..." "sudo apt-get install -y ${packages}"

}

function sb::install_everything {

    sb::install_common && echo "" \
        && sb::install_php && echo "" \
        && sb::install_aws_cli && echo "" \
        && sb::install_terraform && echo "" \
        && sb::install_docker

}

function sb.install.packages {

    local packages package

    packages=$@

    sb.sudo

    printf "\n${SB_INFO}Installing Packages:${SB_RESET}\n\n"

    sb.list $packages

    echo

    sb.input.proceed && {

        sb.spinner.run "Installing... " "sudo apt-get install -qy --dry-run ${packages}"

        if [ $? -ne 0 ]; then
            echo $(tail -n 1 $SB_LOG_FILE)
        fi

    }

}


# Install core things that should probably be everywhere already anyway
function sb.install.core {

    sb.install.packages apt-transport-https ca-certificates software-properties-common python-is-python3 python3-pip python3-venv curl wget jq zip

}

# Install PHP CLI and Composer
function sb.install.php {

    local php_version

    php_version=${1:-"8.2"}

    sb.sudo

    sb.header "Installing PHP ${php_version}"

    sb.spinner.run "Adding APT Repository... " "sudo add-apt-repository -yu ppa:ondrej/php"

    sb.install.packages php${php_version}-cli

    # sb.install.packages php${php_version}-cli php${php_version}-common php${php_version}-curl php${php_version}-mbstring \
    #     php${php_version}-mysql php${php_version}-odbc php${php_version}-opcache php${php_version}-pgsql \
    #     php${php_version}-readline php${php_version}-sqlite3 php${php_version}-xml




    # if [ $? -eq 0 ]; then
    #     sb::success "v$(php --version | head -n 1 | cut -d" " -f2) installed"
    # else
    #     sb::fail
    # fi

    # echo ""
    # sb::install_composer

}

# Install latest version of PHP Composer
function sb.install.composer {

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
        sb::fail
    fi

    echo ""
    sb::install_aws_vault

}

function sb::install_aws_vault {


    local current latest desired arch

    sb::header "Installing AWS Vault:"

    sb::spinner start "Version Check..."

    # find latest version
    latest=$(curl -fs https://api.github.com/repos/99designs/aws-vault/releases/latest | jq --raw-output '.tag_name' | cut -c 2-)

    # check if we already have aws vault installed - for some fucking reason it outputs the version number to stderr and not stdout...
    current=$(aws-vault --version 2>&1)

    # if the command failed then it's not installed so current should be blank
    if [[ $? -ne 0 ]]; then
        current=""
    else
        # skip the 'v' at the start of the output
        current=${current:1}
    fi

    sb::spinner stop 0 "${current:+"Current ${current} / "}${latest:+"Latest v${latest}"}"

    if [ "${current}" == "${latest}" ]; then
        sb::success "Latest version already installed"
        return
    fi

    # check system architecture, default to x86_64
    arch=amd64
    if [ $(uname -m) = "aarch64" ]; then
        arch=arm64
    fi

    sb::spin "Downloading..." "wget -O /tmp/aws-vault https://github.com/99designs/aws-vault/releases/download/v${latest}/aws-vault-linux-${arch}"

    chmod a+x /tmp/aws-vault >2 $SB_LOG_FILE

    sb::spin "Installing..." "sudo cp /tmp/aws-vault /usr/local/bin/aws-vault"

    current=$(aws-vault --version 2>&1)

    if [[ $? -eq 0 ]]; then
        sb::success "${current} installed"
    else
        sb::fail
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
        sb::fail
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

    sb::install "Packages" docker-ce docker-ce-cli containerd.io docker-compose-plugin

    sb::spin "Adding User to Docker Group" "sudo usermod -aG docker ${USER}"

    current=$(docker --version | cut -d, -f1 | cut -d" " -f3)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::fail
    fi

}

# Install latest version of Hugo
function sb::install_hugo {

    local current latest desired arch

    sb::header "Installing Hugo:"

    sb::spinner start "Version Check..."

    # find latest hugo version
    latest=$(curl -fs https://api.github.com/repos/gohugoio/hugo/releases/latest | jq --raw-output '.tag_name' | cut -c 2-)

    # check if we already have hugo installed
    current=$(hugo version 2> /dev/null | cut -d"-" -f1 | cut -d"v" -f2)

    sb::spinner stop 0 "${current:+"Current v${current} / "}${latest:+"Latest v${latest}"}"

    if [ "${current}" == "${latest}" ]; then
        sb::success "Latest version already installed"
        return
    fi

    # check system architecture, default to x86_64
    arch=amd64
    if [ $(uname -m) = "aarch64" ]; then
        sb::fail "ARM binary must be compiled/installed manually"
        return 1
    fi

    sb::spin "Downloading..." "wget -O /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${latest}/hugo_extended_${latest}_Linux-64bit.tar.gz"

    sb::spin "Extracting..." "tar -xvzf /tmp/hugo.tar.gz --directory /tmp"

    sb::spin "Installing..." "sudo mv /tmp/hugo /usr/local/bin/hugo"

    # clean up
    rm -f /tmp/hugo.tar.gz

    current=$(hugo version 2> /dev/null | cut -d"-" -f1 | cut -d"v" -f2)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::fail
    fi

}

# Install latest version of Caddy webserver
function sb::install_caddy {

    local current latest desired arch

    sb::header "Installing Caddy:"

    sb::spinner start "Version Check..."

    # find latest hugo version
    latest=$(curl -fs https://api.github.com/repos/caddyserver/caddy/releases/latest | jq --raw-output '.tag_name' | cut -c 2-)

    # check if we already have hugo installed
    current=$(caddy version 2> /dev/null | cut -d" " -f1 | cut -d"v" -f2)

    sb::spinner stop 0 "${current:+"Current v${current} / "}${latest:+"Latest v${latest}"}"

    if [ "${current}" == "${latest}" ]; then
        sb::success "Latest version already installed"
        return
    fi

    # check system architecture, default to x86_64
    arch=amd64
    if [ $(uname -m) = "aarch64" ]; then
        arch=armv7
    fi

    sb::spin "Downloading..." "wget -O /tmp/caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v${latest}/caddy_${latest}_linux_${arch}.tar.gz"

    sb::spin "Extracting..." "tar -xvzf /tmp/caddy.tar.gz --directory /tmp"

    sb::spin "Installing..." "sudo mv /tmp/caddy /usr/local/bin/caddy"

    # clean up
    rm -f /tmp/caddy.tar.gz

    current=$(caddy version 2> /dev/null | cut -d" " -f1 | cut -d"v" -f2)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::fail
    fi

}

# Install latest version of Hugo
function sb::install_sass {

    local current latest desired arch

    sb::header "Installing Dart Sass:"

    sb::spinner start "Version Check..."

    # find latest hugo version
    latest=$(curl -fs https://api.github.com/repos/sass/dart-sass/releases/latest | jq --raw-output '.tag_name')

    # check if we already have hugo installed
    current=$(sass --version 2> /dev/null)

    sb::spinner stop 0 "${current:+"Current v${current} / "}${latest:+"Latest v${latest}"}"

    if [ "${current}" == "${latest}" ]; then
        sb::success "Latest version already installed"
        return
    fi

    # check system architecture, default to x86_64
    arch=x64
    if [ $(uname -m) = "aarch64" ]; then
        sb::fail "ARM binary must be compiled/installed manually"
        return 1
    fi

    sb::spin "Downloading..." "wget -O /tmp/sass.tar.gz https://github.com/sass/dart-sass/releases/download/${latest}/dart-sass-${latest}-linux-x64.tar.gz"

    sb::spin "Extracting..." "tar -xvzf /tmp/sass.tar.gz --directory /tmp"

    sb::spin "Installing..." "sudo mv /tmp/dart-sass/sass /usr/local/bin/sass"

    # clean up
    rm -f /tmp/sass.tar.gz
    rm -rf /tmp/dart-sass

    current=$(sass --version 2> /dev/null)

    if [ ! -z "${current}" ]; then
        sb::success "v${current} installed"
    else
        sb::fail
    fi

}
