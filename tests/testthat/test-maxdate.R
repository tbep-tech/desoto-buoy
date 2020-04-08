test_that("Checking maximum date", {
  
  library(here)
  library(dplyr)
  
  load(file = here('data/dat.RData'))
  result <- max(dat$DateTime, na.rm = T)
  
  expect_lt(result, Sys.time())
  
})

