"""
Department Contacts Configuration for Kerala Government (Pathanamthitta Focus)
Hierarchical routing: District -> Local Body Name -> Department -> Contact Info
"""

# Default fallbacks if a specific local body hasn't specialized their contacts yet
# In a real system, these would be the District-level contacts for each department.
DISTRICT_DEFAULTS = {
    'pwd': {
        'name': 'Public Works Department (PWD)',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',  # District PWD Engineer
        'response_time_hours': 48,
    },
    'kseb': {
        'name': 'Kerala State Electricity Board (KSEB)',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',  # KSEB District Office
        'response_time_hours': 24,
    },
    'water': {
        'name': 'Kerala Water Authority',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 72,
    },
    'health': {
        'name': 'Health Department',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547', # DMO Office
        'response_time_hours': 24,
    },
    'municipal': {
        'name': 'Municipal/Panchayat Office',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547', # District Collectorate / LSGD
        'response_time_hours': 72,
    },
    'police': {
        'name': 'Kerala Police',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',  # District Police Chief Pathanamthitta
        'response_time_hours': 2,
    },
    'other': {
        'name': 'General Administration',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547', # District Collectorate
        'response_time_hours': 72,
    }
}

SUBDIVISION_CONTACTS = {
    # PWD
    'PWD Roads Section, Pathanamthitta': {
        'name': 'PWD Roads Section, Pathanamthitta',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 48,
    },
    'PWD Roads Section, Adoor': {
         'name': 'PWD Roads Section, Adoor',
         'emails': ['gowthampnair123@gmail.com'],
         'whatsapp': '+918281090547',
         'phone': '+918281090547',
         'escalation_emails': ['gowthampnair7@gmail.com'],
         'escalation_whatsapp': '+918281090547',
         'response_time_hours': 48,
    },
    # Police
    'Pathanamthitta Police Station': {
        'name': 'Pathanamthitta Police Station',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'], 
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 2,
    },
    'Adoor Police Station': {
        'name': 'Adoor Police Station',
        'emails': ['gowthampnair123@gmail.com'],
        'whatsapp': '+918281090547',
        'phone': '+918281090547',
        'escalation_emails': ['gowthampnair7@gmail.com'],
        'escalation_whatsapp': '+918281090547',
        'response_time_hours': 2,
    },
    # Can extend for all options. We will fallback to DISTRICT_DEFAULTS if not fully mapped explicitly.
}

DISTRICT_DATA = {
    'Pathanamthitta': {
        'local_bodies': {
            # --- MUNICIPALITIES ---
            'Pathanamthitta': {
                'police': {
                    'name': 'Pathanamthitta Police Station',
                    'emails': ['gowthampnair123@gmail.com'], # Replace with real Pathanamthitta Station Email
                    'whatsapp': '+918281090547',
                    'phone': '+918281090547',
                    'escalation_emails': ['gowthampnair7@gmail.com'], # DPC
                    'escalation_whatsapp': '+918281090547',
                    'response_time_hours': 2,
                },
                'municipal': {
                    'name': 'Pathanamthitta Municipality Secretary',
                    'emails': ['gowthampnair123@gmail.com'],
                    'whatsapp': '+918281090547',
                    'phone': '+918281090547',
                    'escalation_emails': ['gowthampnair7@gmail.com'],
                    'escalation_whatsapp': '+918281090547',
                    'response_time_hours': 72,
                }
            },
            'Adoor': {
                'police': {
                    'name': 'Adoor Police Station',
                    'emails': ['gowthampnair123@gmail.com'],
                    'whatsapp': '+918281090547',
                    'phone': '+918281090547',
                    'escalation_emails': ['gowthampnair7@gmail.com'],
                    'escalation_whatsapp': '+918281090547',
                    'response_time_hours': 2,
                },
                'municipal': {
                     'name': 'Adoor Municipality Secretary',
                     'emails': ['gowthampnair123@gmail.com'],
                     'whatsapp': '+918281090547',
                     'phone': '+918281090547',
                     'escalation_emails': ['gowthampnair7@gmail.com'],
                     'escalation_whatsapp': '+918281090547',
                     'response_time_hours': 72,
                }
            },
            # --- GRAMA PANCHAYATS ---
            'Omalloor': {
                'municipal': {
                    'name': 'Omalloor Grama Panchayat Secretary',
                    'emails': ['gowthampnair123@gmail.com'],
                    'whatsapp': '+918281090547',
                    'phone': '+918281090547',
                    'escalation_emails': ['gowthampnair7@gmail.com'],
                    'escalation_whatsapp': '+918281090547',
                    'response_time_hours': 72,
                }
                # If Omalloor doesn't have a specific overridden 'police', it falls back to DISTRICT_DEFAULTS['police']
            },
            'Malayalapuzha': {
                'municipal': {
                     'name': 'Malayalapuzha Grama Panchayat Secretary',
                     'emails': ['gowthampnair123@gmail.com'],
                     'whatsapp': '+918281090547',
                     'phone': '+918281090547',
                     'escalation_emails': ['gowthampnair7@gmail.com'],
                     'escalation_whatsapp': '+918281090547',
                     'response_time_hours': 72,
                }
            }
            # Note: Other panchayats like Konni, Ranni, etc., will use the DISTRICT_DEFAULTS 
            # until explicitly mapped here. All route correctly to the district level.
        }
    }
}


def get_department_contacts(district, local_body_name, department_code, department_office=None):
    """
    Get contact information for a specific department at a localized level.
    Hierarchy: Exact Department Office -> District -> Local Body -> Department
    Falls back to District Default -> 'Other'
    """
    if department_office and department_office in SUBDIVISION_CONTACTS:
        return SUBDIVISION_CONTACTS[department_office]

    district_node = DISTRICT_DATA.get(district, {})
    local_bodies_node = district_node.get('local_bodies', {})
    local_body_node = local_bodies_node.get(local_body_name, {})
    
    dept = department_code.lower()
    
    # Check if this specific local body has overridden this department
    if dept in local_body_node:
        return local_body_node[dept]
        
    # Check if there is a district-level default
    if dept in DISTRICT_DEFAULTS:
        return DISTRICT_DEFAULTS[dept]
        
    # Ultimate fallback
    return DISTRICT_DEFAULTS['other']

def get_emails_for_department(district, local_body_name, department_code, department_office=None, escalation=False):
    """Get email addresses for a specific local office"""
    contacts = get_department_contacts(district, local_body_name, department_code, department_office)
    if escalation:
        return contacts.get('escalation_emails', contacts['emails'])
    return contacts['emails']

def get_whatsapp_for_department(district, local_body_name, department_code, department_office=None, escalation=False):
    """Get WhatsApp number for a specific local office"""
    contacts = get_department_contacts(district, local_body_name, department_code, department_office)
    if escalation:
        return contacts.get('escalation_whatsapp', contacts['whatsapp'])
    return contacts['whatsapp']

def get_response_time_for_department(district, local_body_name, department_code, department_office=None):
    """Get expected response time for a specific local office"""
    contacts = get_department_contacts(district, local_body_name, department_code, department_office)
    return contacts.get('response_time_hours', 72)

