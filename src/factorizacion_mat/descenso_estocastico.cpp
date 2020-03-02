#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]

List descenso_estocastico(NumericVector i_idx, NumericVector j_idx, NumericVector x,
                  NumericMatrix U, NumericMatrix V, double mu,
                  NumericVector a, NumericVector b,
                  double gamma, double lambda_mat,
                  double lambda_sesgos, int n_iter, 
                  NumericVector num_peli, NumericVector num_usu) {
    double e;
    NumericVector i = i_idx - 1;
    NumericVector j = j_idx - 1;
    NumericVector U_row;
    NumericVector V_row;
    for(int iter = 0; iter < n_iter; iter++){
      for(int t = 0; t < i.size(); t++){
           //Rcout << "Numero de usuario " << i(t) ;
           //Rcout << "Numero de pelicula " << j(t) << std::endl;
           e = x(t) - mu - a(i(t)) - b(j(t)) - sum(U(i(t), _) * V(j(t), _) );
           U_row = U(i(t), _);
           V_row = V(j(t), _);
           U(i(t), _) = U_row + gamma*(e * V_row - (lambda_mat / num_usu(i(t)))  * U_row);
           V(j(t), _) = V_row + gamma*(e * U_row - (lambda_mat / num_peli(j(t))) * V_row);
           a(i(t)) = a(i(t)) + gamma*(e - (lambda_sesgos / num_usu(i(t))) * a(i(t)));
           b(j(t)) = b(j(t)) + gamma*(e - (lambda_sesgos / num_peli(j(t)))* b(j(t)));
           mu = mu + gamma * e;
      }
    }
    return List::create(Rcpp::Named("U") = U,
                        Rcpp::Named("V") = V,
                        Rcpp::Named("a") = a,
                        Rcpp::Named("b") = b);
}
