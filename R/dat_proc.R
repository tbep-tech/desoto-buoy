library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(tbeptools)
library(lubridate)
library(here)
library(utils)
library(sf)

# buoy data ---------------------------------------------------------------

# pth <- here::here('data-raw/dat.xlsx')
# dtfl <- here('data/dat.RData')
# urlin <- 'https://files.pinellascounty.org/pw/FtDesotoTBEP/Ft_DeSoto_Buoys_Data.xlsx'
# 
# # remove so read_dlcurrent doesn't break
# if(file.exists(pth))
#   file.remove(pth)
# 
# # download data from ftp
# read_dlcurrent(pth, urlin = urlin)
# 
# # col types
# coltyps <- c('numeric', 'numeric', 'text', 'text', rep('numeric', 8))
# 
# # import and process
# dat208 <- read_excel(pth, sheet = 'Ft_DeSoto_Buoy208', na = '-', col_types = coltyps) 
# dat209 <- read_excel(pth, sheet = 'Ft_DeSoto_Buoy209', na = '-', col_types = coltyps)  
# dat <- bind_rows(dat208, dat209) %>%  
#   mutate(
#     Date = case_when(
#       grepl('/', Date) ~ mdy(Date),
#       T ~ as.Date(as.numeric(Date), origin = '1900-01-01')
#     ),
#     Time = case_when(
#       !grepl(':', Time) ~ format(as.POSIXct(Sys.Date() + as.numeric(Time)), "%H:%M", tz="America/Jamaica"),
#       T ~ as.character(Time)
#     )
#   ) %>% 
#   unite('DateTime', Date, Time, sep = ' ') %>% 
#   mutate(
#     DateTime = ymd_hm(DateTime, tz = 'America/Jamaica'),
#     DateTime = lubridate::round_date(DateTime, "15 minutes")
#   ) %>% 
#   arrange(`Station ID`, DateTime) %>%
#   select(-Year) %>%
#   group_by(`Station ID`, DateTime) %>%
#   summarise_all(mean) %>%
#   ungroup() %>% 
#   mutate_if(is.numeric, ~ ifelse(. < 0, NaN, .))
# 
# # create complete time series
# tms <- range(dat$DateTime)
# tms <- seq(tms[1], tms[2], by = '15 min')
# 
# tojn <- crossing(
#   `Station ID` = unique(dat$`Station ID`), 
#   DateTime = tms
# )
# 
# # join with original 
# dat <- tojn %>% 
#   left_join(dat,by = c('Station ID', 'DateTime'))
# 
# save(dat, file = dtfl, version = 2)


# from EDontis 3/8/23 via email
pth <- here::here('data-raw/FtDeSoto_buoys.xlsx')

# col types
coltyps <- c('numeric', 'numeric', 'text', 'text', rep('numeric', 8))

# import and process
dat208 <- read_excel(pth, sheet = '208', na = '-', col_types = coltyps) 
dat209 <- read_excel(pth, sheet = '209', na = '-', col_types = coltyps)  
dat <- bind_rows(dat208, dat209) %>%  
  mutate(
    Date = case_when(
      grepl('/', Date) ~ mdy(Date),
      T ~ as.Date(as.numeric(Date), origin = '1899-12-30')
    ),
    Time = case_when(
      !grepl(':', Time) ~ format(as.POSIXct(Sys.Date() + as.numeric(Time)), "%H:%M", tz="UTC"),
      T ~ as.character(Time)
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

save(dat, file = here('data/dat.RData'), version = 2)

# log so commit is updated
writeLines(as.character(paste(Sys.time(), Sys.timezone())), 'log.txt')

# # temp replacement with file from RB
# 
# coltyps <- c('numeric', 'numeric', 'text', 'text', rep('numeric', 8))
# 
# # import and process
# dat209ext <- read_excel('data-raw/Buoy 209 West of Cut Data.xlsx', sheet = 'Ft_DeSoto_Buoy209', na = '-', col_types = coltyps)  
# dat209 <- dat209ext %>% 
#   mutate(
#     Date = case_when(
#       grepl('/', Date) ~ mdy(Date),
#       T ~ as.Date(as.numeric(Date), origin = '1900-01-01')
#     ),
#     Time = case_when(
#       !grepl(':', Time) ~ format(as.POSIXct(Sys.Date() + as.numeric(Time)), "%H:%M", tz="America/Jamaica"),
#       T ~ as.character(Time)
#     )
#   ) %>% 
#   unite('DateTime', Date, Time, sep = ' ') %>% 
#   mutate(
#     DateTime = ymd_hm(DateTime, tz = 'America/Jamaica'),
#     DateTime = lubridate::round_date(DateTime, "15 minutes")
#   ) %>% 
#   arrange(`Station ID`, DateTime) %>%
#   select(-Year) %>%
#   group_by(`Station ID`, DateTime) %>%
#   summarise_all(mean) %>%
#   ungroup() %>% 
#   mutate_if(is.numeric, ~ ifelse(. < 0, NaN, .))
# 
# data(dat)
# 
# dat208 <- dat %>% 
#   filter(`Station ID` %in% '208')
# 
# dat <- bind_rows(dat208, dat209)
# 
# # create complete time series
# tms <- range(dat$DateTime)
# tms <- seq(tms[1], tms[2], by = '15 min')
# 
# tojn <- crossing(
#   `Station ID` = unique(dat$`Station ID`), 
#   DateTime = tms
# )
# 
# # join with original 
# dat <- tojn %>% 
#   left_join(dat,by = c('Station ID', 'DateTime'))
# 
# save(dat, file = dtfl, version = 2)
# 
# # log so commit is updated
# writeLines(as.character(paste(Sys.time(), Sys.timezone())), 'log.txt')

# prop scarring data ------------------------------------------------------

# # download zip gdb, unzip, all in temp files
# url <- 'https://files.pinellascounty.org/pw/FtDesotoTBEP/propscar.gdb.zip'
# tmp1 <- tempfile()
# tmp2 <- tempfile()
# download.file(url, destfile = tmp1)
# unzip(tmp1, exdir = tmp2)
# gdb <- list.files(tmp2, full.names = T)
# # st_layers(gdb)
# 
# propscarlines <- sf::st_read(dsn = gdb, layer = 'propscarlines')
# 
# save(propscarlines, file = 'data/propscarlines.RData', version = 2)

