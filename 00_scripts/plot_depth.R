library(ggplus)
library(ggplot2)
library(dplyr)
library(data.table)

dp <- fread("zcat depth.txt.gz")

dp1 <- dp %>% group_by(V1) %>%
        filter(n()>2.5e4)  #ignore the small contigs

p1 <- ggplot(dp1, aes(x=V2, y=V3)) +
        #facet_wrap(V1) + 
        geom_line() +
        xlab("position bp") +
        ylab("dp") +
        theme(legend.position="none")

pdf("depth_longest_contig.pdf")
p0 <- facet_multiple(plot = p1, facets = "V1", scales = "free", ncol = 1, nrow=5)
dev.off()
