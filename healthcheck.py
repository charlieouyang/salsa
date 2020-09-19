import requests
import datetime
import sendgrid
from sendgrid.helpers.mail import (Email, Mail, Content, To)

myobj = {'email': 'healthcheck@email.com', 'password': '123'}

try:
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(now)
    res = requests.post(url='https://helistrong.com/api/v1/login',
                      verify=False,
                      json=myobj)
    print('We are good')
except:
    try:
        for recipient in ['charlieouyang@gmail.com', 'ouyangkevin77@gmail.com']:
            sg = sendgrid.SendGridAPIClient(api_key='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')
            from_email = Email('helistrongtogether@gmail.com')
            to_email = To(recipient)
            subject = 'Healthcheck Failed - ' + now
            body = 'Digitalocean helistrong healthcheck failed!'
            content = Content('text/plain', body)
            mail = Mail(from_email, to_email, subject, content)
            response = sg.client.mail.send.post(request_body=mail.get())
            print('Email dispatched!')
    except Exception as e:
        print('DID NOT WORK!!!')
