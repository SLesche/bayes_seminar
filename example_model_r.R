# Library
library(dplyr)
library(tidyr)
library(cmdstanr)

# Data
data_read <- rio::import("./markdown/data/diffusion_data_location.rdata")

# prep for stan
data <- data_read %>% 
  group_by(rsi, error_factor, stimulus, previous_stimulus) %>% 
  mutate(cnd = cur_group_id()) %>% 
  ungroup()
# mutate(cnd = as.numeric(factor(condition_name))) %>% 
mutate(stim = stimulus,
       prevstim = ifelse(previous_stimulus == "X", 0, 1),
       subj = id) %>% 
  select(
    subj, cnd, stim, prevstim, rt, decision
  )

min_rt_subj_cond <- data %>% 
  group_by(subj, cnd) %>% 
  summarize(
    min_rt = min(rt)
  ) %>% 
  filter()
pivot_wider(
  names_from = subj,
  values_from = min_rt
) %>% 
  select(-cnd) %>% 
  as.matrix()

stan_data <- list(
  N = nrow(data),
  Nsubj = length(unique(data$subj)),
  Nconds = length(unique(data$cnd)),
  Nstim = length(unique(data$stim)),
  rt = data$rt,
  decision = data$decision,
  cnd = data$cnd,
  stim = data$stim,
  prevstim = data$prevstim,
  subj = data$subj,
  min_rt_subj_cond = min_rt_subj_cond
  
)