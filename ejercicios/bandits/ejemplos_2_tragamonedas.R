library(tidyverse)

## Maquinas simuladas

crear_maquina_poisson <- function(lambda){
  # utilizamos recompensas poisson con distintas medias lambda
  n_brazos <- length(lambda)
  simular_maquina <- function(brazo){
    rpois(1, lambda = lambda[brazo])
  }
  simular_maquina
}
crear_maquina_bernoulli <- function(lambda){
  # utilizamos recompensas poisson con distintas medias lambda
  n_brazos <- length(lambda)
  simular_maquina <- function(brazo){
    rbinom(1, 1, p = lambda[brazo])
  }
  simular_maquina
}
sim_1 <- crear_maquina_poisson(lambda = c(3, 1, 8))
sim_2 <- crear_maquina_bernoulli(lambda = c(0.0, 0.1, 0.5, 0.95))
sim_2(1)
map_dbl(1:1000, ~ sim_2(4)) %>% mean


## Epsilon miope

crear_epsilon_miope <- function(epsilon, inicial = 1, sim_fun){
  n_brazos <- environment(sim_fun)$n_brazos
  conteos <- rep(0, n_brazos)
  iteracion <- 0
  #recompensas <- vector("list", n_brazos)
  sumas <- rep(0, n_brazos)
  S <- rep(0, n_brazos)
  mejor <- inicial
  epsilon <- epsilon
  fun <- function(){
    if(runif(1) <= epsilon){
      #explorar
      brazo <- sample.int(n_brazos, 1)
    } else {
      #explotar
      brazo <- mejor
    }
    sim <- sim_fun(brazo)
    #recompensas[[brazo]] <<- c(recompensas[[brazo]], sim)
    media_ant <- ifelse(conteos[brazo] > 0, sumas[brazo] / conteos[brazo], 0)
    conteos[brazo] <<- conteos[brazo] + 1
    sumas[brazo] <<- sumas[brazo] + sim
    media <- sumas[brazo] / conteos[brazo]
    S[brazo] <<- S[brazo] + (sim - media_ant)*(sim - media)
    mejor <<- which.max(sumas /conteos)
    iteracion <<- iteracion + 1
    estado <- data_frame(n = iteracion,
                         brazo = 1:n_brazos,
                         conteo = conteos,
                         suma = sumas, 
                         media = sumas / conteos,
                         ee = sqrt(S / conteos)/sqrt(conteos))
    return(estado)
  }
  fun
}

e_miope <- crear_epsilon_miope(epsilon = 0.3, inicial = 1, sim_fun = sim_1)
e_miope_2 <- crear_epsilon_miope(epsilon = 0.3, inicial = 1, sim_fun = sim_1)
e_miope()
e_miope_2()
environment(e_miope)$conteos


df_iteraciones <- map_df(1:600, ~ e_miope())


## Graficar, prueba con distintas epsilon

sim_1 <- crear_maquina_poisson(lambda = c(3, 1, 8))
e_miope <- crear_epsilon_miope(epsilon = 0.1, inicial = 1, sim_fun = sim_1)
df_iteraciones <- map_df(1:600, ~ e_miope())
resumen <- df_iteraciones %>% group_by(n) %>%
  summarise(promedio_recompensa = sum(suma) / sum(conteo))
ggplot(resumen, aes(x = n, y = promedio_recompensa)) + geom_line() +
  geom_hline(yintercept = 8, colour = "red")


## UCB
# Idea de intervalos:

intervalos <- tibble(inf = c(3+1, 2, 3.5), sup = c(7+1, 8.5, 5), brazo = c(1,2,3)) %>% 
  mutate(media = (inf + sup) /2 )
ggplot(intervalos, aes(x = brazo, ymin = inf, ymax = sup, y = media)) + 
  geom_point()+
  geom_linerange() +
  ylim(c(0, 10)) + ylab("recompensa promedio")


intervalos_2 <- tibble(inf = c(3, 4.1, 3.5), sup = c(7, 6.5, 5), brazo = c(1,2,3)) %>% 
  mutate(media =(inf + sup) / 2)
ggplot(intervalos_2, aes(x = brazo, ymin = inf, ymax = sup, y = media)) + geom_linerange() +
  geom_point() +
  ylim(c(0,10)) + ylab("recompensa promedio")

bind_rows(intervalos %>% mutate(t = 1), intervalos_2 %>% mutate(t = 2)) %>% 
  ggplot(aes(x = brazo, ymin = inf, ymax=sup, y = media)) +
  geom_linerange() + geom_point() + facet_wrap(~t)


## Tragamonedas bayesiano


