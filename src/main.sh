#!/bin/bash
#
# This file is part of the simon-downes/sibash package which is distributed under the MIT License.
# See LICENSE.md or go to https://github.com/simon-downes/sibash for full license details.
#
# Defines common/core functions used throughout the framework
#
# /HEADER

function usage {

    echo $"Usage: $0 {install|spinner|blah}"

}

function main {

    local fn=$1

    # determines if function exists
    #declare -F "sb::${fn}"

    case "${fn}" in
        install)
            (eval "sb::${fn}_${2}")
        ;;

        *)
            (eval "sb::${fn} "\"${@:2}\""")
        ;;
    esac

}

main "$@"
