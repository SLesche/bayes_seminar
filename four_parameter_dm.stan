data {
  int<lower=0> N;
  vector[N] rt;                         //response times in secons
  int<lower=0, upper=1> resp[N]; //responses (0, 1)
}

parameters {
  real <lower=0> a;         //boundary separation
  real v;                   //drift rate
  // real<lower=0, upper=1> w; //starting point
  real<lower=0> t0;        //non-decision time
}

model {
  //priors
  a  ~ normal(5, 1);
  // w  ~ normal(0.5, 0.1);
  v  ~ normal(2, 3);
  t0 ~ gamma(0.2, 1);
  
  //diffusion model
  for(i in 1:N) {
    if(resp[i] == 1) {
      // Starting point fixed at 0.5 because accuracy-coded
      //upper boundary wie definiert
      rt[i] ~ wiener(a, t0, 0.5, v);
    } else {
      //für lower boundary müssen drift und starting point gespiegelt werden 
      rt[i] ~ wiener(a, t0, 0.5, -v);
    }
  }
}

