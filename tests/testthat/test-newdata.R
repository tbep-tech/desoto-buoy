test_that("Checking new data, will break if data are added", {
  
  library(here)
  library(dplyr)
  
  load(file = here('data/dat.RData'))
  result <- nrow(dat)
  
  expect_equal(result, 115862)
  
})

