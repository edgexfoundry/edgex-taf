#!/usr/bin/env sh
#This file is used to update your local OS environment to get project
#dependencies.
sudo apt -y update
sudo apt -y install python3.6
sudo apt -y install python3-pip
sudo apt -y install git
pip3 install -r requirements.txt
