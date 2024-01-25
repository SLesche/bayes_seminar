//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  vector[N] rt;                         //response times in secons
  int<lower=0, upper=1> resp[N]; //responses (0, 1)
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real <lower=0> a;         //boundary separation
  real v;                   //drift rate
  real<lower=0, upper=1> w; //starting point
  real<lower=0> t0;        //non-decision time
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  //priors
  a  ~ normal(5, 1);
  w  ~ normal(0.5, 0.1);
  v  ~ normal(2, 3);
  t0 ~ normal(0.435, 0.12);
  
  //diffusion model
  for(i in 1:N) {
    if(resp[i] == 1) {
      //upper boundary wie definiert
      rt[i] ~ wiener(a, t0, w, v);
    } else {
      //für lower boundary müssen drift und starting point gespiegelt werden 
      rt[i] ~ wiener(a, t0, 1-w, -v);
    }
  }
}

