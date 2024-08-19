
# show a message and spinner whilst running a command
# $1: the message to display before the spinner
# $2: the command to run
# $3: the file that the command' stdout and stderr are directed to
function sb.spinner.run {

    local msg cmd log result

    msg=$1
    cmd=$2
    log=${3:-$SB_LOG_FILE}

    printf "${msg}"

    sb.spinner.start

    echo "" >> "${log}"

    sb.log.info "Executing: $cmd" >> ${log}

    eval $cmd >> "${log}" 2>&1

    # store the result of the command so we can return it later
    result=$?

    sb.spinner.stop $result

    return $result

}

function sb.spinner.start {

    # if we already have a spinner then stop it
    sb.is.process $SB_SPINNER_PID && sb.spinner.stop

    # call the spinner in a new background process
    { sb.spinner.go & } 2>/dev/null

    # store spinner pid
    SB_SPINNER_PID=$!

    # remove the background job from job control
    disown

}

# internal function to stop the spinner and output the status and information message
# $1: integer exit code or string status message
# $2: optional information message
function sb.spinner.stop {

    # if we don't have a spinner process id then don't do anything
    sb.is.process $SB_SPINNER_PID || return

    local result on_success on_fail

    result=${1:-0}
    on_success="${SB_GREEN}DONE${SB_RESET}"
    on_fail="${SB_RED}FAILED${SB_RESET}"

    _sb.spinner.kill

    # if result is a number then it's an exit code so set an appropriate result message
    if [ "${result}" -eq "${result}" ] 2> /dev/null; then

        if sb.is.zero $result; then
            result=$on_success
        else
            result=$on_fail
        fi

    fi

    # output result status - start with a backspace to erase the spinner character
    printf "\b[ ${result} ]\n"

}

function sb.spinner.go {

    local frame_index frames delay

    # kill current spinner if there is one
    sb.is.empty $SB_SPINNER_PID || _sb.spinner.kill

    frame_index=1
    frames="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    delay=0.15

    # output a space as the first character of the spinner is a backspace
    printf " "

    while true
    do
        printf "\b${SB_GREEN}${frames:frame_index++%${#frames}:1}${SB_RESET}"
        sleep $delay
    done

}

# kill the spinner process
function _sb.spinner.kill {

    kill $SB_SPINNER_PID > /dev/null 2>&1
    unset SB_SPINNER_PID

}
