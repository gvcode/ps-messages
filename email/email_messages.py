import pandas as pd
import re
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def get_html(html_path):
    with open(html_path, encoding='utf-8') as file:
        return file.read()

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

def main(df, html_path, email_column, subject, from_mail, from_password):
    html = get_html(html_path)
    vars = re.findall(r'%(\w+)%', html)

    for _, row in df.iterrows():
        email = row[email_column]
        row.drop(email_column)

        for var in vars:
            html.replace(f"%{var}%", row[var])

        enviar_email(email, html, subject, from_mail, from_password)
        print(f'E-mail enviado para {email}.')

# Setup:
from_mail ="gvcode.head@gmail.com"
from_password = 'yjvhecubcjrsqqwz'

# Data:
df_main = pd.read_excel("data/PS 2024.2 - Inscrição.xlsx", "Form1")
df_main = df_main[['Carteira', 'Celular', 'EmailContato']].drop_duplicates(subset='Carteira')

df_alloc = pd.read_excel("data/PS 2024.2 - Inscrição.xlsx", "Alocação")
df_alloc = df_alloc.merge(df_main, on="Carteira", how="left")

df_grades = pd.read_excel("data/PS 2024.2 - Inscrição.xlsx", "Notas")
df_grades = df_grades.merge(df_main, on="Carteira", how="left")


# Email para a alocação da dinâmica:
main(
    df_alloc, "email/phase1_alloc.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)

# Emails de resultado. Cuidado para apenas rodar após já terem atualizado a coluna de Status,
#   e escolher corretamente o html "phaseX_approved":
main(
    df_grades.query('StatusDinâmica == "Ativo"'), "email/phase1_approved.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
main(
    df_grades.query('StatusCase == "Ativo"'), "email/phase2_approved.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
main(
    df_grades.query('StatusEntrevista == "Ativo"'), "email/phase3_approved.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
main(
    df_grades.query('StatusDinâmica == "Reprovado"'), "email/rejected.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
