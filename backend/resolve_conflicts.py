import re

app_file = r"c:\Users\gowth\Desktop\smart_public\backend\app.py"

with open(app_file, "r", encoding="utf-8") as f:
    text = f.read()

# 1
text = re.sub(
    r"<<<<<<< HEAD\n    R = 6371\.0\n=======\n    R = 6371\.0 # Radius of the Earth in km\n>>>>>>> [a-z0-9]+",
    r"    R = 6371.0 # Radius of the Earth in km",
    text
)

# 2
text = re.sub(
    r"<<<<<<< HEAD\n    dlon = lon2_rad - lon1_rad\n    dlat = lat2_rad - lat1_rad\n    a = math\.sin\(dlat / 2\)\*\*2 \+ math\.cos\(lat1_rad\) \* math\.cos\(lat2_rad\) \* math\.sin\(dlon / 2\)\*\*2\n    c = 2 \* math\.atan2\(math\.sqrt\(a\), math\.sqrt\(1 - a\)\)\n    return R \* c\n\n=======\n\n    dlon = lon2_rad - lon1_rad\n    dlat = lat2_rad - lat1_rad\n\n    a = math\.sin\(dlat / 2\)\*\*2 \+ math\.cos\(lat1_rad\) \* math\.cos\(lat2_rad\) \* math\.sin\(dlon / 2\)\*\*2\n    c = 2 \* math\.atan2\(math\.sqrt\(a\), math\.sqrt\(1 - a\)\)\n\n    distance = R \* c\n    return distance\n>>>>>>> [a-z0-9]+",
    r"\n    dlon = lon2_rad - lon1_rad\n    dlat = lat2_rad - lat1_rad\n\n    a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2\n    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))\n\n    distance = R * c\n    return distance",
    text
)

# 3
text = re.sub(
    r"<<<<<<< HEAD\n\n                    <div style=\"background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n                        <h4 style=\"margin: 0 0 10px 0; color: #856404;\">Reporter Information</h4>\n                        <p style=\"margin: 5px 0;\"><strong>Name:</strong> \{report\.get\('reporter_name', ''\)\}</p>\n                        <p style=\"margin: 5px 0;\"><strong>Email:</strong> \{report\.get\('reporter_email', ''\)\}</p>\n                    </div>\n\n                    <div style=\"background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n                        <h4 style=\"margin: 0 0 10px 0; color: #0c5460;\">Action Required</h4>\n                        <p>Please review this report and take appropriate action within \{get_response_time_for_department\(district, local_body_name, department_code, department_office\)\} hours\.</p>\n                        <p><strong>Expected Response Time:</strong> \{get_response_time_for_department\(district, local_body_name, department_code, department_office\)\} hours</p>\n                    </div>\n\n                    <div style=\"text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;\">\n                        <p style=\"color: #666; font-size: 12px;\">\n                            This is an automated notification from the Public Assets Reporting System\.<br>\n                            Please do not reply to this email directly\.\n                        </p>\n                    </div>\n=======\n>>>>>>> [a-z0-9]+",
    r"\n                    <div style=\"background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n                        <h4 style=\"margin: 0 0 10px 0; color: #856404;\">Reporter Information</h4>\n                        <p style=\"margin: 5px 0;\"><strong>Name:</strong> {report.get('reporter_name', '')}</p>\n                        <p style=\"margin: 5px 0;\"><strong>Email:</strong> {report.get('reporter_email', '')}</p>\n                    </div>\n\n                    <div style=\"background-color: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n                        <h4 style=\"margin: 0 0 10px 0; color: #0c5460;\">Action Required</h4>\n                        <p>Please review this report and take appropriate action within {get_response_time_for_department(district, local_body_name, department_code, department_office)} hours.</p>\n                        <p><strong>Expected Response Time:</strong> {get_response_time_for_department(district, local_body_name, department_code, department_office)} hours</p>\n                    </div>\n\n                    <div style=\"text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd;\">\n                        <p style=\"color: #666; font-size: 12px;\">\n                            This is an automated notification from the Public Assets Reporting System.<br>\n                            Please do not reply to this email directly.\n                        </p>\n                    </div>",
    text
)

# 4
# We want to replace carefully for OTP verify block
c4_search = """<<<<<<< HEAD
                'escalationHistory': [],
            }

        # Verify OTP before saving
        otp_doc = db.collection('otps').document(reporter_email).get()
        if not otp_doc.exists:
            return jsonify({"msg": "OTP not requested or expired. Please request a new OTP."}), 400
            
        otp_data = otp_doc.to_dict()
        if otp_data.get('otp') != otp:
            return jsonify({"msg": "Invalid OTP. Please try again."}), 400
            
        expires_at = otp_data.get('expires_at')
        if expires_at and isinstance(expires_at, datetime) and datetime.now(timezone.utc) > expires_at:
            return jsonify({"msg": "OTP expired. Please request a new OTP."}), 400
            
        # Delete OTP after successful verification
        try:
            db.collection('otps').document(reporter_email).delete()
        except:
            pass


=======
                'escalationHistory': []
            }

>>>>>>>"""
c4_replace = """                'escalationHistory': []
            }

        # Verify OTP before saving
        otp_doc = db.collection('otps').document(reporter_email).get()
        if not otp_doc.exists:
            return jsonify({"msg": "OTP not requested or expired. Please request a new OTP."}), 400
            
        otp_data = otp_doc.to_dict()
        if otp_data.get('otp') != otp:
            return jsonify({"msg": "Invalid OTP. Please try again."}), 400
            
        expires_at = otp_data.get('expires_at')
        if expires_at and isinstance(expires_at, datetime) and datetime.now(timezone.utc) > expires_at:
            return jsonify({"msg": "OTP expired. Please request a new OTP."}), 400
            
        # Delete OTP after successful verification
        try:
            db.collection('otps').document(reporter_email).delete()
        except:
            pass
"""
# Since >>>>>>> is followed by commit hash, let's use re.sub
text = re.sub(
    re.escape(c4_search) + r" [a-z0-9]+",
    c4_replace,
    text
)

# 5
c5_search = """<<<<<<< HEAD
                    existing_reports = db.collection('requests').where('category', '==', new_cat).stream()
=======
                    # Search logic: fetch recent pending/in_progress from same category
                    # We can't do an OR query easily in firestore for 'status', so we filter in Python
                    existing_reports = db.collection('requests').where('category', '==', new_cat).stream()
                    
>>>>>>>"""
c5_replace = """                    # Search logic: fetch recent pending/in_progress from same category
                    # We can't do an OR query easily in firestore for 'status', so we filter in Python
                    existing_reports = db.collection('requests').where('category', '==', new_cat).stream()
                    """
text = re.sub(re.escape(c5_search) + r" [a-z0-9]+", c5_replace, text)

# 6
c6_search = """<<<<<<< HEAD
=======
                            
>>>>>>>"""
c6_replace = """                            """
text = re.sub(re.escape(c6_search) + r" [a-z0-9]+", c6_replace, text)

# 7
c7_search = """<<<<<<< HEAD
=======
                                        # Match found! Cluster them
>>>>>>>"""
c7_replace = """                                        # Match found! Cluster them"""
text = re.sub(re.escape(c7_search) + r" [a-z0-9]+", c7_replace, text)

# 8
c8_search = """<<<<<<< HEAD
                                        if reporter_email and reporter_email not in existing_reporters:
                                            existing_reporters.append(reporter_email)
                                        doc.reference.update({'upvotes': updated_upvotes, 'co_reporters': existing_reporters})
=======
                                        
                                        if reporter_email and reporter_email not in existing_reporters:
                                            existing_reporters.append(reporter_email)
                                            
                                        doc.reference.update({
                                            'upvotes': updated_upvotes,
                                            'co_reporters': existing_reporters
                                        })
>>>>>>>"""
c8_replace = """                                        
                                        if reporter_email and reporter_email not in existing_reporters:
                                            existing_reporters.append(reporter_email)
                                            
                                        doc.reference.update({
                                            'upvotes': updated_upvotes,
                                            'co_reporters': existing_reporters
                                        })"""
text = re.sub(re.escape(c8_search) + r" [a-z0-9]+", c8_replace, text)

# 9
c9_search = """<<<<<<< HEAD
=======
            # Fallback to creating a new report if clustering fails
>>>>>>>"""
c9_replace = """            # Fallback to creating a new report if clustering fails"""
text = re.sub(re.escape(c9_search) + r" [a-z0-9]+", c9_replace, text)


# 10 and 11
empty_conflict = """<<<<<<< HEAD

=======
>>>>>>>"""
text = re.sub(re.escape(empty_conflict) + r" [a-z0-9]+", "", text)


with open(app_file, "w", encoding="utf-8") as f:
    f.write(text)

print("Conflicts resolved programmatically!")
