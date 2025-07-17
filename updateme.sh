#!/usr/bin/env sh
#This file is used to update your local OS environment to get project
#dependencies.

# WARNING: Running pip as the 'root' user can result in broken permissions and
# conflicting behaviour with the system package manager.
# It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv

set -e

echo "Updating package list and installing base tools..."
apt -y update
apt -y install python3-pip git

# Detect OS for libpq install
if grep -qi "debian\|ubuntu" /etc/os-release; then
  echo "Detected Debian/Ubuntu. Installing libpq-dev..."
  apt -y install libpq-dev
elif grep -qi "alpine" /etc/os-release; then
  echo "Detected Alpine. Installing postgresql-dev..."
  apk add --no-cache postgresql-dev
elif grep -qi "centos\|fedora\|rhel" /etc/os-release; then
  echo "Detected RHEL/CentOS/Fedora. Installing postgresql-devel..."
  yum install -y postgresql-devel
elif uname | grep -qi "darwin"; then
  echo "Detected macOS. Installing postgresql with Homebrew..."
  brew install postgresql
else
  echo "Unsupported OS. Please install libpq (PostgreSQL client library) manually."
fi

# Download requirements.txt if not exists
if [ ! -f requirements.txt ]; then
  echo "Downloading requirements.txt..."
  wget https://raw.githubusercontent.com/edgexfoundry/edgex-taf-common/refs/heads/main/requirements.txt
fi

# Check for virtual environment
if [ -z "$VIRTUAL_ENV" ]; then
  echo "❗ Not inside a Python virtual environment. Please activate a venv before installing Python packages."
  exit 1
fi

echo "Installing Python dependencies..."
pip3 install -r requirements.txt
