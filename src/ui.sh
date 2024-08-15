
function sb.list {
    for item in $@; do
        printf " ${SB_BULLET} ${item}\n"
    done
}

# Display a simple header
# $1: The message to be displayed
# $2: The character(s) to use as the outline
# $3: The number of times to repeat the outline characters
# $4: The colour of the outline characters
function sb.header {

    local msg length text_colour line_colour line_char

    msg="$1"
    length=${2:-60}
    text_colour="${3}"
    line_colour="${4}"
    line_char="${5}"

    sb.hr $length $line_char $line_colour

    printf "${text_colour}%b${SB_RESET}\n" "${msg}"

    sb.hr $length $line_char "$line_colour"

}

function sb.hr {

    local length char colour range line i

    length=${1:-60}
    char="${2:--}"
    colour="${3:-$SB_GRAY}"

    for (( i = 1; i <= length; ++i )); do
        line="${line}${char}"
    done

    printf "${colour}${line}${SB_RESET}\n"

}
