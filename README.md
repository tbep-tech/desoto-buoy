# README

[![Build Status](https://travis-ci.org/tbep-tech/desoto-buoy.svg?branch=master)](https://travis-ci.org/tbep-tech/desoto-buoy)

Build is completed daily on Travis to process raw data in [R/dat_proc.R](https://github.com/tbep-tech/desoto-buoy/blob/master/R/dat_proc.R) and run checks.  

Processing includes: 

* Import of the file <https://files.pinellascounty.org/pw/FtDesotoTBEP/Ft_DeSoto_Buoys_Data.xlsx>
* Combining data for buoys 208 and 209
* Standardizing time step to 15 minute intervals, including rounding to nearest 15 minute time step and creation of continuous record
* Averaging observations with duplicate time stamps
* Assigning NA value to observations less than zero

Tests include: 

* Verify all dates are parsed correctly
* Minimum date does not occur before 2019-06-29 15:15:00 EST
* Maximum date does not occur after current system time
* Column names are "Station ID", "DateTime", "Temperature", "Conductivity", "Salinity", "pH", "Chlorophyll-a", "Pheophytin", "DO%", "DO"

