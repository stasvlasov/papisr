expect_equal(
  system.file("testdata", "papis", package = "papisr") |>
  collect_papis_records("data" %in% info$tags)
, list(list(path = "inst/testdata/papis/a", info = list(tags = c("data", "research"), url = "example.com", year = 2022L)), list(path = "inst/testdata/papis/c", info = list(tags = "data", year = 2222L))))
