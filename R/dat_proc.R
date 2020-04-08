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
    Time = str_pad(Time, 4, pad = '0')
    ) %>% 
  unite('DateTime', Date, Time, sep = ' ') %>% 
  mutate(
    DateTime = ymd_hm(DateTime, tz = 'America/Jamaica'),
    DateTime = lubridate::round_date(DateTime, "15 minutes")
  ) %>% 
  arrange(`Station ID`, DateTime) %>% 
  select(-Year) %>%
  group_by(`Station ID`, DateTime) %>%
  summarise_all(mean) %>%
  ungroup() %>% 
  mutate_if(is.numeric, ~ ifelse(. < 0, NaN, .))

# create complete time series
tms <- range(dat$DateTime)
tms <- seq(tms[1], tms[2], by = '15 min')

tojn <- crossing(
  `Station ID` = unique(dat$`Station ID`), 
  DateTime = tms
)

# join with original 
dat <- tojn %>% 
  left_join(dat,by = c('Station ID', 'DateTime'))

save(dat, file = dtfl, version = 2)

# log so commit is updated
writeLines(as.character(Sys.time()), 'log.txt')


