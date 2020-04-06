test_that("Checking date parse", {
  
  library(here)
  
  dat <- readRDS(file = here('data/dat.RDS'))
  result <- anyNA(dat$DateTime)
  
  expect_false(result)
  
})