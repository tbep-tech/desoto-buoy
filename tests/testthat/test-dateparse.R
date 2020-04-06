test_that("Checking date parse", {
  
  load(file = '../../data/dat.R)
  result <- anyNA(dat$DateTime)
  
  expect_false(result)
  
})