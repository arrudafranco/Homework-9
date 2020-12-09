# hw09

## Gustavo Arruda

This repository is part of a University of Chicago course called "Computation for the Social Sciences" taught in the fall of 2020. It contains 2020 data from the [Preaching Goes Viral](https://blogs.miamioh.edu/critical-distance/preaching-goes-viral-responses-to-the-pandemic/) project, which contains online religious responses to the pandemic with a focus on Brazilian Pentecostal-charismatic groups. The repository also contains a probabilistic topical model of PGV data.

 - [PT_stop_words.xlsx](PT_stop_words.xlsx) contains a list of Portuguese stop words.
 - [PT_stop_word_sources.xlsx](PT_stop_word_sources.xlsx) contains a list of data sets used to generate PT_stop_words.xlsx.
 - Running the [COVID_religion_topics.R](COVID_religion_topics.R) script loads the data sets and generates the topical model. This script is also necessary to produce the graphs from COVID_religion_topics.Rmd.
 - [COVID_religion_topics.Rmd](COVID_religion_topics.Rmd) is a Markdown file that renders a written analysis of the data, including graphs. It also automatically runs the previous script.
 - [COVID_religion_topics.md](COVID_religion_topics.md) is the final product with analysis and graphs.
  
Used Libraries:

- To run the code in this repository, the libraries used were:
```r
library(readxl)
library(tidyverse)
library(tidytext)
library(topicmodels)
library(here)
library(tm)
library(tictoc)
library(RColorBrewer)
```