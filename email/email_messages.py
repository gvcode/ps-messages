import pandas as pd
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def get_csv(sheet_path):
    df = pd.read_csv(sheet_path, encoding='utf-8', on_bad_lines='skip', index_col=False)
    return list(df.to_records(index=False))

def get_html(html_path):
    return open(html_path, encoding='utf-8').read()

def enviar_email(email, html, subject, from_mail, from_password):
    mensagem = MIMEMultipart()
    mensagem['From'] = from_mail
    mensagem['To'] = email
    mensagem['Subject'] = subject
    mensagem.attach(MIMEText(html, 'html'))

    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.starttls()
        server.login(from_mail, from_password)
        server.sendmail(from_mail, email, mensagem.as_string())

def main(sheet_path, html_path, email_column, subject, from_mail, from_password):
    df = get_csv(sheet_path)
    html = get_html(html_path)

    for _, row in df.iterrows():
        email = row[email_column]
        row.drop(email_column)

        for label, var in row.iteritems():
            html.replace(f"%{label}%", var)

        enviar_email(email, html, subject, from_mail, from_password)
        print(f'E-mail enviado para {email}.')

from_mail ="gvcode.head@gmail.com"
from_password = 'yjvhecubcjrsqqwz'
main("example.xlsx", "example.html", email_column="Email", subject="teste", from_mail=from_mail, from_password=from_password)

# Ta dando erro aqui ó:
#pd.read_csv("example.xlsx", encoding='utf-8', on_bad_lines='skip', index_col=False)
