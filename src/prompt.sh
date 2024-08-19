
function sb.prompt.on {

    # not running interactively so don't do anything
    [[ $- == *i* ]] || {
        echo "Prompt not supported for non-interactive shells"
        return 1
    }

    # if prompt command is already set to our prompt then do nothing
    if [ "${PROMPT_COMMAND}" == "_sb.prompt.build"  ]; then
        return
    fi

    # store current prompt
    _sb_prompt_old=$PS1

    # store the process id of the current bash session
    # no need to export it as it's only relevant to the current shell session
    _sb_root_pid=$BASHPID

    # determine where we're storing the command timer data
    _sb_cmd_timer_data=/dev/shm/${USER}.cmd_timer.${_sb_root_pid}

    # # run command timer function before each command
    trap "_sb.prompt.cmd_timer" DEBUG

    PROMPT_COMMAND=_sb.prompt.build

}

function sb.prompt.off {

    # not running interactively so don't do anything
    [[ $- == *i* ]] || {
        echo "Prompt not supported for non-interactive shells"
        return 1
    }

    # if the current prompt command is ours then tidy up our stuff
    if [ "${PROMPT_COMMAND}" == "_sb.prompt.build"  ]; then

        # remove our trap
        trap - DEBUG

        # remove command timer data
        _sb.prompt.cmd_timer reset > /dev/null

        # remove current prompt command
        unset PROMPT_COMMAND

    fi

    # restore old prompt or use a simple default one
    _sb.prompt.set "${_sb_prompt_old:- }"

}

function _sb.prompt.set {

    # no prompt given so use a simple default one
    sb.is.empty "$1" && {
        $1="\[${SB_YELLOW}\]\u\[${SB_RESET}\]@\[${SB_GREEN}\]\h\[${SB_RESET}\]:\[${SB_BLUE}\]\w\[${SB_RESET}\]\$"
    }

    PS1=$1

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
        xterm*|rxvt*)
            PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
        *)
        ;;
    esac

}

# handle timing of commands
function _sb.prompt.cmd_timer {

    # no ROOT_PID so don't bother tracking command times
    sb.is.empty $_sb_root_pid && return

    local cmd_time start

    cmd_time=$(date +%s.%3N)

    # if we're reseting the timer then calculate the elapsed time and echo it
    # then remove the shared memory file to reset the timer
    if [ "$1" == "reset" ]; then

        # no file so user probably just pressed enter so 0ms
        if [ ! -f $_sb_cmd_timer_data ]; then
            echo "0ms"
            return
        fi

        # get the start of the first command that was run since the last prompt
        start=$(head -n 1 $_sb_cmd_timer_data)

        echo "${cmd_time} ${start}" | awk '{
            # calc duration
            duration = $1 - $2

            # remove milliseconds
            ts = int(duration)

            # split into components - milliseconds, seconds, minutes and hours
            ms = (duration%1)
            s = ts%60
            m = int((ts/60)%60)
            h = int(ts/3600)

            # print hours if any
            if (h > 0)
                printf "%dh ", h

            # print minutes if any
            if (m > 0)
                printf "%dm ", m

            # if seconds print s
            if ( s >= 1 )
                printf "%ds", s

            # else print ms
            else
                printf "%dms", ms * 1000

        }'

        rm -f $_sb_cmd_timer_data

        return

    fi

    # # if we're not running the prompt command then we're executing a command since the last prompt
    # # so append the current time and the command to the log
    if [ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]; then
        echo "$cmd_time $BASH_COMMAND" >> $_sb_cmd_timer_data
    fi

    # for debugging
    # echo "$cmd_time $SB_ROOT_PID $BASHPID $BASH_COMMAND" >> /tmp/cmd.log

}

function _sb.prompt.build {

    # must come first - grab exit code of last command
    local _exit=$?

    # define prompt colour sequences - needs surround square brackets
    # https://unix.stackexchange.com/questions/158412/are-the-terminal-color-escape-sequences-defined-anywhere-for-bash
    local red="\[${SB_RED}\]"
    local green="\[${SB_GREEN}\]"
    local yellow="\[${SB_YELLOW}\]"
    local blue="\[${SB_BLUE}\]"
    local magenta="\[${SB_MAGENTA}\]"
    local cyan="\[${SB_CYAN}\]"
    local white="\[${SB_WHITE}\]"
    local gray="\[${SB_GRAY}\]"

    local bright_red="\[${SB_BRIGHT_RED}\]"
    local bright_green="\[${SB_BRIGHT_GREEN}\]"
    local bright_yellow="\[${SB_BRIGHT_YELLOW}\]"
    local bright_blue="\[${SB_BRIGHT_BLUE}\]"
    local bright_magenta="\[${SB_BRIGHT_MAGENTA}\]"
    local bright_cyan="\[${SB_BRIGHT_CYAN}\]"
    local bright_white="\[${SB_BRIGHT_WHITE}\]"

    local bold="\[${SB_BOLD}\]"
    local underline="\[${SB_UNDERLINE}\]"
    local invert="\[${SB_INVERT}\]"
    local reset="\[${SB_RESET}\]"

    # get the time it took run the commands since the last prompt appeared
    local cmd_time="${gray}$(_sb.prompt.cmd_timer reset) ${reset}"

    # default prompt colour is green to indicate success of previous command
    local prompt_colour="${green}"

    # if last command failed then prompt is red and includes exit code
    if [ $_exit != 0 ]; then
        prompt_colour="${red}"
        _exit="${prompt_colour}🗙 ${_exit} ${reset}"
    else
        _exit="${prompt_colour}✔ ${reset}"
    fi

    # character definitions
    local box_top="${prompt_colour}╭ ${reset}"
    local box_bottom="${prompt_colour}╰ ${reset}"
    local prompt_char="${prompt_colour}❯ ${reset}"
    local separator="${bright_white} :: ${reset}"
    local git_separator="${reset}•"

    if [ $USER == "root" ]; then
        local user=${bright_red}${USER}${reset}
    else
        local user=${yellow}${USER}${reset}
    fi

    local host="${bright_magenta}${HOSTNAME}${reset}"

    local current_dir="${bright_blue}\\w${reset}"

    local git_status=""

    sb.is.command git && {

        # determine if we're in a git work tree:
        # empty string = not in a git repo
        # true = in a git repo - not in the .git directory
        # false = in the .git directory of a git repo
        local git_work_tree=$(git rev-parse --is-inside-work-tree 2> /dev/null)

        if [ ! -z "${git_work_tree}" ]; then

            # check for what branch we're on. (fast)
            #   if… HEAD isn’t a symbolic ref (typical branch),
            #   then… get a tracking remote branch or tag
            #   otherwise… get the short SHA for the latest commit
            #   lastly just give up.
            local git_branch="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
                git describe --all --exact-match HEAD 2> /dev/null || \
                git rev-parse --short HEAD 2> /dev/null || \
                echo '(unknown)')";

            local git_changes=""

            if [ $git_work_tree = "true" ]; then

                # get number of staged but not commited files
                local git_staged=$(git diff-index --cached HEAD -- 2> /dev/null | wc -l)

                # number of unstaged files
                local git_unstaged=$(git diff-files --ignore-submodules | wc -l)

                # number of untracked files (that aren't ignored)
                local git_untracked=$(git ls-files --others --exclude-standard | wc -l)

                git_changes=" ${green}${git_staged}${git_separator}${yellow}${git_unstaged}${git_separator}${cyan}${git_untracked}${no_colour}"
            fi

            # combine the git info into a single string
            git_status="${separator}${red}${git_branch}${git_changes}${no_colour}"

        fi

    }

    _sb.prompt.set "\n${box_top}${user}@${host}${separator}${current_dir}${git_status}\n${box_bottom}${_exit}${cmd_time}${prompt_char}"

}
