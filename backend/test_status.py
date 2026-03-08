import os
from flask import Flask
from flask_jwt_extended import JWTManager, create_access_token
import requests

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'your-super-secret-jwt-key-change-it'
jwt = JWTManager(app)

with app.app_context():
    t = create_access_token(
        identity='VP9H2vNkCHhwuwowUkWrshIYkY72', 
        additional_claims={
            'email': 'gowthampnair7@gmail.com', 'admin_id': 'VP9H2vNkCHhwuwowUkWrshIYkY72', 
            'uid': 'VP9H2vNkCHhwuwowUkWrshIYkY72', 'department': 'pwd', 'name': 'Gowtham P Nair'
        }
    )
    # Get complaints to find an ID
    res = requests.get('http://localhost:3000/api/admin/complaints', headers={'Authorization': 'Bearer ' + t})
    if res.status_code == 200:
        complaints = res.json().get('complaints', [])
        if complaints:
            c_id = complaints[0]['id']
            print(f"Testing update on {c_id}...")
            # Try to update status
            put_res = requests.put(f'http://localhost:3000/api/admin/complaints/{c_id}/status', headers={'Authorization': 'Bearer ' + t}, json={'status': 'in_progress', 'notes': 'testing'})
            print("Status Code:", put_res.status_code)
            print("Response:", put_res.text)
        else:
            print("No complaints found")
    else:
        print("Failed to fetch complaints")
