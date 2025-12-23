import sys
import os
from datetime import datetime

# Configuration
LOG_FILE = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', 'logs', 'alerts.log')

def log_alert(message):
    """Logs the alert message to a file with a timestamp."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted_message = f"{timestamp} [ALERT] {message}\n"
    
    try:
        with open(LOG_FILE, "a") as f:
            f.write(formatted_message)
        print(f"Alert logged: {message}")
    except Exception as e:
        print(f"Failed to log alert: {e}", file=sys.stderr)

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 notifier.py <alert_message>")
        sys.exit(1)

    message = sys.argv[1]
    
    # Here you could extend to send emails, Slack messages, etc.
    # send_slack_notification(message)
    # send_email_alert(message)
    
    log_alert(message)

if __name__ == "__main__":
    main()
