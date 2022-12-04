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

    if [[ -z "$fn" ]]; then
        usage
        exit 1
    fi

    case "${fn}" in

        install)
            if [ -z $2 ]; then
                (eval "sb::${fn}")
            else
                (eval "sb::${fn}_${2}")
            fi
        ;;

        *)

            # no function with the given name so display usage instead
            if [[ ! $(declare -F "sb::${fn}") ]]; then
                usage
                exit 1
            fi

            # otherwise run the command in the current context
            (eval "sb::${fn} "\"${@:2}\""")

        ;;
    esac

}

main "$@"
