import pandas as pd
import re
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def format_carteira(carteiras):
    def match_and_format(carteira):
        match = re.match(r'(C|B)?([0-9]{6})', carteira).group(0)
        return match if len(match) == 7 else f'C{match}'
    return pd.Series(carteiras).apply(match_and_format).tolist()

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
    html = [
        get_html(re.sub(r"^(.+)(\.html)$", r"\1_gmail\2", html_path)),
        get_html(re.sub(r"^(.+)(\.html)$", r"\1_outlook\2", html_path))
    ]

    vars = re.findall(r'%(\w+)%', html[0])

    for _, row in df.iterrows():
        email = row[email_column]

        if re.search("gmail", email) is not None:
            html_row = html[0]
        else:
            html_row = html[1]

        for var in vars:
            html_row = html_row.replace(f"%{var}%", row[var])

        enviar_email(email, html_row, subject, from_mail, from_password)
        print(f'E-mail enviado para {email}.')

# Setup:
from_mail ="gvcode.head@gmail.com"
from_password = 'hnjfvikorpoojvmb'

path_main = "data/PS 2024.2 - Inscrição - test.xlsx" #remover '- test'
path_test = "data/PS 2024.2 - Programação - test.xlsx" #remover '- test'

# Data:
df_main = pd.read_excel(path_main, "Form1")
df_main['Carteira'] = format_carteira(df_main['Carteira'])
df_main = df_main[['Carteira', 'Celular', 'EmailContato']].drop_duplicates(subset='Carteira')

df_alloc = pd.read_excel(path_main, "Alocação")
df_alloc = df_alloc.merge(df_main, on="Carteira", how="left")

df_grades = pd.read_excel(path_main, "Notas")
df_grades = df_grades.merge(df_main, on="Carteira", how="left")


# Email para a alocação da dinâmica:
main(
    df_alloc, "email/phase1_alloc.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)

# Emails de resultado. Cuidado para apenas rodar após já terem atualizado a coluna de Status,
#   e escolher corretamente o html "phaseX_approved":
main(
    df_grades.query('StatusDinâmica == "Aprovado"'), "email/phase1_approved.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
main(
    df_grades.query('StatusDinâmica == "Reprovado"'), "email/rejected.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)

main(
    df_grades.query('StatusCase == "Aprovado"'), "email/phase2_approved.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
main(
    df_grades.query('StatusCase == "Reprovado"'), "email/rejected.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)

main(
    df_grades.query('StatusEntrevista == "Aprovado"'), "email/phase3_approved.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
main(
    df_grades.query('StatusEntrevista == "Reprovado"'), "email/rejected.html",
    email_column="EmailContato", subject="teste", from_mail=from_mail, from_password=from_password
)
