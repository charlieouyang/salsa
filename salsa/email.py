# using SendGrid's Python Library
# https://github.com/sendgrid/sendgrid-python
import os
import json
import sendgrid
from sendgrid.helpers.mail import (Email, Mail, Content, To)


def send(action, recipient, data):
    try:
        sg = sendgrid.SendGridAPIClient(api_key='')
        from_email = Email('helistrongtogether@gmail.com')
        to_email = To('charlieouyang@hotmail.com')

        subject = 'Healthcheck Failed'
        body = 'Digitalocean helistrong healthcheck failed!'
        content = Content('text/plain', body)

        mail = Mail(from_email, to_email, subject, content)
        response = sg.client.mail.send.post(request_body=mail.get())
        print('Email dispatched!')
    except Exception as e:
        print('DID NOT WORK!!!')
