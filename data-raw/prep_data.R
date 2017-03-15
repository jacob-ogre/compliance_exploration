
library(dplyr)
library(lubridate)
library(readr)
library(readxl)
library(stringr)
library(tidyr)

###############################################################################
# Load the data and prep
form_eval <- "data-raw/remote_sensing_monitor_evaluation.xlsx"
inform_eval <- "data-raw/remote_sensing_eval_informal.xlsx"
form_consults <- "data-raw/random_sample_formal_consults_w_decdeg.tab"
inform_consults <- "data-raw/random_sample_informal_consults_w_decdeg.tab"
expected_f <- "data-raw/joined_w_Nconsults_Nformal.tab"

form <- read_excel(form_eval, sheet = 1)
inform <- read_excel(inform_eval, sheet = 1)
form_cons <- read_tsv(form_consults)
inform_cons <- read_tsv(inform_consults)
expect <- read_tsv(expected_f)

names(form)
names(inform)
names(form_cons)
names(inform_cons)
names(expect)

# Winnow to just the rows with data
form <- filter(form, !is.na(form$activity_code))
inform <- filter(inform, !is.na(form$activity_code))
expect <- filter(expect, with_coord == TRUE)

###############################################################################
# Formal consultations
#
# Do the first join to get consult data
form_1 <- left_join(form, form_cons, by = "activity_code")
form_1 <- form_1[, c(1:12, 15:20, 23:27, 34:36, 49)]

# Do the second join to get our expectations
form_dat <- left_join(form_1, expect, by = c("work_type" = "Work_type"))
names(form_dat)[2] <- "action_found"

# Informal consultations
#
# Do the first join to get consult data for informal consults
inform_1 <- left_join(inform, inform_cons, by = "activity_code")
inform_1 <- inform_1[, c(1:12, 15:20, 23:27, 34:36, 49)]

# Do the second join to get our expectations
inform_dat <- left_join(inform_1, expect, by = c("work_type" = "Work_type"))
names(inform_dat)[2] <- "action_found"

# some type conversions for formal and informal
form_dat$area <- as.numeric(form_dat$area)
inform_dat$area <- as.numeric(inform_dat$area)
form_dat$start_date <- mdy(form_dat$start_date)
inform_dat$start_date <- mdy(inform_dat$start_date)
form_dat$FWS_concl_date <- mdy(form_dat$FWS_concl_date)
inform_dat$FWS_concl_date <- mdy(inform_dat$FWS_concl_date)

# make a combined df
names(inform_dat)[9] <- "completed"
form_dat$formal_in <- rep("formal", length(form_dat$activity_code))
inform_dat$formal_in <- rep("informal", length(inform_dat$activity_code))
combo_dat <- rbind(form_dat, inform_dat)

write_tsv(combo_dat, "data/merged_formal_informal_data.tsv")
saveRDS(combo_dat, "data/merged_formal_informal_data.rds")

