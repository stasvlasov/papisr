#' @details
#' Bundle of convenience functions for papis workflows in R.
#' Provides some convenience functions for [[https://github.com/papis/papis][papis] workflows in R. Papis is '[p]owerful and highly extensible command-line based document and bibliography manager'.
#' 
#' This package does not require actually require `papis` to be installed in order for its functions to work.
#' @keywords internal
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

tabulate_papis_records <- function(papis_records
                                 , ...
                                 , use_path_as_row_names = FALSE) {
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
                     col_val_len <- length(col_val)
                     if(col_val_len == 1) {
                         return(col_val)
                     } else if(col_val_len == 0) {
                         return(NA)
                     } else {
                         stop("tabulate_papis_records -- the calculated values should have length of 1 or 0 (NA). Here col_val = '", paste(col_val, collapse = ", "), "' has length of ", col_val_len)
                     }
                 })
        })
    if(use_path_as_row_names) {
        row_names <- sapply(papis_records, `[[`, "path")
    } else {
        row_names <- NULL
    }
    do.call(rbind, papis_table) |>
    `dimnames<-`(list(row_names, col_names))
}
