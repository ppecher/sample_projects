##############################################################
# Philipp Pecher                                             #             
# p.pecher@student.uw.edu.pl                                 #
# Faculty of Economic Sciences, University of Warsaw         #
#                                                            #
# Time Series Analysis, Spring 2021                          #
# Home Project # 2                                           #
##############################################################


library(tidyverse)
library(xts) # e.g. xts objects
library(fBasics) # e.g. basicStats()
library(tseries)# e.g. jarque.bera.test()
library(car) # e.g. durbinWatsonTest()
library(FinTS) # e.g. ArchTest()
library(fGarch) # e.g. garchFit()
library(quantmod) # e.g. getSymbol()
library(rugarch) # e.g. ugarchfit()

setwd("/Users/philipp/Library/Mobile Documents/com~apple~CloudDocs/Uni/Time Series Analysis/Project")

source("function_compareICs.GARCH.R")
source("function_compare.ICs.ugarchfit.R")


#choice of the cryptocurrency

x <- c(9,1,2,7,9,7)

sum(x)%%5+1
# result: 1
#-> Hence, the choice is Bitcoin (BTC)


##############
#
##############

SP500 <- 
  getSymbols(Symbols = "^GSPC",             
             from = "2018-01-02", 
             to = "2021-06-01",   
             auto.assign = FALSE)

DAX <- 
  getSymbols(Symbols = "^GDAXI",             
             from = "2018-01-02", 
             to = "2021-06-01",   
             auto.assign = FALSE)

WIG20 <- 
  getSymbols(Symbols = "^WIG20",             
             from = "2018-01-02", 
             to = "2021-06-01",   
             auto.assign = FALSE)

BTC <- 
  getSymbols(Symbols = "BTC-USD",             
             from = "2018-01-02", 
             to = "2021-06-01",   
             auto.assign = FALSE)


#include only adjusted close prices

SP500 <- SP500[, 6]
names(SP500) <- "SP500"

DAX <- DAX[, 6]
names(DAX) <- "DAX"

BTC <- BTC[, 6]
names(BTC) <- "BTC"

WIG20 <- WIG20[, 6]
names(WIG20) <- "WIG20"

#add log-returns

SP500$SP500.r <- diff.xts(log(SP500$SP500))

DAX$DAX.r <- diff.xts(log(DAX$DAX))

BTC$BTC.r <- diff.xts(log(BTC$BTC))

WIG20$WIG20.r <- diff.xts(log(WIG20$WIG20))


#merge to Portfolio with eqeual weithts

quotes <- 0.25*SP500$SP500.r+0.25*DAX$DAX.r+0.25*BTC$BTC.r+0.25*WIG20$WIG20.r
names(quotes) <- "quotes.r"
quotes$quotes <- 0.25*SP500$SP500+0.25*DAX$DAX+0.25*BTC$BTC+0.25*WIG20$WIG20
#quotes <- na.omit(quotes)

quotes$obs <- 1:length(quotes$quotes)

head(quotes) 
tail(quotes)

#plot of quotations and returns.

par(mfrow = c(2, 1))
plot(quotes$quotes.r,
     type = "l", col = "red", lwd = 1,
     main = "Portfolio returns")
plot(quotes$quotes,
     type = "l", col = "black", lwd = 1,
     main = "Portfolio quotes")
     
 
# plot of quotations and returns 
par(mfrow = c(2, 1))
plot(quotes$quotes.r,
     type = "l", col = "red", lwd = 1,
     main = "Portfolio returns")
plot(quotes$quotes,
     type = "l", col = "black", lwd = 1,
     main = "Portfolio prices")
par(mfrow = c(1, 1))

# plot of ACF for returns 
acf(quotes$quotes.r, lag.max = 36, na.action = na.pass,
    col = "darkblue", lwd = 7,
    main = "ACF for Portfolio returns")

acf(quotes$quotes.r, lag.max = 36, na.action = na.pass,
    ylim = c(-0.1, 0.1), # we rescale the vertical axis
    col = "darkblue", lwd = 7,
    main = "ACF for Portfolio returns")




#ggf. Verändern!!!!!!!!!!!!!!




# Based on the ACF analysis for Portfolio returns, we can say
# that there is - to some extent - an autoregressive relationship 
# among returns. 

# plot of ACF for squared returns 
acf(quotes$quotes.r^2, lag.max = 36, na.action = na.pass,
    col = "darkblue", lwd = 7,
    main = "ACF for Portfolio squared returns")

acf(quotes$quotes.r^2, lag.max = 36, na.action = na.pass,
    ylim = c(0, 0.5), # we rescale the vertical axis
    col = "darkblue", lwd = 7,
    main = "ACF for Portfolio squared returns")

# Plot of ACF for squares of NASDAQ returns shows a clear autoregressive
# relationship among them, which allows to conclude that ARCH effects
# are present in the log-returns. We can verify a formal hypothesis about this:


# testing for ARCH effects
ArchTest(quotes$quotes.r, lags = 5)

# durbinWatsonTest(lm(quotes$quotes.r^2 ~ 1),
#                  max.lag = 5) # first 5 lags


# Do returns come from normal distribution? 
basicStats(quotes$quotes.r) 
hist(quotes$quotes.r, prob = T, breaks = 40, main = "Density of Portfolio log-returns", xlab = "Portfolio log-returns")
curve(dnorm(x, mean = mean(quotes$quotes.r, na.rm = T),
            sd  = sd(quotes$quotes.r, na.rm = T)),
      col = "darkblue", lwd = 2, add = TRUE)

#Do returns com from t-student distribution?
hist(quotes$quotes.r, prob = T, breaks = 40, main = "Histogram of Portfolio Returns (t-student)", xlab = "Portfolio Returns")
curve(dt(x, df = 1, log),
     col = "darkblue", lwd = 2, add = TRUE)



basicStats(quotes$quotes.r)
# Skewness: left tail is (strongly) thicker than the right tail
# (excess) Kurtosis: Suggest a thicker tail than normal distribution (actural Kurtosis is approx. 39)

jarque.bera.test(na.omit(quotes$quotes.r))
# strongly reject Null-Hypothesis to a level of confidence of 99%


ArchTest(quotes$quotes.r, 
         lags = 5)

ArchTest(quotes$quotes.r, 
         lags = 50)
#with either 5 or 50 lags we can still reject the Null-Hypothesis 
#Thus we can consier an Arch Model

quotes$quotes.r[is.na(quotes$quotes.r)] <- 0
###################
# Garch(1,1)

spec <- ugarchspec(
  variance.model = list(model = "sGARCH", 
                        garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), 
                    include.mean = TRUE), 
  distribution.model = "norm")

quotes$quotes.r[is.na(quotes$quotes.r)] <- 0

# and estimate the model
k.garch11 <- ugarchfit(spec = spec, 
                           data = quotes$quotes.r)

k.garch11

##################  
# The EGARCH model
  
  spec <- ugarchspec(
    variance.model = list(model = "eGARCH", 
                          garchOrder = c(2, 1)),
    mean.model = list(armaOrder = c(5, 0), 
                      include.mean = TRUE), 
    distribution.model = "norm")
  
  
  
  # and estimate the model
  k.ar5egarch21 <- ugarchfit(spec = spec, 
                             data = quotes$quotes.r)
  
  k.ar5egarch21
  
  
  # ar2 to ar5 are not statistically significant !!!
  # lets remove them and estimate a simpler model AR(1)-EGARCH(2,1)
  
  spec <- ugarchspec(# variance equation
    variance.model = list(model = "eGARCH", 
                          garchOrder = c(2, 1)),
    mean.model = list(armaOrder = c(1, 0), 
                      include.mean = TRUE), 
    distribution.model = "norm")
  
  # function ugarchfit() doesn't accept missing values
  
  k.ar1egarch21 <- ugarchfit(spec = spec, 
                             data = quotes$quotes.r)
  
  k.ar1egarch21


###########################
# The GARCH-in-Mean model    

# lets first define a model specification
spec <- ugarchspec(# variance equation
  variance.model = list(model = "sGARCH", 
                        # sGARCH = standard GARCH
                        garchOrder = c(2, 1)),
  mean.model = list(armaOrder = c(1, 0), 
                    include.mean = TRUE,
                    archm = TRUE, archpow = 1), 
  distribution.model = "norm")

# function doesn't accept missing values

k.ar1garchm21 <- ugarchfit(spec = spec, 
                           data = quotes$quotes.r)

k.ar1garchm21

# mu not significant - lets remove it from the model

spec <- ugarchspec(# variance equation
  variance.model = list(model = "sGARCH", 
                        # sGARCH = standard GARCH
                        garchOrder = c(2, 1)),
 
  mean.model = list(armaOrder = c(1, 0), 
                    include.mean = FALSE,archpow = 1),
  distribution.model = "norm")


k.ar1garchm21 <- ugarchfit(spec = spec, 
                           data = quotes$quotes.r)

k.ar1garchm21

####################
# The GARCH-t model          

# lets first define a model specification
spec <- ugarchspec(# variance equation
  variance.model = list(model = "sGARCH", 
                        garchOrder = c(2, 1)),
  mean.model = list(armaOrder = c(1, 0), 
                    include.mean = TRUE), 
  distribution.model = "std") 

k.ar1garcht21 <- ugarchfit(spec = spec, 
                           data = quotes$quotes.r)

k.ar1garcht21

############################
# The EGARCH in mean-t model 

spec <- ugarchspec(
  variance.model = list(model = "eGARCH", 
                        garchOrder = c(2, 1)),
  mean.model = list(armaOrder = c(1, 0), 
                    include.mean = TRUE,
                    archm = TRUE, archpow = 1), 
  distribution.model = "std") # std = t-Student

# function doesn't accept missing values
k.ar1egarchmt21 <- ugarchfit(spec = spec, 
                             data = quotes$quotes.r)

k.ar1egarchmt21

############################
# The EGARCH-t in model 

spec <- 
  ugarchspec(variance.model = list(model = "eGARCH", garchOrder = c(2, 1)),
             mean.model = list(armaOrder = c(0, 0), include.mean = T),
             distribution.model = "std")



# function doesn't accept missing values
k.ar0egarcht21 <- ugarchfit(spec = spec, 
                             data = quotes$quotes.r)

k.ar0egarcht21



compare.ICs.ugarchfit(c("k.garch11",
                        "k.ar5egarch21",
                        "k.ar1egarch21", 
                        "k.ar1garchm21", 
                        "k.ar1garcht21", 
                        "k.ar1egarchmt21",
                        "k.ar0egarcht21"))



#Suggestions: 
# Akaike        Bayes      Shibata Hannan.Quinn 
# 6            4            6            4 

#7: k.ar1garcht21
#8: k.ar1egarchmt21

###
#(a) estimates of annualized conditional standard deviation in the in-sample period produced by the two models

#annualized conditional standard deviation k.ar1garchm21
sigma.forecast.longrun1 <- ugarchforecast(k.ar1garchm21, n.ahead = 252)
unconditional_sigma1 <-
  sqrt(
    k.ar1garchm21@model$pars["omega", 1] /
      (1 -
         k.ar1garchm21@model$pars["alpha1", 1] -
         k.ar1garchm21@model$pars["beta1", 1]))

plot(
  c(as.numeric(k.ar1garchm21@fit$sigma * sqrt(252)),
    as.numeric(sigma.forecast.longrun1@forecast$sigmaFor * sqrt(252))),
  main = "Annaulized Conditional Standard Deviation GARCH t-model",
  type = "l",
  ylab = "sigma annualized")
abline(h = unconditional_sigma1 * sqrt(252), col = "red")



#We can see that maximum value of estimated conditional standard deviation (sigma) was 
max(k.ar1garchm21@fit$sigma) * sqrt(252)*100
#annualized, while its long term uncoditional level was 
unconditional_sigma1 * sqrt(252)*100
#annualized.


#annualized conditional standard deviation k.ar1egarcht21

sigma.forecast.longrun2 <- ugarchforecast(k.ar0egarcht21, n.ahead = 252)
unconditional_sigma2 <-
  sqrt(
    k.ar0egarcht21@model$pars["omega", 1]/
      (1 -
         k.ar0egarcht21@model$pars["alpha1", 1] -
         k.ar0egarcht21@model$pars["beta1", 1]))
plot(
  c(as.numeric(k.ar0egarcht21@fit$sigma * sqrt(252)),
    as.numeric(sigma.forecast.longrun2@forecast$sigmaFor * sqrt(252))),
  main = "Annaulized Conditional Standard Deviation GARCH",
  type = "l",
  ylab = "sigma annualized")
abline(h = unconditional_sigma2 * sqrt(252), col = "red")

#omega is negative ??????


#We can see that maximum value of estimated conditional standard deviation (sigma) was 
max(k.ar0egarcht21@fit$sigma) * sqrt(252)*100
#annualized, while its long term uncoditional level was 
unconditional_sigma2 * sqrt(252)*100
#annualized.





###
#(b) estimates of the Value-at-Risk produced by the two models in the out-of-sample period
  
#######################
#Out-of-sample period
######################

#choice of the out-of-the sample data

k <- sum(x)%%6+1
k
# k=6 hence, the out-of-sample date starts 2020-06-01 

quotes2 <- quotes["2020-05-30/2021-06-01"]
quotes2$quotes.r[is.na(quotes$quotes.r)] <- 0

####################
# The GARCH-t model          

# lets first define a model specification
spec <- ugarchspec(# variance equation
  variance.model = list(model = "sGARCH", 
                        garchOrder = c(2, 1)),
  mean.model = list(armaOrder = c(1, 0), 
                    include.mean = TRUE), 
  distribution.model = "std") 

ar1garcht21 <- ugarchfit(spec = spec, 
                           data = quotes2$quotes.r)

ar1garcht21

############################
# The GARCH(1,1)

spec <- ugarchspec(
  variance.model = list(model = "sGARCH", 
                        garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), 
                    include.mean = TRUE), 
  distribution.model = "norm")


# and estimate the model
garch11 <- ugarchfit(spec = spec, 
                       data = quotes2$quotes.r)

garch11




#Standardization of returns.

quotes2$rstd <- (quotes2$quotes.r - mean(quotes2$quotes.r, na.rm = T)) /
  sd(quotes2$quotes.r ,na.rm = T)

#1% empirical quantile

q01 <- quantile(quotes2$rstd, 0.01, na.rm = T)
q01


#Calculation the value-at-risk (VaR)
quotes2$VaR1 <- q01 * ar1garcht21@fit$sigma

quotes2$VaR2 <- q01 * garch11@fit$sigma

#Plot of returns vs VaR

plot(quotes2$quotes.r, 
     main = "returns vs. VaR (GARCH-t)",
     col = "red", lwd = 1, type = 'l', 
     ylim = c(-0.1, 0.1))
abline(h = 0, lty = 2)
lines(quotes2$VaR1, type = 'l', col = "green")

plot(quotes2$quotes.r, 
     main = "returns vs. VaR (GARCH)",
     col = "red", lwd = 1, type = 'l', 
     ylim = c(-0.1, 0.1))
abline(h = 0, lty = 2)
lines(quotes2$VaR2, type = 'l', col = "green")

#In how many days losses were higher the assumed VaR?

sum(quotes2$quotes.r < quotes2$VaR1) / length(quotes2$VaR1)

sum(quotes2$quotes.r < quotes2$VaR2) / length(quotes2$VaR2)










# #Calculate Predictions of VaR for the Out-Of-Sample period
# 
# #GARCH t-model
# start   <- as.integer(quotes2$obs["2020-06-03"])  
# finish  <- as.integer(quotes2$obs["2021-05-27"])
# quotes4 <- quotes2
# VaR <- rep(NA, times = finish - start + 1)
# 
# mu     <- rep(NA, times = finish - start + 1)
# omega  <- rep(NA, times = finish - start + 1)
# alpha1 <- rep(NA, times = finish - start + 1)
# beta1  <- rep(NA, times = finish - start + 1)
# 
# time1 <- Sys.time()
# for (k in start:finish) {
#   tmp.data <- quotes2[quotes2$obs <= (k - 1), ]
#   #tmp.data <- tmp.data["2020-05-29" <= index(tmp.data) ]
#   tmp.data$rstd <- 
#     (tmp.data$quotes.r - mean(tmp.data$quotes.r, na.rm = T)) / sd(tmp.data$r, na.rm = T)
#   q01  <- quantile(tmp.data$rstd, 0.01, na.rm = T)
#   spec <- 
#     ugarchspec(# variance equation
#       variance.model = list(model = "sGARCH", 
#                             garchOrder = c(2, 1)),
#       mean.model = list(armaOrder = c(1, 0), 
#                         include.mean = TRUE), 
#       distribution.model = "std") 
#   
#   tmp.k.ar1garcht21     <- ugarchfit(spec = spec, data = na.omit(tmp.data$quotes.r))
#   sigma.forecast        <- ugarchforecast(tmp.k.ar1garcht21, n.ahead = 1)
#   sigma.forecast2       <- sigma.forecast@forecast$sigmaFor[1, 1]
#   VaR[k - start + 1]    <- q01 * sigma.forecast2
#   mu[k - start + 1]     <- tmp.k.ar1garcht21@fit$coef[1]
#   omega[k - start + 1]  <- tmp.k.ar1garcht21@fit$coef[2]
#   alpha1[k - start + 1] <- tmp.k.ar1garcht21@fit$coef[3]
#   beta1[k - start + 1]  <- tmp.k.ar1garcht21@fit$coef[4]
# }
# time2 <- Sys.time()
# time2 - time1
# 


# Plot mu omega and show that alpaha and beta are below 1 all the time

# quotes2$VaR1 <- VaR
# 
# ########## 
# # The EGARCH in mean-t model 
# 
# time1 <- Sys.time()
# for (k in start:finish) {
#   tmp.data <- quotes2[quotes2$obs <= (k - 1), ]
#   #tmp.data <- tmp.data["2020-05-29" <= index(tmp.data) ]
#   tmp.data$rstd <- 
#     (tmp.data$r - mean(tmp.data$quotes.r, na.rm = T)) / sd(tmp.data$r, na.rm = T)
#   q01  <- quantile(tmp.data$rstd, 0.01, na.rm = T)
#   spec <- ugarchspec(
#     variance.model = list(model = "eGARCH", 
#                           garchOrder = c(2, 1)),
#     mean.model = list(armaOrder = c(1, 0), 
#                       include.mean = TRUE,
#                       archm = TRUE, archpow = 1), 
#     distribution.model = "std") # std = t-Student
#   
#   tmp.k.ar1egarchmt21       <- ugarchfit(spec = spec, data = na.omit(tmp.data$quotes.r))
#   sigma.forecast        <- ugarchforecast(tmp.k.ar1egarchmt21, n.ahead = 1)
#   sigma.forecast2       <- sigma.forecast@forecast$sigmaFor[1, 1]
#   VaR[k - start + 1]    <- q01 * sigma.forecast2
#   mu[k - start + 1]     <- tmp.k.ar1egarchmt21@fit$coef[1]
#   omega[k - start + 1]  <- tmp.k.ar1egarchmt21@fit$coef[2]
#   alpha1[k - start + 1] <- tmp.k.ar1egarchmt21@fit$coef[3]
#   beta1[k - start + 1]  <- tmp.k.ar1egarchmt21@fit$coef[4]
# }
# time2 <- Sys.time()
# time2 - time1
# 
# quotes2$VaR2 <- VaR
# 
# 
# for (k in start:finish) {
#   k
# }
