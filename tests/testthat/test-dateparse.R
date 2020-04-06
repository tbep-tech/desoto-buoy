test_that("Checking date parse", {
  
  library(here)
  
  load(file = here('data/dat.Rds'))
  result <- anyNA(dat$DateTime)
  
  expect_false(result)
  
})