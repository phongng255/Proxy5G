# ⚡ Proxy 5G for macOS

[![Build & Release](https://github.com/phongng255/Proxy5G/actions/workflows/build-release.yml/badge.svg)](https://github.com/phongng255/Proxy5G/actions/workflows/build-release.yml)
[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Apple Silicon](https://img.shields.io/badge/Architecture-Apple%20Silicon%20(arm64)-success)](https://www.apple.com/mac/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A lightweight, native macOS Menu Bar application written in **Swift & SwiftUI** designed to route your Mac's internet traffic through an **iPhone's 5G / 4G Proxy Sharing tunnel** (via Shadowrocket, Sing-box, Loon, Quantumult X, or Stash) with a single click.

---

## 📌 Problem & Solution

### The Problem
1. **iOS Personal Hotspot Limitation:** When an iPhone connects to a VPN using zero-rated carrier data packages (e.g., SNI bug packets for TikTok, YouTube, etc.), Apple's Personal Hotspot **bypasses the local VPN tunnel**. A connected Mac receives raw cellular data that lacks a standard quota, resulting in no internet connectivity.
2. **Enterprise Security Restrictions on macOS:** On managed corporate MacBooks equipped with endpoint protection (such as **Trellix Network Extension**, ForeScout, or Microsoft Intune), running third-party VPN clients locally often triggers routing collisions or blocks network extensions entirely.

### The Solution
* The iPhone runs Shadowrocket with **Proxy Sharing** enabled, acting as an internal HTTP/HTTPS proxy server (default: `172.20.10.1:1082`).
* **Proxy 5G** runs quietly on the macOS Menu Bar. With one click, it assigns macOS system proxy settings for **Wi-Fi** and **iPhone USB** to route directly through the iPhone.
* **Result:** Fast, unblocked internet on your Mac without triggering enterprise VPN restrictions or requiring complex command-line configurations.

---

## ✨ Features

- 🎛️ **Native macOS Control Center UI:**
  - Modern Popover card with Apple-standard styling.
  - Minimalist monochrome Menu Bar icon (`personalhotspot`) with clean white `5G` text matching macOS system aesthetics.
- ⚙️ **Customizable Host & Port:**
  - Defaults to `172.20.10.1:1082`.
  - Expandable ⚙️ Settings panel to customize server IP and port with automatic persistence in `UserDefaults`.
  - One-click "Reset Default" button.
- 🔌 **Dual Network Interface Support:**
  - Individual toggles for both **Wi-Fi** (wireless hotspot) and **iPhone USB** (tethered cable connection).
- ⚡ **Master One-Click Controls:**
  - "Turn On All" and "Turn Off All" action buttons for instant switching.
- 🚀 **Zero Dependencies & Ultra-Lightweight:**
  - Compiled as a native ARM64 Apple Silicon binary (`swiftc`).
  - No background CPU overhead or battery drain.

---

## 🛠️ Project Structure

```text
Proxy5G/
├── .github/
│   └── workflows/
│       └── build-release.yml   # CI/CD: Automated build, test, and GitHub Release pipeline
├── main.swift                  # Core Swift application (AppKit, SwiftUI & Network Controller)
├── Info.plist                  # macOS Application bundle metadata (LSUIElement: Menu Bar App)
├── build.sh                    # Automated build, package, and installation script
├── Resources/
│   └── AppIcon.icns            # macOS application icon
├── INSTALL.md                  # Comprehensive installation & troubleshooting guide
├── LICENSE                     # MIT Open Source License
└── README.md                   # Project documentation
```

---

## 🚀 Quick Start & Installation

### Option 1: Automated Build Script (Recommended)

Clone the repository and run the build script:

```bash
git clone https://github.com/phongng255/Proxy5G.git
cd Proxy5G
chmod +x build.sh
./build.sh
```

The script compiles the application, packages it into `/Applications/Proxy5G.app`, signs it ad-hoc, and launches it directly onto your Menu Bar.

### Option 2: Download Pre-built Release (.zip)

1. Download the latest `Proxy5G-macOS-arm64.zip` from [GitHub Releases](https://github.com/phongng255/Proxy5G/releases).
2. Extract and drag `Proxy5G.app` into your `/Applications` folder.
3. Open Spotlight (`Cmd + Space`), type `Proxy5G`, and press **Enter**.
4. *(If prompted by Gatekeeper about unidentified developer)*, run:
   ```bash
   xattr -cr /Applications/Proxy5G.app
   ```

---

## 📖 How to Use

### 1. Setup on iPhone
1. Open **Shadowrocket** (or your VPN app) and connect to your VPN node.
2. Go to **Settings** $\rightarrow$ **Proxy Sharing** $\rightarrow$ Toggle **Enabled** (note IP `172.20.10.1`, Port `1082`).
3. Enable **Personal Hotspot** in iOS Settings (or plug your iPhone into your Mac via USB cable).

### 2. Connect on Mac
1. Connect your Mac to the iPhone's Wi-Fi Hotspot or via USB cable.
2. Click the **5G** icon in the Menu Bar.
3. Click the switch or **Turn On All** to activate the proxy.
4. Enjoy high-speed internet routed seamlessly through your iPhone!
5. When finished, click **Turn Off All** to return to your standard Wi-Fi network.

---

## 🤖 CI/CD Pipeline

The project includes a GitHub Actions workflow (`.github/workflows/build-release.yml`) running on macOS Apple Silicon (`macos-14`):
- **On Push/PR to `main`:** Automatically compiles the Swift source code and generates a distributable `Proxy5G-macOS-arm64.zip` artifact.
- **On Version Tag (`v*`):** Automatically creates a GitHub Release with release notes and the `.zip` binary attached.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

Developed with ❤️ by **Phong Do** ([@phongng255](https://github.com/phongng255)).
