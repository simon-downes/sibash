
# Install latest version of AWS CLI v2
function sb.install.aws_cli {

    local current latest arch

    sb.sudo

    sb.header "Installing AWS CLI"

    current=$(sb.version.current aws)
    latest=$(sb.version.latest aws)

    sb.is.not_empty $current && {

        [ "${current}" == "${latest}" ] && {
            sb.info "Already at latest version: ${SB_INFO}${latest}${SB_RESET}"
            return
        }

        sb.info "${SB_INFO}v${current}${SB_RESET} installed, ${SB_INFO}v${latest}${SB_RESET} available\n"

        sb.input.proceed Y "Update?" || return

    }

    arch=x86_64
    sb.is.cpu_arm && arch=aarch64

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/aws-cli.zip https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" && \

        sb.spinner.run "Extracting... " "unzip -o /tmp/aws-cli.zip -d /tmp" && \

        sb.spinner.run "Installing... " "sudo /tmp/aws/install --update" && \

        sb.is.command aws

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}v$(sb.version.current aws)${SB_RESET} installed"

}

function sb.install.aws_ssm_plugin {

    local arch

    sb.sudo

    sb.header "Installing AWS Session Manager Plugin"

    # check system architecture, default to x86_64
    arch=64bit
    sb.is.cpu_arm && arch=arm64

    sb.spinner.run "Downloading... " "curl -fs https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${arch}/session-manager-plugin.deb -o /tmp/session-manager-plugin.deb" && \

        sb.spinner.run "Installing... " "sudo dpkg -i /tmp/session-manager-plugin.deb" && \

        sb.is.command session-manager-plugin

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}$(session-manager-plugin --version)${SB_RESET} installed"

}

function sb.install.aws_vault {

    local current latest arch

    sb.sudo

    sb.header "Installing AWS Vault"

    current=$(sb.version.current aws-vault)
    latest=$(sb.version.latest aws-vault)

    sb.is.not_empty $current && {

        [ "${current}" == "${latest}" ] && {
            sb.info "Already at latest version: ${SB_INFO}${latest}${SB_RESET}"
            return
        }

        sb.info "${SB_INFO}v${current}${SB_RESET} installed, ${SB_INFO}v${latest}${SB_RESET} available\n"

        sb.input.proceed Y "Update?" || return

    }

    # check system architecture, default to x86_64
    arch=amd64
    sb.is.cpu_arm && arch=arm64

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/aws-vault https://github.com/99designs/aws-vault/releases/download/v${latest}/aws-vault-linux-${arch}" && \
    # sb.spinner.run "Downloading... " "wget -O /tmp/aws-vault https://github.com/99designs/aws-vault/releases/download/v7.1.2/aws-vault-linux-${arch}" && \

        chmod a+x /tmp/aws-vault >2 $SB_LOG_FILE && \

        sb.spinner.run "Installing... " "sudo cp /tmp/aws-vault /usr/local/bin/aws-vault" && \

        sb.is.command aws-vault

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}$(sb.version.current aws-vault)${SB_RESET} installed"

}
