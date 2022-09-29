expect_equal(system.file("testdata", "papis", package = "papisr") |>
             collect_papis_records() |>
             tabulate_papis_records(year = info$year
                                  , url = info$url
                                  , tag = length(info$tags))
, structure(list(year = c(2022L, 1985L, 2222L, 2000L), url = c("example.com", 
"uvt.nl", NA, NA), tag = c(2L, 2L, 1L, 1L)), row.names = c(NA, 
-4L), class = "data.frame"))


## test filling the columns
expect_equal(
    system.file("testdata", "papis", package = "papisr") |>
             collect_papis_records() |>
             tabulate_papis_records(year = info$year
                                  , url = info$url
                                  , tag = info$tags)
, structure(list(year = c(2022L, 2022L, 1985L, 1985L, 2222L, 2000L
), url = c("example.com", "example.com", "uvt.nl", "uvt.nl", 
NA, NA), tag = c("data", "research", "research", "phd", "data", 
                 "classics")), row.names = c(NA, -6L), class = "data.frame"))


## test eval environment
test_function_length_plus <- function(x) length(x) + 1

expect_equal(
    system.file("testdata", "papis", package = "papisr") |>
             collect_papis_records() |>
             tabulate_papis_records(year = info$year
                                  , url = info$url
                                  , tag = test_function_length_plus(info$tags))
, structure(list(year = c(2022L, 1985L, 2222L, 2000L), url = c("example.com", 
"uvt.nl", NA, NA), tag = c(3, 3, 2, 2)), row.names = c(NA, -4L
), class = "data.frame"))
