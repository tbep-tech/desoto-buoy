library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(tbeptools)
library(lubridate)
library(here)

pth <- here::here('data-raw/dat.xlsx')
dtfl <- here('data/dat.RData')
urlin <- 'https://files.pinellascounty.org/pw/FtDesotoTBEP/Ft_DeSoto_Buoys_Data.xlsx'

# remove so read_dlcurrent doesn't break
if(file.exists(pth))
  file.remove(pth)

# download data from ftp
read_dlcurrent(pth, urlin = urlin)

# import and process
dat208 <- read_excel(pth, sheet = 'Ft_DeSoto_Buoy208', na = '-') 
dat209 <- read_excel(pth, sheet = 'Ft_DeSoto_Buoy209', na = '-')  
dat <- bind_rows(dat208, dat209) %>%  
  mutate(
    Date = mdy(Date),
    Time = str_pad(Time, 4, pad = '0'),
    Time = gsub('^([0-9][0-9])([0-9][0-9])$', '\\1\\:\\2', Time)
    ) %>% 
  separate(Time, c('hrs', 'min'), sep = ':') %>% 
  mutate(
    hrs = as.numeric(hrs), 
    min = as.numeric(min), 
    sec = 0
  ) %>% 
  unite('Time', hrs, min, sec, sep = ':') %>% 
  unite('DateTime', Date, Time, sep = ' ') %>% 
  mutate(
    DateTime = ymd_hms(DateTime)
  ) 

save(dat, file = dtfl, version = 2)

# log so commit is updated
writeLines(as.character(Sys.time()), 'log.txt')


