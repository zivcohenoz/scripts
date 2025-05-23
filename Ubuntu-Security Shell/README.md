# Linux-Scripts

## Ubuntu Security Checks - Shell Script

🔒 Security Enhancements:

✅ Rootkit & malware scanning (Chkrootkit, ClamAV)

✅ Audit sensitive file permissions

✅ Harden SSH security (disable root login, enforce key authentication)

✅ Check for open ports & unnecessary services

✅ Verify SELinux/AppArmor configurations


⚙️ System Optimization:

✅ Monitor CPU, memory, disk usage

✅ Detect outdated packages & vulnerabilities

✅ Scan logs for system errors

✅ Parallel execution for speed

📡 Smart Integration Features:

✅ Email notifications when issues are found

✅ Log issues into a database (SQLite/PostgreSQL)

✅ Enable remote auditing for multiple systems

✅ Generate a full HTML/PDF report for visibility

🛠️ Usability Enhancements:

✅ Interactive CLI menu instead of simple yes/no

✅ Scheduled automatic checks via cron jobs

✅ Color-coded output for better readability


### How To Run:
- Open a terminal and run the script:
```bash
chmod +x Ubuntu-Security-Best-Practice.sh
./Ubuntu-Security-Best-Practice.sh
```

** Uncomment in script what you want (last 4 lines): **
```bash
# check_system
# apply_fixes
# send_report
# schedule_check
```