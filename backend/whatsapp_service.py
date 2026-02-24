
"""
WhatsApp Messaging Service using Twilio
Handles sending WhatsApp messages to government departments
"""

import os
import logging
try:
    from twilio.rest import Client
except ImportError:
    Client = None

import requests

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class WhatsAppService:
    def __init__(self):
        # Twilio credentials from environment variables
        self.account_sid = os.getenv('TWILIO_ACCOUNT_SID')
        self.auth_token = os.getenv('TWILIO_AUTH_TOKEN')
        self.from_number = os.getenv('TWILIO_WHATSAPP_NUMBER')

        self.client = None
        if self.account_sid and self.auth_token:
            if Client:
                try:
                    self.client = Client(self.account_sid, self.auth_token)
                    logger.info("✓ WhatsApp service initialized with Twilio")
                except Exception as e:
                    logger.error(f"❌ Failed to initialize Twilio client: {str(e)}")
            else:
                logger.warning("⚠️ Twilio module not found. WhatsApp messaging disabled.")
        else:
            logger.warning("⚠️ Twilio credentials not found. WhatsApp messaging disabled.")
            logger.info("📝 To enable WhatsApp: Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_WHATSAPP_NUMBER in .env")

    def format_whatsapp_number(self, number):
        """Format phone number for WhatsApp (must start with whatsapp:)"""
        if not number:
            return None

        # Remove any existing whatsapp: prefix
        number = number.replace('whatsapp:', '')

        # Ensure it starts with +
        if not number.startswith('+'):
            # If it's an Indian number without country code, add +91
            if number.startswith('91'):
                number = '+' + number
            elif len(number) == 10:  # Assume Indian mobile
                number = '+91' + number
            else:
                number = '+' + number

        return f'whatsapp:{number}'

    def send_message(self, to_number, message, media_urls=None):
        """
        Send WhatsApp message using Twilio API
        """
        if not self.client or not self.from_number:
            return {
                'success': False,
                'error': 'Twilio WhatsApp service not configured'
            }

        try:
            formatted_to = self.format_whatsapp_number(to_number)
            formatted_from = self.format_whatsapp_number(self.from_number)

            if not formatted_to:
                return {
                    'success': False,
                    'error': 'Invalid phone number format'
                }

            # Prepare message args
            msg_args = {
                'body': message,
                'from_': formatted_from,
                'to': formatted_to
            }

            # Add media if provided
            if media_urls and len(media_urls) > 0:
                msg_args['media_url'] = media_urls

            # Send message
            message_instance = self.client.messages.create(**msg_args)

            logger.info(f"✓ WhatsApp message sent to {to_number}: {message_instance.sid}")

            return {
                'success': True,
                'message_id': message_instance.sid,
                'status': message_instance.status
            }

        except Exception as e:
            error_msg = f"Twilio error: {str(e)}"
            logger.error(f"❌ {error_msg}")
            return {
                'success': False,
                'error': error_msg
            }

    def send_report_notification(self, department_code, report_data, escalation=False):
        """
        Send report notification to department via WhatsApp
        """
        from department_contacts import get_whatsapp_for_department

        whatsapp_number = get_whatsapp_for_department(department_code, escalation)

        if not whatsapp_number:
            logger.warning(f"⚠️ No WhatsApp number configured for department: {department_code}")
            return {'success': False, 'error': 'No WhatsApp number configured'}

        # Create message
        priority_emoji = {
            'high': '🚨',
            'medium': '⚠️',
            'normal': '📋',
            'low': 'ℹ️'
        }.get(report_data.get('priority', 'normal'), '📋')

        escalation_text = " [ESCALATION]" if escalation else ""

        message = f"""{priority_emoji} *NEW PUBLIC REPORT*{escalation_text}

*Department:* {department_code.upper()}
*Priority:* {report_data.get('priority', 'normal').upper()}
*Title:* {report_data.get('title', '')}

*Description:*
{report_data.get('description', '')}

*Location:* {report_data.get('location_text', 'Not specified')}
*Landmark:* {report_data.get('landmark', 'Not specified')}

*Reporter:* {report_data.get('reporter_name', '')}
*Contact:* {report_data.get('reporter_email', '')}

*Report ID:* {report_data.get('id', '')}

Please take immediate action. Reply to this message or contact the reporter directly.

_Sent via Public Assets Reporting System_"""

        # Get image URLs if available
        media_urls = []
        images = report_data.get('images', [])
        if images:
            # Convert local file paths to accessible URLs
            base_url = os.getenv('BASE_URL', 'http://localhost:3000')
            for img_path in images[:3]:  # Limit to 3 images for WhatsApp
                if img_path.startswith('/uploads/'):
                    media_urls.append(f"{base_url}{img_path}")
                elif img_path.startswith('uploads/'):
                    media_urls.append(f"{base_url}/{img_path}")

        return self.send_message(whatsapp_number, message, media_urls)

    def send_reminder_notification(self, department_code, report_data, reminder_count=1):
        """
        Send reminder notification for unresolved reports
        """
        from department_contacts import get_whatsapp_for_department

        whatsapp_number = get_whatsapp_for_department(department_code)

        if not whatsapp_number:
            return {'success': False, 'error': 'No WhatsApp number configured'}

        reminder_emojis = ['⏰', '🔄', '🚨', '‼️']
        emoji = reminder_emojis[min(reminder_count-1, len(reminder_emojis)-1)]

        message = f"""{emoji} *REMINDER #{reminder_count}* - UNRESOLVED REPORT

This report is still pending resolution:

*Report ID:* {report_data.get('id', '')}
*Title:* {report_data.get('title', '')}
*Department:* {department_code.upper()}
*Priority:* {report_data.get('priority', 'normal').upper()}

*Original Report:* {report_data.get('createdAt', 'Unknown date')}

Please update the status or provide resolution details.

_Urgent attention required!_"""

        return self.send_message(whatsapp_number, message)

    def send_escalation_notification(self, department_code, report_data):
        """
        Send escalation notification to higher authorities
        """
        from department_contacts import get_whatsapp_for_department

        whatsapp_number = get_whatsapp_for_department(department_code, escalation=True)

        if not whatsapp_number:
            return {'success': False, 'error': 'No escalation WhatsApp number configured'}

        message = f"""🚨 *ESCALATION ALERT* 🚨

A high-priority report has not been resolved and is being escalated:

*Report ID:* {report_data.get('id', '')}
*Title:* {report_data.get('title', '')}
*Department:* {department_code.upper()}
*Priority:* HIGH

*Description:*
{report_data.get('description', '')}

*Location:* {report_data.get('location_text', '')}

This requires immediate attention from higher authorities.

_Escalated from Public Assets Reporting System_"""

        return self.send_message(whatsapp_number, message)

# Global WhatsApp service instance
whatsapp_service = WhatsAppService()

def send_whatsapp_notification(department_code, report_data, escalation=False):
    """Convenience function to send WhatsApp notification"""
    return whatsapp_service.send_report_notification(department_code, report_data, escalation)

def send_whatsapp_reminder(department_code, report_data, reminder_count=1):
    """Convenience function to send WhatsApp reminder"""
    return whatsapp_service.send_reminder_notification(department_code, report_data, reminder_count)

def send_whatsapp_escalation(department_code, report_data):
    """Convenience function to send WhatsApp escalation"""
    return whatsapp_service.send_escalation_notification(department_code, report_data)

