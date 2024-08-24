# Função para restringir celulares no formato padronizado
format_cel <- function(cels){
  cels %>%
    str_remove_all(" |-|\\(|\\)") %>% #remover espaços, parênteses, e hífens
    str_remove("^0") %>% #remover 0 no começo (se a pessoa digitou o DDD com 0 na frente)
    {ifelse(nchar(.) %in% 8:9, paste0("11", .), .)} %>% #se a pessoa não incluiu DDD, assumir que é São Paulo 11
    paste0("55", .) #adicionar o 55 Brasil no começo
}

# Função para restringir carteiras no formato padronizado
format_carteira <- function(carteiras) {
  str_match(carteiras, "(C|B)?([0-9]{6})") %>%
    `[`(,1) %>%
    {ifelse(nchar(.) == 6, paste0("C", .), .)}
}

# Função para restringir emails no formato padronizado
format_email <- function(emails) {
  str_to_lower(emails)
}


# Função para criar os links da API do WhatsApp
write_whats_url <- function(NomeCompleto, Celular, ..., create_content){
  text <- paste0(
    "&text=Olá ",
    gsub("([[:alpha:]]+) .+", "\\1", NomeCompleto), #adicionar o nome próprio no meio do texto
    create_content(...) #criar o conteúdo da mensagem, com a função passada e os argumentos adicionais
  ) %>% 
    str_replace_all(" ", "%20") #substituir espaços pelo símbolo de espaço para URLs
  
  # Printar o link no console:
  cat(paste0("=> ", NomeCompleto), sep = "\n")
  cat(paste0("https://api.whatsapp.com/send?phone=", Celular, text, "\n\n"))
}
# A função gera uma lista de links. Cole-os no browser. Você será redirecionado
#   para o app WhatsApp (precisa estar instalado), na conversa com a pessoa, e
#   com uma a mensagem já escrita no campo de mensagem, basta clicar em enviar.
# Muitas vezes, a mensagem não aparece, basta recarregar o browser onde você
#   colou o ink e ela deve aparecer.



# Technical functions -----------------------------------------------------

id_unique <- function(x) {
  reference_table <- unique(x) %>% setNames(1:length(.), .)
  reference_table[x]
}

