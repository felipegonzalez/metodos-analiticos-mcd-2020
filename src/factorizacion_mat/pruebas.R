library(Rcpp)
library(Matrix)
sourceCpp('descenso_estocastico.cpp')
sourceCpp('descenso_estocastico_prueba.cpp')

i <- c(1,1,1,2,2,3,4)
j <- c(1,2,3,1,2,1,1)
y <- c(5,1,3,4,1,3,5)
X <- sparseMatrix(i, j, x = y, dims=c(4,3))
dim(X)
X
U_0 <- matrix(rnorm(4*2, 0, 0.1), ncol = 2)
V_0 <- matrix(rnorm(3*2, 0, 0.1), ncol = 2)
a <- c(0, 0, 0, 0)
b <- c(0, 0, 0)
mu <- 3
U <- U_0
V <- V_0

tiempo_1 <- system.time(
    descenso_estocastico(i, j, y, U, V, mu, a, b, 
                         gamma = 0.1,n_iter = 3e6,
                         lambda_mat = 0.5, lambda_sesgos = 0.5,
                         num_peli = c(4,2,1), num_usu = c(3,2,1,1))
)
U_1 <- U
V_1 <- V

a <- c(0, 0, 0, 0)
b <- c(0, 0, 0)
mu <- 3
U <- U_0
V <- V_0
tiempo_2 <- system.time(
  descenso_estocastico_p(i, j, y, U, V, mu, a, b, 
                       gamma = 0.1, n_iter = 3e6,
                       lambda_mat = 0.5, lambda_sesgos = 0.5,
                       num_peli = c(4,2,1), num_usu = c(3,2,1,1))
)
100*(tiempo_1/tiempo_2 - 1 )
U
U_1
V
V_1

a <- c(0, 0, 0, 0)
b <- c(0, 0, 0)
mu <- 3
U <- U_0
V <- V_0
#salida <- descenso_estocastico_p(i, j, y, U, V, mu, a, b, 
#                       gamma = 0.1,n_iter = 1,
#                       lambda_mat = 0.5, lambda_sesgos = 0.5,
#                       num_peli = c(4,2,1), num_usu = c(3,2,1,1))
