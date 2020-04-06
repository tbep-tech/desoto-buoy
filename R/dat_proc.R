library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(tbeptools)
library(lubridate)

# orig data
load(file = 'data/dat.RData')
dimorig <- dim(dat)

pth <- '../data-raw/dat.1xlsx'
urlin <- 'https://files.pinellascounty.org/pw/FtDesotoTBEP/Ft_DeSoto_Buoys_Data.xlsx'
if(file.exists(pth))
  file.remove(pth)
read_dlcurrent(pth, urlin = urlin)

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

save(dat, file = '../data/dat.RData', compress = 'xz')
