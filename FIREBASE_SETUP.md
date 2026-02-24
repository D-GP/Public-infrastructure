# Firebase Setup for Python Backend

## Prerequisites
- Python 3.8 or higher installed
- Firebase account (free tier available)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name: `smart_public` (or any name)
4. Click "Create project"
5. Wait for project to be created

## Step 2: Enable Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **Create database**
3. Select region (closest to you)
4. Select **Start in test mode** (for development)
5. Click **Create**

## Step 3: Get Service Account Key

1. Go to **Project Settings** (⚙️ icon)
2. Click **Service Accounts** tab
3. Click **Generate New Private Key**
4. A JSON file will download
5. Rename it to `firebaseServiceAccountKey.json`
6. Place it in the `backend` folder

```
smart_public/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   ├── firebaseServiceAccountKey.json  ← Put it here
│   └── ...
└── ...
```

## Step 4: Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

## Step 5: Run the Python Backend

```bash
python app.py
```

You should see:
```
✓ Firebase Initialized successfully
✓ Backend Server running on port 3000
Ready to receive requests...
```

## Step 6: Test Registration/Login

Your Flutter app can now:
- Register new users (saved to Firestore)
- Login with email and password
- All data is in Firebase instead of MySQL

## Firebase Rules (Optional but Recommended)

In Firebase Console, go to **Firestore Database** → **Rules** and replace with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{document=**} {
      allow read, write: if true;  // For development only
      // allow read: if request.auth != null;
      // allow write: if request.auth != null;
    }
  }
}
```

Click **Publish** when done.

## Security Notes

⚠️ **Important for Production:**
- Never commit `firebaseServiceAccountKey.json` to git
- Add to `.gitignore`
- Hash passwords before storing (use bcryptjs)
- Use Firebase Authentication instead of manual password storage
- Set proper Firestore security rules

---

If you face any issues:
1. Check that `firebaseServiceAccountKey.json` is in the `backend` folder
2. Verify Python 3.8+ is installed
3. Make sure all dependencies are installed: `pip install -r requirements.txt`
4. Check Firebase Console shows your project
