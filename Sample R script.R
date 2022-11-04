#This script can help analyse results from DNA replication reactions - in vitro and in vivo
#This script will import data from an Excel file and plot:
  #(a) ridgeline plots of pixel intensity per nucleus
  #(b) percentage of replicating nuclei under different experimental conditions
#The script works using data from an ImageJ script that identifies nuclei, measures pixel intensity per nucleus, exports results to Excel
#Sample data for this script is included on GitHub
#For more information and the ImageJ scripts, see here: https://github.com/ilyacarey/nuclei or email iic21@cam.ac.uk
#Written for Ilya Carey's MPhil thesis (2022), which also includes more information about how the scripts work. 

#importing necessary packages
library(tidyverse)
library(Rcpp)
library(readxl)
library(ggridges)
library(scales)
library(gridExtra)

#setting working directory (where the data is)
setwd("C:/Users/ilyai/Pictures/Camera Roll/Confocal microscopy/5 july asyn brdu inhibitors")

#importing data, relabelling column, and setting treatment as a factor
data <-rename(read_excel("5 july asyn brdu inhibitors data.xlsx", skip=1), treatment = Label ) 
data$treatment <- factor(data$treatment, levels = unique(data$treatment), ordered=TRUE)

#Normalising data. The modal value for nuclei intensity value is substracted for each experiment
library(modeest)
data<- data %>% group_by(treatment) %>% mutate(Mean=Mean-mlv(Mean, method = "HSM")) 

#this variable stores how many nuclei ther are per image (in case you want it for some reason, e.g. manual scoring of nuclei) 
counts <- data %>% count(File) 

#ridgeline plot showing the distribution of normalised uptake of the modified nucleotide
p1 <- (ggplot(data, aes(x=Mean, y=treatment)) + 
         geom_density_ridges_gradient(rel_min_height = 0.005, linetype=1, lwd=0.5)+
         geom_density_ridges_gradient(aes(fill = stat(x)),scale=2, alpha=0.5, color = 5, stat="binline", bins=50, linetype=1, lwd=1, rel_min_height = 0.005)+
         scale_fill_viridis_c(name = "Modified nucleotide uptake", option = "D") +theme(text = element_text(size = 15)) +
         labs(title="Mean modified nucleotide signal per nucleus",y="Treatment", x = "Mean modified nucleotide signal per nucleus")
)


#calculating the percentage of replicating nuclei per experiment by applying a threshold (in this case of 400, you can recalibrate if you want)
threshold <- data %>% group_by(treatment) %>% summarise(values=100*sum(Mean>400)/length(Mean))

#plotting the percentage of replicating nuclei per image under different experimental conditions
p2 <- ( ggplot(data=threshold, aes(y=values, x=treatment))+geom_bar(stat="identity")+  ylim(0,60)+
          theme(text = element_text(size = 15), axis.text.x = element_text(angle = 20, hjust = 1, size=12)) +
          labs(x="Treatment", y="% nuclei replicating per image", title="Percentage of replicating nuclei"))

#plotting both plots
grid.arrange(p1, p2, ncol=2)

#you can easily export the plots using code below - uncomment it if you want to do so. 
#ggsave("Ridgeline plot.svg", p1 , width = 7.5, height = 5.5)


