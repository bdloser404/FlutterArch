#!/data/data/com.termux/files/usr/bin/bash
echo "Inspired From Hax4us Flutter Installation Script.."
echo "Installing FlutterArch...."

#Checking for required pkgs
function check_deps() {
    for package in "$@"; do
        if ! pkg list-installed "$package" >/dev/null 2>&1; then
            echo "Installing $package..."
            pkg install -y "$package"
        else
            echo "$package is already installed."
        fi
    done
}

#Installing Arch
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
  #Android SDK Path 
  echo Downloading Requirements..

  function install_fsdk() {
    echo "Flutter SDK Instalation...."
    if [ -f $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux/home/$user/flutter_linux_3.3.10-stable.tar.xz ]; then
      echo "Flutter SDK zip file already exists."
      proot-distro login --user $user archlinux -- tar -xvf flutter_linux_3.3.10-stable.tar.xz
    else
      echo "Downloading Flutter SDK..."
      proot-distro login --user $user archlinux -- curl -OL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.10-stable.tar.xz && tar -xvf flutter_linux_3.3.10-stable.tar.xz

    fi

    if [ ! -f $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux/home/$user/engine.zip ]; then
      echo " Downloading engine.zip..."
      proot-distro login --user $user archlinux -- curl -OL https://github.com/bdloser404/FlutterArch/releases/download/files/engine.zip
    fi
  }

  install_fsdk
  proot-distro login --user $user archlinux -- unzip engine.zip
  echo Setting Up Arch For Flutter...
  proot-distro login --user $user archlinux -- sed -i "s#export PATH=.*#&:/home/$user/Android/flutter/bin#g" /etc/profile.d/termux-proot.sh
  proot-distro login --user $user archlinux -- mkdir -p Android
  proot-distro login --user $user archlinux -- mv flutter/ Android/
  proot-distro login --user $user archlinux -- rm -rf Android/flutter/bin/cache/
  proot-distro login --user $user archlinux -- mkdir -p Android/flutter/bin/cache/artifacts/
  proot-distro login --user $user archlinux -- mv engine Android/flutter/bin/cache/artifacts/
  proot-distro login --user $user archlinux -- flutter doctor
  proot-distro login --user $user archlinux -- flutter doctor -v
}

#optional configuration
# Neovim For Flutter
nvim_config_installation(){
  echo setting up neovim for flutter..
# Set the directory names as variables
  confign=".config/nvim"
  locald=".local/share/nvim"
  cachen=".cache/nvim"

# Loop through the list of directories
  for dir in "$confign" "$locald" "$cachen"
  do   
  # Check if the directory exists
    if [ -d "$dir" ]
    then
      echo "Directory $dir exists"
      echo Back up...
      proot-distro login --user $user archlinux -- mv .config ~/.config.bak
      proot-distro login --user $user archlinux -- mv .local ~/.local.bak
      proot-distro login --user $user archlinux -- mv .cache ~/.cache.bak
      proot-distro login --user $user archlinux -- ln -sr /root/.local .
      proot-distro login --user $user archlinux -- ln -sr /root/.cache .

      echo dir linked 


    else
    # Create the directory if it doesn't exist
      proot-distro login --user $user archlinux -- ln -sr /root/.local .
      proot-distro login --user $user archlinux -- ln -sr /root/.cache .
      echo dir linked
    fi
  done

    if [ ! -f $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux/home/$user/nvim.zip ]; then
      echo " Downloading nvim.zip..."
      proot-distro login --user $user archlinux -- curl -OL https://github.com/bdloser404/FlutterArch/releases/download/files/nvim.zip
    fi
  proot-distro login --user $user archlinux -- mkdir -p .config/nvim 

  proot-distro login --user $user archlinux -- unzip nvim.zip
  proot-distro login --user $user archlinux -- mv init.vim /home/$user/.config/nvim/
  proot-distro login --user $user archlinux -- sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  proot-distro login --user $user archlinux -- nvim +'PlugInstall --sync' +qa

  echo 'Neovim Successfully Installed'
}

function setup_environment() {
  function install_sdk() {
    echo "Installing cmdline-tools..."
    if [ -e $PREFIX/var/lib/proot-distro/installed-rootfs/archlinux/home/$user/commandlinetools-linux-9477386_latest.zip ]; then
      echo "cmdline-tool zip file already exists."
    else
      echo "Downloading Android SDK..."
      proot-distro login --user $user archlinux -- curl -OL https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    fi
    # Your installation commands here
    proot-distro login --user $user archlinux -- unzip commandlinetools-linux-9477386_latest.zip
    proot-distro login --user $user archlinux -- mkdir -p Android/cmdline-tools
    proot-distro login --user $user archlinux -- mv cmdline-tools Android/cmdline-tools/tools
    proot-distro login --user $user archlinux -- sed -i "s#export PATH=.*#&:/home/$user/Android/cmdline-tools/tools/bin#g" /etc/profile.d/termux-proot.sh
    proot-distro login --user $user archlinux -- sed -i "s#export PATH=.*#&:/home/$user/Android/platform-tools/bin#g" /etc/profile.d/termux-proot.sh
    echo Installing A30.....
    proot-distro login --user $user archlinux -- sdkmanager "platform-tools" "platforms;android-30"
    #$puser -- yes | sdkmanager --licenses
    proot-distro login --user $user archlinux -- flutter config --android-sdk ~/Android
  }

  read -p "Do you want to install the SDK? (y[recomanded]/n): " confirm

  if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
    install_sdk
  else
    echo "SDK installation cancelled."
    exit 1
  fi
}

# Call the functions
call_main ()
{
  check_deps "proot-distro" "sed" "git" 
  install_arch
  setting_up_arch
  add_normal_user
  install_flutter_as_normal_user
  nvim_config_installation
  setup_environment
}

call_main

echo "Installation Success"
echo "Login Proot-> $ proot-distro login --user $user archlinux"
