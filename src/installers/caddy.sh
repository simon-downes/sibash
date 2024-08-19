
# Install latest version of Caddy webserver
function sb.install.caddy {

    local current latest arch

    sb.sudo

    sb.header "Installing Caddy"

    current=$(sb.version.current caddy)
    latest=$(sb.version.latest caddy)

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

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v${latest}/caddy_${latest}_linux_${arch}.tar.gz" && \

        sb.spinner.run "Extracting... " "tar -xvzf /tmp/caddy.tar.gz --directory /tmp" && \

        sb.spinner.run "Installing... " "sudo mv /tmp/caddy /usr/local/bin/caddy" && \

        sb.is.command caddy

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}$(sb.version.current caddy)${SB_RESET} installed"

}
