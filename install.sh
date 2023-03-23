#!/data/data/com.termux/files/usr/bin/bash
echo "Inspired From Hax4us Flutter Installation Script.."
echo "Installing FlutterArch...."

#termux-setup-storage
# Root Login Command 
root = $("proot-distro login archlinux")
# Flutter SDK Directory
FLUTTER = $("$HOME/Android/flutter")
# cmdline tool directoru 
CMDLINE = $("$HOME/Android/cmdline-tools")
#platform tools 
PTOOLS = $("$HOME/Android/platform-tools")
# neovim plug install cmd
PLUG_INSTALL = $("nvim +'PlugInstall --sync' +qa")
#install VimPlug For Neovim
VIM_PLUG = $("sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'")

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
  $root -- pacman -Sy
  $root -- chmod +x required.sh
  $root -- source ./required.sh
  $root -- rm -rf required.sh
}

add_normal_user() {
  read -p "Type Your Arch Username:" user
  readonly $user
  echo Adding user $user..
  $root -- useradd $user
  $root -- mkdir /home/$user
  $root -- sh -c "echo \"$user ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
}

# User Login Commannd 
puser = $("proot-distro login --user $user archlinux")

install_flutter_as_normal_user(){
  #Android SDK Path 
  echo Downloading Requirements..

  function install_fsdk() {
    echo "Flutter SDK Instalation...."
    if [ -e flutter_linux_3.3.10-stable.tar.xz ]; then
      echo "Flutter SDK zip file already exists."
      $puser -- tar -xvf flutter_linux_3.3.10-stable.tar.xz
    else
      echo "Downloading Flutter SDK..."
      $puser -- curl https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.10-stable.tar.xz && tar -xvf flutter_linux_3.3.10-stable.tar.xz
      $puser -- curl -LO https://github.com/bdloser404/FlutterArch/releases/download/files/engine.zip
    fi
  }

  install_fsdk
  $puser -- unzip engine.zip
  echo Setting Up Arch For Flutter...
  $puser -- sed -i "s#export PATH=.*#&:$FLUTTER/bin#g" /etc/profile.d/termux-proot.sh
  $puser -- rm -rf $FLUTTER/bin/cache/dart-sdk
  $puser -- mkdir -p $FLUTTER/bin/cache/artifacts/
  $puser -- mv engine $FLUTTER/bin/cache/artifacts/
  $puser -- flutter doctor
  $puser -- flutter doctor -v
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
      Back up...
      $puser -- mv .config $HOME/config.bak
      $puser -- mv .local $HOME/.local.bak
      $puser -- mv .cache $HOME/.cache.bak
      $puser -- ln -sr /root/.local .
      $puser -- ln -sr /root/.cache .

      echo dir linked 


    else
    # Create the directory if it doesn't exist
      $puser -- ln -sr /root/.local .
      $puser -- ln -sr /root/.cache .
      echo dir linked
    fi
  done



  $puser -- curl -OL https://github.com/bdloser404/FlutterArch/releases/download/files/nvim.zip

  $puser -- mkdir -p .config/nvim 

  $puser -- unzip nvim.zip
  $puser -- mv init.vim ~/.config/nvim/
  $puser -- $VIM_PLUG
  $puser -- $PLUG_INSTALL

  echo 'Neovim Successfully Installed'
}

function setup_environment() {
  function install_sdk() {
    echo "Installing cmdline-tools..."
    if [ -e commandlinetools-linux-9477386_latest.zip ]; then
      echo "cmdline-tool zip file already exists."
    else
      echo "Downloading Android SDK..."
      $puser -- curl -OL https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    fi
    # Your installation commands here
    $puser -- unzip commandlinetools-linux-9477386_latest.zip
    $puser -- mkdir $CMDLINE
    $puser -- mv cmdline-tools $CMDLINE/tools
    $puser -- sed -i "s#export PATH=.*#&:$CMDLINE/bin#g" /etc/profile.d/termux-proot.sh
    $puser -- sed -i "s#export PATH=.*#&:$PTOOLS/bin#g" /etc/profile.d/termux-proot.sh
    echo Installing A30.....
    $puser -- sdkmanager "platform-tools" "platforms;android-30"
    #$puser -- yes | sdkmanager --licenses
    $puser -- flutter config --android-sdk ~/Android
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
check_deps "proot-distro" "sed" "git" 
install_arch
setting_up_arch
add_normal_user
install_flutter_as_normal_user
nvim_config_installation
setup_environment

echo "Installation Success"
echo "Login Proot-> $ $puser"
