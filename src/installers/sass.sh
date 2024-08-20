
function sb.install.sass {

    local current latest arch

    local current latest arch

    sb.sudo

    sb.header "Installing Dart Sass"

    current=$(sb.version.current sass)
    latest=$(sb.version.latest sass)

    sb.is.not_empty $current && {

        [ "${current}" == "${latest}" ] && {
            sb.info "Already at latest version: ${SB_INFO}${latest}${SB_RESET}"
            return
        }

        sb.info "${SB_INFO}v${current}${SB_RESET} installed, ${SB_INFO}v${latest}${SB_RESET} available\n"

        sb.input.proceed Y "Update?" || return

    }

    # check system architecture, default to x86_64
    arch=x64
    sb.is.cpu_arm && arch=arm64

    sb.spinner.run "Downloading... " "wget -nv -O /tmp/sass.tar.gz https://github.com/sass/dart-sass/releases/download/${latest}/dart-sass-${latest}-linux-${arch}.tar.gz" && \

        sb.spinner.run "Extracting... " "tar -xvzf /tmp/sass.tar.gz --directory /tmp" && \

        sb.spinner.run "Installing... " "sudo mv /tmp/dart-sass/sass /usr/local/bin/sass && sudo mkdir -p /usr/local/bin/src && sudo mv /tmp/dart-sass/src/* /usr/local/bin/src/" && \

        sb.is.command sass

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}v$(sb.version.current sass)${SB_RESET} installed"

}
