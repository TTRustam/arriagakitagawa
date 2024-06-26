source("00_initial_data_preparation.R")
source("01_smoothing_and_ungroupping.R")
source("03_LT_and_average_quantities.R")
source("04_decomposition_results.R")
source("05_gaps.R")

# table
mxc_decomp %>% 
  group_by(educ, year) %>%
  summarise(decomp = sum(result)) %>% 
  full_join(struct_kit) %>%
  full_join(e35_kit) %>%
  dplyr::select(-c(st_mean, st_mean)) %>% 
  relocate(decomp, .after = e35_diff) %>%
  relocate(e35_avg, .after = e35_Males) %>%
  set_names(c("Education", 
              "Period", 
              "C(x) Females",
              "C(x) Males",
              "C(x) Difference",
              "e(35) Females", 
              "e(35) Males", 
              "e(35) Average",
              "e(35) Difference",
              "Decomposition")) %>% 
  mutate(across(contains("C(x)"), ~ .x %>% 
                  round(3))) %>% 
  mutate(across(contains("e(35)"), ~ .x %>% 
                  round(2))) %>% 
  mutate(Decomposition = round(Decomposition, 2)) %>%
  xtable()

# causes
decomp_total |> 
  filter(year == "2016-2019") |> 
  group_by(cause) |> 
  summarize(margin = sum(result_rescaled)) |> 
  filter(cause != "Covid-19") |> 
  full_join(dplyr::select(st_gaps[1, ], margin = cc_str) %>% 
              mutate(cause = "Educ. component")) %>% 
  mutate(margin_sign = if_else(sign(margin) == 1, "#F8766D","#C77CFF")) |>
  mutate(margin_sign = if_else(cause == "Educ. component", "#00BFC4", margin_sign)) %>% 
  ggplot(aes(y = reorder(cause, margin), 
             x = margin, 
             color = margin_sign,
             fill = margin_sign)) +
  geom_col() +
  guides(color= "none") +
  theme_minimal() +
  scale_color_identity() +
  scale_fill_identity() +
  scale_x_continuous(breaks = pretty_breaks())+
  xlab("Contribution to sex-gap") + 
  theme(
    legend.position = "none",
    axis.title = element_blank(),
    strip.background = element_blank(),
    strip.text =element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold", color = "black"),
    legend.title = element_text(face = "bold", color = "black"),
    axis.text.y = element_text(color = "black", face = "bold"),
    axis.text.x = element_text(color = "black"))

# education | Stationary, non-stationary
education %>% 
  full_join(tot_gps) %>% 
  full_join(orig_gap) %>%
  mutate(labels = educ) %>% 
  mutate(educ = ifelse(type == "Stationary", "Total (Stationary)", educ)) %>% 
  mutate(educ = ifelse(type == "Non-Stationary", "Total (Non-Stationary)", educ)) %>%
  mutate(educ = factor(educ, levels = c("Total (Stationary)", "Total (Non-Stationary)", 
                                        "Higher", "Secondary", "Primary"))) %>% 
  ggplot(aes(x = educ, y = gap, fill = educ)) + 
  geom_col(position = position_dodge(), color = "white") + 
  theme_minimal() + 
  coord_flip()+
  scale_y_continuous(breaks = pretty_breaks(n = 12)) +
  # scale_fill_discrete(labels = c("Higher", "Primary", "Secondary", "Total", "Total")) + 
  theme(
    legend.position = "none",
    legend.direction = "horizontal",
    axis.title = element_text(face = "bold", color = "black"),
    axis.text.y = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold", color = "black"),
    legend.title = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold", color = "black"),
    axis.text = element_text(color = "black")) +
  labs(fill = "Education groups",) + 
  labs(x = "e(35) difference type", 
       y = "Difference in years") 

# composed figure
decomp_total |>
  filter(year == "2016-2019") |>
  mutate(cause = case_when(
    !cause %in% c(
      "External",
      "Circulatory",
      "Digestive",
      "Neoplasms",
      "Respiratory"
    ) ~ "Other",
    TRUE ~ cause
  )) |>
  group_by(educ, year, cause, age) |>
  summarise(valuersc = sum(result_rescaled), 
            value = sum(result),.groups = "drop") |>
  mutate(cause = factor(cause),
         cause = reorder(cause, -valuersc)) |>
  mutate(
    educ = as.factor(educ),
    educ = fct_relevel(educ, "Higher", after = Inf)) |> 
  ggplot(aes(x = age, y = valuersc, fill = educ)) +
  geom_density(stat = "identity",
               alpha = 0.8,
               color = "white",
               position = "stack",
               linewidth = .25) +
  facet_grid(rows = vars(cause), switch = "y") +
  theme_minimal() +
  scale_x_continuous(breaks = pretty_breaks(n = 8)) +
  scale_color_viridis_b() +
  theme(
    legend.position = "bottom",
    axis.title = element_blank(),
    strip.background = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold", color = "black"),
    legend.title = element_text(face = "bold", color = "black"),
    axis.text = element_text(color = "black")) +
  labs(fill = "Education groups")

# education gaps
decomp_total |> 
  filter(year == "2016-2019") |> 
  group_by(educ) |> 
  summarize(margin = sum(result_rescaled)) |>
  full_join(dplyr::select(st_gaps[1, ], margin = cc_str) %>% 
              mutate(educ = "Educ. component")) %>%
  mutate(educ = fct_relevel(educ, "Higher", after = Inf)) |> 
  ggplot(aes(y = educ, 
             x = margin,
             fill = educ)) +
  geom_col() +
  guides(color= "none") +
  theme_minimal() +
  xlab("Contribution to sex-gap")+
  scale_x_continuous(breaks = pretty_breaks())+
  scale_fill_manual(values = c("#F8766D", "#C77CFF", "#00BFC4", "#7CAE00"))+
  xlab("Contribution to sex-gap") + 
  ylab("Education") +
  theme(
    legend.position = "none",
    axis.title = element_blank(),
    strip.background = element_blank(),
    strip.text =element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold", color = "black"),
    legend.title = element_text(face = "bold", color = "black"),
    axis.text.y = element_text(color = "black", face = "bold"),
    axis.text.x = element_text(color = "black"))
