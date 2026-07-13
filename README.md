# Raylib Template Software Development Kit V1.0
Source code repository for the Raylib Template SDK, which provides Windows ↔ Linux cross-compilation support for RaylibTemplate.  

## 🚧 In Development
![Windows](https://img.shields.io/badge/Windows-green)
![Linux](https://img.shields.io/badge/Linux-red)
![Web](https://img.shields.io/badge/Web-yellow)

## Toolchain
RTSDK uses Zig as the native C/C++ compiler toolchain for cross-compilation between Windows and Linux.  
Web builds are powered by Emscripten.  
All required dependencies and toolchains are automatically downloaded and configured through the Setup.sh and Setup.bat scripts.  

## Third-Party Software
This project includes the original Raylib(6.1-dev) source code.  
Raylib is developed by **Ramon Santamaria** and **contributors** and is distributed under the zlib/libpng license.  
The Source/Raylib directory contains the original Raylib source code and its respective license.  

## Linux Build Dependencies
The following packages are required only to build RTSDK on Linux.
They are not required to use the generated RaylibTemplate SDK.

### Debian / Ubuntu

```bash
sudo apt install build-essential libx11-dev libgl1-mesa-dev
```

### Fedora

```bash
sudo dnf install @development-tools libX11-devel mesa-libGL-devel
```

### Arch Linux

```bash
sudo pacman -S base-devel libx11 mesa
```

# **Note**
>
> Due to Linux system library dependencies, RTSDK cannot currently build Linux targets when running on Windows.  
> For full RTSDK development and packaging (Windows, Linux, and Web), Linux is the recommended host platform.
>
> This limitation only affects RTSDK development.  
> The generated RaylibTemplate SDK works normally on both Windows and Linux, allowing Game Developers to build their games for all supported target platforms.
