#Calling and categorizing DEGs

#import aldex output
x <- readRDS("aldex_object.data")

#significance levels
cutoff.pval = 0.05
cutoff.effect = 1
       
#smallest nonzero p value divided by 10, used as an adjustment of some kind?
#p.add <- min(x$we.eBH[x$we.eBH > 0])/10    	
#all.p <- x$we.eBH + p.add #adjustment to p values

#boolean masks, & for elementwise AND
deg.by.pval <- x$we.eBH <= cutoff.pval #anything with a p value below 0.05 is a DEG
deg.by.pval.effect <- x$we.eBH <= cutoff.pval & abs(x$effect) >= cutoff.effect

#4 CSVs of upreg and downreg under each condition, sorted by diff.btw?
pos.fold.change <- x$diff.btw >= 0
neg.fold.change <- x$diff.btw < 0

#all data on appropriate rows. don't need all the cols.
required.cols <- c("we.eBH", "diff.btw", "diff.win", "effect")
upreg.by.pval <- x[ deg.by.pval & pos.fold.change, required.cols ]
downreg.by.pval <- x[ deg.by.pval & neg.fold.change, required.cols ]  
upreg.by.both <- x[ deg.by.pval.effect & pos.fold.change, required.cols ]
downreg.by.both <- x[ deg.by.pval.effect & neg.fold.change, required.cols ]

#sort frames by diff.btw - positive and negative DEGs have opposite orders
upreg.by.pval <- upreg.by.pval[order(upreg.by.pval$diff.btw, decreasing = T),]
downreg.by.pval <- downreg.by.pval[order(downreg.by.pval$diff.btw),]
upreg.by.both <- upreg.by.both[order(upreg.by.both$diff.btw, decreasing = T),]
downreg.by.both <- downreg.by.both[order(downreg.by.both$diff.btw),]

#can make LPI taxonomy tables now or later. might prefer to use python function.
#write table for custom separators. rownames (orf_id) and colnames printed
#by default.)
write.table(upreg.by.pval, file = "05_out_upreg_pval.tsv", quote = F, 
            sep = "\t")
write.table(downreg.by.pval, file = "05_out_downreg_pval.tsv", quote = F, 
            sep = "\t")

write.table(upreg.by.both, file = "05_out_upreg_pval_effect.tsv", quote = F, 
            sep = "\t")
write.table(downreg.by.both, file = "05_out_downreg_pval_effect.tsv", quote = F,            sep = "\t")
