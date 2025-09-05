# app.py
# Display Manager - Central control service for Pi display modes

import os
from flask import Flask, render_template, request, jsonify

# --- Configuration ---
# Available display modes with their URLs
MODES = {
    "infohub": {"name": "InfoHub", "url": "http://localhost:5000"},
    "security": {"name": "Surveillance Mode", "url": "http://localhost:8080"}
}

# Default mode
current_mode = "infohub"

# --- Flask App Initialization ---
app = Flask(__name__)

# --- Routes ---

@app.route('/')
def display_page():
    """
    Display Page - This is what will be shown on the Pi's display.
    Contains an iframe that will be updated based on the current mode.
    """
    return render_template('index.html')

@app.route('/control')
def control_page():
    """
    Control Page - Remote control interface for mobile devices.
    Shows buttons to switch between different display modes.
    """
    return render_template('control.html', modes=MODES)

@app.route('/api/state')
def get_state():
    """
    API endpoint to get the current state.
    Returns the current mode and its corresponding URL.
    """
    return jsonify({
        "mode": current_mode,
        "url": MODES[current_mode]["url"]
    })

@app.route('/api/mode', methods=['POST'])
def set_mode():
    """
    API endpoint to set a new display mode.
    Expects JSON body with 'mode' field.
    """
    global current_mode
    
    try:
        data = request.get_json()
        if not data or 'mode' not in data:
            return jsonify({"error": "No mode specified"}), 400
        
        new_mode = data['mode']
        
        if new_mode not in MODES:
            return jsonify({"error": f"Invalid mode: {new_mode}"}), 400
        
        current_mode = new_mode
        
        return jsonify({
            "status": "success",
            "new_mode": current_mode,
            "url": MODES[current_mode]["url"]
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/modes')
def get_modes():
    """
    API endpoint to get all available modes.
    Useful for dynamic control interfaces.
    """
    return jsonify(MODES)

@app.route('/status')
def status():
    """
    Simple status page showing current mode and available modes.
    """
    return render_template('status.html', current_mode=current_mode, modes=MODES)

# --- Run the App ---
if __name__ == '__main__':
    # Ensure templates directory exists
    os.makedirs('templates', exist_ok=True)
    
    print("=== Display Manager Starting ===")
    print(f"Available modes: {list(MODES.keys())}")
    print(f"Default mode: {current_mode}")
    print("Control interface will be available at: http://localhost:8000/control")
    print("Display page will be available at: http://localhost:8000/")
    print("=====================================")
    
    # Running on 0.0.0.0 makes the server accessible from other devices on the same network
    app.run(host='0.0.0.0', port=8000, debug=True)
