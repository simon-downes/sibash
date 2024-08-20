# ------------------------------------------------------------------------------
# Core Installer Functions
# ------------------------------------------------------------------------------

# TODO: Install Poetry (Python)

function sb.install.packages {

    local packages package

    packages=$@

    sb.sudo

    printf "\n${SB_INFO}Installing Packages:${SB_RESET}\n\n"

    sb.list $packages

    echo

    sb.input.proceed && {

        sb.spinner.run "Installing... " "sudo apt-get install -qy ${packages}"

        if [ $? -ne 0 ]; then
            echo $(tail -n 1 $SB_LOG_FILE)
        fi

    }

}

# Install core things that should probably be everywhere already anyway
function sb.install.core {

    sb.install.packages apt-transport-https ca-certificates software-properties-common python-is-python3 python3-pip python3-venv curl wget jq zip

}
