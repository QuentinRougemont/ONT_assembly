#!/usr/bin/env Rscript

if("dplyr" %in% rownames(installed.packages()) == FALSE)
{install.packages("dplyr", repos="https://cloud.r-project.org") }
if("ggplot2" %in% rownames(installed.packages()) == FALSE)
{install.packages("ggplot2", repos="https://cloud.r-project.org") }
if("data.table" %in% rownames(installed.packages()) == FALSE)
{install.packages("data.table", repos="https://cloud.r-project.org") }
if("ggforce" %in% rownames(installed.packages()) == FALSE)
{install.packages("ggforce", repos="https://cloud.r-project.org") }

library(ggforce)
library(ggplot2)
library(dplyr)
library(data.table)

dp <- fread("zcat depth.txt.gz")

dp1 <- dp %>% group_by(V1) %>%
        filter(n()>25e4) %>%  #ignore the small contigs
	ungroup()

p1 <- ggplot(dp1, aes(x=V2, y=V3)) +
        #facet_wrap(V1) + 
        geom_line() +
        xlab("position bp") +
        ylab("dp") +
        theme(legend.position="none") +
	facet_wrap_paginate(~ V1, scales = "free", ncol = 1, nrow = 5 ) 


for(i in 1:n_pages(p1)){
  p2 <- p1 + facet_wrap_paginate(~ V1, ncol = 1, nrow = 5, page = i)
  ggsave(plot = p2, filename = paste0('page_', i, '.png'))
}

