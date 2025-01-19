#Preprocessing notebook

###FLAGS
benchmark <- F
benchmark.size <- 100000
run.parallel <- F #running on PC now

#step 1: adding personal library to path
### on PC, no need
#personal.lib <- file.path(getwd(), "R_lib")
#.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out
#library(data.table)
library(ALDEx2)

#1) Import design frame, 
#will have rows for admitted samples (indexed by sample num)
#and column of conditions (factor A/B).
###will now require a filepath from args[1]
args <- commandArgs(trailingOnly=T)
if(is.na(args[1])){
  print("Please provide a path to a folder with an expdesign.tsv")
  q()
}
workspace = args[1]

design.frame <- read.csv2(file.path(workspace, "expdesign.tsv"), sep = "\t", row.names = 1)
sprintf("Read %s", file.path(workspace, "expdesign.tsv"))

###2) import data
if(is.na(args[2])){
  print("Please provide a path to an input file.")
  q()
}
orfhits_path = args[2]

orfhits <- read.csv2(orfhits_path, 
                        sep = "\t", 
                        row.names = 1,
                        numerals = "allow.loss",
                        #dec = "."
)

###benchmark: remove features
full.length <- dim(orfhits)[1] #n rows. length() gives n cols.
if(benchmark) {
    orfhits <- head(orfhits, benchmark.size)
}
#remember r vectors are 1 indexed
sprintf("Using %i of %i features", dim(orfhits)[1], full.length)

#select rows according to design.frame
intersection = intersect(colnames(orfhits), rownames(design.frame))
sprintf("Intended to use %i samples, only %i found in frame", dim(design.frame)[1], length(intersection))
sprintf("Using %i of %i samples", length(intersection), dim(orfhits)[2])
print(table(design.frame[intersection, 1]))
#print(rownames(design.frame))
#print(colnames(orfhits)) #this actually only has 307 cols not 558
orfhits <- orfhits[, intersection]
#print(dim(orfhits))
gc(verbose = T)

#aldex object - can generate plots, etc
#x.aldex <- aldex(orfhits, conditions, mc.samples=16, test="t", effect=TRUE, 
#  include.sample.summary=FALSE, denom="all", verbose=TRUE, paired.test=FALSE, 
#  gamma = NULL,
#  useMC = TRUE) #enables parallel functions

#using the modular functions so I can parallelize them
#gamma throws error, figure it out
x <- aldex.clr(orfhits, design.frame[intersection, 1], mc.samples=128, 
                denom="all", verbose=T, useMC=run.parallel)#, gamma=0.25)
print("CLR complete")

rm(orfhits) #assuming aldex.clr object no longer needs this
gc(verbose=T)

#Error in aldex.ttest(x, hist.plot = F, paired.test = FALSE, verbose = T) :
#Please define the aldex.clr object for a vector of two unique 'conditions'.

x.tt <- aldex.ttest(x, hist.plot=F, paired.test=FALSE, verbose=T)
sprintf("T tests complete, size of object %i", object.size(x.tt))
gc(verbose=T)

x.effect <- aldex.effect(x, CI=T, verbose=T, include.sample.summary=F, 
  paired.test=FALSE, glm.conds=NULL, useMC=run.parallel)
sprintf("Effect sizes complete, size of object %i", object.size(x.effect))
gc(verbose=T)

x.all <- data.frame(x.tt,x.effect)
sprintf("Total output data size %i", object.size(x.all))

#serialize aldex object & reload when needed
#doing this before the graph stuff to avoid errors
exp_condition = args[3]
saveRDS(x.all, file = file.path(workspace, exp_condition, "aldex_object.data"), compress = "gzip")
write.csv2(x.all, file = file.path(workspace, exp_condition, "aldex_object.tsv"), sep = "\t")
#graphing, save for next
#par(mfrow=c(1,2))
#next time read the code before making assumptions about arguments
#why this failed: if "test" is an unexpected value, "called" is never 
#calculated and function call fails
#valid [graph] "type": MW, MA, volcano, volcano.var

##unbelievable: so the version of aldex that was downloaded to the personal
#Library doesn't have the volcano plot setting. check docs in R. (?).
#is this because R version is behind?

#more lenient cutoff for significance: t 
#aldex.plot(x.all, type="volcano", test="welch") #t test on plot
#aldex.plot(x.all, type="volcano.var", test="welch") #only t test on plot

#stricter cutoffs: absolute value of effect size has to be >1
#welch t test p value has to be greater than 0.05
#aldex.plot(x.all, type="volcano", test="both") #t test on plot
#aldex.plot(x.all, type="volcano.var", test="both") #only t test on plot



