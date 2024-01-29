#packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

#read data
stroop_data <- data.table::fread("data/stroop_data.csv") %>% 
  filter(rt > 0.2 & rt < 2)

test_data <- RWiener::rwiener(1000, 3, 0.2, 0.5, 3)

test_data$subject <- rep(1:10, each = 100)   
test_data$resp = ifelse(test_data$resp == "upper", 1, 0)
test_data$condition <- rep(1:2, n = 1000)

n_chains <- 1

get_initial_values <- function(n_chains = 4){
  initial_values <- vector(mode = "list", length = n_chains)
  
  for (i in seq_along(initial_values)){
    a = runif(1, 1, 4)
    v = runif(1, 1, 5)
    t0 = runif(1, 0, 0.1)
    w = runif(1, 0.4, 0.6)
    
    initial_values[[i]] = list(a = a, v= v, t0 = t0, w = w)
  }
  return(initial_values)
}

stan_data <- list(
  N = nrow(test_data),
  Nsubj = length(unique(test_data$subject)),
  Nconds = length(unique(test_data$condition)),
  rt = test_data$q,
  decision = test_data$resp,
  cnd = test_data$condition,
  subj = test_data$subject,
  min_rt_subj_cond = matrix(0.2, length(unique(test_data$condition)), length(unique(test_data$subject)))
)

fit_test <- stan(
  file = "hierarch_model_stan.stan",
  data = stan_data,
  init = get_initial_values(n_chains),
  chains = n_chains
)
