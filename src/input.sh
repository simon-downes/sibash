# ------------------------------------------------------------------------------
# User Input Functions
# ------------------------------------------------------------------------------

function sb.input.proceed {

    local prompt default options

    # default is to proceed
    default=${1:-y}
    prompt=${2:-"Proceed?"}

    case "$default" in
        y|Y|yes )
            options="${SB_GREEN}Y${SB_RESET}/n"
        ;;
        * )
          options="y/${SB_RED}N${SB_RESET}"
          default="n"
        ;;
    esac

    read -p "${prompt} [${options}]: " -n 1 -r
    echo

    # if reply is empty then user just pressed enter so use default
    sb.is.empty $REPLY && REPLY=$default

    # return code will be the result of this function call
    sb.is.true $REPLY

}
