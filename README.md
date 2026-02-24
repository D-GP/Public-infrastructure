# Smart Public (Public Assets Reporting System)

A comprehensive platform to report public infrastructure issues to relevant government authorities (PWD, KSEB, Water Authority, Health Department, etc.). The system comprises a Flutter mobile application for citizens and a Python Flask backend for API services and notifications.

## 📱 Mobile App (Frontend)

Built with **Flutter**, the mobile app allows citizens to easily report issues by capturing photos, recording videos, and logging their geographical location.

### Key Features
- **User Authentication**: Secure login and registration (JWT + Firebase).
- **Auto-Logout Security**: Sessions are automatically cleared after 2 minutes of user inactivity.
- **Report Generation**: Submit reports with precise location (GPS), images, and videos.
- **Categorization**: Report issues to specific departments natively from the app.
- **Smart Geographic Clustering**: Prevents duplicate reports by automatically grouping issues within a 50-meter radius under a single ticket with an upvote counter.
- **Dashboard**: Track the status of submitted reports (Pending, In Progress, Resolved).
- **Multi-language Support**: Supports English, Malayalam, and Hindi.
- **Profile & Notifications**: Manage personal details and app notifications.

### Tech Stack / Dependencies
- **Framework**: Flutter (Dart)
- **State Management / Networking**: `http`
- **Media**: `image_picker`, `video_player`, `chewie`
- **Location**: `geolocator`
- **Security**: `flutter_secure_storage`, `jwt_decoder`

### Setup Instructions
1. Navigate to the app directory:
   ```bash
   cd mobile_app/public_asset_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## ⚙️ Backend API

Built with **Python Flask**, the backend handles secure data processing, authentication, and communication between citizens and government departments.

### Key Features
- **RESTful API**: Handles mobile app requests (reports, user profiles, stats).
- **Firebase Integration**: Utilizes Firestore for database management and Firebase Admin for secure operations.
- **Automated Escalation Matrix**: A scheduled Cron worker scans reports. If ignored for 15 days, local authorities receive an urgent warning. If ignored for 30 days, reports are auto-escalated to State Ministries with full history logging.
- **Admin Delay System**: Admins can log valid reasons for delay on the dashboard, which pauses the automated escalation timers.
- **Email Notifications**: Automated email routing to relevant department authorities using `Flask-Mail`.
- **Media Handling**: Secure upload processing for images and videos.
- **Authentication**: JWT-based access tokens with `bcrypt` password hashing.

### Tech Stack / Dependencies
- **Framework**: Flask
- **Database**: Firebase (Firestore)
- **Authentication**: Flask-JWT-Extended, bcrypt
- **Integrations**: Flask-Mail, Twilio (WhatsApp notifications)

### Setup Instructions
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Configuration:
   - Create a `.env` file in the `backend` folder based on your configuration needs (JWT secret, Mail server details).
   - Place your `firebaseServiceAccountKey.json` inside the `backend` folder.
5. Run the server:
   ```bash
   python app.py
   ```

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!

## 📝 License
This project is proprietary and confidential.
