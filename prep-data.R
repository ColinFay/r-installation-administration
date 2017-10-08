library(tidyverse)
library(stringr)
library(glue)
library(magrittr)
# Download epub

download.file("https://cran.r-project.org/doc/manuals/r-release/R-admin.epub", destfile = "radmin.epub")
unzip(zipfile = "radmin.epub")
file.remove(c("toc.ncx","titlepage.xhtml", "stylesheet.css"))

# Rename file and keep a track of file change
rename_file <- function(name){
  new_file <- gsub("(R-admin)_split_([0-9]*)", "\\2-\\1", name)
  new_file <- gsub("^0", "", new_file)
  file.rename(from = name, to = new_file)
  return(data.frame(orig = name, new = new_file))
}

file_names_change <- purrr::map_df(list.files(pattern = "R-admin"), rename_file)

html_converter <- function(file){
  file_name <- gsub("\\.html", "", file)
  system(command = glue("pandoc {file_name}.html -o {file_name}.Rmd"))
}

purrr::walk(list.files(pattern = "R-admin"), html_converter)

purrr::walk(list.files(pattern = "\\.html"), file.remove)


clean_html_rmd <- function(file){
  
  a <- readLines( file )
  
  a %<>% str_replace_all("<h1 .*>([A-Za-z0-9])", "# \\1") %>%
    str_replace_all("</h1>", "")%>% 
    str_replace_all("<h2 .*>([A-Za-z0-9])", "# \\1") %>%
    str_replace_all("</h2>", "") %>%
    str_replace_all("# [0-9]+", "# ")
  write(a, file = file)
}

purrr::walk(list.files(pattern = "Rmd"), clean_html_rmd)

clean_auto_ref <- function(file){
  
  a <- readLines( file )
  
  a %<>% str_replace_all("(R-admin)_split_([0-9]*)", "\\2-\\1") %>%
    str_replace_all("^0", "")
  write(a, file = file)
  
}

purrr::walk(list.files(pattern = "Rmd"), clean_auto_ref)

build_url_ref <- function(file){
  a <- readLines( file )
  url <- tolower(a[1]) %>%
    str_replace_all("# *", "") %>%
    str_replace_all(" +", "-")
  return(glue("{url}.html"))
}

file_names_change$url <- map(list.files(pattern = "admin.Rmd"), build_url_ref)

# Manual changes to index.Rmd

# Append some files 

file.append("index.Rmd", "02-R-admin.Rmd")

# Remove some useless files

file.remove(c("01-intro.Rmd","02-literature.Rmd","03-method.Rmd",
              "04-application.Rmd", "05-summary.Rmd","06-references.Rmd"))


file.remove(c("00-R-admin.Rmd","01-R-admin.Rmd", "02-R-admin.Rmd"))

# Manually replace url 

clean_url <- function(file){
  a <- readLines( file )
  
  a %<>% str_replace_all("R-admin_split_003.html", "obtaining-r.html") %>%
    str_replace_all("R-admin_split_004.html", "installing-r-under-unix-alikes.html") %>%
    str_replace_all("R-admin_split_005.html", "installing-r-under-windows.html") %>%
    str_replace_all("R-admin_split_006.html", "installing-r-under-macos.html") %>%
    str_replace_all("R-admin_split_007.html", "relational-databases.html") %>%
    str_replace_all("R-admin_split_008.html", "running-r.html") %>%
    str_replace_all("R-admin_split_009.html", "add-on-packages.html") %>%
    str_replace_all("R-admin_split_010.html", "internationalization-and-localization.html") %>%
    str_replace_all("R-admin_split_011.html", "choosing-between-32-and-64-bit-builds.html") %>%
    str_replace_all("R-admin_split_012.html", "the-standalone-rmath-library.html") %>%
    str_replace_all("R-admin_split_013.html", "appendix-a-essential-and-useful-other-programs-under-a-unix-alike.html") %>%
    str_replace_all("R-admin_split_014.html", "appendix-b-configuration-on-a-unix-alike.html") %>%
    str_replace_all("R-admin_split_015.html", "appendix-c-platform-notes.html") %>%
    str_replace_all("R-admin_split_016.html", "appendix-d-the-windows-toolset.html") %>%
    str_replace_all("R-admin_split_017.html", "function-and-variable-index.html") %>%
    str_replace_all("R-admin_split_018.html", "environment-variable-index.html")  
  write(a, file = file)
}

purrr::walk(list.files(pattern = "Rmd"), clean_url)
# Do some manual work here

# Build \o/

bookdown::render_book("index.Rmd", "bookdown::gitbook")

