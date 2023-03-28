## Plots trees and colors taxa according to lineage affinities

library(ape)
library(phangorn)
library(phytools)
library(RColorBrewer)
library(tidyverse)
library(ggtree)
library(ggrepel)
library(dplyr)
library(ggtext)

# id relevant nodes by using mrca() function
clades <- data.frame(node = c(285, 429),
                     ids = c(" "," "),
                     pos = rep(1, times=2))
#read in data
Tree1 <- read.tree("RAxML_bestTree.Ascari_Cen_Dig_align.raxml.raxml.support")

# assign the groups
groupInfo <- split(Tree1$tip.label, gsub(".*_", "", Tree1$tip.label)) # split(x, f) split dataset x into groups defined by f

Tree1 <- groupOTU(Tree1, groupInfo)

myHosts <- c(Cen = "orange", Dig = "purple", Pen = "blue")

# plot and save the tree
pdf("Fig2B_MPG1_tree.pdf", 11, 11)
p <- ggtree(Tree1, 
       layout = "fan", 
       branch.length="none",
       aes(color = "black")) +
     geom_tiplab(aes(subset=(grepl("UFVPY.*Cen", label, fixed = F) == TRUE), label = paste("        ", gsub("_.*", "", label), "        ")), color = "orange", size = 3.5, align=F, offset = 1) +
     geom_tiplab(aes(subset=(grepl("UFVPY.*Dig", label, fixed = F) == TRUE), label = paste("        ", gsub("_.*", "", label), "        ")), color = "purple", size = 3.5, align=F, offset = 1) +
     geom_tiplab(aes(subset=(grepl("UFVPY.*Pen", label, fixed = F) == TRUE), label = paste("        ", gsub("_.*", "", label), "        ")), color = "blue", size = 3.5, align=F, offset = 1) +
  
     theme(legend.position=c(0.7, 0.04),
         legend.title=element_text(size=16, face = "bold"),
         legend.text=element_text(size = 12),
         legend.background = element_rect(fill=NA)) +
     scale_color_manual(name = "Host of origin", values = myHosts,
         labels = c("*Cenchrus*", "*Digitaria*", "*Pennisetum*"), aes(fontface="italic")) +
     guides(col = guide_legend(nrow = 1, override.aes = aes(size = 10))) +
     theme(legend.text = element_markdown())

p1 <- p + geom_cladelab(data=clades, mapping=aes(node=node, label = ids, fontface = "italic"), align = F,
            offset = 0.1 , offset.text = 0.6, angle = "auto", barsize=1, horizontal=FALSE, hjust = 0.5, fontsize = 6)

p1
dev.off()



