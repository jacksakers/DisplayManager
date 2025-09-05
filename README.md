# Display Manager

A centralized service for controlling what content is displayed on a Raspberry Pi's screen. This service allows you to remotely switch between different display modes (like InfoHub and Security Camera views) from a mobile device.

## Features

- **Remote Control**: Switch display modes from any device on your network
- **Extensible**: Easily add new display modes
- **Responsive**: Mobile-friendly control interface
- **Automatic Recovery**: Handles service failures gracefully
- **Kiosk Mode**: Full-screen display without browser UI

## Architecture

The Display Manager acts as a central hub that controls what is shown on the Pi's display by embedding other services in an iframe. This decoupled approach means:

- Each service (SmartFrame, StreamServer, etc.) maintains its own functionality
- The display can switch between services without affecting them
- New display modes can be added easily
- Service failures are isolated

## Available Modes

- **InfoHub**: Photo slideshow with weather, news, and other widgets (port 5000)
- **Security**: Live security camera feeds (port 8080)

## Installation

### Method 1: Automatic Setup (Recommended)

1. Copy all files to your Raspberry Pi
2. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

### Method 2: Manual Setup

1. **Install dependencies:**
   ```bash
   sudo apt update
   sudo apt install python3-pip python3-venv
   ```

2. **Set up the project:**
   ```bash
   mkdir -p /home/pi/DisplayManager
   cd /home/pi/DisplayManager
   # Copy all project files here
   ```

3. **Create virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

4. **Install and start the service:**
   ```bash
   sudo cp display-manager.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable smart-display-manager
   sudo systemctl start smart-display-manager
   ```

## Usage

### Access Points

- **Display Page**: `http://YOUR_PI_IP:8000/` - Full-screen view for the Pi's display
- **Control Page**: `http://YOUR_PI_IP:8000/control` - Mobile-friendly remote control
- **Status Page**: `http://YOUR_PI_IP:8000/status` - Service status and debugging info

### Setting Up Kiosk Mode

To have the Pi automatically display the content in full-screen mode:

1. Install Chromium:
   ```bash
   sudo apt install chromium-browser
   ```

2. Create autostart file:
   ```bash
   mkdir -p ~/.config/autostart
   cat > ~/.config/autostart/display-manager-kiosk.desktop << EOF
   [Desktop Entry]
   Type=Application
   Name=Display Manager Kiosk
   Exec=chromium-browser --kiosk --disable-infobars --disable-session-crashed-bubble --disable-restore-session-state http://localhost:8000/
   Hidden=false
   NoDisplay=false
   X-GNOME-Autostart-enabled=true
   EOF
   ```

### Adding New Display Modes

1. **Update the configuration** in `app.py`:
   ```python
   MODES = {
       "infohub": {"name": "InfoHub", "url": "http://localhost:5000"},
       "security": {"name": "Security Camera", "url": "http://localhost:8080"},
       "newmode": {"name": "New Display Mode", "url": "http://localhost:9000"}
   }
   ```

2. **Restart the service**:
   ```bash
   sudo systemctl restart display-manager
   ```

## Service Management

### Check Status
```bash
sudo systemctl status display-manager
```

### View Logs
```bash
sudo journalctl -u display-manager -f
```

### Restart Service
```bash
sudo systemctl restart display-manager
```

### Stop Service
```bash
sudo systemctl stop display-manager
```

### Disable Service
```bash
sudo systemctl disable display-manager
```

## API Reference

### GET /api/state
Returns the current display mode and URL.

**Response:**
```json
{
  "mode": "infohub",
  "url": "http://localhost:5000"
}
```

### POST /api/mode
Changes the current display mode.

**Request:**
```json
{
  "mode": "security"
}
```

**Response:**
```json
{
  "status": "success",
  "new_mode": "security",
  "url": "http://localhost:8080"
}
```

### GET /api/modes
Returns all available display modes.

**Response:**
```json
{
  "infohub": {"name": "InfoHub", "url": "http://localhost:5000"},
  "security": {"name": "Security Camera", "url": "http://localhost:8080"}
}
```

## Configuration

### Changing Ports
To change the port the Display Manager runs on, edit `app.py`:
```python
app.run(host='0.0.0.0', port=8000, debug=True)  # Change 8000 to your desired port
```

### Updating Service URLs
Update the `MODES` dictionary in `app.py` to change where each mode points:
```python
MODES = {
    "infohub": {"name": "InfoHub", "url": "http://192.168.1.100:5000"},  # Can use different IPs
    "security": {"name": "Security Camera", "url": "http://localhost:8080"}
}
```

## Troubleshooting

### Service Won't Start
1. Check the logs: `sudo journalctl -u display-manager -f`
2. Verify Python path in service file
3. Check file permissions
4. Ensure port 8000 is available

### Display Not Updating
1. Check if other services (SmartFrame, StreamServer) are running
2. Verify URLs in the MODES configuration
3. Check network connectivity
4. Look for JavaScript errors in browser console

### Control Page Not Working
1. Verify the Pi's IP address
2. Check firewall settings
3. Ensure the service is running: `sudo systemctl status display-manager`

## Dependencies

- **Python 3.7+**
- **Flask 2.3.3**
- **Werkzeug 2.3.7**

## License

This project is designed to work with your existing SmartFrame and StreamServer services. Make sure those services are running on their respective ports for the Display Manager to function properly.

## Development

To run in development mode:
```bash
source venv/bin/activate
python app.py
```

The service will run with debug mode enabled and automatically reload when files change.
