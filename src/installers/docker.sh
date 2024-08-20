
function sb.install.docker {

    sb.sudo

    sb.header "Installing Docker Engine"

    sb.spinner.run "Adding APT Repository... " "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
        sudo chmod a+r /etc/apt/keyrings/docker.asc && \
        echo \
        \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable\" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" && \

        sb.spinner.run "Updating Package List... " "sudo apt-get -q update" && \

        sb.spinner.run "Installing Packages... " "sudo apt-get install -qy docker-ce docker-ce-cli containerd.io docker-compose-plugin" && \

        sb.spinner.run "Adding user '${USER}' to Docker group... " "sudo usermod -aG docker ${USER}" && \

        sb.is.command docker

    sb.is.not_zero $? && {
        echo
        sb.fail "$(tail -n 1 $SB_LOG_FILE)"
        return 1
    }

    echo
    sb.success "${SB_INFO}$(sb.version.current docker)${SB_RESET} installed"

}
