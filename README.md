
# papisr

[![R-CMD-check](https://github.com/stasvlasov/papisr/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/papisr/actions)
[![codecov](https://codecov.io/gh/stasvlasov/papisr/branch/master/graph/badge.svg?token=1HD07SWHSH)](https://codecov.io/gh/stasvlasov/papisr)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/papisr)

Bundle of convenience functions for papis workflows in R.

Provides some convenience functions for [papis](https://github.com/papis/papis) workflows in R. Papis is a 'powerful and highly extensible command-line based document and bibliography manager'. The package does not actually require `papis` to be installed in order for its functions to work.


## Installation

    ## Installs and loads papisr
    devtools::install_github("stasvlasov/papisr")
    library("papisr")


## Usage

Suppose you have a papis library located in `testdata/papis` that includes 4 simple bibliographic records (see below for the content of files). This example papis library is provided with the package and accessible with `system.file()`

Now, for example, if you want to tabulate `year` and `url` fields and number of `tags` for each record that is not tagged as 'classics' you can do it with the following simple script:

    system.file("testdata", "papis", package = "papisr") |>
        papisr::collect_papis_records(!("classics" %in% info$tags)) |>
        papisr::tabulate_papis_records(`Year` = info$year
                                     , `URL` = info$url
                                     , `No. of tags` = length(info$tags))

The script returns the following data.frame:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-right" />

<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">Year</th>
<th scope="col" class="org-left">URL</th>
<th scope="col" class="org-right">No. of tags</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-right">2022</td>
<td class="org-left">example.com</td>
<td class="org-right">2</td>
</tr>


<tr>
<td class="org-right">1985</td>
<td class="org-left">uvt.nl</td>
<td class="org-right">2</td>
</tr>


<tr>
<td class="org-right">2222</td>
<td class="org-left">&#xa0;</td>
<td class="org-right">1</td>
</tr>
</tbody>
</table>

Here 3 out of 4 records were tabulated because the one records with `tag` "classics" was filtered out.


## Test records in papis format

`testdata/papis/a/info.yml`

    tags:
      - data
      - research
    url: example.com
    year: 2022

`testdata/papis/b/info.yml`

    tags:
      - research
      - phd
    url: uvt.nl
    year: 1985

`testdata/papis/c/INFO.YML`

    tags: data
    year: 2222

`testdata/papis/d/info.yaml`

    tags: classics
    year: 2000

