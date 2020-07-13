test_that("Checking minimum date", {
  
  library(here)
  library(dplyr)
  
  load(file = here('data/dat.RData'))
  result <- min(dat$DateTime, na.rm = T)
  
  expect_equal(result, structure(1561821300, class = c("POSIXct", "POSIXt"), tzone = "America/Jamaica"))
  
})

