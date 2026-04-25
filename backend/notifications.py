# notifications.py — Firebase removed, DB-only approach

class NotificationService:
    """Stores notifications in DB. Flutter app polls /notifications/<user_id>."""

    def __init__(self, credentials_path=None):
        # credentials_path ignored — kept for signature compatibility with app.py
        self.initialized = True
        print("[*] NotificationService ready (DB-only mode, no Firebase)")

    def send_to_token(self, device_token, title, body, data=None):
        # No-op: notifications are now saved to DB by the route handlers directly
        print(f"[INFO] send_to_token called (no-op): {title} - {body}")
        return True

    def send_to_multiple(self, device_tokens, title, body, data=None):
        print(f"[INFO] send_to_multiple called (no-op): {title}")
        return {'success': len(device_tokens), 'failure': 0}

    def send_queue_update(self, device_token, service_name, new_position):
        return True  # DB record already written by update_queue_positions

    def send_admin_message(self, device_tokens, custom_message):
        return {'success': len(device_tokens), 'failure': 0}

    def send_token_completed(self, device_token, service_name):
        return True  # DB record already written by complete_token route


notification_service = None

def init_notification_service(credentials_path=None):
    global notification_service
    notification_service = NotificationService(credentials_path)
    return notification_service

def get_notification_service():
    global notification_service
    if notification_service is None:
        notification_service = NotificationService()
    return notification_service