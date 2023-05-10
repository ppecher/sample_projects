# setting the working directory if needed
setwd("/Users/philipp/Library/Mobile Documents/com~apple~CloudDocs/Uni/Quantitative Strategies. High Frequency Trading/assessment")

library(xts)
library(chron)
library(TTR)
library(knitr) # for nicely looking tables in html files
library(kableExtra) # for even more nicely looking tables in html files
library(quantmod) # for PnL graphs
library(roll) # for rolling sd,...
library(lubridate)
library(dplyr)
library(lattice) 
library(grDevices)
library(xts)
library(quantmod)
library(gtools)
library(chron)

library(caTools)

source("https://raw.githubusercontent.com/ptwojcik/HFD/master/function_positionVB.R")
source("https://raw.githubusercontent.com/ptwojcik/HFD/master/functions_plotPositions.R")
source("https://raw.githubusercontent.com/ptwojcik/HFD/master/function_positionVB_new.R")

# lets change the LC_TIME option to English
Sys.setlocale("LC_TIME", "C")

# mySR function
mySR <- function(x, scale) {
  sqrt(scale) * mean(coredata(x), na.rm = TRUE) / 
                sd(coredata(x), na.rm = TRUE)
  } 


# lets define the system time zone as America/New_York (used in the data)
Sys.setenv(TZ = 'America/New_York')

# do it simply in a loop on quarters



for (selected_quarter in c("2018_Q1","2018_Q2", "2018_Q3", "2018_Q4", 
                           "2019_Q1", "2019_Q2","2019_Q3", "2019_Q4", 
                           "2020_Q1", "2020_Q2", "2020_Q3", "2020_Q4")) {
 message(selected_quarter)
  
  
  # loading the data for a selected quarter from a subdirectory "data""

   filename_ <- paste0("data_all_with_out_of_sample/data2_", selected_quarter, ".RData")
  
   load(filename_)
  
   data.group2 <- get(paste0("data2_", selected_quarter))
  
  times_ <- substr(index(data.group2), 12, 19)
  
  times_data <- substr(index(data.group2), 12, 19)
  

  

  
  # do not use calculations 5 minutes before and after the break
  data.group2["T16:56/T17:00",] <- NA 
  data.group2["T17:01/T17:05",] <- NA
  

  ### Calculations for all other strategies
  # lets calculate EMA and sd
  #AUD
  data.group2$AUD_EMA20 <- EMA(na.locf(data.group2$AUD), 20)
  data.group2$AUD_EMA120 <- EMA(na.locf(data.group2$AUD), 120)
  data.group2$AUD_rollsd120 <- roll_sd(na.locf(data.group2$AUD), 120)
  #CAD
  data.group2$CAD_EMA30 <- EMA(na.locf(data.group2$CAD), 30)
  data.group2$CAD_EMA120 <- EMA(na.locf(data.group2$CAD), 120)
  data.group2$CAD_rollsd60 <- roll_sd(na.locf(data.group2$CAD), 60)
  #XAG
  data.group2$XAG_EMA15 <- EMA(na.locf(data.group2$XAG), 15)
  data.group2$XAG_EMA180 <- EMA(na.locf(data.group2$XAG), 180)
  data.group2$XAG_rollsd120 <- roll_sd(na.locf(data.group2$XAG), 120)
  
  #XAU
  data.group2$XAU_EMA15 <- EMA(na.locf(data.group2$XAU), 15)
  data.group2$XAU_EMA180 <- EMA(na.locf(data.group2$XAU), 180)
  data.group2$XAU_rollsd120 <- roll_sd(na.locf(data.group2$XAU), 120)
  
  # put missing value whenever the original price is missing
  data.group2$AUD_EMA20[is.na(data.group2$AUD)] <- NA
  data.group2$AUD_EMA120[is.na(data.group2$AUD)] <- NA
  data.group2$AUD_rollsd120[is.na(data.group2$AUD)] <- NA
  
  data.group2$CAD_EMA30[is.na(data.group2$CAD)] <- NA
  data.group2$CAD_EMA120[is.na(data.group2$CAD)] <- NA
  data.group2$CAD_rollsd60[is.na(data.group2$CAD)] <- NA
  
  data.group2$XAG_EMA15[is.na(data.group2$XAG)] <- NA
  data.group2$XAG_EMA180[is.na(data.group2$XAG)] <- NA
  data.group2$XAG_rollsd120[is.na(data.group2$XAG)] <- NA

  data.group2$XAU_EMA15[is.na(data.group2$XAU)] <- NA
  data.group2$XAU_EMA180[is.na(data.group2$XAU)] <- NA
  data.group2$XAU_rollsd120[is.na(data.group2$XAU)] <- NA
  
  #Strategies
  
  data.group2$position.AUD.mom <- 
    positionVB(signal = data.group2$AUD_EMA20,
               upper = data.group2$AUD_EMA120 + 2 * data.group2$AUD_rollsd120,
               lower = data.group2$AUD_EMA120 - 2 * data.group2$AUD_rollsd120, 
               times_data = times_data, # column with times
               strategy = "mom")
  
  
  data.group2$position.CAD.mom <- 
    positionVB(signal = data.group2$CAD_EMA30,
               upper = data.group2$CAD_EMA120 + 2 * data.group2$CAD_rollsd60,
               lower = data.group2$CAD_EMA120 - 2 * data.group2$CAD_rollsd60, 
               times_data = times_data, # column with times 
               strategy = "mom")
  
  data.group2$position.XAG.mom <- 
    positionVB(signal = data.group2$XAG_EMA15,
               upper = data.group2$XAG_EMA180 + 2 * data.group2$XAG_rollsd120,
               lower = data.group2$XAG_EMA180 - 2 * data.group2$XAG_rollsd120, 
               times_data = times_data, # column with times 
               strategy = "mom")
  
  
  
  data.group2$position.XAU.mom <- 
    positionVB(signal = data.group2$XAU_EMA15,
               upper = data.group2$XAU_EMA180 + 2 * data.group2$XAU_rollsd120,
               lower = data.group2$XAU_EMA180 - 2 * data.group2$XAU_rollsd120, 
               times_data = times_data, # column with times 
               strategy = "mom")
 
  
  
  # lets apply the remaining assumptions
  # - exit all positions 15 minutes before the session end, i.e. at 16:45
  # - do not trade within the first 15 minutes after the break (until 18:15)
  
  data.group2$position.AUD.mom[times(times_) > times("16:45:00") &
                                 times(times_) <= times("18:15:00")] <- 0
  
  data.group2$position.CAD.mom[times(times_) > times("16:45:00") &
                                 times(times_) <= times("18:15:00")] <- 0
  
  data.group2$position.XAG.mom[times(times_) > times("16:45:00") &
                                 times(times_) <= times("18:15:00")] <- 0
  
  data.group2$position.XAU.mom[times(times_) > times("16:45:00") &
                                 times(times_) <= times("18:15:00")] <- 0
  
  
  # lets also fill every missing position with the previous one
  data.group2$position.AUD.mom <- na.locf(data.group2$position.AUD.mom, na.rm = FALSE)
  data.group2$position.CAD.mom <- na.locf(data.group2$position.CAD.mom, na.rm = FALSE)
  data.group2$position.XAG.mom <- na.locf(data.group2$position.XAG.mom, na.rm = FALSE)
  data.group2$position.XAU.mom <- na.locf(data.group2$position.XAU.mom, na.rm = FALSE)
  
  
  # calculating gross pnl - remember to multiply by the point value !!!!
  data.group2$pnl_gross.AUD.mom <- data.group2$position.AUD.mom * diff.xts(data.group2$AUD) * 100000
  data.group2$pnl_gross.CAD.mom <- data.group2$position.CAD.mom * diff.xts(data.group2$CAD) * 100000
  data.group2$pnl_gross.XAU.mom <- data.group2$position.XAU.mom * diff.xts(data.group2$XAU) * 100
  data.group2$pnl_gross.XAG.mom <- data.group2$position.XAG.mom * diff.xts(data.group2$XAG) * 5000
  
  # number of transactions
  
  data.group2$ntrans.AUD.mom <- abs(diff.xts(data.group2$position.AUD.mom))
  data.group2$ntrans.AUD.mom[1] <- 0
  
  data.group2$ntrans.CAD.mom <- abs(diff.xts(data.group2$position.CAD.mom))
  data.group2$ntrans.CAD.mom[1] <- 0
  
  data.group2$ntrans.XAG.mom <- abs(diff.xts(data.group2$position.XAG.mom))
  data.group2$ntrans.XAG.mom[1] <- 0
  
  data.group2$ntrans.XAU.mom <- abs(diff.xts(data.group2$position.XAU.mom))
  data.group2$ntrans.XAU.mom[1] <- 0
  
  # net pnl
  data.group2$pnl_net.AUD.mom <- data.group2$pnl_gross.AUD.mom  -
    data.group2$ntrans.AUD.mom * 5 # 5$ per transaction
  
  data.group2$pnl_net.CAD.mom <- data.group2$pnl_gross.CAD.mom  -
    data.group2$ntrans.CAD.mom * 5 # 5$ per transaction
  
  data.group2$pnl_net.XAG.mom <- data.group2$pnl_gross.XAG.mom  -
    data.group2$ntrans.XAG.mom * 5 # 5$ per transaction
  
  data.group2$pnl_net.XAU.mom <- data.group2$pnl_gross.XAU.mom  -
    data.group2$ntrans.XAU.mom * 10 # 10$ per transaction
  
  
  # aggregate pnls and number of transactions to daily
  my.endpoints <- endpoints(data.group2, "days")
  
  data.group2.daily <- period.apply(data.group2[,c(grep("pnl", names(data.group2)),
                                                   grep("ntrans", names(data.group2)))],
                                    INDEX = my.endpoints, 
                                    FUN = function(x) colSums(x, na.rm = TRUE))
  
  # lets SUM gross and net pnls
  
  data.group2.daily$pnl_gross.mom <- 
    data.group2.daily$pnl_gross.AUD.mom +
    data.group2.daily$pnl_gross.CAD.mom +
    data.group2.daily$pnl_gross.XAU.mom +
    data.group2.daily$pnl_gross.XAG.mom
  
  data.group2.daily$pnl_net.mom <- 
    data.group2.daily$pnl_net.AUD.mom +
    data.group2.daily$pnl_net.CAD.mom +
    data.group2.daily$pnl_net.XAU.mom +
    data.group2.daily$pnl_net.XAG.mom
  
  # lets SUM number of transactions (with the same weights)
  
  data.group2.daily$ntrans.mom <- 
    data.group2.daily$ntrans.AUD.mom +
    data.group2.daily$ntrans.CAD.mom +
    data.group2.daily$ntrans.XAG.mom +
    data.group2.daily$ntrans.XAU.mom
  
  
  # summarize the strategy for this quarter
  
  # SR
  grossSR = mySR(x = data.group2.daily$pnl_gross.mom, 
                 scale = 252)
  netSR = mySR(x = data.group2.daily$pnl_net.mom, 
               scale = 252)
  # average number of transactions
  av.daily.ntrades = mean(data.group2.daily$ntrans.mom, 
                          na.rm = TRUE)
  # PnL
  grossPnL = sum(data.group2.daily$pnl_gross.mom)
  netPnL = sum(data.group2.daily$pnl_net.mom)
  
  # stat
  stat = (netSR - 0.5) * log(abs(netPnL/1000))
  
  # collecting all statistics for a particular quarter
  
  quarter_stats <- data.frame(quarter = selected_quarter,
                              assets.group = 2,
                              grossSR,
                              netSR,
                              av.daily.ntrades,
                              grossPnL,
                              netPnL,
                              stat,
                              stringsAsFactors = FALSE
  )
  
  # collect summaries for all quarters
  if(!exists("quarter_stats.all.group2")) quarter_stats.all.group2 <- quarter_stats else
    quarter_stats.all.group2 <- rbind(quarter_stats.all.group2, quarter_stats)
  
  # create a plot of gros and net pnl and save it to png file
  
  png(filename = paste0("pnl_group2_", selected_quarter, ".png"),
      width = 1000, height = 600)
  print( # when plotting in a loop you have to use print()
    plot(cbind(cumsum(data.group2.daily$pnl_gross.mom),
               cumsum(data.group2.daily$pnl_net.mom)),
         multi.panel = FALSE,
         main = paste0("Gross and net PnL for asset group 2 \n quarter ", selected_quarter), 
         col = c("#377EB8", "#E41A1C"),
         major.ticks = "weeks", 
         grid.ticks.on = "weeks",
         grid.ticks.lty = 3,
         legend.loc = "topleft",
         cex = 1)
  )
  dev.off()
  
  # remove all unneeded objects for group 2
  rm(data.group2, my.endpoints, grossSR, netSR, av.daily.ntrades,
     grossPnL, netPnL, stat, quarter_stats, data.group2.daily)
  
  gc()
  
  
} # end of the loop

write.csv(quarter_stats.all.group2, 
          "quarter_stats.all.group2.csv",
          row.names = FALSE)
