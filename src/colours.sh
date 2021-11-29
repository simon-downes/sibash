#!/bin/bash
#
# This file is part of the simon-downes/sibash package which is distributed under the MIT License.
# See LICENSE.md or go to https://github.com/simon-downes/sibash for full license details.
#
# Defines the ANSI colour codes used throughout the framework
#
# /HEADER

export SB_RED=$(tput setaf 1)
export SB_GREEN=$(tput setaf 2)
export SB_YELLOW=$(tput setaf 3)
export SB_BLUE=$(tput setaf 4)
export SB_MAGENTA=$(tput setaf 5)
export SB_CYAN=$(tput setaf 6)
export SB_WHITE=$(tput setaf 7)
export SB_GRAY=$(tput setaf 8)
export SB_BOLD=$(tput bold)
export SB_UNDERLINE=$(tput sgr 0 1)
export SB_INVERT=$(tput sgr 1 0)
export SB_NOCOLOUR=$(tput sgr0)
