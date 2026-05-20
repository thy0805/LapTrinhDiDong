import smtplib
from email.mime.text import MIMEText

SMTP_HOST = 'smtp.gmail.com'
SMTP_PORT = 587
FROM_EMAIL = '2001230640phat@gmail.com'
SMTP_PASSWORD = 'cpmgzwqpvqkeceao'

TO_EMAILS = [
    '2001230640phat@gmail.com',
    'ndthanhphat.study@gmail.com',
]

def send_test_mail():
    print("Dang gui mail qua Gmail SMTP...")
    try:
        server = smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=30)
        server.starttls()
        server.login(FROM_EMAIL, SMTP_PASSWORD)

        for email in TO_EMAILS:
            msg = MIMEText('Hi', 'plain', 'utf-8')
            msg['From'] = FROM_EMAIL
            msg['To'] = email
            msg['Subject'] = 'Hi'
            server.sendmail(FROM_EMAIL, email, msg.as_string())
            print(f"Gui thanh cong toi: {email}")

        server.quit()
        print("Xong!")
    except Exception as e:
        print(f"Loi: {e}")

if __name__ == '__main__':
    send_test_mail()
