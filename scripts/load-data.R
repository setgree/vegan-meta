#' run the following only if you've made changes to the data online
# drive_auth()
# drive_download(as_id('1mPCt7HuK7URvuWcsMQokQCOGnSold-TS0NyC1EZniJk'),
#               path = './data/vegan-meta.csv',
#               overwrite = TRUE)

#' options
options(scipen = 99)

#' data
dat <- read.csv('./data/vegan-meta.csv') |>
  group_by(title) |>
  mutate(unique_paper_id = cur_group_id())  |> 
  ungroup() |> 
  group_by(unique_paper_id, study_num_within_paper) |> 
  mutate(unique_study_id = cur_group_id()) |>
  ungroup() |>
  mutate(decade = as.factor(case_when(year >= 2000 & year <= 2009 ~ "2000s",
                                      year >= 2010 & year <= 2019  ~ "2010s",
                                      year >= 2020 ~ "2020s")),
         pub_status = case_when(
           str_detect(venue, "dissertation|thesis") ~ "Thesis",
           str_detect(venue, "advocacy") ~ "Advocacy organization",
           str_detect(doi_or_url, "osf\\.io") ~ "Preprint",str_detect(doi_or_url, "10\\.") ~ "Journal article"),
         total_sample = n_c_post + n_c_post,
         d = mapply(
           FUN = d_calc,
           stat_type = eff_type,
           stat =  u_s_d,
           sample_sd = ctrl_sd,
           n_t = n_t_post,
           n_c = n_c_post),
         var_d = mapply(
           FUN = var_d_calc,
           d = d,
           n_c = n_c_post,
           n_t = n_t_post),
         se_d = sqrt(var_d)) |> 
  select(-one_of("X")) |>   
  select(author, year, title, unique_paper_id, unique_study_id, everything())
