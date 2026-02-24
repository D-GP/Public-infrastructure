# Database Setup Instructions

Your app needs MySQL to be configured. Follow these steps:

## Step 1: Set MySQL Root Password (if not already set)

Open Command Prompt and run:
```
mysql -u root
```

Then in the MySQL prompt, run:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root123';
FLUSH PRIVILEGES;
```

Type `exit` to quit MySQL.

## Step 2: Update server.js with Password

Edit `backend/server.js` and change line 12 from:
```javascript
password: "", // Update with your MySQL password if needed
```

To:
```javascript
password: "root123",
```

(Use whatever password you set in Step 1)

## Step 3: Create Database and Tables

Run this command:
```
mysql -u root -p
```

When prompted, enter the password you set (e.g., `root123`).

Then run these SQL commands:

```sql
CREATE DATABASE IF NOT EXISTS asset_monitor;
USE asset_monitor;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  age INT,
  phone VARCHAR(20),
  gender VARCHAR(10),
  address TEXT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

EXIT;
```

## Step 4: Start the Backend

```
cd backend
npm start
```

You should see:
```
✓ Backend Server running on port 3000
✓ Database Connected successfully
Ready to receive requests...
```

## Step 5: Run Your App

In a new terminal:
```
cd mobile_app/public_asset_app
flutter run
```

Now registration and login should work!

---

**If you need to reset everything:**
```
mysql -u root -p
DROP DATABASE asset_monitor;
# Then repeat Step 3
```
