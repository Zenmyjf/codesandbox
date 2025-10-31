#!/bin/bash
# -----------------------------------------------------------------------------
# NOMACHINE SETUP SCRIPT - Optimized for Performance
#
# Nomachine uses its own protocol (NX) and server (nxserver) on port 4000.
# VNC components are removed for a cleaner setup.
# -----------------------------------------------------------------------------

# --- Configuration ---
# Nomachine's default port
NOMACHINE_PORT="4000"
NOMACHINE_DEB_URL="https://web9001.nomachine.com/download/9.2/Linux/nomachine_9.2.18_3_amd64.deb"

# NOTE: Using the ngrok auth token you provided
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

echo "--- Nomachine XFCE Desktop Setup Starting ---"

# 1. Update and Install XFCE4 and Browser
# -----------------------------------------------------------------------------
echo -e "\n--- 1. Installing XFCE4, Desktop Dependencies, and Firefox Browser ---"
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


# 2. Download and Install Nomachine
# -----------------------------------------------------------------------------
echo -e "\n--- 2. Downloading and Installing Nomachine Server ---"

# Download the Nomachine .deb package
curl -LO $NOMACHINE_DEB_URL

# Use dpkg to install the package and fix dependencies afterward
DEBIAN_FRONTEND=noninteractive sudo dpkg -i "$(basename $NOMACHINE_DEB_URL)"
# This command forces apt to install any missing dependencies needed by Nomachine
DEBIAN_FRONTEND=noninteractive sudo apt install -f -y

# Nomachine is started automatically upon installation and configuration is user-specific.
echo "✅ Nomachine server installed and started automatically."


# 3. Install and Configure Ngrok
# -----------------------------------------------------------------------------
echo -e "\n--- 3. Installing and Configuring ngrok ---"

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


# 4. Start Ngrok Tunnel (Final Step)
# -----------------------------------------------------------------------------
echo -e "\n--- 4. Starting ngrok Tunnel for Nomachine (Port $NOMACHINE_PORT) ---"

echo "🔥 SUCCESS! Nomachine is now running. Look for the 'Forwarding' line below to find your access address."
echo "Use a Nomachine Client (downloadable from their site) to connect to the 'tcp://...' address."
echo "Login credentials are your Codesandbox username (likely 'codesandbox') and your password (which you haven't set yet)."
echo "Press Ctrl+C to stop the tunnel (which will stop the script)."

# Ngrok will start and remain in the foreground
ngrok tcp $NOMACHINE_PORT
