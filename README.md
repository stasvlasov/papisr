# papisr

[![R-CMD-check](https://github.com/stasvlasov/papisr/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/papisr/actions)
[![codecov](https://codecov.io/gh/stasvlasov/papisr/branch/master/graph/badge.svg?token=1HD07SWHSH)](https://codecov.io/gh/stasvlasov/papisr)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/papisr)

Bundle of convenience functions for papis workflows in R.

Provides some convenience functions for [papis](https://github.com/papis/papis) workflows in R. Papis is a 'powerful and highly extensible command-line based document and bibliography manager'. The package does not actually require `papis` to be installed in order for its functions to work.

## Installation

``` {.r org-language="R"}
## Installs and loads papisr
devtools::install_github("stasvlasov/papisr")
library("papisr")
```

## Usage

Suppose you have a papis library located in `testdata/papis` that
includes 4 simple bibliographic records (see
[1.3](#Test records in papis format) for the content of files). This
example papis library is provided with the package and accessible with
`system.file()`

Now, for example, if you want to tabulate `year` and `url` fields and
number of `tags` for each record that is not tagged as \'classics\' you
can do it with the following simple script:

``` {#papisr-example .r org-language="R"}
system.file("testdata", "papis", package = "papisr") |>
    papisr::collect_papis_records(!("classics" %in% info$tags)) |>
    papisr::tabulate_papis_records(`Year` = info$year
                                 , `URL` = info$url
                                 , `No. of tags` = length(info$tags))
```

The script returns the following data.frame

Here 3 out of 4 records were tabulated because the one records with
`tag` \"classics\" was filterd out.

## Test records in papis format

`testdata/papis/a/info.yml`

``` yaml
tags:
  - data
  - research
url: example.com
year: 2022
```

`testdata/papis/b/info.yml`

``` yaml
tags:
  - research
  - phd
url: uvt.nl
year: 1985
```

`testdata/papis/c/INFO.YML`

``` yaml
tags: data
year: 2222
```

`testdata/papis/d/info.yaml`

``` yaml
tags: classics
year: 2000
```
