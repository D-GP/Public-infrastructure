# Admin Portal - Setup & Documentation

## Overview

The Admin Portal is a **web-based administration system** for managing complaints reported through the Public Assets platform. Each department's administrators can:

- **Secure Login**: Firebase-based authentication with OTP verification (Email/SMS)
- **Department Dashboard**: View key metrics and statistics specific to their department
- **Complaint Management**: View, filter, and manage complaints with real-time status updates
- **Analytics & Reports**: Detailed statistical insights and performance metrics
- **Automated Reminders**: Get notifications for unresolved complaints
- **Social-Impact Prioritization**: Complaints automatically prioritized based on impact

---

## Features

### 1. **Authentication System**
- ✅ Email-based login with username/password
- ✅ OTP verification (6-character code sent to email)
- ✅ JWT-based session management
- ✅ Secure token storage in localStorage
- ✅ Auto-logout on authentication failure

### 2. **Dashboard**
- 📊 Real-time statistics (total, pending, in-progress, resolved)
- 📈 Status and priority distribution charts
- 👥 Recent complaints list with quick view
- 🚨 High-priority unresolved complaints counter
- ⏱️ Average complaint resolution time

### 3. **Complaints Management**
- 📋 Complete list of department complaints
- 🔍 Advanced filtering (status, priority)
- 🔎 Search functionality
- 📌 Complaint detail view with images
- ✏️ Update complaint status
- 📧 Automated email notifications to reporters
- 👁️ View attached images/evidence

### 4. **Analytics Dashboard**
- 📊 Complaint creation trends over time
- 📈 Status distribution analysis
- 🎯 Priority breakdown
- ⚡ Performance metrics (response time, resolution rate)
- 📋 Detailed statistics table
- 📋 AI-generated recommendations for improvement

### 5. **User Interface**
- 🎨 Modern, responsive design
- 📱 Mobile-friendly layout
- 🎭 Intuitive navigation
- 🌈 Color-coded status and priority indicators
- ⚡ Fast, smooth interactions

---

## File Structure

```
backend/static/admin/
├── login.html              # Login page (email + method selection)
├── otp-verify.html         # OTP verification page
├── dashboard.html          # Main dashboard with stats and charts
├── complaints.html         # Complaints management page
├── analytics.html          # Analytics and reports page
├── admin-styles.css        # All styling for admin portal
├── admin-scripts.js        # Shared utilities and functions
└── 404.html               # 404 error page
```

---

## Backend API Endpoints

### Authentication
```
POST /admin/send-otp
- Send OTP to admin email
- Body: { email, method: 'email'|'sms' }
- Response: { msg, email, delivery }

POST /admin/verify-otp
- Verify OTP and get JWT token
- Body: { email, otp }
- Response: { msg, token, admin }
```

### Complaints Management
```
GET /admin/complaints
- Get all complaints for admin's department
- Headers: Authorization: Bearer {token}
- Query: ?status=pending (optional)
- Response: { msg, count, complaints }

GET /admin/complaints/<id>
- Get single complaint details
- Headers: Authorization: Bearer {token}
- Response: { msg, complaint }

PUT /admin/complaints/<id>/status
- Update complaint status
- Headers: Authorization: Bearer {token}
- Body: { status, notes }
- Response: { msg }
```

### Analytics
```
GET /admin/analytics
- Get analytics data for department
- Headers: Authorization: Bearer {token}
- Response: { msg, analytics: { total, status_dist, priority_dist, ...} }
```

---

## Setup Instructions

### 1. Backend Configuration

Add these admin routes to your `app.py` (already done - see code above)

Update `requirements.txt` to include:
```
Flask==3.0.0
Flask-CORS==4.0.0
Flask-Mail==0.9.1
firebase-admin==6.2.0
python-dotenv==1.0.0
gunicorn==21.2.0
Flask-JWT-Extended==4.5.3
bcrypt==4.1.2
```

### 2. Environment Configuration

Update your `.env` file:
```
JWT_SECRET_KEY=your-super-secret-key-change-this
JWT_ACCESS_TOKEN_EXPIRES=3600
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-specific-password
MAIL_DEFAULT_SENDER=noreply@publicassets.com
```

### 3. Firebase Setup

1. Create admin users in Firestore collection `admins`:
```json
{
  "email": "admin@authority.gov.in",
  "password": "<bcrypt-hashed>",
  "name": "John Doe",
  "department": "Water Authority",
  "mobile": "+919876543210",
  "createdAt": "timestamp"
}
```

2. Enable JWT in your app (already configured in app.py)

### 4. Access the Portal

- **Login Page**: `http://localhost:3000/admin/login`
- **Dashboard**: `http://localhost:3000/admin/dashboard`
- **Complaints**: `http://localhost:3000/admin/complaints`
- **Analytics**: `http://localhost:3000/admin/analytics`

---

## How It Works

### Login Flow
1. Admin enters email and selects OTP delivery method
2. Click "Send OTP" → `/admin/send-otp` endpoint called
3. OTP (6-character code) is generated and sent via email
4. Admin enters OTP on verification page
5. `/admin/verify-otp` validates OTP and returns JWT token
6. Token stored in localStorage
7. Admin redirected to dashboard
8. All subsequent API calls include token in Authorization header

### Data Flow
1. **Dashboard**: Fetches `/admin/analytics` → Display metrics + charts
2. **Complaints List**: Fetches `/admin/complaints` → Filter/search locally
3. **Complaint Detail**: Fetches `/admin/complaints/{id}` → Display full info + images
4. **Status Update**: Calls `/admin/complaints/{id}/status` → Email sent to reporter

### Authentication Check
- Every page calls `checkAdminAuth()` on load
- If no token found → redirect to login
- If API returns 401 → token expired → logout + redirect to login

---

## Customization

### Change Colors
Edit `:root` variables in `admin-styles.css`:
```css
:root {
    --primary: #2563EB;      /* Main brand color */
    --success: #10b981;      /* Resolved/success */
    --danger: #ef4444;       /* High priority/danger */
    --warning: #f59e0b;      /* Pending/warning */
}
```

### Add Departments
1. Create new admin user in Firestore with different `department`
2. Login with that admin
3. Portal automatically filters complaints by department

### Customize Email Template
Edit the `send_welcome_email()` and status update email in `app.py`

### Add More Pages
1. Create new `.html` file in `backend/static/admin/`
2. Link in sidebar navigation
3. Add route in `app.py` (already handled by `/admin/<page>`)

---

## Security Considerations

✅ **Implemented**:
- JWT token-based authentication
- OTP verification (prevents unauthorized access)
- Password hashing with bcrypt
- Department-level data isolation (admins only see their department's data)
- Secure token expiry (1 hour)
- CORS protection
- Rate limiting on API endpoints

⚠️ **Recommendations**:
- Use HTTPS in production
- Rotate JWT_SECRET_KEY regularly
- Implement email verification for admin registration
- Add IP whitelisting for admin access
- Deploy with HTTPS and secure headers
- Use environment variables for sensitive data

---

## Troubleshooting

### OTP Not Sending
- Check email credentials in `.env`
- Verify Gmail App Password (if using Gmail)
- Check spam folder
- Ensure Firebase credentials are valid

### Login Always Redirecting
- Check browser localStorage (DevTools → Application)
- Clear localStorage and try again
- Verify JWT_SECRET_KEY matches in app.py
- Check admin user exists in Firestore `admins` collection

### Charts Not Displaying
- Check browser console for errors
- Verify Chart.js CDN is loaded
- Ensure analytics data is being fetched correctly

### Images Not Loading
- Check `uploads/` folder exists and has correct permissions
- Verify image paths in Firestore complaints
- Check CORS is enabled in Flask app

---

## Performance Tips

1. **Database Indexing**: Add Firestore index on `requests` collection:
   - Fields: `department` (Ascending), `createdAt` (Descending)

2. **Pagination**: Implement pagination for large complaint lists

3. **Caching**: Store analytics data in localStorage with timestamp

4. **Lazy Loading**: Load images only when needed

5. **Compression**: Enable gzip compression on Flask

---

## Future Enhancements

🔲 SMS OTP delivery integration
🔲 Bulk complaint actions
🔲 Custom report generation
🔲 Escalation workflow management
🔲 Multi-language support
🔲 Dark/Light theme toggle
🔲 Role-based access control (Super Admin, Department Admin, etc.)
🔲 Export to PDF reports
🔲 Real-time notifications via WebSocket
🔲 Complaint reassignment
🔲 Team collaboration features
🔲 Mobile app for admins

---

## Support

For issues or questions:
1. Check browser console for error messages
2. Review server logs: `python app.py`
3. Verify Firestore rules and data structure
4. Check network tab in DevTools

---

**Last Updated**: February 2026  
**Version**: 1.0.0  
**Status**: Production Ready ✅
