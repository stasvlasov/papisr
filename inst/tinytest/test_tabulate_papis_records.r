expect_equal(system.file("testdata", "papis", package = "papisr") |>
             collect_papis_records() |>
             tabulate_papis_records(year = info$year
                                  , url = info$url
                                  , tag = length(info$tags)
                                  , use_path_as_row_names = FALSE)
, structure(list(2022L, 1985L, 2222L, 2000L, "example.com", "uvt.nl", 
    NA, NA, 2L, 2L, 1L, 1L), .Dim = 4:3, .Dimnames = list(NULL, 
    c("year", "url", "tag"))))
