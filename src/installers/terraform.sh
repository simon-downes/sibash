
# Install latest version of Terraform
function sb.install.terraform {

    local current latest arch target

    sb.sudo

    sb.header "Installing Terraform"

    current=$(sb.version.current terraform)
    latest=$(sb.version.latest terraform)

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

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${latest}/terraform_${latest}_linux_${arch}.zip" && \
    # sb.spinner.run "Downloading... " "wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.5.6/terraform_1.5.6_linux_${arch}.zip" && \

        sb.spinner.run "Extracting... " "unzip -o /tmp/terraform.zip -d /tmp" && \

        sb.spinner.run "Installing... " "sudo mv /tmp/terraform /usr/local/bin/terraform" && \

        sb.is.command terraform

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}$(sb.version.current terraform)${SB_RESET} installed"

}

# Install legacy version of Terraform - pre-license change 1.5.7
function sb.install.terraform-legacy {

    local current latest arch target

    sb.sudo

    sb.header "Installing Legacy Terraform"

    sb.is.command terraform-1.5.7 && {
        sb.info "${SB_INFO}v1.5.7${SB_RESET} already installed"
        return
    }

    # check system architecture, default to x86_64
    arch=amd64
    sb.is.cpu_arm && arch=arm64

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_${arch}.zip" && \

        sb.spinner.run "Extracting... " "unzip -o /tmp/terraform.zip -d /tmp" && \

        sb.spinner.run "Installing... " "sudo mv /tmp/terraform /usr/local/bin/terraform-1.5.7" && \

        sb.is.command terraform-1.5.7

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}terraform-1.5.7${SB_RESET} installed"

}
