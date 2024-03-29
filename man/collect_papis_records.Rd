% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/papisr.r
\name{collect_papis_records}
\alias{collect_papis_records}
\title{Collects papis records}
\usage{
collect_papis_records(dir, filter_info)
}
\arguments{
\item{dir}{A character vector of directories to scan recursevely for papis records.}

\item{filter_info}{Exprocion that allows to filter info.yml files that is evaluated in the environment with two variables bound for each record - 'path' (root dir of papis record) and 'info' (content of info.yml). The expression should return TRUE in order for record to be filtered in. Other returned value will filter the record out. Example: \code{'data' \%in\% info$tags} will filter only records that have tag 'data' in their info.yml descriptions}
}
\value{
list of 'path' (root dir of papis record) and 'info' (content of info.yml) for each record
}
\description{
The collection is done by (1) looking for all subdirectories with info.yml file that defines papis record, (2) filtering those records and (3) returning lists of 'path' (root dir of papis record) and 'info' (content of info.yml) for each record
}
