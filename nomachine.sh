#!/bin/bash
# -----------------------------------------------------------------------------
# NOMACHINE SETUP SCRIPT - Optimized for Performance
#
# This version adds an interactive prompt to set the current Linux user's
# password, which is required for Nomachine authentication.
# -----------------------------------------------------------------------------

# --- Configuration ---
NOMACHINE_PORT="4000"
NOMACHINE_DEB_URL="https://web9001.nomachine.com/download/9.2/Linux/nomachine_9.2.18_3_amd64.deb"

# NOTE: Using the ngrok auth token you provided
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

# --- Get Current User ---
CURRENT_USER=$(whoami)

echo "--- Nomachine XFCE Desktop Setup Starting for User: $CURRENT_USER ---"

# 1. Interactive User Password Setup
# -----------------------------------------------------------------------------
echo -e "\n=========================================================================="
echo "  🛑 USER PASSWORD SETUP - INTERACTIVE STEP"
echo "  Nomachine requires a Linux user password for access."
echo "  You must set the password for the current user ($CURRENT_USER) now."
echo "  This password is what you will use to log into Nomachine."
echo "=========================================================================="

# The passwd command will prompt the user to set a new password interactively
sudo passwd $CURRENT_USER

echo -e "\n✅ User password set for $CURRENT_USER. Continuing with installation..."


# 2. Update and Install XFCE4 and Browser
# -----------------------------------------------------------------------------
echo -e "\n--- 2. Installing XFCE4, Desktop Dependencies, and Firefox Browser ---"
DEBIAN_FRONTEND=noninteractive sudo apt update

# Install XFCE4, XFCE4 Goodies, DBUS, and Firefox
DEBIAN_FRONTEND=noninteractive sudo apt install \
  xfce4 \
  xfce4-goodies \
  dbus \
  dbus-x11 \
  firefox \
  -y

echo "✅ All core packages installed."


# 3. Download and Install Nomachine
# -----------------------------------------------------------------------------
echo -e "\n--- 3. Downloading and Installing Nomachine Server ---"

# Download the Nomachine .deb package
curl -LO $NOMACHINE_DEB_URL

# Use dpkg to install the package and fix dependencies afterward
DEBIAN_FRONTEND=noninteractive sudo dpkg -i "$(basename $NOMACHINE_DEB_URL)"
# This command forces apt to install any missing dependencies needed by Nomachine
DEBIAN_FRONTEND=noninteractive sudo apt install -f -y

echo "✅ Nomachine server installed and started automatically."


# 4. Install and Configure Ngrok
# -----------------------------------------------------------------------------
echo -e "\n--- 4. Installing and Configuring ngrok ---"

# Ngrok Installation
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && DEBIAN_FRONTEND=noninteractive sudo apt install ngrok -y

# Configure the auth token
ngrok config add-authtoken $NGROK_AUTH_TOKEN
echo "✅ Ngrok installed and configured."


# 5. Start Ngrok Tunnel (Final Step)
# -----------------------------------------------------------------------------
echo -e "\n--- 5. Starting ngrok Tunnel for Nomachine (Port $NOMACHINE_PORT) ---"

echo "🔥 SUCCESS! Nomachine is now running. Look for the 'Forwarding' line below to find your access address."
echo "Use a Nomachine Client to connect to the 'tcp://...' address."
echo "Login with Username: $CURRENT_USER and the password you just set."
echo "Press Ctrl+C to stop the tunnel (which will stop the script)."

# Ngrok will start and remain in the foreground
ngrok tcp $NOMACHINE_PORT
