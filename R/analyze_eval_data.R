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
library(ggthemes)
library(readxl)

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

# Do the first join to get consult data
form_1 <- left_join(form, form_cons, by = "activity_code")
dim(form_1)
names(form_1)
form_1 <- form_1[, c(1:12, 15:20, 23:27, 34:36, 49)]
names(form_1)

# Do the second join to get our expectations
form_dat <- left_join(form_1, expect, by = c("work_type" = "Work_type"))
names(form_dat)[2] <- "action_found"

###############################################################################
# Let's do some analysis!
mean(form_dat$action_found, na.rm = TRUE)
mean(form_dat$reconcile, na.rm = TRUE)

par(mfrow=c(1,2))
hist(form_dat$reconcile,
     xlab = "No    <--- Expect to see? --->    Yes",
     ylab = "Frequency",
     main = "")
hist(form_dat$action_found,
     xlab = "No    <--- Observed? --->    Yes",
     ylab = "",
     main = "")

plt <- ggplot(form_dat, aes(factor(work_type), action_found)) +
       geom_boxplot()
plt

plt <- ggplot(form_dat, aes(factor(work_category), action_found)) +
       geom_violin(fill = "#D1E9D6", colour = "white") +
       geom_jitter(width = 0.2, height = 0.1, alpha = 0.3, size = 4) +
       labs(x = "Work Category",
            y = "No              <--- Action found? --->              Yes") +
       theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
       theme_hc()
plt

plt <- ggplot(form_dat, aes(factor(work_type), action_found)) +
       geom_violin(fill = "#D1E9D6", colour = "white") +
       geom_jitter(width = 0.2, height = 0.1, alpha = 0.3, size = 4) +
       labs(x = "Work Type",
            y = "No              <--- Action found? --->              Yes") +
       theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
       theme_hc()
plt













