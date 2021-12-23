#/bin/bash
#
# This file is part of the simon-downes/sibash package which is distributed under the MIT License.
# See LICENSE.md or go to https://github.com/simon-downes/sibash for full license details.
#
# Provides a simple single character spinner.
# Based on: https://github.com/tlatsas/bash-spinner
#
# /HEADER

# Internal function to start the spinner
# $1: message to display before the spinner
function sb::spinner_start {

    local frame_index frames delay

    sb::spinner_kill

    frame_index=1
    frames="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    delay=0.15

    echo -ne "${1}  " # Status message, two spaces as the first character of the spinner is a backspace

    while true
    do
        printf "\b${SB_GREEN}${frames:frame_index++%${#frames}:1}${SB_NOCOLOUR}"
        sleep $delay
    done

}

# Internal function to stop the spinner and output the status and information message
# $1: integer exit code or string status message
# $2: optional information message
function sb::spinner_stop {

    local result info on_success on_fail

    result=${1:-0}
    info=${2:+" - ${SB_CYAN}${2}${SB_NOCOLOUR}"}

    on_success="${SB_GREEN}DONE${SB_NOCOLOUR}"
    on_fail="${SB_RED}FAIL${SB_NOCOLOUR}"

    sb::spinner_kill

    # if result is a number then it's an exit code so set an appropriate result message
    if [ "${result}" -eq "${result}" ] 2> /dev/null; then

        if [ $result -eq 0 ]; then
            result=$on_success
        else
            result=$on_fail
        fi

    fi

    # output result status and info message
    echo -e "\b[${result}]${info}"

}

# Kill the spinner process
function sb::spinner_kill {

    kill $SB_SPINNER_PID > /dev/null 2>&1

}

# Start or stop the spinner
# $1: action to take (start|stop)
# $2: on start: the message to display
#     on stop: the command exit code or status message
# $3: on stop: the information message
function sb::spinner {

    case $1 in
        start)

            # $2 : msg to display
            { sb::spinner_start "${2}" & } 2>/dev/null

            # set global spinner pid
            SB_SPINNER_PID=$!

            # remove the background job from job control
            disown

            # make sure the spinner dies once the current process exits
            trap "kill -9 ${SB_SPINNER_PID} > /dev/null 2>&1" EXIT

        ;;

        stop)

            sb::spinner_stop "$2" "$3"

            unset SB_SPINNER_PID

        ;;

        *)
            echo "Invalid argument, try {start/stop}"
            exit 1
        ;;

    esac

}

# Show a message and spinner whilst running a command
# $1: the message to display before the spinner
# $2: the command to run
# $3: the file that the command' stdout and stderr are directed to
function sb::spin {

    local msg cmd log result

    msg=$1
    cmd=$2
    log=${3:-$SB_LOG_FILE}

    sb::spinner start "$msg"

    echo "" >> ${log}

    $(sb::info $cmd 2>> ${log})

    $($cmd >> ${log} 2>&1)

    # store the result of the command so we can return it later
    result=$?

    sb::spinner stop $result

    return $result

}
