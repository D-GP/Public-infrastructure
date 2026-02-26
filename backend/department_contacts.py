"""
Department Contacts Configuration for Kerala Government
This file contains official contact information for various government departments.
Update these with real contact details when available.
"""

DEPARTMENT_CONTACTS = {
    'pwd': {
        'name': 'Public Works Department (PWD)',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # PWD Control Room
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',  # Higher authority
        'response_time_hours': 48,  # Expected response time
        'jurisdiction': 'Roads, bridges, buildings, public infrastructure'
    },
    'kseb': {
        'name': 'Kerala State Electricity Board (KSEB)',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # KSEB Call Center
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',  # KSEB HQ
        'response_time_hours': 24,  # Power issues need quick response
        'jurisdiction': 'Electricity supply, power outages, electrical infrastructure'
    },
    'water': {
        'name': 'Kerala Water Authority',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Kerala Water Authority
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 72,
        'jurisdiction': 'Water supply, sewage, drainage, water infrastructure'
    },
    'health': {
        'name': 'Health Department',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Directorate of Health Services
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 24,  # Health emergencies
        'jurisdiction': 'Public health, hospitals, medical facilities'
    },
    'municipal': {
        'name': 'Municipal Corporation',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Thiruvananthapuram Corporation
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 72,
        'jurisdiction': 'Local municipal services, waste management, local infrastructure'
    },
    'police': {
        'name': 'Kerala Police',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Police Emergency
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',  # Police HQ
        'response_time_hours': 2,  # Emergency response
        'jurisdiction': 'Law enforcement, public safety, emergency response'
    },
    'education': {
        'name': 'Education Department',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # SCERT Kerala
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 168,  # 1 week for educational issues
        'jurisdiction': 'Schools, education infrastructure, academic matters'
    },
    'sanitation': {
        'name': 'Sanitation Department',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Local body sanitation
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 48,
        'jurisdiction': 'Waste management, sanitation, public cleanliness'
    },
    'transport': {
        'name': 'Transport Department',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Transport Commissioner
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 72,
        'jurisdiction': 'Public transport, roads, traffic management'
    },
    'forest': {
        'name': 'Forest Department',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Forest HQ
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 96,
        'jurisdiction': 'Forest protection, wildlife, environmental conservation'
    },
    'other': {
        'name': 'General Administration',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',  # Test WhatsApp number
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 72,
        'jurisdiction': 'General complaints and issues not covered by other departments'
    }
}

def get_department_contacts(department_code):
    """Get contact information for a specific department"""
    return DEPARTMENT_CONTACTS.get(department_code.lower(), DEPARTMENT_CONTACTS['other'])

def get_all_departments():
    """Get all department information"""
    return DEPARTMENT_CONTACTS

def get_emails_for_department(department_code, escalation=False):
    """Get email addresses for a department"""
    contacts = get_department_contacts(department_code)
    if escalation:
        return contacts.get('escalation_emails', contacts['emails'])
    return contacts['emails']

def get_whatsapp_for_department(department_code, escalation=False):
    """Get WhatsApp number for a department"""
    contacts = get_department_contacts(department_code)
    if escalation:
        return contacts.get('escalation_whatsapp', contacts['whatsapp'])
    return contacts['whatsapp']

def get_response_time_for_department(department_code):
    """Get expected response time for a department"""
    contacts = get_department_contacts(department_code)
    return contacts.get('response_time_hours', 72)
