#!/bin/bash
# -----------------------------------------------------------------------------
# SEQUENCED VNC REMOTE DESKTOP SETUP
#
# Execution Order:
# 1. Install All Packages (XFCE4, VNC, Firefox, Ngrok)
# 2. Configure VNC (Interactive Password & xstartup)
# 3. Start VNC Server
# 4. Start Ngrok Tunnel (Final foreground step)
# -----------------------------------------------------------------------------

# --- Configuration for Speed and Performance ---
VNC_DISPLAY=":1"
VNC_PORT="5901"
# Optimization: 16-bit color and fixed geometry for faster response
VNC_GEOMETRY="1280x800"
VNC_DEPTH="16"

# NOTE: Using the ngrok auth token you provided in your original file
NGROK_AUTH_TOKEN="2lrcV3R6170b8KA6NGdhfygsUhd_3C9Kgt4YELwaPNmCEeUKb"

echo "--- Sequenced XFCE Desktop Setup Starting ---"

# 1. Install ALL Required Packages (VNC, XFCE4, Firefox, Ngrok)
# ---------------------------------------------------------------
echo -e "\n--- 1. Installing All Desktop and Service Packages (This may take a few minutes) ---"

# Install ngrok first to configure its repository
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
  sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
  echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" | \
  sudo tee /etc/apt/sources.list.d/ngrok.list

# Update and install everything in one robust command
DEBIAN_FRONTEND=noninteractive sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt install \
  tightvncserver \
  xfce4 \
  xfce4-goodies \
  dbus \
  dbus-x11 \
  firefox \
  ngrok \
  -y

# Check for successful installation
if ! command -v startxfce4 &> /dev/null
then
    echo -e "\n🔴 ERROR: XFCE4 installation failed. Please review terminal output."
    exit 1
fi
echo "✅ All packages installed successfully."

# 2. Ngrok Configuration (Setup)
# ---------------------------------------------------------------
echo -e "\n--- 2. Configuring ngrok Authentication ---"
ngrok config add-authtoken $NGROK_AUTH_TOKEN
echo "✅ Ngrok configured with auth token."

# 3. VNC Server Configuration (Setup)
# ---------------------------------------------------------------
echo -e "\n--- 3. Configuring VNC Server (xstartup and Password) ---"

# 3a. Interactive VNC Password Setup
if [ ! -f ~/.vnc/passwd ]; then
    echo -e "\n=========================================================================="
    echo "  🛑 VNC PASSWORD SETUP - INTERACTIVE STEP"
    echo "  Please enter and confirm your password when prompted below."
    echo "  (You can safely skip the 'View-only password'.)"
    echo "=========================================================================="
    # Run vncserver interactively to set the password
    vncserver
    # Kill the temporary session created by the password command
    vncserver -kill $VNC_DISPLAY 2>/dev/null || true
    echo -e "\n✅ VNC Password has been set. Preparing to launch services..."
fi

# 3b. Configure VNC xstartup file for XFCE
mkdir -p ~/.vnc
cat << EOF > ~/.vnc/xstartup
#!/bin/sh
# Start XFCE4 Desktop and necessary components
xrdb \$HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
# Launch XFCE4 with dbus support for a complete desktop experience
dbus-launch --exit-with-session startxfce4 &
EOF
chmod +x ~/.vnc/xstartup
echo "✅ xstartup file configured."

# 4. Start VNC Server
# ---------------------------------------------------------------
echo -e "\n--- 4. Starting VNC Server on $VNC_DISPLAY (Port $VNC_PORT) ---"
vncserver -kill $VNC_DISPLAY 2>/dev/null || true # Ensure it's killed first

echo "🚀 Settings: Geometry=$VNC_GEOMETRY, Depth=$VNC_DEPTH (Optimization for Speed)"
vncserver $VNC_DISPLAY -geometry $VNC_GEOMETRY -depth $VNC_DEPTH
echo "✅ VNC Server started."

# 5. Start ngrok Tunnel (Final Step)
# ---------------------------------------------------------------
echo -e "\n--- 5. Starting ngrok Tunnel (Foreground Process) ---"
echo "🔥 SUCCESS! Look for the 'Forwarding' line below to find your VNC access address (e.g., tcp://X.tcp.ngrok.io:XXXXX)."
echo "Press Ctrl+C to stop the tunnel (which will stop the script)."

ngrok tcp $VNC_PORT
