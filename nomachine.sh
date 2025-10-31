
#!/bin/bash
# -----------------------------------------------------------------------------
# NOMACHINE SETUP SCRIPT - Fixed for Installation and Authentication Errors
# Protocol: NX (Nomachine) on port 4000
# -----------------------------------------------------------------------------

# --- Configuration ---
NOMACHINE_PORT="4000"
NOMACHINE_DEB_URL="https://web9001.nomachine.com/download/9.2/Linux/nomachine_9.2.18_3_amd64.deb"
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

CURRENT_USER=$(whoami)

echo "--- Nomachine XFCE Desktop Setup Starting for User: $CURRENT_USER ---"

# 1. Update and Install XFCE4 and Browser (Highest Priority)
# -----------------------------------------------------------------------------
echo -e "\n--- 1. Installing XFCE4, Desktop Dependencies, and Firefox Browser ---"
DEBIAN_FRONTEND=noninteractive sudo apt update

# Install all necessary components in one command for dependency resolution
DEBIAN_FRONTEND=noninteractive sudo apt install \
  xfce4 \
  xfce4-goodies \
  dbus \
  dbus-x11 \
  firefox \
  -y

echo "✅ All core desktop packages installed."

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

# Download the Nomachine .deb package
curl -LO $NOMACHINE_DEB_URL

# Install the Nomachine package
DEBIAN_FRONTEND=noninteractive sudo dpkg -i "$(basename $NOMACHINE_DEB_URL)"

# Clean up broken dependencies which can happen after dpkg install
DEBIAN_FRONTEND=noninteractive sudo apt install -f -y

echo "✅ Nomachine server installed and started automatically."


# 4. Install and Configure Ngrok
# -----------------------------------------------------------------------------
echo -e "\n--- 4. Installing and Configuring ngrok ---"

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


# 5. Start Ngrok Tunnel (Final Step)
# -----------------------------------------------------------------------------
echo -e "\n--- 5. Starting ngrok Tunnel for Nomachine (Port $NOMACHINE_PORT) ---"

echo "--------------------------------------------------------------------------"
echo "🔥 SUCCESS! Nomachine is ready."
echo "Use the Nomachine Client and the 'tcp://...' address below."
echo "Login with Username: $CURRENT_USER and the password you set in Step 2."
echo "Press Ctrl+C to stop the tunnel (which will stop the script)."
echo "--------------------------------------------------------------------------"

# Ngrok will start and remain in the foreground
ngrok tcp $NOMACHINE_PORT
