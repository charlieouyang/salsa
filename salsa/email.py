# using SendGrid's Python Library
# https://github.com/sendgrid/sendgrid-python
import os
import json
import sendgrid
from sendgrid.helpers.mail import (Email, Mail, Content, To)

SENDGRID_FROM_EMAIL = 'helistrongtogether@gmail.com'
MESSAGE_CONTENT = {
    'reset_password': {
        'subject': 'Password Reset',
        'body': 'Your password has been reset. Your new password is \n\n'
    }
}


def send(action, recipient, data):
    try:
        sg = sendgrid.SendGridAPIClient(api_key=os.environ.get('SENDGRID_API_KEY'))
        from_email = Email(SENDGRID_FROM_EMAIL)
        to_email = To(recipient)

        message_content = MESSAGE_CONTENT.get(action)

        subject = message_content.get('subject')
        body = message_content.get('body')
        body += data
        content = Content('text/plain', body)

        mail = Mail(from_email, to_email, subject, content)
        response = sg.client.mail.send.post(request_body=mail.get())
        print('Email dispatched!')
    except Exception as e:
        print('DID NOT WORK!!!')
