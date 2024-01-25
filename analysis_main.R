

#packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

#read data
stroop_data <- read_csv("data/stroop_data.csv")

#split data set into conditions
stroop_data_cong <- stroop_data %>% 
  filter(congruency == 1)

stroop_data_incong <- stroop_data %>% 
  filter(congruency == 2)

#write stan data separate for each conditon
#congruent data
stan_data_cong <- list(
  N <- nrow(stroop_data_cong),
  rt <- stroop_data_cong$rt,
  resp <- stroop_data_cong$accuracy,
  #cond <- stroop_data$congruency,
  id <- stroop_data_cong$subject
)

#incongruent data
stan_data_incong <- list(
  N <- nrow(stroop_data_incong),
  rt <- stroop_data_incong$rt,
  resp <- stroop_data_incong$accuracy,
  #cond <- stroop_data$congruency,
  id <- stroop_data_incong$subject
)

#fit models, separately for each condition
#congruent model
fit_cong = stan(
  file = "four_parameter_dm",
  data = stan_data_cong)

#incongruent model
fit_incong <- stan(
  file = "four_parameter_dm",
  data = stan_data_incong
)


