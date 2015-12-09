# Compare, average, and homogenize section 7 work type scores.
# Copyright © 2015 Defenders of Wildlife, jmalcom@defenders.org

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

#############################################################################
# Load data
base <- "/Users/jacobmalcom/Repos/Defenders/compliance_exploration/"
TK <- read.table(paste0(base, "data/workType_TKim_v2.tab"),
                 sep="\t",
                 header=TRUE,
                 stringsAsFactors=FALSE)
JM <- read.table(paste0(base, "data/workType_JMalcom.tab"),
                 sep="\t",
                 header=TRUE,
                 stringsAsFactors=FALSE)

sum(TK$Work_type != JM$Work_type)

new <- data.frame(work_type=TK$Work_type,
                  TK=TK$expect_visible,
                  JM=JM$expect_visible)
new$mismatch <- (TK$expect_visible != JM$expect_visible)
mismat <- new[new$mismatch ==FALSE, ]

### This is the actual data to use! ###
base <- "/Users/jacobmalcom/Repos/Defenders/compliance_exploration/"
dat <- read.table(paste0(base, "data/workTypes_reconcile.tab"),
                  sep="\t",
                  header=TRUE,
                  stringsAsFactors=FALSE)
head(dat)
dat$reconcile <- ifelse(dat$reconcile == 5,
                        0.5,
                        dat$reconcile)

# load the consultation data using shiny::runApp(); df name == 'full'

#############################################################################
# some analysis
table(dat$reconcile)

full$with_coord <- ifelse(full$datum != "", TRUE, FALSE)
sum(full$with_coord, na.rm=T)
full$with_coord <- as.factor(full$with_coord)

##################################################
# let's get all consultation tallies by work category
cons_workType_tab <- table(full$work_type, full$with_coord)
head(cons_workType_tab)
tmp <- as.data.frame(cons_workType_tab)
names(tmp) <- c("Work_type", "with_coord", "N_consultations")
head(tmp)
cons_workType <- tmp
head(cons_workType)
w_coord <- cons_workType[cons_workType$with_coord == TRUE, ]
dim(w_coord)
head(w_coord)

newd <- merge(dat, cons_workType, by="Work_type")
head(newd)

##################################################
# let's get just the formal consultation tallies by work category
formal <- full[full$formal_consult == "Yes", ]
formal_workType_tab <- table(formal$work_type, formal$with_coord)
head(formal_workType_tab)
tmp <- as.data.frame(formal_workType_tab)
names(tmp) <- c("Work_type", "with_coord", "N_formal")
head(tmp)
formal_workType <- tmp
head(formal_workType)
formal_w_coord <- formal_workType[formal_workType$with_coord == TRUE, ]
dim(formal_w_coord)

newf <- merge(dat, formal_workType, by="Work_type")
head(newf)

##################################################
# combine the all and formal dfs
all_sub <- newd[, c(1,5,6)]
final <- merge(all_sub, newf, by=c("Work_type", "with_coord"))
head(final)
names(final)

forsure <- final[final$reconcile == 1, ]
maybe <- final[final$reconcile == 0.5, ]
novis <- final[final$reconcile == 0, ]

n_forsure <- sum(forsure$N_consult, na.rm=TRUE)
n_maybe <- sum(maybe$N_consult, na.rm=TRUE)
n_novis <- sum(novis$N_consult, na.rm=TRUE)
all_tally <- c(n_forsure, n_maybe, n_novis)

f_forsure <- sum(forsure$N_formal, na.rm=TRUE)
f_maybe <- sum(maybe$N_formal, na.rm=TRUE)
f_novis <- sum(novis$N_formal, na.rm=TRUE)
form_tally <- c(f_forsure, f_maybe, f_novis)

cats <- c("for sure", "maybe", "no vis.")
tally <- data.frame(cats, all_tally, form_tally)

write.table(final,
            paste0(base, "data/joined_w_Nconsults_Nformal.tab"),
            sep="\t",
            quote=FALSE,
            row.names=FALSE)




