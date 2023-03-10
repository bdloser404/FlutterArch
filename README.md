
# FlutterArch

using this script you can install  most latest version of __Flutter__ on your ARM64 / aarch64 device through Termux. 
Additionally , it will automatically configure Neovim for Flutter Development .

the script plugin draws inspiration from [@hax4us](https://github.com/Hax4us/flutter_in_termux/releases/) and [@flutterFocus](https://github.com/flutterfocus/development_nvim)

### Support

- Termux
- Respberry pi ( coming )

### Installation
#### Run Script Manually

- Clone the project

```bash
  git clone --depth=1 https://github.com/bdloser404/FlutterArch.git ~/YourFlutter
```

- Go to the project directory

```bash
  cd YourFlutter
```

- give execute permission 

```bash
  chmod +x install.sh
```

- executing script 

```bash
 ./install.sh
```

### Run Your First Flutter App

<details><summary>How To Use</summary>

- login to archlinux 

```bash
proot-distro login --user yourname archlinux
```
- create flutter app 

```bash
flutter create myapp
```
- run your app 

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8000

```

</details>
