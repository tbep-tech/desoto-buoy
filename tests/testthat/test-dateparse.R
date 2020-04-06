test_that("Checking date parse", {
  
  load(file = here('data/dat.RData'))
  result <- anyNA(dat$DateTime)
  
  expect_false(result)
  
})