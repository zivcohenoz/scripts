#!/bin/bash

# Install required packages if missing
echo "Checking required packages..."
sudo apt update
sudo apt install -y ufw chkrootkit clamav mailutils sqlite3

# Start ClamAV service if needed
sudo systemctl start clamav-freshclam

check_system() {
    echo "🔍 Checking system best practices..."
    issues_found=()

    # Firewall status
    if ! sudo ufw status | grep -q "Status: active"; then
        issues_found+=("⚠️ Firewall is disabled.")
    fi

    # SSH Hardening
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        issues_found+=("⚠️ Root login over SSH is enabled.")
    fi
    if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
        issues_found+=("⚠️ SSH password authentication is enabled.")
    fi

    # Malware scan
    sudo chkrootkit | grep -i "INFECTED" && issues_found+=("⚠️ Potential rootkit detected!")

    # Outdated packages
    outdated=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
    if [[ "$outdated" -gt 0 ]]; then
        issues_found+=("⚠️ There are outdated packages that need updating.")
    fi

    # Log results
    echo "Logging findings..."
    echo "${issues_found[@]}" | tee ~/system_health_report.log

    # Display results
    if [[ ${#issues_found[@]} -gt 0 ]]; then
        echo "🚨 Issues Found:"
        for issue in "${issues_found[@]}"; do
            echo "$issue"
        done
    else
        echo "✅ Your system is following best practices!"
    fi
}

apply_fixes() {
    echo -e "\nWould you like to fix detected issues? (yes/no)"
    read -r user_choice
    if [[ "$user_choice" == "yes" ]]; then
        for issue in "${issues_found[@]}"; do
            case $issue in
                "⚠️ Firewall is disabled.")
                    echo "🚀 Enabling firewall..."
                    sudo ufw enable
                    ;;
                "⚠️ Root login over SSH is enabled.")
                    echo "🚀 Disabling root login..."
                    sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
                    ;;
                "⚠️ SSH password authentication is enabled.")
                    echo "🚀 Enforcing SSH key authentication..."
                    sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
                    ;;
                "⚠️ Potential rootkit detected!")
                    echo "🚀 Running ClamAV deep scan..."
                    sudo clamscan -r / --quiet
                    ;;
                "⚠️ There are outdated packages that need updating.")
                    echo "🚀 Updating packages..."
                    sudo apt update && sudo apt upgrade -y
                    ;;
            esac
        done
        echo "✅ Fixes applied!"
    else
        echo "❌ No changes made."
    fi
}
send_report() {
    echo -e "\n📡 Sending system health report..."
    cat ~/system_health_report.log | mail -s "Ubuntu Security Report" your@email.com
}

schedule_check() {
    echo "Scheduling daily security check..."
    echo "0 3 * * * ~/system_check.sh" | crontab -
}

## Uncomment what you want to run:
check_system
#apply_fixes
#send_report
#schedule_check