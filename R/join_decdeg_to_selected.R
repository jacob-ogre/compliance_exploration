# Join the file of decimal-degree coords with compliance eval consultations.
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
library(readxl)

base <- "~/Google Drive/Defenders/EndSpCons_shared/"
decdegf <- paste0(base, "mapping/sec7_consults/Section7_ForJacob.csv")
decdeg <- read.table(decdegf, sep=",", header=TRUE, stringsAsFactors=FALSE)

# First do the merge for formal consultations --------------------
selconsf <- paste0(base, 
                  "Compliance Exploration/Study/random_sample_formal_consults.xlsx")
selcons <- read_excel(selconsf)

with_new <- left_join(selcons, decdeg, by=c("activity_code" = "ActivityCode"))
dim(with_new)

fout <- paste0(base,
               "Compliance Exploration/Study/random_sample_formal_consults_w_decdeg.tab")
write.table(with_new,
            file=fout,
            sep="\t",
            quote=FALSE,
            row.names=FALSE)

# Now do the merge for informal consultations --------------------
selconsf <- paste0(base, 
                  "Compliance Exploration/Study/random_sample_informal_consults.tab")
selcons <- read.table(selconsf, sep="\t", header=TRUE, stringsAsFactors=FALSE)

with_new <- left_join(selcons, decdeg, by=c("activity_code" = "ActivityCode"))
dim(with_new)

fout <- paste0(base,
               "Compliance Exploration/Study/random_sample_informal_consults_w_decdeg.tab")
write.table(with_new,
            file=fout,
            sep="\t",
            quote=FALSE,
            row.names=FALSE)
