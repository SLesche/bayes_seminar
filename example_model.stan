functions {
  real partial_sum_fullddm(array[] real rt_slice, int start, int end,
      matrix a, matrix t0, array[,,] real v,  array[,,] real w,
      array[] int decision, array[] int cnd, array[] int subj, array[] int stim, array[] int prevstim) {
    real ans = 0;
    for (i in start:end) {
      if (decision[i] == 1) {  // response Y -> upper bound
      rt[i] ~ wiener(a[cnd[i],subj[i]], w[cnd[i],prevstim[i],subj[i]], t0[cnd[i],subj[i]], v[cnd[i],stim[i],subj[i]]);
      } else {  // response X -> lower bound, switch v -> -v and w -> 1-w
      rt[i] ~ wiener(a[cnd[i],subj[i]], 1-w[cnd[i],prevstim[i], subj[i]], t0[cnd[i],subj[i]], -v[cnd[i],stim[i],subj[i]]);
      }
    }
    return ans;
  }
}

data {
  int<lower=0> N;                       // No trials
  int<lower=0> Nsubj;                  // No subjects
  int<lower=1> Nconds;
  int<lower=1, upper=2> Nstim;
  array[N] real rt;                     // response times (seconds)
  array[N] int<lower=0, upper=1> decision;  // responses (0,1)
  array[N] int<lower=1, upper=Nconds> cnd; //condition
  array[N] int<lower=0, upper=1> stim;
  array[N] int<lower=0, upper=1> prevstim;
  array[N] int<lower=1, upper=Nsubj> subj;  // subject index
  matrix<lower=0>[Nconds, Nsubj] min_rt_subj_cond;
}

parameters {
  // group parameters
  array[Nconds] real<lower=0> mu_a;  // boundary separation: group mean
  array[Nconds] real<lower=0> sigma_a;  // boundary separation: group sd
  matrix<lower=0, upper = 1>[Nconds, Nstim] mu_w;  // relative starting point: group mean
  matrix<lower=0>[Nconds, Nstim] sigma_w;  // relative starting point: group sd
  matrix[Nconds, Nstim] mu_v;  // mean drift for each condition type: group mean
  matrix<lower=0>[Nconds, Nstim] sigma_v;  // mean drift for each condition type: sd
  array[Nconds] real<lower=0> mu_t0;  // non-decision time (lower bound): group mean
  array[Nconds] real<lower=0> sigma_t0;  // non-decision time (lower bound): sd

  // parameters for each subject
  matrix<lower=0>[Nconds, Nsubj] a;
  array[Nconds, Nstim, Nsubj] real v;
  matrix<lower=0>[Nconds, Nsubj] t0_rel;
  array[Nconds, Nstim, Nsubj] real<lower=0,upper=1> w;
}

transformed parameters {
  matrix<lower=0>[Nconds, Nsubj] t0;
  t0 = t0_rel .* min_rt_subj_cond;
}

model {
// Priors
  // prior
  mu_a ~ normal(2.5, 1);
  sigma_a ~ gamma(2, 4);
  
  for (i in 1:2) {
    mu_v[i] ~ normal(0, 10);
    sigma_v[i] ~ gamma(2, 4);
  }

  mu_t0 ~ gamma(0.2, 1);
  sigma_t0 ~ gamma(2, 4);
  
  for(i in 1:2){
    mu_w[i] ~ beta(4, 4);
    sigma_w[i] ~ gamma(2, 4);
  }
  
  // hierarchical model
  for (i in 1:Nconds) {
    for (j in 1:Nstim) {
      v[i,j] ~ normal(mu_v[i,j], sigma_v[i,j]);
      w[i,j] ~ normal(mu_w[i,j], sigma_w[i,j]);
    }
    a[i] ~ normal(mu_a[i], sigma_a[i]);
    t0[i] ~ normal(mu_t0[i], sigma_t0[i]);
  }
  
  
  // likelihood
  // using reduce_sum to allow for parallel processing
  target += reduce_sum(partial_sum_fullddm, rt, 1,
    a, t0, v, w, decision, cnd, subj, stim, prevstim);
}