#!/bin/bash
# -----------------------------------------------------------------------------
# Automated VNC Remote Desktop Setup for Codesandbox/Linux Environments
#
# This script installs:
# 1. TightVNC Server
# 2. Full XFCE4 Desktop (xfce4 and xfce4-goodies)
# 3. Firefox Web Browser
# 4. Ngrok Client
#
# It prompts for the VNC password, then automates installation, configuration,
# and starts the VNC server and ngrok tunnel with speed optimizations.
# -----------------------------------------------------------------------------

# --- Configuration for Speed and Performance ---
VNC_DISPLAY=":1"
VNC_PORT="5901"
# Optimization: 16-bit color and fixed geometry for faster response (less network data)
VNC_GEOMETRY="1280x800"
VNC_DEPTH="16"

# NOTE: Using the ngrok auth token you provided in the original file
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

echo "--- Full XFCE Desktop Setup Starting ---"

# 1. Interactive VNC Password Check/Setup
if [ ! -f ~/.vnc/passwd ]; then
    echo ""
    echo "=========================================================================="
    echo "  🛑 VNC PASSWORD SETUP - INTERACTIVE STEP"
    echo "  The VNC server requires you to set an access password now."
    echo "  Please enter and confirm your password when prompted below."
    echo "  (You can safely skip the 'View-only password' if you wish.)"
    echo "=========================================================================="
    echo ""
    # Run vncserver interactively to set the password
    vncserver
    # Kill the temporary session created by the password command
    vncserver -kill $VNC_DISPLAY 2>/dev/null || true
    echo ""
    echo "=========================================================================="
    echo "  ✅ VNC Password has been set. Continuing with installation..."
    echo "=========================================================================="
    echo ""
fi


# 2. Update and Install ALL Required Packages (Optimized single command)
echo "--- 2. Installing XFCE4, XFCE4-GOODIES, Firefox, and TightVNC Server ---"
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
# Launch XFCE4 with dbus support for a complete desktop experience
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
echo "  🚀 Settings: Geometry=$VNC_GEOMETRY, Depth=$VNC_DEPTH (Optimization for Speed)"
# Start VNC with performance optimizations
vncserver $VNC_DISPLAY -geometry $VNC_GEOMETRY -depth $VNC_DEPTH

# 6. Start ngrok Tunnel
echo "--- 7. Starting ngrok Tunnel (Foreground Process) ---"
echo "  🔥 SUCCESS! LOOK FOR THE 'Forwarding' LINE below to find your VNC access address."

# The ngrok process will run in the foreground and display the URL
ngrok tcp $VNC_PORT

echo "--- Script finished ---"
