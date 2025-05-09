#!/bin/bash

. "$(dirname "$0")/config.env"

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Update and install sysstat
echo "Installing sysstat..."
apt-get update -y && apt-get install -y sysstat

# Enable data collection in sysstat
echo "Enabling sysstat data collection..."
sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat

# Restart the sysstat service to apply changes
echo "Restarting sysstat service..."
systemctl restart sysstat

echo "Configuring data collection interval..."
echo -e "# Run sysstat every ${CRONTAB_MIN} minutes\n*/${CRONTAB_MIN} * * * * root command -v sa1 > /dev/null && sa1 1 1" | sudo tee -a /etc/cron.d/sysstat

echo "Restarting cron service..."
sudo systemctl restart cron

echo "Setup complete! Sysstat is now collecting system performance data every 10 minutes."
