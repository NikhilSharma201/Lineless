from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)

# In-memory database for the prototype
users = {
    "24107095": {"pin": "123456", "name": "Nikhil Sharma", "role": "student"},
    "24107096": {"pin": "654321", "name": "Priya Patel", "role": "student"}
}

# Admin credentials (email and password)
admins = {
    "admin@apsit.edu.in": {"password": "admin123", "name": "Admin User"}
}

services = [
    {"id": "s1", "name": "Scholarships", "desc": "Apply for merit & need-based grants", "icon": "school"},
    {"id": "s2", "name": "Train Concessions", "desc": "Monthly railway pass verification", "icon": "train"},
    {"id": "s3", "name": "Visa Letters", "desc": "Request official bonafide docs", "icon": "description"},
    {"id": "s4", "name": "Fee Waiver", "desc": "Financial aid documentation", "icon": "payments"},
]

tokens = []
token_counter = 88290

def calculate_queue_position(service_name):
    """Calculate queue position for a service"""
    active_tokens = [t for t in tokens if t['service_name'] == service_name and t['status'] == 'ACTIVE']
    return len(active_tokens) + 1

def update_queue_positions():
    """Update queue positions for all active tokens"""
    for service in services:
        service_tokens = [t for t in tokens if t['service_name'] == service['name'] and t['status'] == 'ACTIVE']
        service_tokens.sort(key=lambda x: x['created_at'])
        for idx, token in enumerate(service_tokens):
            token['queue_position'] = idx + 1
            # Update estimated wait time based on position
            wait_mins = (idx + 1) * 3  # Assuming 3 mins per person
            token['est_wait'] = f"{wait_mins}-{wait_mins+3} Mins"

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    student_id = data.get('student_id')
    pin = data.get('pin')
    
    if student_id in users and users[student_id]['pin'] == pin:
        return jsonify({
            "success": True, 
            "user": {
                "id": student_id, 
                "name": users[student_id]['name'],
                "role": "student"
            }
        })
    return jsonify({"success": False, "message": "Invalid Student ID or PIN"}), 401

@app.route('/admin/login', methods=['POST'])
def admin_login():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    if email in admins and admins[email]['password'] == password:
        return jsonify({
            "success": True,
            "user": {
                "email": email,
                "name": admins[email]['name'],
                "role": "admin"
            }
        })
    return jsonify({"success": False, "message": "Invalid admin credentials"}), 401

@app.route('/services', methods=['GET'])
def get_services():
    # Add queue count to each service
    services_with_queue = []
    for service in services:
        active_count = len([t for t in tokens if t['service_name'] == service['name'] and t['status'] == 'ACTIVE'])
        service_copy = service.copy()
        service_copy['queue_count'] = active_count
        services_with_queue.append(service_copy)
    return jsonify({"services": services_with_queue})

@app.route('/tokens', methods=['GET'])
def get_tokens():
    student_id = request.args.get('student_id')
    user_tokens = [t for t in tokens if t['student_id'] == student_id]
    return jsonify({"tokens": user_tokens})

@app.route('/admin/tokens', methods=['GET'])
def get_all_tokens():
    """Admin endpoint to get all tokens"""
    # Return tokens sorted by creation time (newest first)
    sorted_tokens = sorted(tokens, key=lambda x: x['created_at'], reverse=True)
    return jsonify({"tokens": sorted_tokens})

@app.route('/tokens', methods=['POST'])
def create_token():
    global token_counter
    data = request.json
    token_counter += 1
    
    student_id = data.get('student_id')
    service_name = data.get('service_name')
    
    # Get student name
    student_name = users.get(student_id, {}).get('name', 'Unknown Student')
    
    # Calculate queue position
    queue_pos = calculate_queue_position(service_name)
    wait_mins = queue_pos * 3
    
    new_token = {
        "id": f"LL-{token_counter}",
        "student_id": student_id,
        "student_name": student_name,  # Added student name
        "service_name": service_name,
        "status": "ACTIVE",
        "created_at": datetime.now().isoformat(),  # Store as ISO format for sorting
        "display_time": datetime.now().strftime("%b %d, %Y • %I:%M %p"),
        "est_wait": f"{wait_mins}-{wait_mins+3} Mins",
        "queue_position": queue_pos
    }
    tokens.insert(0, new_token)
    update_queue_positions()
    return jsonify({"success": True, "token": new_token})

@app.route('/tokens/<token_id>/complete', methods=['POST'])
def complete_token(token_id):
    for t in tokens:
        if t['id'] == token_id:
            t['status'] = "COMPLETED"
            t['completed_at'] = datetime.now().strftime("%b %d, %Y • %I:%M %p")
            update_queue_positions()  # Update queue after completion
            return jsonify({"success": True})
    return jsonify({"success": False, "message": "Token not found"}), 404

@app.route('/tokens/<token_id>/cancel', methods=['POST'])
def cancel_token(token_id):
    """Student can cancel their token"""
    for t in tokens:
        if t['id'] == token_id:
            t['status'] = "CANCELLED"
            t['cancelled_at'] = datetime.now().strftime("%b %d, %Y • %I:%M %p")
            update_queue_positions()  # Update queue after cancellation
            return jsonify({"success": True})
    return jsonify({"success": False, "message": "Token not found"}), 404

@app.route('/queue/<service_name>', methods=['GET'])
def get_queue_info(service_name):
    """Get queue information for a specific service"""
    active_tokens = [t for t in tokens if t['service_name'] == service_name and t['status'] == 'ACTIVE']
    active_tokens.sort(key=lambda x: x['created_at'])
    
    return jsonify({
        "service_name": service_name,
        "total_in_queue": len(active_tokens),
        "tokens": active_tokens
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)