

#packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

#read data
stroop_data <- data.table::fread("data/stroop_data.csv")

#split data set into conditions
stroop_data_cong <- stroop_data %>% 
  filter(rt > 0.2 & rt < 2) %>% 
  filter(congruency == 1) %>% 
  sample_n(10000)

stroop_data_incong <- stroop_data %>% 
  filter(rt > 0.2 & rt < 2) %>% 
  filter(congruency == 2) %>% 
  sample_n(10000)

#write stan data separate for each conditon
#congruent data
stan_data_cong <- list(
  N = length(stroop_data_cong$rt),
  rt = stroop_data_cong$rt,
  resp = stroop_data_cong$accuracy
  #cond <- stroop_data$congruency,
  #id <- stroop_data_cong$subject
)

#incongruent data
stan_data_incong <- list(
  N = nrow(stroop_data_incong),
  rt = stroop_data_incong$rt,
  resp = stroop_data_incong$accuracy
  #cond <- stroop_data$congruency,
  #id <- stroop_data_incong$subject
)
n_chains <- 4

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

#fit models, separately for each condition
#congruent model
fit_cong <- stan(
  file = "four_parameter_dm.stan",
  data = stan_data_cong,
  init = get_initial_values(n_chains),
  chains = n_chains
  )

#incongruent model
fit_incong <- stan(
  file = "four_parameter_dm.stan",
  data = stan_data_incong
)


