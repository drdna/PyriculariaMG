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


clades <- data.frame(node = c(428, 282, 290, 365, 302, 323, 438), ids = c("PoEc","PoE3", "PoM", "PoE", "PoU3", "PoO/PoS", "Pu"), pos=rep(1, times=7))

#read in data
Tree1 <- read.tree("~/AscariBAC9finalRAXML/RAxML_bipartitions.outSupport")

groupInfo <- split(Tree1$tip.label, gsub(".*_", "", Tree1$tip.label)) # split(x, f) split dataset x into groups defined by f
groupInfo <- lapply(groupInfo, function(x) gsub("_.*", "", x))        # apply function(x) to each eleemtn in each group

Tree1$genus <- gsub(".*_", "", Tree1$tip.label)

Tree1$tip.label <- gsub("_.*", "", Tree1$tip.label)

Tree1 <- groupOTU(Tree1, groupInfo)


# plot and save the tree
pdf("Fig1_AscariCH7BAC9treecladeLabelFanNoLength.pdf", 22, 22)
ggtree(Tree1, 
       layout = "fan", 
       branch.length="none",
       aes(label = gsub(".*_", "", label))) +
  
       geom_tree(aes(color=group), show.legend = F) +
       geom_label2(aes(label=label, subset = !is.na(as.numeric(label)) & as.numeric(label) > 50), position = "identity", size = 2) +
  geom_tiplab(aes(color = group, subset = grepl("UFVPY", label), label = gsub("UVFPY", "ufv", label)), size = 6, offset =3, show.legend = F) +
  geom_polygon(aes(fill = group, x = 0, y = 0)) +
  geom_hilight(data=clades, mapping=aes(node=node), extendto=2.7, fill = "grey", color = "grey50", size = 0.05) +
  geom_cladelab(data=clades, mapping=aes(node=node, label = ids), align = T, offset = 0.5, angle = "auto", barsize=NA, horizontal=FALSE, hjust = 0.5, fontsize = 6, ) +
    theme(legend.position="top",
    legend.text= element_text(size=20, face="italic"),
    legend.title = element_text(colour="black", size=24, face="bold"),
    legend.direction = "horizontal",
    legend.justification = c(0.5, 1),
    legend.background = element_rect(fill="white",size=0.3, linetype="solid",colour ="black")) +
    #legend.key = element_rect(fill = "white")) +
    guides(fill = guide_legend(title = "Species", nrow = 3, override.aes = list(label = "")))
dev.off()



