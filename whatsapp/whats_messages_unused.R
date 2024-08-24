# Função para transformar celulares padronizados em um formato mais legível
prettify_cel <- function(cels) {
  cels %>% 
    substr(3, 13) %>%
    gsub("([0-9]{2})(9*[0-9]{4})([0-9]{4})", "\\1 \\2-\\3", .)
}



# Phase 1 Allocation ------------------------------------------------------

# Definir links diferentes para dinâmicas que ocorrem ao mesmo tempo:
links <- tribble(
  ~"Grupo", ~"Link",
  1,  "https://meet.google.com/zjm-zpyi-rcb",
  2,  "https://meet.google.com/dtf-esdk-jff"
)

left_join(data_alloc, links, by = "Group")

cc_alloc <- function(Horário, Link, ...) { #para o argument create_content
  paste0(
    ", tudo bem? Vim te mandar o link para a dinâmica da GVCode:%0D", #%0D é quebra de linha para URLs
    Horário, ": ",  Link
  )
}

data_alloc %>%
  filter(HorárioID == 1) %>% #selecionar o grupo para qual você deseja mandar os links
  pwalk(write_whats_url, create_content = cc_alloc)



# Phase 1 Results ---------------------------------------------------------

cc_phase1_results <- function(...) { #para o argument create_content
  paste0(
    ", tudo bem? Parabéns pela aprovação na dinâmica! Para seguirmos adiante no PS, preciso que você responda esse formulário (https://forms.gle/bvKdN4b9mWDLDxcR6) até hoje (é rapidinho). Obrigado!"
  )
}

data_grades %>%
  filter(Status = "Ativo") %>%
  pwalk(write_whats_url, create_content = cc_phase1_results)



# Phase 2 Results ---------------------------------------------------------

cc_phase2_results <- function(...) { #para o argument create_content
  paste0(
    ", tudo bem? Parabéns pela aprovação no case! Para seguirmos adiante no PS, preciso que você coloque todos os horários que teria disponível para realizar a entrevista, neste When2Meet (https://link) até hoje (é rapidinho). Obrigado!"
  )
}

data_grades %>%
  filter(Status = "Ativo") %>%
  pwalk(write_whats_url, create_content = cc_phase2_results)



# Phase 3 Results ---------------------------------------------------------

cc_phase3_results <- function(...) { #para o argument create_content
  paste0(
    ", parabéns pela aprovação em nosso PS!!! Te convidamos a entrar neste grupo para iniciar sua jornada conosco (chat.whatsapp.com/IlJJsNcbXEtLVcPBt6TfEK). Por favor, tente responder até hoje, mas se precisar de mais tempo, nos avise :)"
  )
}

data_grades %>%
  filter(Status = "Aprovado") %>%
  pwalk(write_whats_url, create_content = cc_phase3_results)



# Others ------------------------------------------------------------------

# Outras mensagens que se poderia criar: mensagens para os reprovados
