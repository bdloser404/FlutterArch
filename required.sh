#!/bin/bash
# Function to check for existing packages and install missing ones
check_install_packages() {
    # Loop through packages array
    for package in "$@"
    do
        # Check if package is already installed
        if pacman -Qi "$package" > /dev/null 2>&1; then
            echo "$package is already installed"
        else
            # Install missing package
            echo "Installing $package"
            pacman -S --noconfirm "$package"
        fi
    done
}

# Call function with list of package names
check_install_packages "git" "glu" "xz" "zip" "neovim"
