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

data_main <- read_excel("data/PS 2024.2 - Inscrição.xlsx", "Form1") %>%
  select(Carteria, Celular, EmailContato) %>%
  mutate(Celular = format_cel(Celular)) %>%
  filter(!duplicated(Carteira))

data_alloc <- read_excel("data/PS 2024.2 - Inscrição.xlsx", "Alocação") %>%
  mutate(HorárioID = id_unique(HorárioID)) %>% #criar coluna para criar links por partes
  left_join(data_main, by = "Carteira")

data_grades <- read_excel("data/PS 2024.2 - Inscrição.xlsx", "Notas") %>%
  left_join(data_main, by = "Carteira")

data_test <- read_excel("data/Case 2024.2 - Programação.xlsx", "Form1") %>%
  filter(!duplicated(Carteira))



# Phase 1 Reminder --------------------------------------------------------

cc_phase1_reminder <- function(Horário, ...) { #para o argument create_content
  paste0(
    ", tudo bem? Vim te lembrar da dinâmica da GVCode, que ocorrerá em ", Horário
  )
}

data_allocation %>%
  filter(HorárioID == 1) %>% #selecionar o grupo para qual você deseja mandar os links
  pwalk(write_whats_url, create_content = cc_phase1_reminder)


# Phase 2 Test ------------------------------------------------------------

cc_test <- function(...) {
  ", tudo bem? Só para lembrar de preencher o teste de programação da GVCode (https://forms.gle/bvKdN4b9mWDLDxcR6). Obrigado!"
}

data_grades %>%
  filter(Status = "Ativo") %>%
  filter(Carteira %in% data_test$Carteira) %>%
  pwalk(write_whats_url, create_content = cc_test)
