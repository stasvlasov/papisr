expect_equal(
  system.file("testdata", "papis", package = "papisr") |>
  collect_papis_records("data" %in% info$tags)
, list(list(path = "/Library/Frameworks/R.framework/Versions/4.1/Resources/library/papisr/testdata/papis/a", 
    info = list(tags = c("data", "research"), url = "example.com", 
        year = 2022L)), list(path = "/Library/Frameworks/R.framework/Versions/4.1/Resources/library/papisr/testdata/papis/c", 
    info = list(tags = "data", year = 2222L))))
