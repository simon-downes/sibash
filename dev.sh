#!/bin/bash

artifact=sibash

function main {

    case $1 in

        build)
            sb_build
        ;;

        deploy)
            sb_deploy
        ;;

        *)
            echo "Usage: $0 <command>"
            echo "  <command>:"
            echo "    - build"
            echo "    - deploy"
        ;;

    esac

}

function sb_build {

    echo "#!/bin/bash" > $artifact

    cat << EOF >> $artifact

# ------------------------------------------------------------------------------
#    SiBash - A handy Bash library
# ------------------------------------------------------------------------------
#
# https://github.com/simon-downes/sibash
#

EOF

    components="colours core is log input session prompt ui spinner install version"

    # cat the component files into output file
    for component in $components; do
        cat "src/${component}.sh" >> $artifact
        echo -e "\n" >> $artifact
    done

    # cat the installer files into output file
    for installer in ./src/installers/*; do
        cat $installer >> $artifact
        echo -e "\n" >> $artifact
    done

    # cleanup goes last
    cat "src/cleanup.sh" >> $artifact

    chmod a+x $artifact

    . $artifact

    sb.success

}

function sb_deploy {

    local username token gist_id local_sha remote_sha

    username=simon-downes
    token=$(cat ~/.github/gist.token)
    gist_id=8f6591e3bba4b4f532c41ec5fb8f3fa8

    # no source file found so build it
    [ ! -f sb ] && {
        echo
        echo -n "Building... "
        sb_build
        echo
    }

    # calc local and remote hashes to check if we need to upload
    local_sha=$(sha1sum $artifact  | cut -f1 -d' ')
    remote_sha=$(curl -sfL https://gist.githubusercontent.com/${username}/${gist_id}/raw/ | sha1sum | cut -f1 -d' ')

    . $artifact

    sb.info "Local SHA : ${SB_INFO}${local_sha}${SB_RESET}"
    sb.info "Remote SHA: ${SB_INFO}${remote_sha}${SB_RESET}"
    echo

    [ "${local_sha}" == "${remote_sha}"  ] && {
        sb.info "Skipping deployment: ${SB_INFO}No changes${SB_RESET}"
        return
    }

    printf "Uploading... "

    curl -fs -X PATCH -u ${username}:${token} -d "{\"files\":{\"sibash\":{\"content\": $(cat $artifact | jq -Rsa)}}}\"" https://api.github.com/gists/${gist_id} > /dev/null || {
        sb.failed
        return 1
    }

    sb.success

}

main $@
