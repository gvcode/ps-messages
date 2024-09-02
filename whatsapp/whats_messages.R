# Setup -------------------------------------------------------------------

library(tidyverse)
library(readxl)

source("whatsapp/utils.R")

# Na mudança de semestre, deve-se garantir que a as planílhas dos formulários
#   tenham os mesmos nomes de coluna. Se o código apresenta erros, esse deve
#   ser a primeira coisa a ser checada.



# Tables ------------------------------------------------------------------

# pode-se ler os dados direto do SharePoint com o pacote Microsoft365R,
#   (https://github.com/Azure/Microsoft365R), mas aparentemente, precisa pedir
#   permissão do administrador da FGV. Atualemente, baixe os dados na pasta
#   "data/".

path_main <- "data/PS 2024.2 - Inscrição - test.xlsx" #remover '- test'
path_test <- "data/Case 2024.2 - Programação - test.xlsx" #remover '- test'

data_main <- read_excel(path_main, "Form1") %>%
  select(Carteira, Celular, EmailContato) %>%
  mutate(
    Celular = format_cel(Celular),
    Carteira = format_carteira(Carteira),
    Email = format_email(EmailContato)
  ) %>%
  filter(!duplicated(Carteira))

data_alloc <- read_excel(path_main, "Alocação") %>%
  mutate(HorárioID = id_unique(`Horário`)) %>% #criar coluna para criar links por partes
  left_join(data_main, by = "Carteira")

data_grades <- read_excel(path_main, "Notas") %>%
  left_join(data_main, by = "Carteira")

data_test <- read_excel(path_test, "Sheet1") %>%
  filter(!duplicated(Carteira)) %>%
  select(Carteira)



# Phase 1 Reminder --------------------------------------------------------

cc_phase1_reminder <- function(Horário, ...) { #para o argument create_content
  paste0(
    ", tudo bem? Eu sou o Hugo da GVCode. Vim te lembrar da dinâmica da GVCode, que ocorrerá em ",
    Horário, ".",
    "O link para a ligação é https://bit.ly/DinamicaPSGVCode2024-2. Até lá!"
  )
}

data_alloc %>%
  filter(HorárioID == 1) %>% #selecionar o grupo para qual você deseja mandar os links
  pwalk(write_whats_url, create_content = cc_phase1_reminder)


# Phase 2 Test ------------------------------------------------------------

cc_test <- function(...) {
  ", tudo bem? Só para lembrar de preencher o teste de programação da GVCode (https://forms.gle/bvKdN4b9mWDLDxcR6). Obrigado!"
}

data_grades %>%
  filter(DinâmicaStatus == "Aprovado") %>%
  filter(!Carteira %in% data_test$Carteira) %>%
  pwalk(write_whats_url, create_content = cc_test)
