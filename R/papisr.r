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
    env <- parent.frame()
    sys_call <- sys.call()
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
    if(length(sys_call) == 3) {
        filter_info <- sys_call[[3]]
        papis_records_filter <-
            papis_records |>
            sapply(\(papis_record) {
                filter_info |>
                    eval(papis_record, env) |>
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
##' @param ... Colums specification as named expressions that are evaluated in papis record environment where two variables are bound - `path` and `info` (see `collect_papis_records()` for details. The evaluation environment is enclosed in parent frame (aka `tabulate_papis_records` calling environment)
##' 
##' @param .omit_all_na_rows Whether to remove rows with all NAs.
##' @param .bind_dot_n_and_dot_dot Whethet to bind two extra variables to the evaluation environment for columns. Namely `.n` (current row/record's number) and `..` as the entire `papis_records` input.
##' @return Data frame. If some of the column values have length > 1 then the table will be filled with these values.
##' 
##' @md 
##' @export 
tabulate_papis_records <- function(papis_records, ...
                                 , .omit_all_na_rows = TRUE
                                 , .bind_dot_n_and_dot_dot = TRUE) {
    fun_call <- sys.call()
    col_names <- ...names()
    env <- parent.frame()
    papis_table <-
        ifelse(.bind_dot_n_and_dot_dot
             , mapply(
                   \(papis_record, n) {
                       c(papis_record, .n = n, .. = papis_records)
                   }
                 , papis_records
                 , seq_along(papis_records)
                 , SIMPLIFY = FALSE)
             , papis_records) |>
        lapply(\(papis_record) {
            lapply(col_names
                 , \(col_name) {
                     col_val <- 
                         fun_call[[col_name]] |>
                         eval(papis_record, enclos = env)
                     if(length(col_val) == 0) {
                         return(NA)
                     } else if(is.list(col_val) || length(col_val) > 1) {
                         col_val <- 
                             col_val |>
                             lapply(\(col_val_el) {
                                 if(length(col_val_el) == 0) NA else col_val_el
                             }) |>
                             unlist()
                         return(col_val)
                     } else {
                         return(col_val)
                     }
                 }) |>
                `names<-`(col_names) |>
                as.data.frame(stringsAsFactors = FALSE
                            , check.names = FALSE)
        })
    papis_table <- do.call(rbind, papis_table)
    if(.omit_all_na_rows) {
        papis_table <- papis_table[rowSums(is.na(papis_table)) != ncol(papis_table), ]
    }
    return(papis_table)
}

validate_with_json_schema <- function(yml_file = "eee-ppat/info.yml"
                   , json_shema = "test-schema.json"
                     ## , yq_path = "."
                   , yq_path = '.data_description') {
    if(all(dependencies <- Sys.which(c('yq', 'ajv')) != "")) {
        tmp_json_file_name <-
            "tmp.json"
        ## tempfile("papis-info-yml-data", fileext = c(".json"))
        file.create(tmp_json_file_name)
        tmp_json_file <- file(tmp_json_file_name)
        ## do things here
        yq_cmd <- paste0(
            "yq --output-format=json '", yq_path, "' ", shQuote(yml_file)
        )
        system(yq_cmd, intern = TRUE) |>
            writeLines(tmp_json_file)
        ajv_cmd <- paste0(
            "ajv test",
            " -s ", shQuote(json_shema)
          , " -d ", shQuote(tmp_json_file_name)
          , " --all-errors"
          , " --valid"
          , " --messages=false"
        )
        ajv_out <- 
            system(ajv_cmd
                 , intern = TRUE
                 , ignore.stderr = TRUE, invisible = TRUE)
        close(tmp_json_file)
        ## file.remove(tmp_json_file_name)
    } else {
        stop("The following dependencies are not available on your system: "
           , paste(names(dependencies[!dependencies]), collapse = ", "))
    }
    return(ajv_out)
}
