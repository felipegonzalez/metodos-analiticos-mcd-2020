#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]



double calc_error(NumericVector i, NumericVector j, NumericVector x,
                  NumericMatrix P, NumericMatrix Q, double mu, NumericVector a, NumericVector b){
    double suma = 0;
    for(int t = 0; t < i.size(); t++){
        double e = x(t) - mu - a(i[t]-1) - b(j[t]-1) - sum(P(i(t)-1,_) * Q(j(t)-1,_) );
        suma += e*e;
    }
    double tam = i.size();
    return suma/tam      ;
}
