**🛡️ Snort IDS**

**Complete Installation Guide**

_Intrusion Detection System with Multi-Channel Alerts_

Ubuntu Server • Kali Linux • Snort • Slack • Grafana

Author: Moustapha Damdele | IT Specialist | CompTIA Security+

# **📋 Project Overview**

This guide covers the complete installation and configuration of a Network Intrusion Detection System (IDS) based on Snort on Ubuntu Server, with alert integration via Email (Postfix), Slack, and Grafana.

Environment:

- 🖥️ Ubuntu Server 22.04 LTS - Target machine / IDS
- 💀 Kali Linux 2024 - Attacker machine (simulation)
- 📧 Postfix - Email alert management
- 💬 Slack - Real-time messaging alerts
- 📊 Grafana - Graphical alert dashboard

# **🛠️ Tools & Technologies**

| **Tool**      | **Role**                   | **Version** |
| ------------- | -------------------------- | ----------- |
| Snort         | Intrusion Detection System | 2.9.20      |
| DAQ           | Network Data Acquisition   | 2.0.7       |
| Ubuntu Server | Target Machine OS          | 22.04 LTS   |
| Kali Linux    | Attacker Machine OS        | 2024        |
| Postfix       | Email Alert Management     | Latest      |
| Slack         | Real-time Messaging Alerts | API v2      |
| Grafana       | Graphical Visualization    | Latest      |

# **⚙️ Step 1 - System Prerequisites**

Update the system and install all required dependencies:

sudo apt update && sudo apt upgrade -y

sudo apt install -y build-essential libpcap-dev libpcre3-dev \\

libdumbnet-dev bison flex zlib1g-dev liblzma-dev \\

openssl libssl-dev libnghttp2-dev libluajit-5.1-dev \\

libunwind-dev pkg-config autoconf libtool \\

git curl wget python3 python3-pip

# **📦 Step 2 - Install DAQ**

DAQ (Data Acquisition) is required by Snort to capture network packets:

cd /tmp

wget <https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz>

tar -xvzf daq-2.0.7.tar.gz

cd daq-2.0.7

./configure

make

sudo make install

sudo ldconfig

# **🔍 Step 3 - Install Snort**

cd /tmp

wget <https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz>

tar -xvzf snort-2.9.20.tar.gz

cd snort-2.9.20

./configure --enable-sourcefire

make

sudo make install

sudo ldconfig

\# Verify installation

snort --version

# **📝 Step 4 - Configure Snort**

## **Create Required Directories**

sudo mkdir -p /etc/snort/rules

sudo mkdir -p /var/log/snort

sudo mkdir -p /usr/local/lib/snort_dynamicrules

\# Copy configuration files

sudo cp /tmp/snort-2.9.20/etc/\*.conf /etc/snort/

sudo cp /tmp/snort-2.9.20/etc/\*.map /etc/snort/

\# Create rule files

sudo touch /etc/snort/rules/local.rules

sudo touch /etc/snort/rules/white_list.rules

sudo touch /etc/snort/rules/black_list.rules

\# Set permissions

sudo chmod -R 5775 /etc/snort /var/log/snort

sudo chown -R snort:snort /etc/snort /var/log/snort

## **Edit snort.conf**

Open the configuration file:

sudo nano /etc/snort/snort.conf

Set these values:

ipvar HOME_NET 192.168.1.0/24

ipvar EXTERNAL_NET !\$HOME_NET

var RULE_PATH /etc/snort/rules

var SO_RULE_PATH /etc/snort/so_rules

var PREPROC_RULE_PATH /etc/snort/preproc_rules

var WHITE_LIST_PATH /etc/snort/rules

var BLACK_LIST_PATH /etc/snort/rules

include \$RULE_PATH/local.rules

# **📜 Step 5 - Snort Detection Rules**

Edit the local rules file:

sudo nano /etc/snort/rules/local.rules

Add the following rules:

\# Detect ICMP Ping

alert icmp any any -> \$HOME_NET any (msg:"ICMP Ping Detected"; sid:1000001; rev:1;)

\# Detect Port Scanning

alert tcp any any -> \$HOME_NET any (msg:"Port Scan Detected"; flags:S;

threshold:type threshold, track by_src, count 5, seconds 10; sid:1000002; rev:1;)

\# Detect SSH Brute Force Attempt

alert tcp any any -> \$HOME_NET 22 (msg:"SSH Connection Attempt"; flags:S; sid:1000003; rev:1;)

\# Detect Suspicious HTTP Traffic

alert tcp any any -> \$HOME_NET 80 (msg:"Suspicious HTTP Traffic"; sid:1000004; rev:1;)

\# Detect FTP Attack

alert tcp any any -> \$HOME_NET 21 (msg:"FTP Connection Attempt"; flags:S; sid:1000005; rev:1;)

Test the configuration:

sudo snort -T -c /etc/snort/snort.conf -i eth0

# **📧 Step 6 - Email Alerts (Postfix)**

## **Install Postfix**

sudo apt install postfix mailutils -y

\# Test email sending

echo "Snort Alert!" | mail -s "🚨 Intrusion Detected" <admin@example.com>

## **Alert Script**

Create the alert script:

sudo nano /usr/local/bin/snort-email-alert.sh

# !/bin/bash

LOG="/var/log/snort/alert"

EMAIL="<admin@example.com>"

tail -f \$LOG | while read line; do

echo "\$line" | mail -s "🚨 SNORT ALERT" \$EMAIL

done

sudo chmod +x /usr/local/bin/snort-email-alert.sh

# **💬 Step 7 - Slack Alerts**

## **Create Slack Webhook**

- Go to api.slack.com/apps
- Create a new app → Incoming Webhooks → Activate
- Copy the Webhook URL

## **Alert Script**

sudo nano /usr/local/bin/snort-slack-alert.sh

# !/bin/bash

SLACK_WEBHOOK="<https://hooks.slack.com/services/YOUR/WEBHOOK/URL>"

LOG="/var/log/snort/alert"

LAST_FILE="/tmp/last_snort_alert.txt"

tail -f \$LOG | while read ALERT; do

if \[ "\$ALERT" != "\$(cat \$LAST_FILE 2>/dev/null)" \]; then

echo "\$ALERT" > \$LAST_FILE

MESSAGE="🚨 \*SNORT ALERT\*\\n\\\`\\\`\\\`\$ALERT\\\`\\\`\\\`"

curl -s -X POST -H "Content-type: application/json" \\

\--data "{\\"text\\":\\"\$MESSAGE\\"}" \\

\$SLACK_WEBHOOK

fi

done

sudo chmod +x /usr/local/bin/snort-slack-alert.sh

# **📊 Step 8 - Grafana Dashboard**

## **Install Grafana**

sudo apt install -y software-properties-common

sudo add-apt-repository "deb <https://packages.grafana.com/oss/deb> stable main"

wget -q -O - <https://packages.grafana.com/gpg.key> | sudo apt-key add -

sudo apt update && sudo apt install grafana -y

\# Start Grafana

sudo systemctl enable grafana-server

sudo systemctl start grafana-server

Access Grafana at: <http://localhost:3000>

Default credentials: admin / admin

## **Configure Snort Data Source**

- Login to Grafana → Configuration → Data Sources
- Add data source → select the Snort log file path
- Import dashboard → use grafana-dashboard.json

# **🔄 Step 9 - Run Snort as System Service**

sudo nano /etc/systemd/system/snort.service

\[Unit\]

Description=Snort IDS Service

After=network.target

\[Service\]

Type=simple

User=root

ExecStart=/usr/local/bin/snort -D -c /etc/snort/snort.conf -i eth0 -l /var/log/snort

Restart=always

RestartSec=10

\[Install\]

WantedBy=multi-user.target

sudo systemctl daemon-reload

sudo systemctl enable snort

sudo systemctl start snort

sudo systemctl status snort

# **🧪 Step 10 - Penetration Tests from Kali Linux**

\# Port scanning with Nmap

nmap -sS 192.168.1.100

\# Ping flood

ping -f 192.168.1.100

\# Aggressive scan

nmap -A -T4 192.168.1.100

\# SSH brute force test

hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.100

# **🔍 Useful Daily Commands**

| **Command**                            | **Description**       |
| -------------------------------------- | --------------------- |
| sudo tail -f /var/log/snort/alert      | View real-time alerts |
| sudo systemctl status snort            | Check Snort status    |
| sudo systemctl restart snort           | Restart Snort         |
| sudo snort -T -c /etc/snort/snort.conf | Test Snort rules      |
| sudo journalctl -u snort -f            | View service logs     |

# **👨‍💻 Author**

**Moustapha Damdele**

- 💼 IT Specialist | Cybersecurity
- 🏆 CompTIA Security+
- 🔗 LinkedIn: linkedin.com/in/moustapha-damdele

_⭐ If this project helped you, feel free to leave a star on GitHub!_