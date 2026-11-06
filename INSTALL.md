# 📖 Installation & User Guide: Proxy 5G for macOS

This guide provides comprehensive instructions for installing, configuring, troubleshooting, and deploying **Proxy 5G** on macOS.

---

## 📑 Table of Contents
1. [System Requirements](#1-system-requirements)
2. [Method 1: Build from Source (Recommended)](#2-method-1-build-from-source-recommended)
3. [Method 2: Install Pre-built Release (.zip)](#3-method-2-install-pre-built-release-zip)
4. [Configuring Your iPhone (Proxy Sharing)](#4-configuring-your-iphone-proxy-sharing)
5. [Using Proxy 5G on Your Mac](#5-using-proxy-5g-on-your-mac)
6. [Launch at Login Configuration](#6-launch-at-login-configuration)
7. [Troubleshooting & Emergency Reset](#7-troubleshooting--emergency-reset)
8. [CI/CD Workflow & Creating Releases](#8-cicd-workflow--creating-releases)

---

## 1. System Requirements

* **Mac Requirements:**
  * macOS Monterey 12.0 or later (macOS Sonoma, Sequoia supported).
  * Architecture: Apple Silicon (M1, M2, M3, M4).
  * Xcode Command Line Tools (pre-installed on macOS, or run `xcode-select --install`).
* **iPhone Requirements:**
  * Cellular data with active connection (e.g. SNI data package).
  * A VPN application supporting **Proxy Sharing** (Shadowrocket, Sing-box, Loon, Quantumult X, Stash).

---

## 2. Method 1: Build from Source (Recommended)

1. Clone or navigate to the repository:
   ```bash
   cd ~/code/phongng255/Proxy5G
   ```

2. Run the automated build script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

**What the script does automatically:**
1. Compiles `main.swift` with maximum optimization (`-O`) for ARM64 macOS.
2. Creates the `/Applications/Proxy5G.app` bundle with `Info.plist` and `AppIcon.icns`.
3. Performs ad-hoc code signing (`codesign`).
4. Automatically launches the application into your Menu Bar.

---

## 3. Method 2: Install Pre-built Release (.zip)

1. Download `Proxy5G-macOS-arm64.zip` from [GitHub Releases](https://github.com/phongng255/Proxy5G/releases).
2. Unzip the file to extract `Proxy5G.app`.
3. Move `Proxy5G.app` into your `/Applications` directory.
4. Launch the application via Spotlight (`Cmd + Space` $\rightarrow$ type `Proxy5G` $\rightarrow$ press **Enter**).

### Bypassing Gatekeeper (Unidentified Developer)
If macOS displays an alert saying *"Proxy5G cannot be opened because it is from an unidentified developer"*, clear the quarantine attribute by running:
```bash
xattr -cr /Applications/Proxy5G.app
```
Then open the app again.

---

## 4. Configuring Your iPhone (Proxy Sharing)

1. **Connect VPN:** Open **Shadowrocket** and turn on your VPN tunnel (ensure your iPhone can access YouTube/Google).
2. **Enable Personal Hotspot:** In iOS **Settings** $\rightarrow$ **Personal Hotspot** $\rightarrow$ Turn on **Allow Others to Join**.
3. **Turn on Proxy Sharing:**
   * In **Shadowrocket**, tap **Settings (⚙️ icon)** at the bottom.
   * Tap **Proxy Sharing** $\rightarrow$ Switch to **Enabled**.
   * Note the displayed IP and Port (default: `172.20.10.1`, Port: `1082`).

---

## 5. Using Proxy 5G on Your Mac

Once running, the **5G** icon will appear in the top-right Menu Bar:

### 5.1. Connecting
* Click the **5G** Menu Bar icon.
* Click the main toggle switch or click **Turn On All**.
* Your Mac is now browsing through the iPhone's VPN tunnel!

### 5.2. Disconnecting
* Click the **5G** Menu Bar icon $\rightarrow$ Click **Turn Off All** (or toggle off).
* Your Mac immediately returns to standard direct Wi-Fi networking.

### 5.3. Customizing Server Host & Port
* If your hotspot IP or proxy port differs from `172.20.10.1:1082`:
  1. Click the **5G** Menu Bar icon.
  2. Click the gear icon **⚙️** next to **Proxy 5G**.
  3. Enter your custom **Host / IP** and **Port**.
  4. Click **Save & Apply** (values are saved persistently in `UserDefaults`).
  5. Click **Reset Default** anytime to restore `172.20.10.1:1082`.

---

## 6. Launch at Login Configuration

To have Proxy 5G automatically launch when your Mac boots:

1. Open **System Settings** $\rightarrow$ **General** $\rightarrow$ **Login Items & Extensions**.
2. Under **Open at Login**, click the **`+`** button.
3. Select `/Applications/Proxy5G.app` and click **Open**.

---

## 7. Troubleshooting & Emergency Reset

### No internet after turning on Proxy 5G:
* Verify that **Proxy Sharing** is enabled in Shadowrocket on your iPhone.
* Check that your iPhone screen is active and the VPN switch is green.
* Make sure your Mac is connected to the iPhone via Wi-Fi Hotspot or USB cable.

### Emergency Terminal Reset:
If the app was forcefully closed while proxy settings were active, run this command in Terminal to restore normal networking:
```bash
networksetup -setwebproxystate "Wi-Fi" off
networksetup -setsecurewebproxystate "Wi-Fi" off
networksetup -setwebproxystate "iPhone USB" off
networksetup -setsecurewebproxystate "iPhone USB" off
```

---

## 8. CI/CD Workflow & Creating Releases

The repository includes a GitHub Actions workflow (`.github/workflows/build-release.yml`):

### Automated CI
Pushes and Pull Requests to the `main` branch trigger an automated build on an Apple Silicon runner (`macos-14`), validating the Swift codebase and generating a downloadable build artifact.

### Automated Release (CD)
To publish a new official release with an attached `.zip` download:

```bash
# Tag a new version
git tag v1.0.0

# Push the tag to GitHub
git push origin v1.0.0
```

GitHub Actions will automatically build, package, and publish the GitHub Release.
