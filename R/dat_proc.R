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

# col types
coltyps <- c('numeric', 'numeric', 'text', 'date', rep('numeric', 8))

# import and process
dat208 <- read_excel(pth, sheet = 'Ft_DeSoto_Buoy208', na = '-', col_types = coltyps) 
dat209 <- read_excel(pth, sheet = 'Ft_DeSoto_Buoy209', na = '-', col_types = coltyps)  
dat <- bind_rows(dat208, dat209) %>%  
  mutate(
    Date = ymd(Date),
    Time = case_when(
      !grepl(':', Time) ~ format(as.POSIXct(Sys.Date() + as.numeric(Time)), "%H:%M", tz="America/Jamaica"),
      T ~ Time
    )
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
writeLines(as.character(paste(Sys.time(), Sys.timezone())), 'log.txt')


