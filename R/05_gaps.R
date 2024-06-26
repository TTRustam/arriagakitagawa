source("00_initial_data_preparation.R")
source("01_smoothing_and_ungroupping.R")
source("03_LT_and_average_quantities.R")
source("04_decomposition_results.R")
# gaps
gaps <- kit |> 
  group_by(year) |> 
  summarize(e35_Males   = sum(st_Males * e35_Males),
            e35_Females = sum(st_Females * e35_Females)) |> 
  mutate(gap = e35_Females - e35_Males)

tot_gps <- gaps |> 
  filter(year == "2016-2019") |> 
  dplyr::select(year, Females = e35_Females, Males = e35_Males) |> 
  pivot_longer(-year,
               names_to = "sex",
               values_to = "e35") |> 
  mutate(educ = "Total")

ed_gps <- e35_kit |> 
  select(educ, year, Females = e35_Females, Males = e35_Males)  |>      
  pivot_longer(Females:Males, names_to = "sex", values_to = "e35") |> 
  filter(year == "2016-2019")

mort_gaps <- decomp_total |> 
  group_by(year) |> 
  summarize(cc_mort = sum(result_rescaled))

st_gaps <- kit |> 
  group_by(year) |> 
  summarize(cc_str = sum(st_component))

dec_gaps <- full_join(mort_gaps, st_gaps, by = join_by(year)) |> 
  mutate(dec_gap = cc_str + cc_mort)

st_bind <- kit |> 
  ungroup() |> 
  filter(year == "2016-2019") |>
  summarize(margin = sum(st_component)) |> 
  mutate(educ = "Educ. Composition", .before = 1)

non_stationary_gap <- 
  e35_total_compare |> 
  pivot_wider(names_from = sex, values_from = ex, names_prefix = "e35_") |> 
  mutate(gap = e35_Females - e35_Males)

education <- e35_kit |> 
  select(educ, year, e35_diff)  |>
  filter(year == "2016-2019") |> 
  mutate(type = "By education") |> 
  rename(gap = e35_diff)

tot_gps <- gaps |> 
  filter(year == "2016-2019") |> 
  dplyr::select(year, gap) |> 
  mutate(educ = "Total") |> 
  mutate(type = "Stationary")

orig_gap <- e35_total_compare |> 
  pivot_wider(names_from = sex, values_from = ex, names_prefix = "e35_") |> 
  mutate(gap = e35_Females - e35_Males) |>  
  filter(year == "2016-2019") |> 
  dplyr::select(year, gap) |> 
  mutate(type = "Non-Stationary") |> 
  mutate(educ = "Total")

st_tib <- tibble(cause = "Educ. Composition", margin = st_bind$margin)
