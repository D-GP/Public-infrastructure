import os
from flask import Flask
from flask_jwt_extended import JWTManager, create_access_token
import requests

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'your-super-secret-jwt-key-change-it'
jwt = JWTManager(app)

with app.app_context():
    t = create_access_token(identity={'email': 'gowthampnair7@gmail.com', 'admin_id': 'VP9H2vNkCHhwuwowUkWrshIYkY72', 'uid': 'VP9H2vNkCHhwuwowUkWrshIYkY72', 'department': 'pwd', 'name': 'Gowtham P Nair'})
    print('Token:', t[:20])
    res = requests.get('http://localhost:3000/api/admin/complaints', headers={'Authorization': 'Bearer ' + t})
    print(res.status_code, res.text)
