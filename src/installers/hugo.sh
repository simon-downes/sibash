function sb.install.hugo {

    local current latest arch

    sb.sudo

    sb.header "Installing Hugo"

    current=$(sb.version.current hugo)
    latest=$(sb.version.latest hugo)

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

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${latest}/hugo_extended_${latest}_linux-${arch}.tar.gz" && \

        sb.spinner.run "Extracting... " "tar -xvzf /tmp/hugo.tar.gz --directory /tmp" && \

        sb.spinner.run "Installing... " "sudo mv /tmp/hugo /usr/local/bin/hugo" && \

        sb.is.command hugo

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}v$(sb.version.current hugo)${SB_RESET} installed"

}
