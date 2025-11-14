# 🖱️ Mouse Keeper

> A lightweight, intelligent mouse jiggler for Windows that prevents your computer from going idle or locking.

[![Python](https://img.shields.io/badge/Python-3.7+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Mouse Keeper runs silently in your system tray and automatically jiggles your mouse only when you're inactive. It's smart enough to pause when you're working and resume when you step away.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎯 **Smart Detection** | Only activates after user inactivity - won't interfere with your work |
| 🎨 **Visual Feedback** | Color-coded tray icon shows current state at a glance |
| ⚙️ **Configurable** | Choose from 5s, 10s, 30s, or 60s intervals via tray menu |
| 🚀 **Auto-Start** | Automatically adds itself to Windows startup |
| 📝 **Advanced Logging** | Optional logging with easy access from tray menu |
| 💻 **System Tray** | Runs quietly - no console window cluttering your taskbar |

### Icon States

| Icon | State | Meaning |
|------|-------|---------|
| 🔴 Red Dot | Paused | You're active - jiggler is paused |
| ⚪ White "M" | Idle | Countdown timer running |
| 🟢 Green Dot | Active | Moving mouse now |

---

## 🚀 Quick Start

### Option 1: Run as Executable (Recommended)

**One-time setup:**

1. **Install Python** from [python.org](https://www.python.org/)

2. **Install dependencies:**
   ```powershell
   pip install pyautogui pystray winshell pillow pyinstaller
   ```

3. **Build the executable:**
   ```powershell
   pyinstaller --onefile --windowed MouseKeeper.py
   ```

4. **Run once as admin:**
   - Right-click `dist/MouseKeeper.exe` → "Run as administrator"
   - This creates the startup shortcut
   - Done! It will now start automatically with Windows

### Option 2: Run as Python Script

1. **Create virtual environment:**
   ```powershell
   python -m venv .venv
   .venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```powershell
   pip install pyautogui pystray winshell pillow
   ```

3. **Run silently:**
   ```powershell
   pythonw.exe MouseKeeper.py
   ```

---

## 📖 Usage

Once running, Mouse Keeper operates from your system tray:

- **Right-click** the tray icon to access settings
- **Set Interval** to choose inactivity threshold
- **Logging** submenu to enable/view logs
- **Exit** to stop the application

---

## 🛠️ Development

### VS Code Setup

Create `.vscode/launch.json` for debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug MouseKeeper",
      "type": "python",
      "request": "launch",
      "program": "${workspaceFolder}/MouseKeeper.py",
      "console": "integratedTerminal",
      "justMyCode": true
    }
  ]
}
```

### Recommended Extensions

- **Black** - Code formatter (`pip install black`)
- **Flake8** - Linter (`pip install flake8`)

---

## 📋 Requirements

- **OS:** Windows 7+
- **Python:** 3.7 or higher
- **Dependencies:**
  - `pyautogui` - Mouse control
  - `pystray` - System tray functionality
  - `winshell` - Windows startup integration
  - `pillow` - Icon generation

---

## 📝 Logging

Logs are stored in `%TEMP%\MouseKeeper\MouseKeeper.log`

**Access logs via tray menu:**
- Enable/Disable logging
- View current log file
- Open log folder

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit pull requests

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

This tool is intended for legitimate use cases like preventing system sleep during presentations or downloads. Please use responsibly and in accordance with your organization's policies.

---

<div align="center">

**Made with ❤️ for productivity**

⭐ Star this repo if you find it useful!

</div>


