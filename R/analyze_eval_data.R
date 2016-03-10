# Analysis of the monitoring data.
# Copyright (c) 2016 Defenders of Wildlife, jmalcom@defenders.org

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.
# 

library(dplyr)
library(ggplot2)
library(ggrepel)
library(ggthemes)
library(lubridate)
library(readxl)
library(stringr)

source("R/multiplot.R")

###############################################################################
# Load the data and prep
base <- "/Users/jacobmalcom/Repos/Defenders/compliance_exploration"
form_eval <- paste0(base, "/data/remote_sensing_monitor_evaluation.xlsx")
inform_eval <- paste0(base, "/data/remote_sensing_eval_informal.xlsx")
form_consults <- paste0(base, "/data/random_sample_formal_consults_w_decdeg.tab")
inform_consults <- paste0(base, "/data/random_sample_informal_consults_w_decdeg.tab")
expected_f <- paste0(base, "/data/joined_w_Nconsults_Nformal.tab")

form <- read_excel(form_eval, sheet = 1)
inform <- read_excel(inform_eval, sheet = 1)
form_cons <- read.table(form_consults, 
                        header = T, 
                        sep = "\t", 
                        stringsAsFactors = F)
inform_cons <- read.table(inform_consults, 
                          header = T, 
                          sep = "\t", 
                          stringsAsFactors = F)
expect <- read.table(expected_f, header = T, sep = "\t", stringsAsFactors = F)

names(form)
names(inform)
names(form_cons)
names(inform_cons)
names(expect)

# Winnow to just the rows with data
form <- form[1:146, ]
inform <- inform[1:50, ]
expect <- expect[expect$with_coord == TRUE, ]

###############################################################################
# Formal consultations
#
# Do the first join to get consult data
form_1 <- left_join(form, form_cons, by = "activity_code")
dim(form_1)
names(form_1)
form_1 <- form_1[, c(1:12, 15:20, 23:27, 34:36, 49)]
names(form_1)

# Do the second join to get our expectations
form_dat <- left_join(form_1, expect, by = c("work_type" = "Work_type"))
names(form_dat)[2] <- "action_found"

# Informal consultations
#
# Do the first join to get consult data
dim(inform)
inform_1 <- left_join(inform, inform_cons, by = "activity_code")
dim(inform_1)
glimpse(inform_1)
names(inform_1)
inform_1 <- inform_1[, c(1:12, 15:20, 23:27, 34:36, 49)]
names(inform_1)

# Do the second join to get our expectations
inform_dat <- left_join(inform_1, expect, by = c("work_type" = "Work_type"))
names(inform_dat)[2] <- "action_found"

###############################################################################
# Let's do some plotting and analysis!

basic_means <- function(dat) {
    cat(paste("mean action found", 
              mean(dat$action_found, na.rm = TRUE),
              "\n"))
    cat(paste("mean action expected", 
              mean(dat$reconcile, na.rm = TRUE),
              "\n"))
}
basic_means(form_dat)
basic_means(inform_dat)

make_expect_obs_hist <- function(dat) {
    par(mfrow=c(1,2))
    hist(dat$reconcile,
         xlab = "No    <--- Expect to see? --->    Yes",
         ylab = "Frequency",
         main = "")
    hist(dat$action_found,
         xlab = "No    <--- Observed? --->    Yes",
         ylab = "",
         main = "")
    par(mfrow=c(1,1))
}
make_expect_obs_hist(form_dat)
make_expect_obs_hist(inform_dat)

# Now let's look by work cat and type
scatter_and_violin_work_cat <- function(dat) {
    plt <- ggplot(dat, aes(factor(work_category), action_found)) +
           geom_violin(fill = "#D1E9D6", colour = "white") +
           geom_jitter(width = 0.3, height = 0.05, alpha = 0.3, size = 4) +
           labs(x = "",
                y = "No              <--- Action found? --->              Yes") +
           theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
           theme_hc()
    plt
}

multiplot(scatter_and_violin_work_cat(form_dat),
          scatter_and_violin_work_cat(inform_dat),
          cols = 2)

scatter_and_violin_work_type <- function(dat) {
    plt <- ggplot(dat, aes(factor(work_type), action_found)) +
           geom_violin(fill = "#D1E9D6", colour = "white") +
           geom_jitter(width = 0.3, height = 0.05, alpha = 0.3, size = 4) +
           labs(x = "",
                y = "No              <--- Action found? --->              Yes") +
           theme(axis.text.x = element_text(angle = 25, hjust = 1)) +
           theme_hc()
    plt
}

multiplot(scatter_and_violin_work_type(form_dat),
          scatter_and_violin_work_type(inform_dat),
          cols = 2)

# Curious about the distribution of earliest image dates:
mean(form_dat$earliest_date, na.rm = T)
median(form_dat$earliest_date, na.rm = T)
summary(form_dat$earliest_date, na.rm = T)
hist(form_dat$earliest_date, breaks = "years")

names(inform_dat)[9] <- "completed"
combo_dat <- rbind(form_dat, inform_dat)

ggplot(combo_dat, aes(earliest_date)) +
    geom_histogram() +
    labs(x = "Earliest Aerial Image Date") +
    theme_hc()

###########################################################################
# OK, we want to get an overview of observeabilities:
get_observabilities <- function(dat, formal_in) {
    type_mean <- tapply(dat$action_found,
                        INDEX = dat$work_type,
                        FUN = mean, na.rm = TRUE)
    type_median <- tapply(dat$action_found,
                        INDEX = dat$work_type,
                        FUN = median, na.rm = TRUE)
    if (formal_in == "formal") {
        type_count <- tapply(dat$N_formal,
                             INDEX = dat$work_type,
                             FUN = mean, na.rm = TRUE)
    } else {
        type_count <- tapply(dat$N_consultations,
                             INDEX = dat$work_type,
                             FUN = mean, na.rm = TRUE)
    }
    expect_to_see_all <- type_mean * type_count

    # And these are the results at the highest level:
    tot_num_formal <- sum(type_count, na.rm = TRUE)
    exp_num_see <- sum(expect_to_see_all, na.rm = TRUE)
    cat(paste("Observability:\n\t", exp_num_see / tot_num_formal, "\n"))
    cat(paste("# consultations in set:\n\t", tot_num_formal, "\n"))
    cat(paste("# consultations we expect to see effects:\n\t", exp_num_see, "\n"))
}

get_observabilities(form_dat, "formal")
get_observabilities(inform_dat, "informal")

# dat = the dplyr'd formal/informal data; cons_dat = formal/informal consult data
make_scatter_df <- function(dat, cons_dat, formal_in) {
    type_mean <- tapply(dat$action_found,
                        INDEX = dat$work_type,
                        FUN = mean, na.rm = TRUE)
    type_median <- tapply(dat$action_found,
                        INDEX = dat$work_type,
                        FUN = median, na.rm = TRUE)
    if (formal_in == "formal") {
        type_count <- tapply(dat$N_formal,
                             INDEX = dat$work_type,
                             FUN = mean, na.rm = TRUE)
    } else {
        type_count <- tapply(dat$N_consultations,
                             INDEX = dat$work_type,
                             FUN = mean, na.rm = TRUE)
    }
    expect_to_see_all <- type_mean * type_count

    tmp_dat <- data.frame(type_count = as.vector(type_count),
                          type_mean = as.vector(type_mean),
                          work = names(type_count))
    work_cat_type <- data.frame(cat = cons_dat$work_category,
                                work = as.character(cons_dat$work_type))
    work_cat_type$uniq <- duplicated(work_cat_type$work)
    work_cat_type <- work_cat_type[work_cat_type$uniq == FALSE, ]
    tmp_dat <- inner_join(tmp_dat, work_cat_type, by = "work")
    return(tmp_dat)
}

form_obs_dat <- make_scatter_df(form_dat, form_cons, "formal")
inform_obs_dat <- make_scatter_df(inform_dat, inform_cons, "informal")

plot_observability_vs_available <- function(dat) {
    plt <- ggplot(dat, aes(type_mean, type_count)) +
           geom_jitter(width = 0, height = 0.1, alpha = 0.3, size = 4) +
           geom_label_repel(aes(type_mean, 
                                type_count, 
                                fill = factor(cat),
                                label = str_wrap(work, width = 30)), 
                           size = 2,
                           show.legend = FALSE) +
           labs(x = "Mean success rate",
                y = "# consultations in work type") +
           theme_hc()
    plt
}

plot_observability_vs_available(form_obs_dat)
plot_observability_vs_available(inform_obs_dat)


