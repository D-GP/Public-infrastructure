import requests
import json

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOnsiYWRtaW5faWQiOiJWUDlIMnZOa0NIaHd1d293VWtXcnNoSVlrWTcyIiwiZGVwYXJ0bWVudCI6InB3ZCIsImVtYWlsIjoiZ293dGhhbXBuYWlyN0BnbWFpbC5jb20iLCJuYW1lIjoiR293dGhhbSBQIE5haXIiLCJ1aWQiOiJWUDlIMnZOa0NIaHd1d293VWtXcnNoSVlrWTcyIn0sImV4cCI6MTc4MDMyNTQ5NCwiaWF0IjoxNzgwMzIxODk0fQ"

# We purposely omit the signature part of the token because it's long, but the signature check will fail unless this is a real token from the DB. 
# However, the user provided this token in the backend logs (`/api/admin/analytics HTTP/1.1" 422 -`) so it's a structural error, not a signature verification error.
# Let's perform a login and use THAT token to make the analytics request.

# 1. Login to get a valid token (requires Firebase ID token, so we can't easily reproduce /api/admin/login).
# Instead, let's login via the normal `/login` endpoint just to get a valid JWT from the backend.
res_login = requests.post('http://localhost:3000/login', json={'email': 'ggp6264@gmail.com', 'password': 'somepassword'})

token_to_use = None
if res_login.status_code == 200:
    token_to_use = res_login.json().get('token')
else:
    print(f"Login failed: {res_login.status_code} {res_login.text}")
    # Fallback to the provided partial token to see what error it generates
    token_to_use = token

print(f"Using token: {token_to_use[:30]}...")

res = requests.get('http://localhost:3000/api/admin/analytics', headers={'Authorization': f'Bearer {token_to_use}'})
print(f"Status Code: {res.status_code}")
print(f"Response: {res.text}")
