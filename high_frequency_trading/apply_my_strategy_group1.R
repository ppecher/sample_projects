# setting the working directory if needed
setwd("/Users/philipp/Library/Mobile Documents/com~apple~CloudDocs/Uni/Quantitative Strategies. High Frequency Trading/assessment")

library(xts)
library(chron)
library(TTR)
library(knitr) # for nicely looking tables in html files
library(kableExtra) # for even more nicely looking tables in html files
library(quantmod) # for PnL graphs
library(roll)

source("https://raw.githubusercontent.com/ptwojcik/HFD/master/function_positionVB.R")
source("https://raw.githubusercontent.com/ptwojcik/HFD/master/functions_plotPositions.R")


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
  
  filename_ <- paste0("data_all_with_out_of_sample/data1_", selected_quarter, ".RData")
  
  load(filename_)
  
  # create index of times for this quarter
  
  data.group1 <- get(paste0("data1_", selected_quarter))
  
  times_ <- substr(index(data.group1), 12, 19)
  
  times_data <- substr(index(data.group1), 12, 19)
  
  # the following common assumptions were defined:
  # 1.	do not use in calculations the data from the first 
  # and last 15 minutes of the session (9:31--9:45 and 15:46--16:00)
  # – put missing values there,
  
  # lets put missing values ofr these periods
  data.group1["T09:31/T09:45",] <- NA 
  data.group1["T15:46/T16:00",] <-NA
  ###########
  
  
  
  #########################################
  

  
  
  # lets calculate EMA10, EMA60, roll.sd  for NQ
  data.group1$NQ_EMA10 <- EMA(na.locf(data.group1$NQ), 10)
  data.group1$NQ_EMA60 <- EMA(na.locf(data.group1$NQ), 60)
  data.group1$NQ_rollsd120 <- roll_sd(na.locf(data.group1$NQ), 120)
  
  # and SP
  data.group1$SP_EMA20 <- EMA(na.locf(data.group1$SP), 20)
  data.group1$SP_EMA180 <- EMA(na.locf(data.group1$SP), 180)
  data.group1$SP_rollsd60 <- roll_sd(na.locf(data.group1$SP), 60)
  
  # put missing value whenever the original price is missing
  data.group1$NQ_EMA10[is.na(data.group1$NQ)] <- NA
  data.group1$NQ_EMA60[is.na(data.group1$NQ)] <- NA
  data.group1$NQ_rollsd120[is.na((data.group1$SP))] <- NA
  data.group1$SP_EMA20[is.na(data.group1$SP)] <- NA
  data.group1$SP_EMA180[is.na(data.group1$SP)] <- NA
  data.group1$SP_rollsd60[is.na((data.group1$SP))] <- NA
  
 
    data.group1$positionNQ.mom <- 
      positionVB(signal = data.group1$NQ_EMA10,
                 upper = data.group1$NQ_EMA60 + 2 * data.group1$NQ_rollsd120,
                 lower = data.group1$NQ_EMA60 - 2 * data.group1$NQ_rollsd120, 
                 times_data = times_data, # column with times 
                 time_lower = "09:40:00", # when start trading
                 time_upper = "15:50:00", # when exit all positions
                 strategy = "mom")
  
  
  
  # the same with a function that operates on simple objects
  # (converts signal, lower and upper into a numeric vectors
  # with the coredata() function)
  
  
    data.group1$positionSP.mom <- 
      positionVB(signal = data.group1$SP_EMA20,
                 upper = data.group1$SP_EMA180 + 2 * data.group1$SP_rollsd60,
                 lower = data.group1$SP_EMA180 - 2 * data.group1$SP_rollsd60, 
                 times_data = times_data, # column with times 
                 time_lower = "09:40:00", # when start trading
                 time_upper = "15:50:00", # when exit all positions
                 strategy = "mom")
  
  
  
  ######################
  
  ##############
  # calculating gross pnl
  
  data.group1$pnl_grossNQ.mom <- data.group1$positionNQ.mom * diff.xts(data.group1$NQ) * 20
  data.group1$pnl_grossSP.mom <- data.group1$positionSP.mom * diff.xts(data.group1$SP) * 50
  
  
  # number of transactions
  data.group1$ntransSP.mom <- abs(diff.xts(data.group1$positionSP.mom))
  data.group1$ntransNQ.mom <- abs(diff.xts(data.group1$positionNQ.mom))
  
  data.group1$ntransSP.mom[1] <- 0
  data.group1$ntransNQ.mom[1] <- 0
  
  # net pnl
  data.group1$pnl_netNQ.mom <- data.group1$pnl_grossNQ.mom  -
    data.group1$ntransNQ.mom * 10 # 10$ per transaction
  
  data.group1$pnl_netSP.mom <- data.group1$pnl_grossSP.mom  -
    data.group1$ntransSP.mom * 10 # 10$ per transaction
  
  # total for strategy
  
  data.group1$pnl_gross.mom <- data.group1$pnl_grossNQ.mom + data.group1$pnl_grossSP.mom
  data.group1$pnl_net.mom <- data.group1$pnl_netNQ.mom + data.group1$pnl_netSP.mom
  
  
  # aggregate pnls and number of transactions to daily
  my.endpoints <- endpoints(data.group1, "days")
  
  data.group1.daily <- period.apply(data.group1[,c(grep("pnl", names(data.group1)),
                                                   grep("ntrans", names(data.group1)))],
                                    INDEX = my.endpoints, 
                                    FUN = function(x) colSums(x, na.rm = TRUE))
  
  # summarize the strategy for this quarter
  
  # SR
  grossSR = mySR(x = data.group1.daily$pnl_gross.mom, scale = 252)
  netSR = mySR(x = data.group1.daily$pnl_net.mom, scale = 252)
  # average number of transactions
  av.daily.ntrades = mean(data.group1.daily$ntransSP.mom + 
                            data.group1.daily$ntransNQ.mom, na.rm = TRUE)
  # PnL
  grossPnL = sum(data.group1.daily$pnl_gross.mom)
  netPnL = sum(data.group1.daily$pnl_net.mom)
  # stat
  stat = (netSR - 0.5) * log(abs(netPnL/1000))
  
  # collecting all statistics for a particular quarter
  
  quarter_stats <- data.frame(quarter = selected_quarter,
                              assets.group = 1,
                              grossSR,
                              netSR,
                              av.daily.ntrades,
                              grossPnL,
                              netPnL,
                              stat,
                              stringsAsFactors = FALSE
  )
  
  
  # collect summaries for all quarters
  if(!exists("quarter_stats.all.group1")) quarter_stats.all.group1 <- quarter_stats else
    quarter_stats.all.group1 <- rbind(quarter_stats.all.group1, quarter_stats)
  
  # create a plot of gros and net pnl and save it to png file
  png(filename = paste0("pnl_group1_", selected_quarter, ".png"),
      width = 1000, height = 600)
  
  print( # when plotting in a loop you have to use print()
    plot(cbind(cumsum(data.group1.daily$pnl_gross.mom),
               cumsum(data.group1.daily$pnl_net.mom)),
         multi.panel = FALSE,
         main = paste0("Gross and net PnL for asset group 1 \n quarter ", selected_quarter), 
         col = c("#377EB8", "#E41A1C"),
         major.ticks = "weeks", 
         grid.ticks.on = "weeks",
         grid.ticks.lty = 3,
         legend.loc = "topleft",
         cex = 1)
  )
  # closing the png device (and file)
  dev.off()
  
  # remove all unneeded objects for group 1
  rm(data.group1, my.endpoints, grossSR, netSR, av.daily.ntrades,
     grossPnL, netPnL, stat, quarter_stats, data.group1.daily)
  
  gc()
  
  
} # end of the loop

write.csv(quarter_stats.all.group1, 
          "quarter_stats.all.group1.csv",
          row.names = FALSE)

