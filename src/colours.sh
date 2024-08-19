# ------------------------------------------------------------------------------
# Define terminal colour codes
# ------------------------------------------------------------------------------

# colours are configureable
export SB_RED=${SB_RED:-$(tput setaf 1)}
export SB_GREEN=${SB_GREEN:-$(tput setaf 2)}
export SB_YELLOW=${SB_YELLOW:-$(tput setaf 3)}
export SB_BLUE=${SB_BLUE:-$(tput setaf 4)}
export SB_MAGENTA=${SB_MAGENTA:-$(tput setaf 5)}
export SB_CYAN=${SB_CYAN:-$(tput setaf 6)}
export SB_WHITE=${SB_WHITE:-$(tput setaf 7)}
export SB_GRAY=${SB_GRAY:-$(tput setaf 8)}

export SB_BRIGHT_RED=${SB_BRIGHT_RED:-$(tput setaf 9)}
export SB_BRIGHT_GREEN=${SB_BRIGHT_GREEN:-$(tput setaf 10)}
export SB_BRIGHT_YELLOW=${SB_BRIGHT_YELLOW:-$(tput setaf 11)}
export SB_BRIGHT_BLUE=${SB_BRIGHT_BLUE:-$(tput setaf 12)}
export SB_BRIGHT_MAGENTA=${SB_BRIGHT_MAGENTA:-$(tput setaf 13)}
export SB_BRIGHT_CYAN=${SB_BRIGHT_CYAN:-$(tput setaf 14)}
export SB_BRIGHT_WHITE=${SB_BRIGHT_WHITE:-$(tput setaf 15)}

# styles
export SB_BOLD=$(tput bold)
export SB_UNDERLINE=$(tput sgr 0 1)

export SB_INVERT=$(tput sgr 1 0)

export SB_RESET=$(tput sgr0)

# colour aliases
export SB_ERROR=${SB_ERROR:-$SB_RED}
export SB_WARN=${SB_WARN:-$SB_YELLOW}
export SB_INFO=${SB_INFO:-$SB_CYAN}
export SB_DEBUG=${SB_DEBUG:-$SB_GRAY}

export SB_FAIL=${SB_FAIL:-$SB_RED}
export SB_SUCCESS=${SB_SUCCESS:-$SB_GREEN}

export SB_BULLET="${SB_CYAN}-${SB_RESET}"
