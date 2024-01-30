data {
  int<lower=0> N;                       // No trials
  int<lower=0> Nsubj;                  // No subjects
  int<lower=1> Nconds;// No conditions
  vector[N] real rt;                     // response times (seconds)
  vector[N] int<lower=0, upper=1> decision;  // responses (0,1)
  vector[N] int<lower=1, upper=Nconds> cnd; //condition
  vector[N] int<lower=1, upper=Nsubj> subj;  // subject index
   // matrix<lower=0>[Nconds, Nsubj] min_rt_subj_cond;
}

parameters {
  // group parameters
  vector[Nconds] real<lower=0> mu_a;  // boundary separation: group mean
  vector[Nconds] real<lower=0> sigma_a;  // boundary separation: group sd
  vector[Nconds] real mu_v;  // mean drift for each condition type: group mean
  vector[Nconds] real<lower=0> sigma_v;  // mean drift for each condition type: sd
  vector[Nconds] real<lower=0> mu_t0;  // non-decision time (lower bound): group mean
  vector[Nconds] real<lower=0> sigma_t0;  // non-decision time (lower bound): sd

  // parameters for each subject
  array[Nconds, Nsubj] real v;
  array[Nconds, Nsubj] real<lower=0> a;
  array[Nconds, Nsubj] real<lower=0> t0;
}

transformed parameters {
  // matrix<lower=0>[Nconds, Nsubj] t0;
  // t0 = t0_rel .* min_rt_subj_cond;
}

model {
// Priors
  // prior
  mu_a ~ normal(2.5, 1);
  sigma_a ~ gamma(2, 4);
  
  mu_v ~ normal(0, 10);
  sigma_v ~ gamma(2, 4);

  mu_t0 ~ gamma(0.2, 1);
  sigma_t0 ~ gamma(2, 4);

  
  // hierarchical model
  for (i in 1:Nconds) {
    v[i] ~ normal(mu_v[i], sigma_v[i]);
    a[i] ~ normal(mu_a[i], sigma_a[i]);
    t0[i] ~ normal(mu_t0[i], sigma_t0[i]);
  }
  
  for (i in 1:N) {
    if (decision[i] == 1) {  // response Y -> upper bound
      rt[i] ~ wiener(a[cnd[i],subj[i]], t0[cnd[i],subj[i]], 0.5, v[cnd[i],subj[i]]);
    } else {  // response X -> lower bound, switch v -> -v and w -> 1-w
      rt[i] ~ wiener(a[cnd[i],subj[i]], t0[cnd[i],subj[i]], 0.5, -v[cnd[i],subj[i]]);
    }
  }
}