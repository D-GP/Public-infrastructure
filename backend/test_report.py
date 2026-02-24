import requests
import os

# Configuration
BASE_URL = 'http://localhost:3000'
TEST_IMAGE_PATH = 'test_image.jpg'

def create_test_image():
    # Create a dummy image file if it doesn't exist
    if not os.path.exists(TEST_IMAGE_PATH):
        with open(TEST_IMAGE_PATH, 'wb') as f:
            f.write(b'\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00\x48\x00\x48\x00\x00\xFF\xDB\x00\x43\x00\xFF\xFF') # Minimal JPEG header
    return TEST_IMAGE_PATH

def test_create_request():
    print(f"Testing Request Creation on {BASE_URL}...")
    
    image_path = create_test_image()
    
    url = f"{BASE_URL}/api/requests"
    
    # Form data
    payload = {
        'title': 'Test Report from Script',
        'description': 'This is a test report to verify image upload and storage.',
        'location': 'Test Location',
        'department': 'other',
        'priority': 'normal',
        'reporter_name': 'Tester',
        'reporter_email': 'test@example.com',
        'landmark': 'Test Landmark'
    }
    
    # Files
    files = [
        ('images', ('test_image.jpg', open(image_path, 'rb'), 'image/jpeg'))
    ]
    
    try:
        response = requests.post(url, data=payload, files=files)
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Body: {response.text}")
        
        if response.status_code == 200 or response.status_code == 201:
            print("âœ… Request created successfully!")
            data = response.json()
            return data.get('id')
        else:
            print("âŒ Request creation failed.")
            return None
            
    except requests.exceptions.ConnectionError:
        print("âŒ Connection refused. Is the server running?")
        print("Run: python backend/app.py")
        return None
    except Exception as e:
        print(f"âŒ Error: {str(e)}")
        return None

if __name__ == "__main__":
    report_id = test_create_request()
    if report_id:
        print(f"Test complete. Report ID: {report_id}")
    else:
        print("Test failed.")
