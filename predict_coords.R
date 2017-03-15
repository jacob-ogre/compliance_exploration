# Code to test for relationships between TAILS variables and geo. coords.
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

library(ggplot2)
library(ggthemes)
library(grid)
library(gtable)

base <- "~/Repos/Defenders/compliance_exploration/"
infile <- paste0(base, "data/FWS_S7_clean_30Jul2015.RData")
load(infile)

full$coords <- ifelse(full$datum == "" | is.na(full$datum), 0, 1)
sum(full$coords)

mod1 <- glm(coords ~ region + ESOffice + formal_consult + work_category,
            data = full,
            family = "binomial")
summary(mod1)
amod1 <- aov(mod1)
summary(amod1)

# Plot the region variable...
by_region <- table(full$coords, full$region)
by_region
round(by_region[2,] / (by_region[1,] + by_region[2,]), 3)

reg_plot <- ggplot(data = full, aes(x = factor(region), y = coords)) +
            # geom_boxplot() +
            geom_jitter(alpha = 0.2) +
            theme_pander()
reg_plot

# wait, ESO is nested in region...
mod2 <- glm(coords ~ ESOffice + formal_consult + region + work_category,
            data = full,
            family = "binomial")
summary(mod2)
amod2 <- anova(mod2)
summary(amod2)

# OK, the variables of actual interest
mod3 <- glm(coords ~ ESOffice + formal_consult, data = full, family = "binomial")
summary(mod3)
amod3_1 <- aov(mod3)
amod3 <- anova(mod3, test="Chisq")
summary(amod3)

mod4 <- glm(coords ~ ESOffice * formal_consult, data = full, family = "binomial")
mod4_df <- data.frame(summary(mod4)$coefficients)
mod4_df$ESO <- row.names(mod4_df)
row.names(mod4_df) <- c(1:length(mod4_df$ESO))
amod4_1 <- aov(mod4)
amod4 <- anova(mod4, test="Chisq")
amod4

# Glancing over the coefficients, curious if there's a relationship to N
mod3_df <- as.data.frame(summary(mod3)$coefficients)
mod3_df$ESO <- row.names(mod3_df)
row.names(mod3_df) <- c(1:length(mod3_df$ESO))
names(mod3_df) <- c("Estimate", "SE", "Z", "p", "ESO")
mod3_df$ESO[1] <- "ALABAMA ECOLOGICAL SERVICES FIELD OFFICE"
mod3_df <- mod3_df[-79, ]
mod3_df$ESO <- gsub(pattern = "ESOffice", 
                    replacement = "",
                    x = mod3_df$ESO)

n_samp <- table(full$ESOffice)
n_df <- data.frame(ESO = names(n_samp), n_cons = as.vector(n_samp))
n_df$ESO <- as.character(n_df$ESO)
par_v_n <- merge(mod3_df, n_df, by="ESO")

n_v_param <- ggplot(data = par_v_n, aes(x = n_cons, y = abs(Estimate))) +
             geom_point() +
             theme_pander()
n_v_param

# Can I make a plot by ESO reaadable?
mean_coord <- tapply(full$coords,
                     INDEX = full$ESOffice,
                     FUN = mean, na.rm = TRUE)

mean_coord <- data.frame(ESO = names(mean_coord),
                         pct_coord = as.vector(mean_coord))
mean_coord <- merge(mean_coord, n_df, by = "ESO")

# Clean the ESO names
mean_coord$ESO <- gsub(pattern = "ECOLOGICAL SERVICES FIELD OFFICE",
                       replace = "ESFO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "ECOLOGICAL SERVICE FIELD OFFICE",
                       replace = "ESFO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "ECOLOGICAL SERVICES",
                       replace = "ESFO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "ECOLOGICAL SERVICES SUB-OFFICE",
                       replace = "ESSO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "Ecological Services Field Office",
                       replace = "ESFO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "FISH AND WILDLIFE FIELD OFFICE",
                       replace = "FWFO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "FISH AND WILDLIFE OFFICE",
                       replace = "FWO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "NATIONAL WILDLIFE REFUGE",
                       replace = "NWR",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "ASSISTANT REGIONAL DIRECTOR",
                       replace = "ARD",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "FISHERIES RESOURCE OFFICE",
                       replace = "FRO",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "NATIONAL FISH HATCHERY",
                       replace = "NFH",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "DIVISION OF CONSULTATION, HCPS, RECOVERY AND STATE GRANTS",
                       replace = "DIV. CONS. HCP RECOV.",
                       x = mean_coord$ESO)
mean_coord$ESO <- gsub(pattern = "BRANCH OF CONSULTATIONS, HCPS AND STATE GRANTS",
                       replace = "BR. CONS. HCP",
                       x = mean_coord$ESO)

pct_v_ESO <- ggplot(data = mean_coord, 
                      aes(x=reorder(ESO, -pct_coord), y = pct_coord)) +
             geom_point(stat="identity") +
             labs(x = "", y = "\n% w/ coordinates\n") +
             theme(axis.text.x = element_blank()) +
             theme_pander()
n_v_ESO <- ggplot(data = mean_coord, 
                  aes(x=reorder(ESO, -pct_coord), y = n_cons)) +
           geom_point() +
           labs(x = "", y = "\n# consultations\n") +
           theme(axis.text.x = element_text(angle = 60, hjust = 1, size=8)) +
           theme_pander()

p1 <- ggplotGrob(pct_v_ESO)
p2 <- ggplotGrob(n_v_ESO)
pc <- rbind(p1, p2, size="first")
grid.newpage()
grid.draw(pc)

n_v_pct <- ggplot(data = mean_coord, 
                  aes(x=n_cons, y = pct_coord)) +
           geom_point() +
           labs(y = "% w/ coords", x="\n# consultations\n") +
           theme(axis.text.x = element_text(angle = 60, hjust = 1, size=8)) +
           theme_pander()
n_v_pct

pct_v_N <- ggplot(data = mean_coord, aes(x = n_cons, y = pct_coord)) +
               geom_point(size = 3, alpha = 0.5) +
               labs(x = "# consultations",
                    y = "% consultations with coordinates") +
               theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
               theme_pander()
pct_v_N





