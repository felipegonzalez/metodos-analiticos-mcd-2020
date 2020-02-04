sim_jaccard <- function(a, b){
  length(intersect(a, b)) / length(union(a, b))
}

calcular_tejas <- function(x, k = 2){
  tokenizers::tokenize_character_shingles(x, n = k, lowercase = FALSE,
                                          simplify = TRUE, strip_non_alpha = FALSE)
}

generar_hash <- function(){
  # hashes para cadenas
  r <- as.integer(stats::runif(1, 1, 2147483647))
  funcion_hash <- function(shingles){
    digest::digest2int(shingles, seed =r) 
  }
  funcion_hash
}

crear_tejas_str <- function(textos, k = 4, tokenizer_fun = calcular_tejas){
  # crear tejas de documentos
  num_docs <- length(textos)
  tejas <- tokenizer_fun(textos, k = k)
  tejas_df <- tibble(doc_id = 1:num_docs, tejas = tejas)
  tejas_df
}

calcular_firmas_doc <- function(tejas_df, hash_funs){
  # Calcula firmas por documento
  num_docs <- nrow(tejas_df)
  num_hashes <- length(hash_funs)
  tejas <- tejas_df$tejas
  firmas <- vector("list", num_docs)
  # este se puede paralelizar facilmente:
  for(i in 1:num_docs){
    firmas[[i]] <- map_dbl(hash_funs, ~ min(.x(tejas[[i]])))
  }
  tibble(doc_id = 1:num_docs, firma = firmas)
}


separar_cubetas_fun <- function(particion){
  # juntar los hashes en bandas segun particion
  # particion es una lista cuyos elementos son los hashes
  # que van en cada banda.
  function(firma){
    map_chr(particion, function(x){
      prefijo <- paste0(x, collapse = '')
      cubeta <- paste(firma[x], collapse = "/")
      paste(c(prefijo, cubeta), collapse = '|')
    })
  }
}

extraer_pares <- function(cubetas_df, cubeta, docs, textos = NULL){
  enq_cubeta <- enquo(cubeta)
  enq_docs <- enquo(docs)
  pares <- cubetas_df %>% 
    group_by(!!enq_cubeta) %>% 
    mutate(pares = map(!!enq_docs, ~ combn(sort(.x), 2, simplify = FALSE))) %>%
    select(!!enq_cubeta, pares) %>% unnest_legacy %>% 
    mutate(a = map_int(pares, 1)) %>% 
    mutate(b = map_int(pares, 2)) %>% 
    select(-pares) %>% ungroup %>% select(-!!enq_cubeta) %>% 
    unique #quitar pares repetidos
  if(!is.null(textos)){
    pares <- pares %>% mutate(texto_a = textos[a], texto_b = textos[b])
  }
  pares %>% ungroup 
}


