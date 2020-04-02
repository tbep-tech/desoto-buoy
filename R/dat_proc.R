library(readxl)
library(tidyverse)
library(tbeptools)
library(lubridate)

pth <- 'data-raw/dat.xlsx'
urlin <- 'https://files.pinellascounty.org/pw/FtDesotoTBEP/Ft_DeSoto_Buoys_Data.xlsx'
if(file.exists(pth))
  file.remove(pth)
read_dlcurrent(pth, urlin = urlin)

dat <- read_excel(pth) %>% 
  unite('DateTime', Date, Time, sep = ' ') %>% 
  mutate(
    DateTime = mdy_hm(DateTime)
  )
