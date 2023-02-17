## Plots tree and colors taxa according to lineage affinities

library(ape)
library(phangorn)
library(phytools)
library(RColorBrewer)
library(tidyverse)
library(ggtree)
library(ggrepel)
library(dplyr)
library(treeio)
library(ggnewscale)


# id relevant nodes by using mrca() function
clades <- data.frame(node = c(428, 282, 290, 365, 302, 323, 438),
                     ids = c("PoEc","PoE3", "PoM", "PoE", "PoU3", "PoO/PoS", "Pu"),
                     pos = rep(1, times=7))

#read in data
Tree1 <- read.tree("~/CH7BAC9_RAxML_bipartitions.outSupport")

groupInfo <- split(Tree1$tip.label, gsub(".*_", "", Tree1$tip.label)) # split(x, f) split dataset x into groups defined by f
groupInfo <- lapply(groupInfo, function(x) gsub("_.*", "", x))        # apply function(x) to each eleemtn in each group

Tree1$genus <- gsub(".*_", "", Tree1$tip.label)

Tree1$tip.label <- gsub("_.*", "", Tree1$tip.label)

Tree1 <- groupOTU(Tree1, groupInfo, "Host")

# write bootstrap values to dataframe
bootstraps <- data.frame(node = 1:Tree1$Nnode, bs = Tree1$node.label)

# plot and save the tree
pdf("Fig2A_CH7BAC9_tree.pdf", 22, 22)

p <- ggtree(Tree1, layout = "fan", branch.length="none", aes(color=Host)) +
       geom_hilight(data=clades, mapping=aes(node=node), extendto=2.7, fill = "grey",
         color = "grey50", size = 0.05) +
       geom_cladelab(data=clades, mapping=aes(node=node, label = ids), align = T,
         offset = 0.5, angle = "auto", barsize=NA, horizontal=FALSE, hjust = 0.5, fontsize = 6) +
       labs(color = "Host\nGenus") +
       theme(legend.position="top",
         legend.title = element_text(colour="black", size=24, face="bold"),
         legend.text= element_text(size=18, face="italic"),
         legend.direction = "horizontal",
         legend.justification = c(0.5, 1),
         legend.background = element_rect(fill="white",size=0.3, linetype="solid",colour ="black")) +
       guides(color = guide_legend(nrow = 4, override.aes = list(size = 3)))
        

p1 <- p %<+% clades + geom_tiplab(aes(color = Host,
      label = gsub("UVFPY", "ufv", label)), size = 6, offset =3, show.legend = F)

p2 <- p1 + ggnewscale::new_scale_fill() + geom_point2(aes(subset=!isTip & !is.na(as.numeric(label)) & as.numeric(label) >= 49,
        size = as.numeric(label)/100), color = "black") +
        scale_size(name = "Bootstrap\nValue", range = c(1, 6)) +
        guides(fill = guide_legend(nrow = 2, override.aes = list(label = "")))

p2
  
dev.off() 
  




