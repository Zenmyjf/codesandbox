#!/bin/bash
# -----------------------------------------------------------------------------
# NOMACHINE DISPLAY FIX SCRIPT - Attempts to resolve "Cannot create a new display"
# Protocol: NX (Nomachine) on port 4000
# -----------------------------------------------------------------------------

# --- Configuration ---
NOMACHINE_PORT="4000"
NOMACHINE_DEB_URL="https://web9001.nomachine.com/download/9.2/Linux/nomachine_9.2.18_3_amd64.deb"
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"
CURRENT_USER=$(whoami)

echo "--- Nomachine XFCE Desktop Setup Starting for User: $CURRENT_USER ---"

# 1. Update and Install ALL Dependencies (Including X-Server components)
# -----------------------------------------------------------------------------
echo -e "\n--- 1. Installing XFCE4, X-Server, and Firefox Browser ---"
DEBIAN_FRONTEND=noninteractive sudo apt update

# Install all desktop components plus the core X-Server components
DEBIAN_FRONTEND=noninteractive sudo apt install \
  xfce4 \
  xfce4-goodies \
  dbus \
  dbus-x11 \
  firefox-esr \
  xinit \
  xserver-xorg \
  -y

echo "✅ All core desktop and X-Server packages installed."

# 2. Interactive User Password Setup (Mandatory for Nomachine Login)
# -----------------------------------------------------------------------------
echo -e "\n=========================================================================="
echo "  🛑 USER PASSWORD SETUP - INTERACTIVE STEP"
echo "  Nomachine authenticates using the current Linux user's password."
echo "  You MUST set the password for user ($CURRENT_USER) now."
echo "  This password is what you will use to log into the Nomachine Client."
echo "=========================================================================="
sudo passwd $CURRENT_USER

echo -e "\n✅ User password set. Continuing with installation..."


# 3. Download and Install Nomachine
# -----------------------------------------------------------------------------
echo -e "\n--- 3. Downloading and Installing Nomachine Server ---"
curl -LO $NOMACHINE_DEB_URL
DEBIAN_FRONTEND=noninteractive sudo dpkg -i "$(basename $NOMACHINE_DEB_URL)"
DEBIAN_FRONTEND=noninteractive sudo apt install -f -y

echo "✅ Nomachine server installed."


# 4. Critical Nomachine Configuration Fix
# -----------------------------------------------------------------------------
echo -e "\n--- 4. Forcing Nomachine to recognize XFCE ---"

# This command ensures Nomachine is aware of XFCE as an available session
sudo /usr/NX/bin/nxserver --startmode xfce

echo "✅ Nomachine configured for XFCE session."


# 5. Install and Configure Ngrok
# -----------------------------------------------------------------------------
echo -e "\n--- 5. Installing and Configuring ngrok ---"

# Ngrok Installation sequence
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && DEBIAN_FRONTEND=noninteractive sudo apt install ngrok -y

# Configure the auth token
ngrok config add-authtoken $NGROK_AUTH_TOKEN
echo "✅ Ngrok installed and configured."


# 6. Start Ngrok Tunnel (Final Step)
# -----------------------------------------------------------------------------
echo -e "\n--- 6. Starting ngrok Tunnel for Nomachine (Port $NOMACHINE_PORT) ---"

echo "--------------------------------------------------------------------------"
echo "🔥 FINAL ATTEMPT: Nomachine is ready with the display fix applied."
echo "Use the Nomachine Client. Login: $CURRENT_USER and the password you set."
echo "--------------------------------------------------------------------------"

# Ngrok will start and remain in the foreground
ngrok tcp $NOMACHINE_PORT
