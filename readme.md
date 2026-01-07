# macOS Sleep Manager v4.6 "Full Transparency"

macOS Sleep Manager is an advanced utility for MacBook designed to drastically reduce battery consumption during standby. Unlike macOS's standard management, this tool forces the system into a Deep Freeze state and monitors energy efficiency both during sleep and active use.

## ✨ Key Features (v4.6)

### 🧊 Hard Deep Freeze
- **Smart Hibernation**: Balance between instant wake (within 60 min) and total hibernation (after 1 hour), where RAM is powered off and saved to disk for 0% consumption.

- **Zero Dark Wakes**: Disables tcpkeepalive during sleep. Prevents the Mac from waking every 15 minutes to search for Wi-Fi networks or download notifications while the lid is closed.

- **Assertion Cleaner**: Force-closes blocking processes (such as print services or suspended updates) that prevent the kernel from entering deep standby.

### 🕵️‍♂️ "Black Box" Monitoring (Full Transparency)
- **Wake Tracking**: New in v4.6. The script records how long the Mac stays on and how much battery is consumed during actual use.

- **Sleep Delta**: Mathematical calculation of charge loss during suspension. If you read DELTA: 0%, the system was perfectly efficient.

- **Driver Freeze**: Logitech drivers or security software (Malwarebytes) are "frozen" (SIGSTOP) at sleep and "unfrozen" (SIGCONT) at wake, avoiding restart loops.

## 🚀 Installation

**Requirements**: Make sure you have sleepwatcher installed:

```bash
brew install sleepwatcher
```

**Clone & Install**:

```bash
git clone https://github.com/dedandy/macos-sleep-manager.git
cd macos-sleep-manager
chmod +x install.sh
./install.sh
```

**Activation**:

```bash
source ~/.zshrc
```

## 🛠 Available Commands

### sleeplog
The main dashboard. Shows the latest Sleep/Wake cycles, indicating:
- Battery at close/open
- Awake time
- Battery used
- Sleep Delta

### sleeplog stats
Generates an efficiency report that sums total usage time and average consumption, helping you understand if battery drops are due to active use or standby issues.

### sleepconf
Opens the interactive editor to manage:
- **Whitelist**: Apps that should never be closed (e.g., Messaging)
- **Heavy Apps**: Apps that are killed at sleep and reopened only if the charger is connected
- **CPU Threshold**: Sensitivity for automatic termination of runaway processes

## 🔐 Security and Permissions

For proper functionality, macOS requires sleepwatcher to have elevated permissions:

1. Go to **System Settings > Privacy & Security > Full Disk Access**
2. Make sure sleepwatcher is enabled

If logs don't update, the installer automatically performs digital signing, but you can force it with:

```bash
sudo codesign --force --deep --sign - $(which sleepwatcher)
```

## 🗑 Uninstallation

To restore your Mac to original factory settings (restoring system timers and standard network functions):

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## 📄 License

Distributed under the MIT License. Free to use and modify.

Developed for those who demand their Mac doesn't lose even 1% charge overnight.