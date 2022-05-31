##' Collects papis records
##'
##' The collection is done by (1) looking for all subdirectories with info.yml file that defines papis record, (2) filtering those records and (3) returning lists of 'path' (root dir of papis record) and 'info' (content of info.yml) for each record
##' 
##' @param dir Directory to scan recursevely for papis records
##' @param filter_info Exprocion that allows to filter info.yml files that is evaluated in the environment with two variables bound for each record - 'path' (root dir of papis record) and 'info' (content of info.yml). The expression should return TRUE in order for record to be filtered in. Other returned value will filter the record out. Example: `'data' %in% info$tags` will filter only records that have tag 'data' in their info.yml descriptions
##' @return list of 'path' (root dir of papis record) and 'info' (content of info.yml) for each record
##' 
##' @md 
##' @export 
collect_papis_records <- function(dir, filter_info) {
    papis_info_yml_files <- 
        list.files(dir
                 , pattern = "^info\\.y[a]?ml$"
                 , full.names = TRUE
                 , recursive = TRUE
                 , ignore.case = TRUE)
    papis_records <-
        papis_info_yml_files |>
        lapply(\(info_yml_file)
               list(path = dirname(info_yml_file)
                  , info = yaml::read_yaml(info_yml_file)))
    ## filter info.yml files based on some filter criteria
    if(!missing(filter_info)) {
        ## save this env because substitute does not enherit from parents
        ## and can not find `filter_info` when called from sapply func env
        env <- environment()
        papis_records_filter <-
            papis_records |>
            sapply(\(papis_record) {
                substitute(filter_info, env)  |>
                    ## bind papis_record to eval env
                    eval(envir = papis_record) |>
                    isTRUE()
            })
        return(papis_records[papis_records_filter])
    } else {
        return(papis_records)
    }
}





## tests
collect_papis_records(
    dir = "~/org/data"
  , "name_standardization" %in% info$tags)

collect_papis_records(
    dir = "~/org/data"
  , info$metacodes$url == "https://www.researchoninnovation.org/epodata/")[[1]]$path


collect_papis_records(
    dir = system.file("testdata", "papis", package = "papisr")
  , info$metacodes$url == "https://www.researchoninnovation.org/epodata/")[[1]]$path

collect_papis_records(
    dir = "inst/testdata/papis"
  , "data" %in% info$tags)






tabulate_papis_records <- function(papis_records, ...) {
    message("HI")
    env <- environment()
    papis_records |>
        sapply(\(papis_record) {
            col_values <-
                sapply(1:...length(), \(n) {
                    parse(paste0("..", n)) |>
                        substitute(env) |>
                        deparse()
                })
                        ## eval(envir = papis_record)
            ## if(length(col_val) > 1) stop("tabulate_papis_records -- col value should be length of 1")
            return(col_values)
                })
    ## names(col_values) <- names(col_formulas)
}


collect_papis_records("inst/testdata/papis") |>
    tabulate_papis_records(year = info$year
                         , url = info$url)
