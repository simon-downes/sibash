
function sb.version.latest {

    local what

    what=$1

    case $what in

        php)
            apt search php8. 2> /dev/null | grep -E -o "8\.[0-9]+\-cli" | cut -f 1 -d- | tail -n 1
        ;;

        composer)
            curl -fs https://api.github.com/repos/composer/composer/releases/latest | jq --raw-output '.tag_name'
        ;;

        aws)
            curl -fs https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst --range 31-37
        ;;

        aws-vault)
            curl -fs https://api.github.com/repos/99designs/aws-vault/releases/latest | jq --raw-output '.tag_name' | cut -c 2-
        ;;

        caddy)
            curl -fs https://api.github.com/repos/caddyserver/caddy/releases/latest | jq --raw-output '.tag_name' | cut -c 2-
        ;;

        terraform)
            curl -fs https://api.github.com/repos/hashicorp/terraform/releases/latest | jq --raw-output '.tag_name' | cut -c 2-
        ;;

        hugo)
            curl -fs https://api.github.com/repos/gohugoio/hugo/releases/latest | jq --raw-output '.tag_name' | cut -c 2-
        ;;

        sass)
            curl -fs https://api.github.com/repos/sass/dart-sass/releases/latest | jq --raw-output '.tag_name'
        ;;

        uv)
            curl -fs https://api.github.com/repos/astral-sh/uv/releases/latest | jq --raw-output '.tag_name'
        ;;

        *)
            sb.error Unknown program: ${SB_INFO}${what}${SB_RESET}
        ;;

    esac

}

function sb.version.current {

    local what

    what=$1

    # if it's not a command then it's not installed and has no current version
    sb.is.command $what || return 1

    case $what in

        php)
            php --version | head -n 1 | cut -d" " -f2
        ;;

        composer)
            composer --version 2> /dev/null | cut -d" " -f3
        ;;

        aws)
            aws --version | cut -d" " -f1 | cut -d"/" -f2
        ;;

        aws-vault)
            aws-vault --version 2>&1  | tr -d "v"
        ;;

        caddy)
            caddy version | cut -d" " -f1 | cut -d"v" -f2
        ;;

        terraform)
            terraform --version | head -n 1 | cut -d'v' -f2
        ;;

        docker)
            docker --version | cut -d, -f1 | cut -d" " -f3
        ;;

        hugo)
            hugo version | cut -d"-" -f1 | cut -d"v" -f2
        ;;

        sass)
            sass --version
        ;;

        uv)
            uv version | cut -d " " -f2
        ;;

        *)
            # if we got here then unknown command so return error code
            return 1
        ;;

    esac


}
