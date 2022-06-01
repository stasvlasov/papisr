expect_equal(
  system.file("testdata", "papis", package = "papisr") |>
  collect_papis_records("data" %in% info$tags) |>
  lapply(`[[`, "info")
  ## remove paths as in test environment it is different
, list(list(tags = c("data", "research"), url = "example.com", 
    year = 2022L), list(tags = "data", year = 2222L)))
