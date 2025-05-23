import sys
import subprocess
import psutil
import os
from PyQt5.QtWidgets import QApplication, QLabel, QVBoxLayout, QPushButton, QWidget, QTextEdit

class SystemCheckApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()
    
    def initUI(self):
        self.setWindowTitle("Ubuntu Security & Optimization Tool")
        self.setGeometry(300, 200, 500, 400)

        layout = QVBoxLayout()

        self.status_label = QLabel("🔍 System Check Report:")
        layout.addWidget(self.status_label)

        self.result_box = QTextEdit()
        self.result_box.setReadOnly(True)
        layout.addWidget(self.result_box)

        self.scan_button = QPushButton("Run Security Check")
        self.scan_button.clicked.connect(self.run_security_check)
        layout.addWidget(self.scan_button)

        self.fix_button = QPushButton("Apply Fixes")
        self.fix_button.clicked.connect(self.apply_fixes)
        layout.addWidget(self.fix_button)

        self.setLayout(layout)

    def run_security_check(self):
        result_text = ""

        # Check firewall status
        firewall_status = subprocess.getoutput("sudo ufw status | grep -o 'Status: active'")
        if not firewall_status:
            result_text += "⚠️ Firewall is disabled.\n"

        # Check SSH security settings
        ssh_status = subprocess.getoutput("grep -E 'PermitRootLogin|PasswordAuthentication' /etc/ssh/sshd_config")
        if "yes" in ssh_status:
            result_text += "⚠️ SSH root login or password authentication is enabled.\n"

        # Check for outdated packages
        outdated = subprocess.getoutput("apt list --upgradable 2>/dev/null | wc -l")
        if int(outdated) > 1:
            result_text += f"⚠️ {outdated} outdated packages need updating.\n"

        # Malware scan
        malware_scan = subprocess.getoutput("sudo clamscan -r / --quiet | grep FOUND")
        if malware_scan:
            result_text += "⚠️ Malware detected!\n"

        if not result_text:
            result_text = "✅ System is following best practices!"
        
        self.result_box.setText(result_text)

    def apply_fixes(self):
        subprocess.run(["sudo", "ufw", "enable"])
        subprocess.run(["sudo", "sed", "-i", "s/^PermitRootLogin yes/PermitRootLogin no/", "/etc/ssh/sshd_config"])
        subprocess.run(["sudo", "sed", "-i", "s/^PasswordAuthentication yes/PasswordAuthentication no/", "/etc/ssh/sshd_config"])
        subprocess.run(["sudo", "systemctl", "restart", "ssh"])
        subprocess.run(["sudo", "apt", "update"])
        subprocess.run(["sudo", "apt", "upgrade", "-y"])

        self.result_box.append("\n✅ Fixes Applied!")

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = SystemCheckApp()
    window.show()
    sys.exit(app.exec_())