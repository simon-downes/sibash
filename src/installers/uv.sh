
# Install latest version of uv python package manager
function sb.install.uv {

    local current latest arch

    sb.sudo

    sb.header "Installing uv"

    current=$(sb.version.current uv)
    latest=$(sb.version.latest uv)

    sb.is.not_empty $current && {

        [ "${current}" == "${latest}" ] && {
            sb.info "Already at latest version: ${SB_INFO}${latest}${SB_RESET}"
            return
        }

        sb.info "${SB_INFO}v${current}${SB_RESET} installed, ${SB_INFO}v${latest}${SB_RESET} available\n"

        sb.input.proceed Y "Update?" || return

    }

    # check system architecture, default to x86_64
    arch=x86_64
    sb.is.cpu_arm && arch=aarch64

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/uv.tar.gz https://github.com/astral-sh/uv/releases/download/${latest}/uv-${arch}-unknown-linux-gnu.tar.gz" && \

        sb.spinner.run "Extracting... " "tar -xvzf /tmp/uv.tar.gz --directory /tmp" && \

        sb.spinner.run "Installing... " "sudo mv /tmp/uv-${arch}-unknown-linux-gnu/uv* /usr/local/bin/" && \

        sb.is.command uv

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}$(sb.version.current uv)${SB_RESET} installed"

}
