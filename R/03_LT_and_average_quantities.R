source("00_initial_data_preparation.R")
source("01_smoothing_and_ungroupping.R")

# LT abd basic quantities
Lt <- mxc_single |>
  filter(cause == "All") |> 
  group_by(sex, year, educ) |>
  mutate(age = as.integer(age)) |> 
  group_by(sex, educ, cause, year) |>  
  summarise(ex = mx_to_e0(mx, age = age), .groups = "drop")

# we compare this later with our weighted-average e35 values just to see.
e35_total_compare <- Lt |>
  filter(educ == "Total", sex != "Total") |> 
  select(sex, year, ex)
# ----------------------------------------------------------------------- #
# Average male and female overall mortality for each age, year and educ
averages <- mxc_single |> 
  filter(cause == "All",
         sex   != "Total",
         educ  != "Total") |> 
  mutate(year = as.character(year),
         age = as.integer(age)) |> 
  dplyr::select(-cause) |> 
  pivot_wider(names_from = sex,
              values_from = mx) |> 
  group_nest(educ, year) |> 
  mutate(data = map(data, ~ 
                      sen_arriaga_sym(mx1 = .x$Males,
                                      mx =  .x$Females,
                                      age = .x$age,
                                      closeout = T))) |> 
  unnest(data) |> 
  group_by(educ, year) |> 
  mutate(age = 35:100) |>  
  ungroup() |> 
  rename(sensitivity = data)