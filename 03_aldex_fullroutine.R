#Preprocessing notebook

###FLAGS
benchmark <- F
benchmark.size <- 100000
run.parallel <- T

#step 1: adding personal library to path
personal.lib <- file.path(getwd(), "R_lib")
.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out
#library(data.table)
library(ALDEx2)

#1) Import design frame, will have rows for admitted samples
#and column of conditions (factor A/B). sep = default, ";'
design.frame <- read.csv2("02_shallow_split_temp.tsv", row.names = 1)

#2) import data -  data table does not have an index column. don't know if ALDEx2 will generate indices.
#this may not be possible at all without filtering out clearly non mixotroph sequences.
#even with 72677 features (100x decrease) it takes over an hour (at least).
#with 200k features it completes but starts running into what looks like memory issues. parallelization doesn't help. not sure if there's a specific memory alloc function in tscc.
#file.length = 7267714 
#orfhits <- fread("01_out_mixo_orfs_rawcounts.tsv", 
#                 drop = c(1),
#                 #nrows = file.length %/% 100
#)

###benchmark setup
#use dataframes, not prioritizing memory and at least these allow rownames
#'reads' matrix for aldex.clr has to be integers only - CLR substitutes for
#all other normalization?
orfhits <- read.csv2("01_out_mixo_orfs_rawcounts.tsv", 
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
sprintf("Using %i of %i samples", dim(design.frame)[1], dim(orfhits)[2])
orfhits <- orfhits[,rownames(design.frame)]
print(dim(orfhits))
gc(verbose = T)

#aldex object - can generate plots, etc
#x.aldex <- aldex(orfhits, conditions, mc.samples=16, test="t", effect=TRUE, 
#  include.sample.summary=FALSE, denom="all", verbose=TRUE, paired.test=FALSE, 
#  gamma = NULL,
#  useMC = TRUE) #enables parallel functions

#using the modular functions so I can parallelize them
#gamma throws error, figure it out
x <- aldex.clr(orfhits, design.frame$conditions, mc.samples=128, 
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
saveRDS(x.all, file = "aldex_object.data", compress = "gzip")

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
aldex.plot(x.all, type="volcano", test="welch") #t test on plot
aldex.plot(x.all, type="volcano.var", test="welch") #only t test on plot

#stricter cutoffs: absolute value of effect size has to be >1
#welch t test p value has to be greater than 0.05
aldex.plot(x.all, type="volcano", test="both") #t test on plot
aldex.plot(x.all, type="volcano.var", test="both") #only t test on plot



