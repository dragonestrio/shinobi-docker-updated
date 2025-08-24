#!/bin/bash

# Check if Git is already installed
if git --version &>/dev/null; then
    echo "Git is already installed. Version: $(git --version)"
else
    # Identify the OS
    OS=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

    # Function to install Git
    install_git() {
        echo "Installing Git..."
        sudo $1 update
        sudo $1 install git -y
        echo "Git installation complete."
    }

    # Check OS and run installation commands
    case $OS in
        ubuntu | debian)
            install_git "apt"
            ;;
        centos)
            # CentOS has different versions that may require different managers
            VERSION_ID=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
            if [[ "$VERSION_ID" == "8" ]]; then
                install_git "dnf"
            else
                install_git "yum"
            fi
            ;;
        rocky | almalinux)
            install_git "dnf"
            ;;
        opensuse* | sles)
            install_git "zypper"
            ;;
        *)
            echo "Unsupported or non-Linux OS: $OS"
            echo "You may try running it manually."
            echo "Learn more at https://gitlab.com/Shinobi-Systems/ShinobiDocker."
            exit 1
            ;;
    esac
fi

# Clone the repository if it doesn't exist
if [ ! -d "/home/ShinobiDocker" ]; then
    git clone https://github.com/dragonestrio/shinobi-docker-updated.git /home/ShinobiDocker --branch master
fi

# Navigate to the directory
cd /home/ShinobiDocker

# Check for Docker and Docker Compose and install if not present
if ! command -v docker &>/dev/null || ! docker-compose --version &>/dev/null; then
    echo "Docker or Docker Compose not found. Running installation script..."
    sh INSTALL/docker.sh
fi

# Run setup script
bash setup_and_run.sh
