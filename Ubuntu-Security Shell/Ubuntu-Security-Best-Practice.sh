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

    # 🔥 Firewall status
    if ! sudo ufw status | grep -q "Status: active"; then
        issues_found+=("⚠️ Firewall is disabled.")
    fi
    # 🔥 Check Firewall (CSF)
    csf_status=$(sudo csf -s | grep -q "Firewall Status: Enabled" && echo "enabled")
    if [[ -z "$csf_status" ]]; then
        issues_found+=("⚠️ CSF Firewall is disabled.")
    fi

    # 🔥 Check SELinux Status
    selinux_status=$(sestatus | grep "SELinux status" | awk '{print $3}')
    if [[ "$selinux_status" != "enabled" ]]; then
        issues_found+=("⚠️ SELinux is not enforced.")
    fi

   # 🔥 Check SSH security settings
    ssh_status=$(grep -E 'PermitRootLogin|PasswordAuthentication' /etc/ssh/sshd_config)
    if [[ "$ssh_status" == *"yes"* ]]; then
        issues_found+=("⚠️ SSH root login or password authentication is enabled.")
    fi

    # Malware scan
    sudo chkrootkit | grep "INFECTED" && issues_found+=("⚠️ Potential rootkit detected!")

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
                "⚠️ CSF Firewall is disabled.")
                    echo "🚀 Enabling CSF Firewall..."
                    sudo csf -e
                    ;;
                "⚠️ SELinux is not enforced.")
                    echo "🚀 Enforcing SELinux..."
                    sudo setenforce 1
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

# Function to install SELinux & CSF if missing
install_security_tools() {
    echo "🔧 Checking for required security tools..."
    
    # Install CSF if not present
    if ! command -v csf &> /dev/null; then
        echo "🚀 Installing CSF Firewall..."
        cd /usr/src
        wget https://download.configserver.com/csf.tgz
        tar -xzf csf.tgz
        cd csf
        sudo bash install.sh
    fi
    
    # Install SELinux utilities if missing
    if ! command -v sestatus &> /dev/null; then
        echo "🚀 Installing SELinux utilities..."
        sudo apt install selinux-utils policycoreutils -y
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
install_security_tools
check_system
#apply_fixes
#send_report
#schedule_check