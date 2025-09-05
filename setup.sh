#!/bin/bash

# Display Manager Setup Script
# This script sets up the DisplayManager service on a Raspberry Pi

echo "=== Display Manager Setup ==="
echo "This script will set up the DisplayManager service on your Raspberry Pi"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root. Run as the pi user."
    exit 1
fi

# Variables
PROJECT_DIR="/home/pi/DisplayManager"
SERVICE_NAME="display-manager"
VENV_DIR="$PROJECT_DIR/venv"

echo "1. Creating project directory..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "2. Setting up Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "3. Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "4. Setting up systemd service..."
sudo cp "$PROJECT_DIR/display-manager.service" "/etc/systemd/system/"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

echo "5. Starting the service..."
sudo systemctl start "$SERVICE_NAME"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager
echo ""
echo "The DisplayManager is now running on port 8000"
echo ""
echo "Access points:"
echo "  - Display page: http://$(hostname -I | awk '{print $1}'):8000/"
echo "  - Control page: http://$(hostname -I | awk '{print $1}'):8000/control"
echo "  - Status page:  http://$(hostname -I | awk '{print $1}'):8000/status"
echo ""
echo "To view logs: sudo journalctl -u $SERVICE_NAME -f"
echo "To restart:   sudo systemctl restart $SERVICE_NAME"
echo "To stop:      sudo systemctl stop $SERVICE_NAME"
echo ""

# Set up browser kiosk mode (optional)
read -p "Would you like to set up the Pi to automatically open the display page in kiosk mode? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Setting up kiosk mode..."
    
    # Install Chromium if not present
    if ! command -v chromium-browser &> /dev/null; then
        echo "Installing Chromium browser..."
        sudo apt update
        sudo apt install -y chromium-browser
    fi
    
    # Create autostart directory
    mkdir -p ~/.config/autostart
    
    # Create autostart file for kiosk mode
    cat > ~/.config/autostart/display-manager-kiosk.desktop << EOF
[Desktop Entry]
Type=Application
Name=Display Manager Kiosk
Exec=chromium-browser --kiosk --disable-infobars --disable-session-crashed-bubble --disable-restore-session-state http://localhost:8000/
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
    
    echo "Kiosk mode configured! The display page will automatically open on boot."
    echo "To disable: remove ~/.config/autostart/display-manager-kiosk.desktop"
fi

echo ""
echo "Setup complete! 🎉"
