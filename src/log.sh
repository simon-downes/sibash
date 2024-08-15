
function _sb.log.time() {
    printf "%s " "$(date +'%Y-%m-%d %H:%M:%S') ${BASHPID}"
}

function sb.log.error {
    _sb.log.time && sb.error "$@"
}

function sb.log.warn {
    _sb.log.time && sb.warn "$@"
}

function sb.log.info {
    _sb.log.time && sb.info "$@"
}

function sb.log.debug {
    _sb.log.time && sb.debug "$@"
}

function sb.log.success {
    _sb.log.time && sb.success "$@"
}

function sb.log.fail {
    _sb.log.time && sb.fail "$@"
}

