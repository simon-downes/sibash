
# Install PHP CLI and Composer
function sb.install.php {

    local php_version result

    php_version=${1:-"8.2"}

    # sb.is.command php${php_version} && {
    #     echo
    #     sb.info "PHP ${SB_INFO}v$(php${php_version} --version | head -n 1 | cut -d" " -f2)${SB_RESET} already installed"
    #     return
    # }

    sb.sudo

    sb.header "Installing PHP ${php_version}"

    sb.spinner.run "Adding APT Repository... " "sudo add-apt-repository -yu ppa:ondrej/php" && \

    sb.install.packages php${php_version}-cli
    # sb.install.packages php${php_version}-cli php${php_version}-common php${php_version}-curl php${php_version}-mbstring \
    #     php${php_version}-mysql php${php_version}-odbc php${php_version}-opcache php${php_version}-pgsql \
    #     php${php_version}-readline php${php_version}-sqlite3 php${php_version}-xml

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}v$(php --version | head -n 1 | cut -d" " -f2)${SB_RESET} installed"

    echo
    sb.install.composer

}

# Install latest version of PHP Composer
function sb.install.composer {

    local current latest

    sb.sudo

    sb.header "Installing Composer"

    current=$(sb.version.current composer)
    latest=$(sb.version.latest composer)

    sb.is.not_empty $current && {

        [ "${current}" == "${latest}" ] && {
            sb.info "Already at latest version: ${SB_INFO}${latest}${SB_RESET}"
            return
        }

        sb.spinner.run "Updating... " "composer self-update" && \
        echo && \
        sb.success "${SB_INFO}v$(sb.version.current composer)${SB_RESET} installed"
        return

    }

    sb.spinner.run "Downloading... " "wget -nv -O composer-installer.php https://getcomposer.org/installer" && \

        sb.spinner.run "Verifying... " "echo \"$(curl -fs https://composer.github.io/installer.sig) composer-installer.php\" | sha384sum -c --status -" && \

        sb.spinner.run "Installing... " "php composer-installer.php --quiet && sudo mv composer.phar /usr/local/bin/composer" && \

        sb.is.command composer

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}v$(sb.version.current composer)${SB_RESET} installed"

}
