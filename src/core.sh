# ------------------------------------------------------------------------------
# Core Functionality
# ------------------------------------------------------------------------------

# default log file
export SB_LOG_FILE=${SB_LOG_FILE:-~/sb.log}

# grab cpu architecture
export SB_CPU_ARCH=$(uname -m)

# Restart the sudo timer or prompt for sudo password
function sb.sudo {

    # ensure we can sudo without being prompted
    # the first sudo will fail if a password is required and will restart the sudo timer otherwise
    # the second will prompt for a password and start the sudo timer
    sudo -nv 2> /dev/null || sudo true

}

function sb.lower {

    sb.is.empty "$1" && {
        tr '[:upper:]' '[:lower:]'
    }

    tr '[:upper:]' '[:lower:]' <<<"$1"

}

function sb.log {
    cat $SB_LOG_FILE | less -FiRswXx4
}

function sb.error {
    printf "[ ${SB_ERROR}ERROR${SB_RESET} ] %b${SB_RESET}\n" "$*"
}

function sb.warn {
    printf "[ ${SB_WARN}WARNING${SB_RESET} ] %b${SB_RESET}\n" "$*"
}

function sb.info {
    printf "[ ${SB_INFO}INFO${SB_RESET} ] %b${SB_RESET}\n" "$*"
}

function sb.debug {
    printf "[ ${SB_DEBUG}DEBUG${SB_RESET} ] %b${SB_RESET}\n" "$*"
}

function sb.success {
    printf "[ ${SB_SUCCESS}SUCCESS${SB_RESET} ] %b${SB_RESET}\n" "$*"
}

function sb.fail {
    printf "[ ${SB_FAIL}FAILED${SB_RESET} ] %b${SB_RESET}\n" "$*"
}

function sb.search {
    if [ $# -lt 3 ]; then
        echo "Usage: search <path> <extension> <term>"
        return
    fi
    grep -Rni --color=always --include="*.$2" "$3" $1 | less
}
