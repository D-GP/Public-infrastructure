import os
import re
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_mail import Mail, Message
from werkzeug.utils import secure_filename
import firebase_admin
from firebase_admin import credentials, firestore, auth
from dotenv import load_dotenv
from dotenv import load_dotenv
from flask_jwt_extended import JWTManager, create_access_token, create_refresh_token, jwt_required, get_jwt_identity
import bcrypt
from functools import wraps
import threading
import time
from datetime import datetime, timedelta, timezone
import uuid
import pathlib
import math

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371.0 # Radius of the Earth in km
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    dlon = lon2_rad - lon1_rad
    dlat = lat2_rad - lat1_rad

    a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    distance = R * c
    return distance

# Import our custom modules
from department_contacts import get_emails_for_department, get_response_time_for_department
from whatsapp_service import send_whatsapp_notification, send_whatsapp_reminder, send_whatsapp_escalation

# Load environment variables
load_dotenv()

from flask import Flask, request, jsonify, send_from_directory

app = Flask(__name__)
# JWT Configuration
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "your-super-secret-jwt-key-change-it")
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)
app.config["JWT_REFRESH_TOKEN_EXPIRES"] = timedelta(days=30)
jwt = JWTManager(app)

CORS(app)




# Configure Flask-Mail
app.config['MAIL_SERVER'] = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.getenv('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.getenv('MAIL_USE_TLS', True)
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME', 'your-email@gmail.com')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD', 'your-app-password')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_DEFAULT_SENDER', 'noreply@publicassets.com')

mail = Mail(app)

# Uploads folder
BASE_DIR = pathlib.Path(__file__).resolve().parent
UPLOAD_FOLDER = BASE_DIR / 'uploads'
UPLOAD_FOLDER.mkdir(parents=True, exist_ok=True)
app.config['UPLOAD_FOLDER'] = str(UPLOAD_FOLDER)

# Initialize Firebase
db = None
try:
    # Check if credentials file exists
    creds_path = BASE_DIR / 'firebaseServiceAccountKey.json'
    if creds_path.exists():
        cred = credentials.Certificate(str(creds_path))
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("✓ Firebase Initialized successfully")
    else:
        print("⚠️ Firebase credentials file not found. Running in offline mode.")
        print("📝 To enable Firebase:")
        print("1. Go to https://console.firebase.google.com")
        print("2. Create a new project")
        print("3. Go to Project Settings → Service Accounts")
        print("4. Generate new private key (JSON)")
        print("5. Save it as 'firebaseServiceAccountKey.json' in the backend folder")
        print("6. Restart this server")
except Exception as e:
    print(f"⚠️ Firebase initialization failed: {str(e)}")
    print("📝 Running in offline mode. Check your internet connection and Firebase credentials.")
    print("The app will still run but database operations will be disabled.")

# Validation functions
def validate_email(email):
    pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
    return re.match(pattern, email) is not None

def validate_password(password):
    return password and len(password) >= 6

def validate_name(name):
    return name and len(name.strip()) >= 2

def validate_phone(phone):
    return phone and len(str(phone)) >= 10

def validate_age(age):
    try:
        age_num = int(age)
        return 18 <= age_num <= 120
    except:
        return False

def validate_address(address):
    return address and len(address.strip()) >= 5

# Error handler decorator
def handle_errors(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception as e:
            print(f"Error in {f.__name__}: {str(e)}")
            return jsonify({"msg": str(e)}), 500
    return decorated_function

# Email sending function
def send_welcome_email(user_email, user_name):
    """Send welcome email to newly registered user"""
    try:
        subject = "Welcome to Public Assets Reporting System"
        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <div style="max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; padding: 20px;">
                    <div style="background-color: #2563EB; color: white; padding: 20px; border-radius: 8px 8px 0 0; text-align: center;">
                        <h1 style="margin: 0;">Welcome to Public Assets!</h1>
                    </div>
                    <div style="padding: 20px;">
                        <p>Hi <strong>{user_name}</strong>,</p>
                        
                        <p>Thank you for registering with the Public Assets Reporting System! We're excited to have you on board.</p>
                        
                        <p>With our platform, you can:</p>
                        <ul>
                            <li>Report public issues and problems to relevant government departments</li>
                            <li>Track the status of your reports in real-time</li>
                            <li>Communicate directly with authorities</li>
                            <li>Help improve public infrastructure in your community</li>
                        </ul>
                        
                        <p><strong>Supported Departments:</strong></p>
                        <ul>
                            <li>PWD (Public Works Department)</li>
                            <li>KSEB (Kerala State Electricity Board)</li>
                            <li>Water Authorities</li>
                            <li>Health Department</li>
                            <li>Municipal Corporation</li>
                            <li>Police</li>
                            <li>Education</li>
                            <li>And more...</li>
                        </ul>
                        
                        <p style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; border-left: 4px solid #2563EB;">
                            <strong>📝 Quick Tip:</strong> When reporting a problem, please provide clear details and location information for faster resolution.
                        </p>
                        
                        <p>If you have any questions or need assistance, please don't hesitate to contact our support team.</p>
                        
                        <p>Best regards,<br>
                        <strong>Public Assets Team</strong></p>
                    </div>
                    <div style="background-color: #f5f5f5; padding: 15px; text-align: center; border-radius: 0 0 8px 8px; font-size: 12px; color: #666;">
                        <p>© 2025 Public Assets Reporting System. All rights reserved.</p>
                        <p>This is an automated email. Please do not reply directly.</p>
                    </div>
                </div>
            </body>
        </html>
        """
        
        msg = Message(
            subject=subject,
            recipients=[user_email],
            html=html_body
        )
        
        mail.send(msg)
        print(f"✓ Welcome email sent to: {user_email}")
        return True
    except Exception as e:
        print(f"❌ Failed to send email to {user_email}: {str(e)}")
        return False


def send_report_email_to_authorities(report):
    """Send department-specific email notification for new reports."""
    try:
        department_code = report.get('department', '').lower()
        recipients = get_emails_for_department(department_code)

        if not recipients:
            print(f"⚠️ No email addresses configured for department: {department_code}")
            return False

        priority_emoji = {
            'high': '🚨',
            'medium': '⚠️',
            'normal': '📋',
            'low': 'ℹ️'
        }.get(report.get('priority', 'normal'), '📋')

        subject = f"{priority_emoji} New Public Report: {report.get('title', 'No Title')}"

        # Create professional HTML email
        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #2563EB; color: white; padding: 20px; border-radius: 8px 8px 0 0; text-align: center;">
                    <h1 style="margin: 0;">🚨 New Public Assets Report</h1>
                    <p style="margin: 5px 0 0 0; font-size: 14px;">Department: {department_code.upper()}</p>
                </div>

                <div style="border: 1px solid #ddd; border-radius: 0 0 8px 8px; padding: 20px;">
                    <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                        <h2 style="margin: 0; color: #2563EB;">Report Details</h2>
                        <p style="margin: 5px 0;"><strong>ID:</strong> {report.get('id')}</p>
                        <p style="margin: 5px 0;"><strong>Priority:</strong> {report.get('priority', 'normal').upper()}</p>
                        <p style="margin: 5px 0;"><strong>Status:</strong> {report.get('status', 'pending').upper()}</p>
                    </div>

                    <h3>Title: {report.get('title')}</h3>
                    <p><strong>Description:</strong></p>
                    <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0;">
                        {report.get('description', '')}
                    </div>

                        <div style="flex: 1;">
                            <h4>Location Information</h4>
                            <p><strong>Coordinates:</strong> {report.get('location_text', 'Not provided')}</p>
                            <p><strong>Landmark:</strong> {report.get('landmark', 'Not specified')}</p>
                        </div>
                    </div>
                </div>
            </body>
        </html>
        """

        msg = Message(
            subject=subject,
            recipients=recipients,
            html=html_body
        )

        mail.send(msg)
        print(f"✓ Notification email sent to {department_code} department")

        # Also try WhatsApp
        try:
            whatsapp_number = get_whatsapp_for_department(department_code)
            if whatsapp_number:
                send_whatsapp_notification(whatsapp_number, report)
        except Exception as e:
            pass

        return True
    except Exception as e:
        print(f"❌ Failed to send department email: {str(e)}")
        return False

def send_cooloff_warning_email(report):
    """Send a strong warning that the 15-day deadline passed."""
    try:
        department_code = report.get('department', '').lower()
        recipients = get_emails_for_department(department_code)

        if not recipients:
            return False

        subject = f"⚠️ URGENT: 15-Day Cool-off Warning for Report {report.get('id')}"

        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <h2 style="color: #d9534f;">⚠️ Escalation Warning ⚠️</h2>
                <p>Attention {department_code.upper()} Department,</p>
                <p>This is an automated warning from the Public Assets Reporting System.</p>
                <p>Report <strong>{report.get('id')}</strong> has been inactive for 15 days.</p>
                <p><strong>Title:</strong> {report.get('title')}</p>
                <hr>
                <p><strong>ACTION REQUIRED:</strong> You must resolve this report or log a "Reason for Delay" in the admin dashboard within 15 days, or this issue will be automatically escalated to the State level.</p>
            </body>
        </html>
        """
        
        msg = Message(subject=subject, recipients=recipients, html=html_body)
        mail.send(msg)
        print(f"✓ Cool-off warning sent to {department_code}")
        return True
    except Exception as e:
        print(f"❌ Cool-off email failed: {e}")
        return False

def send_escalation_email(report):
    """Send an escalation email to State Ministry."""
    try:
        department_code = report.get('department', '').lower()
        recipients = get_emails_for_department(department_code, escalation=True)
        # Also CC the original department
        cc_recipients = get_emails_for_department(department_code)

        if not recipients:
            return False

        subject = f"🚨 ESCALATED: District Non-Compliance on Report {report.get('id')}"

        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <div style="background-color: #d9534f; color: white; padding: 20px; text-align: center;">
                    <h1 style="margin: 0;">🚨 ESCALATION NOTICE</h1>
                </div>
                <div style="padding: 20px; border: 1px solid #ddd;">
                    <p>To the State Ministry / Higher Authority,</p>
                    <p>This report has been automatically escalated to your office because the local district department failed to respond within the mandatory 30-day timeframe.</p>
                    
                    <h3 style="color: #2563EB;">Report Details</h3>
                    <p><strong>ID:</strong> {report.get('id')}</p>
                    <p><strong>Department:</strong> {department_code.upper()}</p>
                    <p><strong>Title:</strong> {report.get('title')}</p>
                    <p><strong>Description:</strong> {report.get('description', '')}</p>
                    <p><strong>Location:</strong> {report.get('location_text', 'Not provided')}</p>
                </div>
            </body>
        </html>
        """
        
        msg = Message(subject=subject, recipients=recipients, cc=cc_recipients, html=html_body)
        mail.send(msg)
        print(f"✓ Escalation email sent to {department_code} higher authorities")
        return True
    except Exception as e:
        print(f"❌ Escalation email failed: {e}")
        return False

                    <div style="background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;">
                        <h4 style="margin: 0 0 10px 0; color: #856404;">Reporter Information</h4>
                        <p style="margin: 5px 0;"><strong>Name:</strong> {report.get('reporter_name', '')}</p>
                        <p style="margin: 5px 0;"><strong>Email:</strong> {report.get('reporter_email', '')}</p>
                    </div>

                    <div style="background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 5px; margin: 20px 0;">
                        <h4 style="margin: 0 0 10px 0; color: #0c5460;">Action Required</h4>
                        <p>Please review this report and take appropriate action within {get_response_time_for_department(department_code)} hours.</p>
                        <p><strong>Expected Response Time:</strong> {get_response_time_for_department(department_code)} hours</p>
                    </div>

                    <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;">
                        <p style="color: #666; font-size: 12px;">
                            This is an automated notification from the Public Assets Reporting System.<br>
                            Please do not reply to this email directly.
                        </p>
                    </div>
                </div>
            </body>
        </html>
        """

        msg = Message(subject=subject, recipients=recipients, html=html_body)

        # Attach images if any
        images = report.get('images', [])
        for i, img_path in enumerate(images[:5]):  # Limit to 5 attachments
            try:
                # Handle both absolute paths (legacy) and relative paths (new)
                if 'uploads/' in img_path:
                     # Remove 'uploads/' prefix if present and join with UPLOAD_FOLDER
                     filename_only = os.path.basename(img_path)
                     full_path = str(UPLOAD_FOLDER / filename_only)
                else:
                     full_path = img_path
                
                with open(full_path, 'rb') as fp:
                    filename = f"report_{report.get('id')}_image_{i+1}.jpg"
                    msg.attach(filename, 'image/jpeg', fp.read())
            except Exception as e:
                print(f"⚠️ Could not attach image {img_path}: {str(e)}")

        mail.send(msg)
        print(f"✓ Email sent to {department_code.upper()}: {', '.join(recipients)} for report {report.get('id')}")

        # Also send WhatsApp notification
        try:
            whatsapp_result = send_whatsapp_notification(department_code, report)
            if whatsapp_result.get('success'):
                print(f"✓ WhatsApp notification sent for report {report.get('id')}")
            else:
                print(f"⚠️ WhatsApp notification failed: {whatsapp_result.get('error')}")
        except Exception as e:
            print(f"⚠️ WhatsApp notification error: {str(e)}")

        return True
    except Exception as e:
        print(f"❌ Failed to notify authorities: {str(e)}")
        return False


def send_completion_email_to_reporter(report):
    """Send completion email to the person who reported the issue."""
    try:
        reporter_email = report.get('reporter_email')
        if not reporter_email:
            print("⚠️ No reporter email; skipping completion email")
            return False

        subject = f"Your Report Completed: {report.get('title', '')}"
        html = f"<p>Hi {report.get('reporter_name', '')},</p>"
        html += f"<p>Your report titled <strong>{report.get('title')}</strong> (ID: {report.get('id')}) has been marked as completed by the authorities.</p>"
        html += f"<p>Notes: {report.get('notes', '')}</p>"
        html += "<p>Thank you for helping improve the community.</p>"

        msg = Message(subject=subject, recipients=[reporter_email], html=html)
        mail.send(msg)
        print(f"✓ Completion email sent to reporter: {reporter_email}")
        return True
    except Exception as e:
        print(f"❌ Failed to send completion email: {str(e)}")
        return False

# REGISTER ENDPOINT
@app.route('/register', methods=['POST'])
@handle_errors
def register():
    if db is None:
        return jsonify({"msg": "Database not available. Please check your Firebase configuration."}), 503

    data = request.get_json()

    # Extract fields
    name = data.get('name', '').strip()
    age = data.get('age')
    phone = data.get('phone', '').strip()
    gender = data.get('gender', '')
    address = data.get('address', '').strip()
    email = data.get('email', '').strip()
    password = data.get('password', '')

    # Validate required fields
    if not all([name, age, phone, gender, address, email, password]):
        return jsonify({"msg": "All fields are required"}), 400

    # Validate individual fields
    if not validate_name(name):
        return jsonify({"msg": "Name must be at least 2 characters"}), 400

    if not validate_age(age):
        return jsonify({"msg": "Age must be between 18 and 120"}), 400

    if not validate_phone(phone):
        return jsonify({"msg": "Phone number must be at least 10 digits"}), 400

    if not validate_email(email):
        return jsonify({"msg": "Invalid email format"}), 400

    if not validate_password(password):
        return jsonify({"msg": "Password must be at least 6 characters"}), 400

    if gender not in ['Male', 'Female']:
        return jsonify({"msg": "Invalid gender selection"}), 400

    if not validate_address(address):
        return jsonify({"msg": "Address must be at least 5 characters"}), 400

    try:
        # Check if email already exists
        existing_users = db.collection('users').where('email', '==', email).stream()
        if any(existing_users):
            return jsonify({"msg": "Email already exists. Please use a different email."}), 400

        # Create user in Firestore
        user_data = {
            'name': name,
            'age': int(age),
            'phone': phone,
            'gender': gender,
            'address': address,
            'email': email,
            'password': bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8'),
            'created_at': firestore.SERVER_TIMESTAMP
        }

        db.collection('users').add(user_data)
        print(f"✓ New user registered: {email}")

        # Send welcome email
        email_sent = send_welcome_email(email, name)

        return jsonify({
            "msg": "Registered Successfully",
            "email_sent": email_sent
        }), 200

    except Exception as e:
        print(f"Register error: {str(e)}")
        return jsonify({"msg": "Registration failed. Please try again later."}), 500

# ADMIN AUTH ENDPOINTS
@app.route('/api/admin/register', methods=['POST'])
@handle_errors
def admin_register():
    if db is None:
        return jsonify({"msg": "Database not available"}), 503

    data = request.get_json()
    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    password = data.get('password', '')
    department = data.get('department', '')

    if not all([name, email, password, department]):
        return jsonify({"msg": "All fields are required"}), 400

    if not validate_email(email):
        return jsonify({"msg": "Invalid email format"}), 400
    
    if len(password) < 6:
        return jsonify({"msg": "Password must be at least 6 characters"}), 400

    # Check existing admin
    existing = db.collection('admins').where('email', '==', email).stream()
    if any(existing):
        return jsonify({"msg": "Admin email already exists"}), 400

    admin_data = {
        'name': name,
        'email': email,
        'password': password, # Note: Hash in production
        'department': department,
        'role': 'admin',
        'createdAt': firestore.SERVER_TIMESTAMP
    }

    db.collection('admins').add(admin_data)
    print(f"✓ New admin registered: {email}")

    return jsonify({"msg": "Admin registered successfully"}), 201

@app.route('/api/admin/login', methods=['POST'])
@handle_errors
def admin_login_api():
    if db is None:
        return jsonify({"msg": "Database not available"}), 503

    data = request.get_json()
    email = data.get('email', '').strip()
    password = data.get('password', '')

    if not email or not password:
        return jsonify({"msg": "Email and password required"}), 400

    # Query admins collection
    admins_ref = db.collection('admins').where('email', '==', email).stream()
    admin_list = list(admins_ref)

    if admin_list:
        admin_doc = admin_list[0]
        admin_data = admin_doc.to_dict()
        
        if admin_data.get('password') == password:
            print(f"✓ Admin logged in: {email}")
            return jsonify({
                "msg": "Login Success",
                "user": {
                    "id": admin_doc.id,
                    "name": admin_data.get('name'),
                    "email": admin_data.get('email'),
                    "department": admin_data.get('department'),
                    "role": "admin"
                },
                "token": f"admin_{admin_doc.id}" # Simple token for demo
            }), 200
        else:
            return jsonify({"msg": "Invalid credentials"}), 401
    
    return jsonify({"msg": "Invalid credentials"}), 401

# CUSTOMER LOGIN ENDPOINT (Keep for mobile app)
@app.route('/login', methods=['POST'])
@handle_errors
def login():
    if db is None:
        return jsonify({"msg": "Database not available. Please check your Firebase configuration."}), 503

    data = request.get_json()

    # Extract fields
    email = data.get('email', '').strip()
    password = data.get('password', '')

    # Validate required fields
    if not email or not password:
        return jsonify({"msg": "Email and password are required"}), 400

    if not validate_email(email):
        return jsonify({"msg": "Invalid email format"}), 400

    if not validate_password(password):
        return jsonify({"msg": "Invalid password"}), 400

    try:
        # Query Firestore for user by email first
        users_ref = db.collection('users').where('email', '==', email).stream()
        user_list = list(users_ref)

        if user_list:
            user_doc = user_list[0]
            user_data = user_doc.to_dict()
            user_id = user_doc.id

            # Check password (handle both hashed and legacy plain text)
            stored_password = user_data.get('password')
            is_valid = False
            
            # 1. Try bcrypt verification first (if it looks like a hash)
            try:
                if stored_password and stored_password.startswith('$2b$'):
                    is_valid = bcrypt.checkpw(password.encode('utf-8'), stored_password.encode('utf-8'))
                else:
                    # 2. Fallback to plain text (legacy)
                    if stored_password == password:
                        is_valid = True
                        # Migrate to hash
                        new_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
                        db.collection('users').document(user_id).update({'password': new_hash})
                        print(f"✓ Migrated user {email} to hashed password")
            except Exception as e:
                print(f"Password verification error: {e}")
                is_valid = False

            if is_valid:
                print(f"✓ User logged in: {email}")
                access_token = create_access_token(identity=user_id)
                refresh_token = create_refresh_token(identity=user_id)
                
                return jsonify({
                    "msg": "Login Success",
                    "user": {
                        "id": user_id,
                        "name": user_data.get('name'),
                        "email": user_data.get('email')
                    },
                    "token": access_token, # Keep for backward compatibility
                    "access_token": access_token,
                    "refresh_token": refresh_token
                }), 200
            else:
                print(f"✗ Invalid password for: {email}")
                return jsonify({"msg": "Invalid email or password"}), 401
        else:
            print(f"✗ User not found: {email}")
            return jsonify({"msg": "Invalid email or password"}), 401

    except Exception as e:
        print(f"Login error: {str(e)}")
        return jsonify({"msg": "Login failed. Please try again later."}), 500

# USER PROFILE ENDPOINTS
@app.route('/api/users/<user_id>', methods=['GET'])
@handle_errors
@jwt_required()
def get_user_profile(user_id):
    current_user_id = get_jwt_identity()
    
    # Allow users to only access their own profile (or admins)
    # in a real app, you'd check roles. For now, strict owner check:
    if current_user_id != user_id:
         # Check if it's an admin (optional, for now just block)
         pass 

    try:
        doc = db.collection('users').document(user_id).get()
        if doc.exists:
            user_data = doc.to_dict()
            # Remove sensitive data
            user_data.pop('password', None)
            user_data['id'] = doc.id
            return jsonify({
                "msg": "Success",
                "user": user_data
            }), 200
        else:
            return jsonify({"msg": "User not found"}), 404
    except Exception as e:
        print(f"Error fetching user profile: {str(e)}")
        return jsonify({"msg": "Failed to fetch profile", "error": str(e)}), 500

@app.route('/api/users/<user_id>', methods=['PUT'])
@handle_errors
@jwt_required()
def update_user_profile(user_id):
    current_user_id = get_jwt_identity()
    
    if current_user_id != user_id:
        return jsonify({"msg": "Unauthorized"}), 403

    try:
        data = request.get_json()
        if not data:
            return jsonify({"msg": "No data provided"}), 400

        # Fields allowed to be updated
        allowed_fields = [
            'name', 'phone', 'address', 'age', 'gender',
            'notification_settings' 
        ]
        
        update_data = {}
        for field in allowed_fields:
            if field in data:
                update_data[field] = data[field]

        if not update_data:
             return jsonify({"msg": "No valid fields to update"}), 400

        db.collection('users').document(user_id).update(update_data)
        
        print(f"✓ User profile updated: {user_id}")
        return jsonify({"msg": "Profile updated successfully"}), 200
        
    except Exception as e:
        print(f"Error updating user profile: {str(e)}")
        return jsonify({"msg": "Failed to update profile", "error": str(e)}), 500

# REFRESH TOKEN ENDPOINT
@app.route('/api/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    current_user = get_jwt_identity()
    new_access_token = create_access_token(identity=current_user)
    return jsonify(access_token=new_access_token), 200

# GET ALL REQUESTS ENDPOINT
@app.route('/api/requests', methods=['GET'])
@handle_errors
def get_requests():
    try:
        # Support optional query params for filtering by department and status
        department = request.args.get('department')
        status = request.args.get('status')
        user_id = request.args.get('userId')  # Get userId filter

        print(f"DEBUG: get_requests called with department={department}, status={status}, userId={user_id}")

        # Build query based on filters
        if department and status:
            # If both filters are present, we need to handle this differently to avoid composite index issues
            # Fetch all documents and filter in Python
            print("DEBUG: Using both filters - fetching all and filtering in Python")
            requests_ref = db.collection('requests').stream()
            requests_list = []
            for doc in requests_ref:
                request_data = doc.to_dict()
                request_data['id'] = doc.id
                # Apply filters in Python
                if (not department or request_data.get('department') == department) and \
                   (not status or request_data.get('status') == status) and \
                    (not user_id or request_data.get('userId') == user_id):
                    requests_list.append(request_data)
        elif department:
            # Single filter by department - fetch all and filter in Python to avoid index issues
            print(f"DEBUG: Using department filter: {department}")
            requests_ref = db.collection('requests').stream()
            requests_list = []
            for doc in requests_ref:
                request_data = doc.to_dict()
                request_data['id'] = doc.id
                if request_data.get('department') == department:
                    if not user_id or request_data.get('userId') == user_id:
                        requests_list.append(request_data)
            # Sort by createdAt in descending order (most recent first)
            requests_list.sort(key=lambda x: x.get('createdAt'), reverse=True)
        elif status:
            # Single filter by status - fetch all and filter in Python to avoid index issues
            print(f"DEBUG: Using status filter: {status}")
            requests_ref = db.collection('requests').stream()
            requests_list = []
            for doc in requests_ref:
                request_data = doc.to_dict()
                request_data['id'] = doc.id
                if request_data.get('status') == status:
                    if not user_id or request_data.get('userId') == user_id:
                        requests_list.append(request_data)
            # Sort by createdAt in descending order (most recent first)
            requests_list.sort(key=lambda x: x.get('createdAt'), reverse=True)
        else:
            # No filters - can use order_by directly
            print("DEBUG: No filters - using order_by")
            requests_ref = db.collection('requests').order_by('createdAt', direction=firestore.Query.DESCENDING).stream()
            requests_list = []
            for doc in requests_ref:
                request_data = doc.to_dict()
                request_data['id'] = doc.id
                if not user_id or request_data.get('userId') == user_id:
                    requests_list.append(request_data)

        print(f"✓ Fetched {len(requests_list)} requests")
        return jsonify({
            "msg": "Success",
            "requests": requests_list
        }), 200
    except Exception as e:
        print(f"Error fetching requests: {str(e)}")
        return jsonify({"msg": "Failed to fetch requests", "error": str(e)}), 500

# CREATE REQUEST ENDPOINT
@app.route('/api/requests', methods=['POST'])
@handle_errors
def create_request():
    try:
        # Support JSON or multipart/form-data with files
        if request.content_type and request.content_type.startswith('multipart/form-data'):
            form = request.form
            title = form.get('title')
            description = form.get('description')
            location_text = form.get('location')
            department = form.get('department')
            category = form.get('category', department)
            priority = form.get('priority', 'normal')
            reporter_name = form.get('reporter_name')
            reporter_email = form.get('reporter_email')
            landmark = form.get('landmark')

            images = []
            for f in request.files.getlist('images'):
                if f and f.filename:
                    filename = secure_filename(f.filename)
                    unique_name = f"{uuid.uuid4().hex}_{filename}"
                    save_path = UPLOAD_FOLDER / unique_name
                    f.save(str(save_path))
                    # Store relative path for web access
                    images.append(f'uploads/{unique_name}')

            request_data = {
                'title': title,
                'description': description,
                'location': {'text': location_text},
                'location_text': location_text,
                'department': department,
                'category': category,
                'priority': priority,
                'status': 'pending',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'reporter_name': reporter_name,
                'reporter_email': reporter_email,
                'landmark': landmark,
                'images': images,
                'lastReminderAt': None,
                'userId': request.form.get('userId'), # Add userId from form
                'escalationLevel': 1,
                'isCoolOffPeriod': False,
                'lastActionDate': firestore.SERVER_TIMESTAMP,
                'escalationHistory': []
            }
        else:
            data = request.get_json()
            # Validate required fields
            required_fields = ['title', 'description', 'location', 'department', 'priority']
            if not data or not all(field in data for field in required_fields):
                return jsonify({"msg": "Missing required fields"}), 400

            request_data = {
                'title': data.get('title'),
                'description': data.get('description'),
                'location': data.get('location'),
                'location_text': data.get('location') if isinstance(data.get('location'), str) else '',
                'department': data.get('department'),
                'category': data.get('category', data.get('department')),
                'priority': data.get('priority', 'normal'),
                'status': 'pending',
                'createdAt': firestore.SERVER_TIMESTAMP,
                'userId': data.get('userId'),
                'images': data.get('images', []),
                'reporter_name': data.get('reporter_name'),
                'reporter_email': data.get('reporter_email'),
                'landmark': data.get('landmark'),
                'lastReminderAt': None,
                'escalationLevel': 1,
                'isCoolOffPeriod': False,
                'lastActionDate': firestore.SERVER_TIMESTAMP,
                'escalationHistory': []
            }

        # ---- NEW CLUSTERING LOGIC ----
        try:
            loc_text = request_data.get('location_text', '')
            if loc_text and ',' in loc_text:
                parts = loc_text.split(',')
                if len(parts) >= 2:
                    new_lat = float(parts[0].strip())
                    new_lon = float(parts[1].strip())
                    new_cat = request_data.get('category')
                    
                    # Search logic: fetch recent pending/in_progress from same category
                    # We can't do an OR query easily in firestore for 'status', so we filter in Python
                    existing_reports = db.collection('requests').where('category', '==', new_cat).stream()
                    
                    for doc in existing_reports:
                        doc_data = doc.to_dict()
                        if doc_data.get('status') not in ['pending', 'in_progress']:
                            continue
                            
                        existing_loc = doc_data.get('location_text', '')
                        if existing_loc and ',' in existing_loc:
                            e_parts = existing_loc.split(',')
                            if len(e_parts) >= 2:
                                try:
                                    e_lat = float(e_parts[0].strip())
                                    e_lon = float(e_parts[1].strip())
                                    dist = calculate_distance(new_lat, new_lon, e_lat, e_lon)
                                    if dist <= 0.05:  # 50 meters
                                        # Match found! Cluster them
                                        existing_upvotes = doc_data.get('upvotes', 1)
                                        updated_upvotes = existing_upvotes + 1
                                        existing_reporters = doc_data.get('co_reporters', [])
                                        reporter_email = request_data.get('reporter_email')
                                        
                                        if reporter_email and reporter_email not in existing_reporters:
                                            existing_reporters.append(reporter_email)
                                            
                                        doc.reference.update({
                                            'upvotes': updated_upvotes,
                                            'co_reporters': existing_reporters
                                        })
                                        print(f"✓ Clustered with existing request: {doc.id}")
                                        return jsonify({"msg": "Report clustered with identical existing issue", "id": doc.id}), 200
                                except ValueError:
                                    pass
        except Exception as cluster_err:
            print(f"Clustering error: {cluster_err}")
            # Fallback to creating a new report if clustering fails
        # ---- END CLUSTERING LOGIC ----

        request_data['upvotes'] = 1
        request_data['co_reporters'] = [request_data.get('reporter_email')] if request_data.get('reporter_email') else []

        # Save to Firestore
        doc_ref = db.collection('requests').add(request_data)
        request_id = doc_ref[1].id
        # update the document with the generated id
        db.collection('requests').document(request_id).update({'id': request_id})

        # Attach id to local copy for email
        request_data['id'] = request_id

        # Notify authorities
        try:
            send_report_email_to_authorities(request_data)
        except Exception:
            pass

        print(f"✓ New request created: {request_data.get('title')} (id: {request_id})")
        return jsonify({"msg": "Request created successfully", "id": request_id}), 200
    except Exception as e:
        print(f"Error creating request: {str(e)}")
        return jsonify({"msg": "Failed to create request", "error": str(e)}), 500

# GET REQUEST BY ID
@app.route('/api/requests/<request_id>', methods=['GET'])
@handle_errors
def get_request(request_id):
    try:
        doc = db.collection('requests').document(request_id).get()
        
        if doc.exists:
            request_data = doc.to_dict()
            request_data['id'] = doc.id
            return jsonify({
                "msg": "Success",
                "request": request_data
            }), 200
        else:
            return jsonify({"msg": "Request not found"}), 404
    except Exception as e:
        print(f"Error fetching request: {str(e)}")
        return jsonify({"msg": "Failed to fetch request", "error": str(e)}), 500

# UPDATE REQUEST ENDPOINT
@app.route('/api/requests/<request_id>', methods=['PUT'])
@handle_errors
def update_request(request_id):
    try:
        data = request.get_json()

        if not data:
            return jsonify({"msg": "No data provided"}), 400

        # Fetch existing document to detect status changes
        doc_ref = db.collection('requests').document(request_id)
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"msg": "Request not found"}), 404

        old = doc.to_dict() or {}

        # Update only provided fields
        update_data = {}
        updateable_fields = ['status', 'priority', 'description', 'notes']
        for field in updateable_fields:
            if field in data:
                update_data[field] = data[field]

        if not update_data:
            return jsonify({"msg": "No fields to update"}), 400

        doc_ref.update(update_data)

        # If status changed to completed, notify reporter
        new_status = update_data.get('status')
        if new_status and new_status.lower() in ['completed', 'complete', 'done', 'resolved']:
            updated_doc = doc_ref.get().to_dict()
            try:
                send_completion_email_to_reporter(updated_doc)
            except Exception:
                pass

        print(f"✓ Request updated: {request_id}")
        return jsonify({"msg": "Request updated successfully"}), 200
    except Exception as e:
        print(f"Error updating request: {str(e)}")
        return jsonify({"msg": "Failed to update request", "error": str(e)}), 500

# ADD NOTE / REASON FOR DELAY ENDPOINT
@app.route('/api/requests/<request_id>/note', methods=['PUT'])
@handle_errors
def add_request_note(request_id):
    try:
        data = request.get_json()
        note = data.get('note', '').strip()
        admin_name = data.get('admin', 'Admin')

        if not note:
            return jsonify({"msg": "Note text is required"}), 400

        doc_ref = db.collection('requests').document(request_id)
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"msg": "Request not found"}), 404

        existing_data = doc.to_dict() or {}
        history = existing_data.get('escalationHistory', [])
        
        history.append({
            'date': firestore.SERVER_TIMESTAMP,
            'note': f"[{admin_name}] Reason for delay logged: {note}"
        })

        # By resetting lastActionDate, we freeze/reset the 15-day timer!
        doc_ref.update({
            'escalationHistory': history,
            'lastActionDate': firestore.SERVER_TIMESTAMP
        })

        print(f"✓ Added delay reason to request: {request_id}")
        return jsonify({"msg": "Reason logged. Escalation timer reset."}), 200
    except Exception as e:
        print(f"Error adding note: {str(e)}")
        return jsonify({"msg": "Failed to add note", "error": str(e)}), 500

# HEALTH CHECK ENDPOINT
@app.route('/health', methods=['GET'])
def health():
    try:
        # Test Firebase connection
        db.collection('_test').document('_test').set({'test': True})
        return jsonify({"msg": "Server is running", "firebase": "connected"}), 200
    except:
        return jsonify({"msg": "Server is running", "firebase": "not connected"}), 200


@app.route('/uploads/<path:filename>', methods=['GET'])
def uploaded_file(filename):
    try:
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename, as_attachment=False)
    except Exception as e:
        return jsonify({"msg": "File not found", "error": str(e)}), 404


def reminder_worker_loop():
    """Background loop that checks for pending reports and emails authorities if overdue."""
    check_interval = int(os.getenv('REMINDER_CHECK_SECONDS', 3600))
    reminder_hours = int(os.getenv('REMINDER_INTERVAL_HOURS', 24))
    repeat_hours = int(os.getenv('REMINDER_REPEAT_HOURS', 24))

    print(f"🔁 Reminder worker started: checking every {check_interval}s for reports older than {reminder_hours}h")

    while True:
        try:
            now = datetime.now(timezone.utc)
            cutoff = now - timedelta(hours=reminder_hours)

            docs = db.collection('requests').where(filter=firestore.FieldFilter('status', '==', 'pending')).stream()
            for doc in docs:
                data = doc.to_dict() or {}
                created = data.get('createdAt')
                last_rem = data.get('lastReminderAt')

                # Normalize created to datetime
                if hasattr(created, 'ToDatetime'):
                    created_dt = created.ToDatetime()
                elif isinstance(created, datetime):
                    created_dt = created
                else:
                    created_dt = None

                send_reminder = False
                if created_dt and created_dt < cutoff:
                    if not last_rem:
                        send_reminder = True
                    else:
                        # last_rem may be stored as datetime-like
                        if hasattr(last_rem, 'ToDatetime'):
                            last_dt = last_rem.ToDatetime()
                        elif isinstance(last_rem, datetime):
                            last_dt = last_rem
                        else:
                            last_dt = None

                        if not last_dt or (now - last_dt) > timedelta(hours=repeat_hours):
                            send_reminder = True

                if send_reminder:
                    try:
                        report = data.copy()
                        report['id'] = doc.id
                        send_report_email_to_authorities(report)
                        db.collection('requests').document(doc.id).update({'lastReminderAt': firestore.SERVER_TIMESTAMP})
                        print(f"🔔 Reminder sent for request: {doc.id}")
                    except Exception as e:
                        print(f"❌ Failed to send reminder for {doc.id}: {str(e)}")
        except Exception as e:
            print(f"Reminder worker error: {str(e)}")

        # ---- ESCALATION LOGIC CHECK ----
        try:
            now = datetime.now(timezone.utc)
            # Use real days or debug minutes based on environment switch
            is_debug = os.getenv('ESCALATION_DEBUG', 'false').lower() == 'true'
            cool_off_delta = timedelta(minutes=1) if is_debug else timedelta(days=15)
            escalate_delta = timedelta(minutes=2) if is_debug else timedelta(days=30)
            
            pending_docs = db.collection('requests').where(filter=firestore.FieldFilter('status', 'in', ['pending', 'in_progress'])).stream()
            
            for doc in pending_docs:
                data = doc.to_dict() or {}
                level = data.get('escalationLevel', 1)
                is_cool = data.get('isCoolOffPeriod', False)
                last_action = data.get('lastActionDate')
                
                # We only escalate level 1 stuff locally right now
                if level != 1:
                    continue
                    
                if last_action:
                    if hasattr(last_action, 'ToDatetime'):
                        la_dt = last_action.ToDatetime().replace(tzinfo=timezone.utc)
                    elif isinstance(last_action, datetime):
                        la_dt = last_action.replace(tzinfo=timezone.utc)
                    else:
                        continue
                        
                    time_elapsed = now - la_dt
                    
                    doc_ref = db.collection('requests').document(doc.id)
                    history_list = data.get('escalationHistory', [])
                    
                    # 1. Check Level 2 Escalation (30 Days Total)
                    if time_elapsed > escalate_delta:
                        print(f"🚨 ESCALATING Report {doc.id} to State Level!")
                        history_list.append({
                            'date': firestore.SERVER_TIMESTAMP,
                            'note': 'District failed to respond within timeframe. Escalated to State authorities.'
                        })
                        doc_ref.update({
                            'escalationLevel': 2,
                            'escalationHistory': history_list
                        })
                        
                        # Trigger email
                        report_copy = data.copy()
                        report_copy['id'] = doc.id
                        send_escalation_email(report_copy)
                        
                    # 2. Check Level 1 Warning (15 Days)
                    elif time_elapsed > cool_off_delta and not is_cool:
                        print(f"⚠️ Report {doc.id} entered cool-off period. Warning District!")
                        doc_ref.update({
                            'isCoolOffPeriod': True
                        })
                        # Trigger warning email specifically for cooloff
                        report_copy = data.copy()
                        report_copy['id'] = doc.id
                        send_cooloff_warning_email(report_copy)

        except Exception as esc_err:
            print(f"Escalation worker error: {str(esc_err)}")

        time.sleep(check_interval)


def start_reminder_worker():
    # Only start the reminder worker if Firestore `db` is available
    if 'db' not in globals() or db is None:
        print("⚠️ Reminder worker not started because Firestore (db) is not available.")
        return

    t = threading.Thread(target=reminder_worker_loop, daemon=True)
    t.start()

# 404 HANDLER
@app.errorhandler(404)
def not_found(error):
    return jsonify({"msg": "Endpoint not found"}), 404

# Run the app
if __name__ == '__main__':
    PORT = int(os.getenv('PORT', 3000))
    print(f"\n✓ Backend Server running on port {PORT}")
    print("Ready to receive requests...\n")
    # Start reminder worker
    try:
        start_reminder_worker()
    except Exception as e:
        print(f"⚠️ Could not start reminder worker: {str(e)}")

    app.run(debug=False, host='0.0.0.0', port=PORT)
