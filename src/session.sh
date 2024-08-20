# ------------------------------------------------------------------------------
# Interactive Session
# ------------------------------------------------------------------------------

function sb.session.init {

    # not running interactively so don't do anything
    [[ $- == *i* ]] || {
        echo "Session not supported for non-interactive shells"
        return 1
    }

    # --------------------------------------------------------------------------
    # Set options
    # --------------------------------------------------------------------------

    # append to the history file, don't overwrite it
    shopt -s histappend

    # check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    # Don't tab-complete an empty line - there's not really any use for it
    shopt -s no_empty_cmd_completion

    # --------------------------------------------------------------------------
    # Environment Variables
    # --------------------------------------------------------------------------

    # Make nano the default editor
    export EDITOR="nano"

    # Entries beginning with space aren't added into history, and duplicate
    # entries will be erased (leaving the most recent entry).
    export HISTCONTROL=ignoredups:ignorespace

    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    export HISTSIZE=10000
    export HISTFILESIZE=10000

    # Make paging output nicer
    # - quit if one screen
    # - ignore case in searches
    # - output ANSI colour sequences
    # - Merge consecutive blank lines into one
    # - highlight new line on movement
    # - don't clear the screen first
    # - set tabs to 4 spaces
    export LESS='-FiRswXx4'
    export PAGER="less -FiRswXx4"
    export MANPAGER="less -FiRswXx4"

    # --------------------------------------------------------------------------
    # Other Stuff
    # --------------------------------------------------------------------------

    # WSL stuff
    # https://stackoverflow.com/questions/61110603/how-to-set-up-working-x11-forwarding-on-wsl2
    sb.is.wsl && {
        # we should have an xserver running (hopefully) so tell our gui apps where to go
        export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
        export LIBGL_ALWAYS_INDIRECT=1
    }

    # nice aliases
    sb.session.aliases

    # use our nice prompt
    sb.prompt.on

}

function sb.session.aliases {

    # not running interactively so don't do anything
    [[ $- == *i* ]] || {
        echo "Aliases not supported for non-interactive shells"
        return 1
    }

    # Allow aliases to be used with sudo
    alias sudo="sudo "

    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."
    alias .....="cd ../../../.."

    sb.is.directory ~/dev && alias dev="cd ~/dev"

    # standard ls setup
    alias ls='ls -l --group-directories-first'

    # list only hidden files
    alias lh='ls -d .*'

    # list only directories
    alias lsd="ls -F | grep --color=never '^d'"

    # better nano
    # show line numbers, cursor position, "scrollbar" and stateflags
    # convert tabs to 4 spaces, auto-indent, smarter home key, don't wrap lines
    alias nano="nano --linenumbers --constantshow --indicator --stateflags --autoindent --smarthome --tabstospaces --tabsize=4 --historylog --nowrap"

    # Show $PATH in a readable way
    alias path='echo -e ${PATH//:/\\n}'

    # quick access to hosts file
    alias hosts='sudo $EDITOR /etc/hosts'

    # get current public IPv4 address
    alias whatsmyip="curl -s --show-error https://api.ipify.org"

    alias search="sb.search"

    # enable color support of ls and also add handy aliases
    # http://linux.die.net/man/1/dircolors
    # http://www.gnu.org/software/coreutils/manual/html_node/dircolors-invocation.html#dircolors-invocation
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls -l --group-directories-first --color=always'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi

    # git aliases
    sb.is.command git && {

        alias g="git status"
        alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
        alias ga="git add"
        alias gc="git commit -m"
        alias gco="git checkout"
        alias gd="git diff"
        alias grm="git rebase main"
        alias gdc="git diff --cached"
        alias gpo="git push origin"

    }

}
