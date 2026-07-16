#!/bin/bash

# Snort alert files
ALERT_FILE="/var/log/snort/alert"

# Destination email address
EMAIL="exemple@gmail.com"

# Check if file exist
if [ ! -f "$ALERT_FILE" ]; then
    echo "Erreur : le fichier $ALERT_FILE n'existe pas."
    exit 1
fi

# check alert
tail -F "$ALERT_FILE" | while read -r line
do
mail -s "🚨 Alerte IDS Snort" "$EMAIL" <<EOF
Alert Snort Detect.

Date : $(date)

Alerte :
$line

Serveur : $(hostname)
EOF

done
