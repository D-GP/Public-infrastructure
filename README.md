# Smart Public (Public Assets Reporting System)

A comprehensive platform to report public infrastructure issues to relevant government authorities (PWD, KSEB, Water Authority, Health Department, etc.). The system comprises a Flutter mobile application for citizens and a Python Flask backend for API services and notifications.

## 📱 Mobile App (Frontend)

Built with **Flutter**, the mobile app allows citizens to easily report issues by capturing photos, recording videos, and logging their geographical location.

### Key Features
- **User Authentication**: Secure login and registration (JWT + Firebase).
- **Report Generation**: Submit reports with precise location (GPS), images, and videos.
- **Categorization**: Report issues to specific departments natively from the app.
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
- **Email Notifications**: Automated email routing to relevant department authorities using `Flask-Mail`.
- **Media Handling**: Secure upload processing for images and videos.
- **Authentication**: JWT-based access tokens with `bcrypt` password hashing.
- **Anti-Spam & Moderation**: Rate Limiting (`Flask-Limiter`), queue-based admin moderation for new reports, and automatic explicit image detection via `google-cloud-vision` AI.

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
