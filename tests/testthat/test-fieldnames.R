test_that("Checking field names", {
  
  load(file = here('data/dat.RData'))
  result <- names(dat)
  
  expect_equal(result, c("Station ID", "DateTime", "Temperature", "Conductivity", "Salinity", 
                         "pH", "Chlorophyll-a", "Phaeophytin", "DO%", "DO")
  )
  
})