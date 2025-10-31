#!/bin/bash
# -----------------------------------------------------------------------------
# Automated VNC Remote Desktop Setup for Codesandbox/Linux Environments
#
# This script installs VNC Server, XFCE4 Desktop, Firefox browser, and ngrok.
# It handles the interactive VNC password setup and starts the ngrok tunnel.
# -----------------------------------------------------------------------------

# --- Configuration ---
VNC_DISPLAY=":1"
VNC_PORT="5901"
# Optimization for better performance over the internet: lower color depth
VNC_GEOMETRY="1280x800"
VNC_DEPTH="16"

# NOTE: Using the ngrok auth token you provided in the original file
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

echo "--- VNC/XFCE/Ngrok Automation Script Starting ---"

# 1. Interactive VNC Password Check/Setup
if [ ! -f ~/.vnc/passwd ]; then
    echo ""
    echo "=========================================================================="
    echo "  🛑 VNC PASSWORD SETUP"
    echo "  The VNC server requires you to set an access password interactively."
    echo "  Please enter and confirm your password when prompted below."
    echo "  (You will be asked to create a 'View-only password'; you can skip this.)"
    echo "=========================================================================="
    echo ""
    # Run vncserver interactively to set the password
    vncserver
    # Kill the temporary session created by the password command
    vncserver -kill $VNC_DISPLAY 2>/dev/null || true
    echo ""
    echo "=========================================================================="
    echo "  VNC Password has been set. Continuing with installation..."
    echo "=========================================================================="
    echo ""
fi


# 2. Update and Install All Packages in one go (Optimized)
echo "--- 2. Installing Desktop Environment (XFCE4, Firefox) and TightVNC Server ---"
# Single apt command for reduced overhead
sudo apt update
sudo apt install tightvncserver xfce4 xfce4-goodies dbus dbus-x11 firefox -y

# 3. Configure VNC xstartup file for XFCE
echo "--- 3. Configuring VNC xstartup file ---"
mkdir -p ~/.vnc
cat << EOF > ~/.vnc/xstartup
#!/bin/sh
# Start XFCE4 Desktop and necessary components
xrdb \$HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
# Using dbus-launch to ensure the XFCE session starts correctly with dependencies
dbus-launch --exit-with-session startxfce4 &
EOF

# Ensure the startup script is executable
chmod +x ~/.vnc/xstartup

# 4. Ngrok Setup and Configuration
echo "--- 4. Installing and Configuring ngrok ---"

# Installation steps combined
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
  sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
  echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" | \
  sudo tee /etc/apt/sources.list.d/ngrok.list && \
  sudo apt update && \
  sudo apt install ngrok -y

# Configure the auth token
echo "Configuring ngrok with provided auth token..."
ngrok config add-authtoken $NGROK_AUTH_TOKEN

# 5. Manage and Start VNC Server (Optimized)
echo "--- 5. Stopping any previous VNC session on $VNC_DISPLAY ---"
# Kill existing VNC session if it's running
vncserver -kill $VNC_DISPLAY 2>/dev/null || true

echo "--- 6. Starting new VNC server on $VNC_DISPLAY (Port $VNC_PORT) ---"
echo "  Settings: Geometry=$VNC_GEOMETRY, Depth=$VNC_DEPTH (Faster response)"
# Start VNC with performance optimizations
vncserver $VNC_DISPLAY -geometry $VNC_GEOMETRY -depth $VNC_DEPTH

# 6. Start ngrok Tunnel
echo "--- 7. Starting ngrok Tunnel (Foreground Process) ---"
echo "  The Ngrok output below contains the address you will use for your VNC client."
echo "  LOOK FOR THE 'Forwarding' line (e.g., tcp://X.tcp.ngrok.io:XXXXX)"

# The ngrok process will run in the foreground and display the URL
ngrok tcp $VNC_PORT

# Cleanup (This line will likely never be reached as ngrok runs indefinitely)
echo "--- Script finished ---"
