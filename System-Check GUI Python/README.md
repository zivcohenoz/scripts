# Linux-Scripts

## Ubuntu System-Security-Check GUI Python:
### 💡 Features in the Script:
✅ PyQt GUI Interface for a clean, user-friendly experience
✅ Real-time system monitoring (CPU, memory, disk usage)
✅ Security best practices checker (Firewall, SSH, malware scan)
✅ Automated fixes (let the user decide which ones to apply)
✅ Scheduled system checks (via cron)
✅ Remote system scanning (manage multiple Ubuntu machines)
✅ Exportable reports (HTML/PDF for tracking)

### 🔥 Step 1: Install Dependencies
Before running the script, install PyQt and other dependencies:
```bash
sudo apt update && sudo apt install -y python3-pip
pip3 install pyqt5 psutil pandas clamav
```

### 🚀 How to Run
- Copy & save the script as system_check.py.
- Run the script using:

```bash
python3 system_check.py
```
- The GUI will open, letting you scan your system and apply fixes!

