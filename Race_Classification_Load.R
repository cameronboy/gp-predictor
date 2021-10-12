#Factored in races with 2 sessions…now we need to account for them in the DF by aggregating them...?
library(tabulizer)
library(miniUI)
library(zoo)
library(RCurl)
library(tidyverse)
library(lubridate)
library(httr)

session <- c("FP1","FP2")#, "FP3", "FP4", "Q1", "Q2", "WUP")
event <- c("AME","AME", "SPA", "FRA", "ITA")#, "CAT", "NED", "GER", "AUT", "CZE", "GBR", "RSM","ARA")
type <- c("Classification")##, "Analysis")
x <- as.matrix(data.table::CJ(event, session, type))
datalist = list()

opts <- list(
  proxy         = "userproxy.biperf.com",
  proxyusername = "boyc", 
  proxypassword = "Fall2016", 
  proxyport     = 8080
)


##Loop through the sessions  
for ( i in seq(nrow(x))) {
  url <- paste("http://resources.motogp.com/files/results/2016/", x[i,1], "/MotoGP/"
               , x[i,2],"/",x[i,3],".pdf", sep = "")
  if(url.exists(url, .opts = opts)){
    dat <- data.frame(extract_tables(url, pages = 1, guess = FALSE, area = list(c(128.296875, 26.403125, 709.9093750000001, 584.215625))), stringsAsFactors = FALSE)
    dat <- dat[-1,]
    dat$url <- url
    dat$Session <- x[i,2]
    dat$Event   <- x[i,1]
    datalist[[i]] <- dat
    print(paste(i,"of", nrow(x),sep = " "))} else {
      break
    }
}


df <- bind_rows(datalist)

df <- as_data_frame(df)

df[df == ""] <- NA

df$Pl <- na.locf(df$X1)

df <- mutate(df, Status = ifelse( !grepl("\\d",df$X1), Pl, NA))

df$X1 <- transmute(df, X1 = ifelse( grepl("\\d",df$X1), Pl, NA))

df <- subset(df,df$X3 != "")

df <- cbind(df, data.frame(do.call('rbind', strsplit(as.character(df$X1),   ' ', fixed=TRUE))))


df <- df[, -1]

df <- df[, c(13,14,1,2,3,4,5,6,7,8,9,11,12,10)]
df <- df[, -5]


names(df) <- c("Pos","Points","RiderNumber","Rider","Nation","Team","Motorcycle","TotalTime","Avg Speed",
               "GapFront","Session","Event","URL")

df$GapFront <- transmute(df, GapFront = ifelse(is.na(GapFront) & Pos == 1, 0,GapFront))

df[,c(1,2,3,9,10)] <- sapply(sapply(df[,c(1,2,3,9,10)], as.character), as.numeric)


df$Points <- transmute(df, Points = ifelse(Pos > 15 | is.na(Pos), 0,Points))

df$TotalTime   <- ms(df$TotalTime)
df$TotalTime_S  <- period_to_seconds(ms(df$TotalTime))
df$Year    <- sapply(sapply("2016",as.character),as.numeric)

write.csv(df, "BigRawTable.csv")

