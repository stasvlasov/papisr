#' @details
#' Bundle of convenience functions for papis workflows in R.
#' 
#' Provides some convenience functions for [papis](https://github.com/papis/papis) workflows in R. Papis is a 'powerful and highly extensible command-line based document and bibliography manager'. The package does not actually require `papis` to be installed in order for its functions to work.
#' @md
"_PACKAGE"

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

##' Tablulate papis records
##' 
##' @param papis_records List of papis records as returned by `collect_papis_records()`
##' @param ... Colums specification as named expressions that are evaluated in papis record environment where two variables are bound - `path` and `info` (see `collect_papis_records()` for details)
##' @return Data frame. If some of the column values have length > 1 then the table will be filled with these values.
##' 
##' @md 
##' @export 
tabulate_papis_records <- function(papis_records
                                 , ...) {
    fun_call <- sys.call()
    col_names <- ...names()
    papis_table <- 
        papis_records |>
        lapply(\(papis_record) {
            lapply(col_names
                 , \(col_name) {
                     col_val <- 
                         fun_call[[col_name]] |>
                         eval(papis_record)
                     if(length(col_val) == 0 ) {
                         return(NA)
                     } else {
                         return(col_val)
                     }
                 }) |>
                `names<-`(col_names) |>
                as.data.frame(stringsAsFactors = FALSE)
        })
    do.call(rbind, papis_table)
}
