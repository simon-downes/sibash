#!/bin/bash
#
# This file is part of the simon-downes/sibash package which is distributed under the MIT License.
# See LICENSE.md or go to https://github.com/simon-downes/sibash for full license details.
#
# Defines common/core functions used throughout the framework
#
# /HEADER

export SB_LOG_FILE=~/sb.log

# Restart the sudo timer or prompt for sudo password
function sb::sudo {

    # ensure we can sudo without being prompted
    # the first sudo will fail if a password is required and will restart the sudo timer otherwise
    # the second will prompt for a password and start the sudo timer
    sudo -nv 2> /dev/null || sudo true

}

# Display a simple header
# $1: The message to be displayed
# $2: The character(s) to use as the outline
# $3: The number of times to repeat the outline characters
# $4: The colour of the outline characters
function sb::header {

    local msg sep length colour range line

    typeset -i i length

    msg="$1"
    outline="${2:--}"
    length=${3:-40}
    colour="${4:-$SB_GRAY}"

    range=$(for ((i=1;i<=length;++i)); do echo -n "$i "; done)

    line="${colour}$(printf "%.0s${outline}" ${range})${SB_NOCOLOUR}"

    echo -e "${line}\n${msg}\n${line}"

}

# Output all arguments as a timestamped message to STDERR
function sb::err {
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') $*" >&2
}

# Output all arguments as a timestamped error message to STDERR
function sb::error {
    sb::err "${SB_RED}ERROR${SB_NOCOLOUR} $*"
}

# Output all arguments as a timestamped warning message to STDERR
function sb::warn {
    sb::err "${SB_YELLOW}WARNING${SB_NOCOLOUR} $*"
}

# Output all arguments as a timestamped info message to STDERR
function sb::info {
    sb::err "${SB_CYAN}INFO${SB_NOCOLOUR} $*"
}

# Output all arguments as a success message to STDOUT
function sb::success {
    echo -e "[${SB_GREEN}SUCCESS${SB_NOCOLOUR}] ${SB_CYAN}$*${SB_NOCOLOUR}"
}

# Output all arguments as a failed message to STDOUT
function sb::fail {
    echo -e "[${SB_RED}FAILED${SB_NOCOLOUR}] ${SB_CYAN}$*${SB_NOCOLOUR}"
}

function sb::apt_update {

    sb::spin "Updating Package List..." "sudo apt-get update"

}
