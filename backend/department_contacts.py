"""
Department Contacts Configuration for Kerala Government
This file contains official contact information for various government departments.
Update these with real contact details when available.
"""

DEPARTMENT_CONTACTS = {
    'pwd': {
        'name': 'Public Works Department (PWD)',
        'emails': ['pwd@kerala.gov.in', 'pwd.helpline@kerala.gov.in'],
        'whatsapp': '+91-471-2321900',  # PWD Control Room
        'phone': '+91-471-2321900',
        'escalation_emails': ['pwd.secretary@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2338100',  # Higher authority
        'response_time_hours': 48,  # Expected response time
        'jurisdiction': 'Roads, bridges, buildings, public infrastructure'
    },
    'kseb': {
        'name': 'Kerala State Electricity Board (KSEB)',
        'emails': ['complaint@kseb.in', 'helpdesk@kseb.in'],
        'whatsapp': '+91-1912',  # KSEB Call Center
        'phone': '+91-1912',
        'escalation_emails': ['ceo@kseb.in'],
        'escalation_whatsapp': '+91-471-2448361',  # KSEB HQ
        'response_time_hours': 24,  # Power issues need quick response
        'jurisdiction': 'Electricity supply, power outages, electrical infrastructure'
    },
    'water': {
        'name': 'Kerala Water Authority',
        'emails': ['complaints@kwa.kerala.gov.in', 'helpdesk@kwa.kerala.gov.in'],
        'whatsapp': '+91-471-2323456',  # Kerala Water Authority
        'phone': '+91-471-2323456',
        'escalation_emails': ['chairman@kwa.kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2323456',
        'response_time_hours': 72,
        'jurisdiction': 'Water supply, sewage, drainage, water infrastructure'
    },
    'health': {
        'name': 'Health Department',
        'emails': ['dhs@kerala.gov.in', 'helpline@dhs.kerala.gov.in'],
        'whatsapp': '+91-471-2304480',  # Directorate of Health Services
        'phone': '+91-471-2304480',
        'escalation_emails': ['minister.health@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2333480',
        'response_time_hours': 24,  # Health emergencies
        'jurisdiction': 'Public health, hospitals, medical facilities'
    },
    'municipal': {
        'name': 'Municipal Corporation',
        'emails': ['corporation@kerala.gov.in', 'complaints@municipality.kerala.gov.in'],
        'whatsapp': '+91-471-2471011',  # Thiruvananthapuram Corporation
        'phone': '+91-471-2471011',
        'escalation_emails': ['mayor@corporation.kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2471011',
        'response_time_hours': 72,
        'jurisdiction': 'Local municipal services, waste management, local infrastructure'
    },
    'police': {
        'name': 'Kerala Police',
        'emails': ['controlroom@kerala.gov.in', 'helpline@kerala.gov.in'],
        'whatsapp': '112',  # Police Emergency
        'phone': '112',
        'escalation_emails': ['dgp@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2724488',  # Police HQ
        'response_time_hours': 2,  # Emergency response
        'jurisdiction': 'Law enforcement, public safety, emergency response'
    },
    'education': {
        'name': 'Education Department',
        'emails': ['scert@kerala.gov.in', 'education@kerala.gov.in'],
        'whatsapp': '+91-471-2336468',  # SCERT Kerala
        'phone': '+91-471-2336468',
        'escalation_emails': ['minister.education@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2336468',
        'response_time_hours': 168,  # 1 week for educational issues
        'jurisdiction': 'Schools, education infrastructure, academic matters'
    },
    'sanitation': {
        'name': 'Sanitation Department',
        'emails': ['sanitation@kerala.gov.in', 'swm@kerala.gov.in'],
        'whatsapp': '+91-471-2323456',  # Local body sanitation
        'phone': '+91-471-2323456',
        'escalation_emails': ['director.sanitation@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2323456',
        'response_time_hours': 48,
        'jurisdiction': 'Waste management, sanitation, public cleanliness'
    },
    'transport': {
        'name': 'Transport Department',
        'emails': ['transport@kerala.gov.in', 'rto@kerala.gov.in'],
        'whatsapp': '+91-471-2323215',  # Transport Commissioner
        'phone': '+91-471-2323215',
        'escalation_emails': ['commissioner.transport@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2323215',
        'response_time_hours': 72,
        'jurisdiction': 'Public transport, roads, traffic management'
    },
    'forest': {
        'name': 'Forest Department',
        'emails': ['forest@kerala.gov.in', 'wildlife@kerala.gov.in'],
        'whatsapp': '+91-471-2323045',  # Forest HQ
        'phone': '+91-471-2323045',
        'escalation_emails': ['principalcc@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2323045',
        'response_time_hours': 96,
        'jurisdiction': 'Forest protection, wildlife, environmental conservation'
    },
    'other': {
        'name': 'General Administration',
        'emails': ['complaints@kerala.gov.in', 'helpline@kerala.gov.in'],
        'whatsapp': '+918281090547',  # Test WhatsApp number
        'phone': '+91-471-2333480',
        'escalation_emails': ['chiefsecretary@kerala.gov.in'],
        'escalation_whatsapp': '+91-471-2333480',
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
