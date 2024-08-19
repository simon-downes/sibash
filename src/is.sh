
function sb.is.command {
    command -v $1 > /dev/null 2>&1
}

function sb.is.interactive {
    [[ $- == *i* ]]
}

function sb.is.true {
    case $(sb.lower <<<"$1") in
        yes|y|true|on|1)
            return 0
        ;;
    esac
    return 1
}

function sb.is.empty {
    [ -z "$1" ]
}

function sb.is.not_empty {
    [ ! -z "$1" ]
}

function sb.is.zero {
    [ "$1" -eq 0 ] 2> /dev/null
}

function sb.is.not_zero {
    [ ! "$1" -eq 0 ] 2> /dev/null
}

function sb.is.file {
    [ -f "$1" ]
}

function sb.is.directory {
    [ -d "$1" ]
}

function sb.is.symlink {
    [ -L "$1" ]
}

function sb.is.user {
    id "$1" >/dev/null 2>&1
}

function sb.is.process {
    ps -p $1 > /dev/null 2>&1
}

function sb.is.wsl {
    grep -qsi Microsoft /proc/sys/kernel/osrelease
}

function sb.is.cpu_arm {

    sb.is.empty "${SB_CPU_ARCH}" && {
        export SB_CPU_ARCH=$(uname -m)
    }

    case $SB_CPU_ARCH in
        aarch64 | arm64)
            return 0
        ;;
    esac

    return 1

}

function sb.is.cpu_x64 {

    sb.is.empty "${SB_CPU_ARCH}" && {
        export SB_CPU_ARCH=$(uname -m)
    }

    [ "${SB_CPU_ARCH}" == "x86_64" ]

}
