library(tabulizer)
library(dplyr)
library(miniUI)
library(stringr)
library(lubridate)
library(data.table)  #Used for Cross Joining our

session <- c("FP1")#, "FP2", "FP3", "FP4", "Q1", "Q2", "WUP")
event <- c("QAT","ARG","AME", "SPA", "FRA", "ITA", "CAT", "NED", "GER", "AUT", "CZE", "GBR", "RSM")
type <- c("Classification")#, "Analysis")
x <- as.matrix(CJ(event, session, type))
datalist = list()

##Loop through the sessions  
for ( i in seq(nrow(x))) {
  url <- paste("http://resources.motogp.com/files/results/2016/", x[i,1], "/MotoGP/"
               , x[i,2],"/",x[i,3],".pdf", sep = "")
  dat <- data.frame(extract_areas(url), stringsAsFactors = FALSE)
  dat <- dat[-1,]
  dat$url <- url
  dat$Session <- x[i,2]
  dat$Event   <- x[i,1]
  dat$BestTime <- 
    datalist[[i]] <- dat
  print(url)
}

df <- ldply(datalist, data.frame)

df <- subset(df,df$X3 != "")

df[df == ""] <- NA

df <- cbind(df, data.frame(do.call('rbind', strsplit(as.character(df$X8),   ' ', fixed=TRUE))))

df <- cbind(df, data.frame(do.call('rbind', strsplit(as.character(df$X9),   ' ', fixed=TRUE))))

df <- df[, c(-8,-9)]

df <- df[, c(1,2,3,4,5,6,7,12,13,14,15,8,10,11,9)]

names(df) <- c("Pos","RiderNumber","Rider","Nation","Team","Motorcycle","Time","FastLap"
               ,"TotalLaps","GapFront","GapNext","Speed","Session","Event","URL")

df$Time    <- ms(df$Time)
df$Time_S  <- period_to_seconds(ms(df$Time))
df$Year    <- sapply(sapply("2016",as.character),as.numeric)

df[,c(1,2,8,9,10,11,12,16,17)] <- sapply(sapply(df[,c(1,2,8,9,10,11,12,16,17)], as.character), as.numeric)
