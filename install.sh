#!/data/data/com.termux/files/usr/bin/bash
echo "Inspired From Hax4us Flutter Installation Script.."
echo "Installing FlutterArch...."

check_deps() {
    pkgs=("proot-distro" "curl" "git" "unzip" "sed")

    for pkg in pkgs; do
        if [ -z $(command -v ${pkg}) ]; then
            echo "Installing ${pkg}"
            apt install ${pkg} > /dev/null 2>&1
        fi
    done
}

install_arch() {
  proot-distro install archlinux
}

setting_up_arch() {
  echo Installing Deps...
  cp required.sh $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux/root
  proot-distro login archlinux -- pacman -Sy
  proot-distro login archlinux -- chmod +x required.sh
  proot-distro login archlinux -- source ./required.sh
  proot-distro login archlinux -- rm -rf required.sh
}

add_normal_user() {
  read -p "Type Your Arch Username:" user
  readonly $user
  echo Adding user $user..
  proot-distro login archlinux -- useradd $user
  proot-distro login archlinux -- mkdir /home/$user
  proot-distro login archlinux -- sh -c "echo \"$user ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
}

install_flutter_as_normal_user(){
  echo Downloading Requirements....
  proot-distro login --user $user archlinux -- curl -LO https://github.com/bdloser404/FlutterArch/releases/download/files/Flutter-ARM64.zip
  proot-distro login --user $user archlinux -- curl -LO https://github.com/bdloser404/FlutterArch/releases/download/files/gen_snapshot.zip
  proot-distro login --user $user archlinux -- curl -LO https://github.com/bdloser404/FlutterArch/releases/download/files/shader_lib.zip

  proot-distro login --user $user archlinux -- unzip Flutter-ARM64.zip
  proot-distro login --user $user archlinux -- unzip gen_snapshot.zip
  proot-distro login --user $user archlinux -- unzip shader_lib.zip
  echo Setting Up Arch For Flutter...
  proot-distro login --user $user archlinux -- sed -i "s#export PATH=.*#&:/home/$user/flutter/bin#g" /etc/profile.d/termux-proot.sh
  proot-distro login --user $user archlinux -- mkdir -p ~/flutter/bin/cache/artifacts/engine/android-arm64-release/linux-arm64
  proot-distro login --user $user archlinux -- mv gen_snapshot ~/flutter/bin/cache/artifacts/engine/android-arm64-release/linux-arm64/
  proot-distro login --user $user archlinux -- flutter doctor
  proot-distro login --user $user archlinux -- flutter channel beta
  proot-distro login --user $user archlinux -- flutter upgrade --force
  proot-distro login --user $user archlinux -- flutter doctor -v
  proot-distro login --user $user archlinux --cp -r shader_lib ~/flutter/bin/cache/artifacts/engine/android-arm64-release/linux-arm64/ && rm -rf shader_lib
}

#optional configuration
# Neovim For Flutter
nvim_config_installation(){
  echo setting up neovim for flutter..
  proot-distro login --user $user archlinux -- curl -OL https://github.com/bdloser404/FlutterArch/releases/download/files/nvim.zip
  proot-distro login --user $user archlinux -- mkdir .config/
  proot-distro login --user $user archlinux -- unzip nvim.zip
  proot-distro login --user $user archlinux -- mv nvim ~/.config/
  
  echo 'Open Neovim Editor Its Autometically Install required Plugins for Flutter Developmemt'
  echo 'command $ nvim '
}
function setup_environment() {
  function install_sdk() {
    echo "Installing SDK..."
    if [ -e android_sdk.zip ]; then
      echo "Android SDK zip file already exists."
    else
      echo "Downloading Android SDK..."
      proot-distro login --user $user archlinux -- curl -OL https://github.com/bdloser404/FlutterArch/releases/download/files/android_sdk.zip
    fi
    # Your installation commands here
    proot-distro login --user $user archlinux -- unzip android_sdk.zip
    proot-distro login --user $user archlinux -- flutter config --android-sdk ~/android_sdk
  }

  read -p "Do you want to install the SDK? (y/n): " confirm

  if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
    install_sdk
  else
    echo "SDK installation cancelled."
    exit 1
  fi
}

# Call the functions
check_deps
install_arch
setting_up_arch
add_normal_user
install_flutter_as_normal_user
nvim_config_installation
setup_environment

echo "Installation Success"
echo "Login Proot-> $ proot-distro login --user $user archlinux"
