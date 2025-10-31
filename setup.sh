#!/bin/bash
# -----------------------------------------------------------------------------
# VNC SETUP SCRIPT - STRICTLY FOLLOWING USER'S ORIGINAL SEQUENCE
#
# This script ensures package installation is complete before VNC configuration.
# The VNC password setting step is interactive.
# -----------------------------------------------------------------------------

# --- Configuration ---
VNC_DISPLAY=":1"
VNC_PORT="5901"
# Performance settings for VNC
VNC_GEOMETRY="1280x800"
VNC_DEPTH="16"

# NOTE: Using the ngrok auth token you provided
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

echo "--- VNC Desktop Setup Starting (Exact Sequence) ---"

# 1. Update and Install ALL VNC and Desktop Packages
# -----------------------------------------------------------------------------
echo -e "\n--- 1. Installing XFCE4, Desktop Dependencies, and TightVNC Server ---"
# Use DEBIAN_FRONTEND=noninteractive and -y for robust, non-stopping installation
DEBIAN_FRONTEND=noninteractive sudo apt update

# Install XFCE4 and XFCE4 Goodies
DEBIAN_FRONTEND=noninteractive sudo apt install xfce4 xfce4-goodies -y

# Install DBUS Dependencies
DEBIAN_FRONTEND=noninteractive sudo apt install dbus dbus-x11 -y

# Install TightVNC Server
DEBIAN_FRONTEND=noninteractive sudo apt install tightvncserver -y

echo "✅ All core packages installed."


# 2. Interactive VNC Password Setting (Manual Step)
# -----------------------------------------------------------------------------
if [ ! -f ~/.vnc/passwd ]; then
    echo -e "\n=========================================================================="
    echo "  🛑 VNC PASSWORD SETUP - INTERACTIVE STEP"
    echo "  (This is step 5 from your original file)"
    echo "  Please enter and confirm your password when prompted below."
    echo "  (You can safely skip the 'View-only password'.)"
    echo "=========================================================================="

    # Run vncserver interactively to create the password file
    vncserver

    # Kill the temporary session created by the password command
    vncserver -kill $VNC_DISPLAY 2>/dev/null || true
    echo -e "\n✅ VNC Password set. Continuing with configuration..."
fi


# 3. Configure VNC xstartup file
# -----------------------------------------------------------------------------
echo -e "\n--- 3. Configuring VNC xstartup file ---"
mkdir -p ~/.vnc
cat << EOF > ~/.vnc/xstartup
#!/bin/sh
xrdb \$HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
dbus-launch --exit-with-session startxfce4 &
EOF

# Ensure the startup script is executable
chmod +x ~/.vnc/xstartup
echo "✅ xstartup file configured."


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


# 5. Start VNC Server and Ngrok Tunnel
# -----------------------------------------------------------------------------
echo -e "\n--- 5. Starting VNC Server and Ngrok Tunnel ---"

# Kill existing VNC session on display :1
echo "Stopping any existing VNC session on $VNC_DISPLAY..."
vncserver -kill $VNC_DISPLAY 2>/dev/null || true

# Start VNC with performance settings
echo "Starting new VNC server (Geometry: $VNC_GEOMETRY, Depth: $VNC_DEPTH)..."
vncserver $VNC_DISPLAY -geometry $VNC_GEOMETRY -depth $VNC_DEPTH

# Start ngrok Tunnel (Foreground Process)
echo -e "\n🔥 SUCCESS! Look for the 'Forwarding' line below to find your VNC access address."
echo "Press Ctrl+C to stop the tunnel (which will stop the script)."
ngrok tcp $VNC_PORT
