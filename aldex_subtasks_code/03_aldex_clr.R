#Preprocessing notebook
#Not going to try this with full set anymore, clearly produces too much data
#and leads to errors. try N-fold cross validation to leave out some of the
#samples. start with 4-fold.

#we're not running this. total size of "x" (aldex.clr object) is about 90 TB.
#not going to try and store that on disk.

###FLAGS
benchmark <- F
benchmark.size <- 100000
run.parallel <- F #keeps timing out doesn't matter how many cores 

#step 1: adding personal library to path
personal.lib <- file.path(getwd(), "R_lib")
.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out
#library(data.table)
library(ALDEx2)

#1) Import design frame created by preprocessing script
design.frame <- read.csv2("02_shallow_split_temp.tsv", row.names = 1)

#use dataframes, at least these allow rownames (feature names)
#'reads' matrix for aldex.clr has to be integers only - CLR substitutes for
#all other normalization?
orfhits <- read.csv2("01_out_mixo_orfs_rawcounts.tsv", 
                        sep = "\t", 
                        row.names = 1,
                        numerals = "allow.loss",
                        #dec = "."
)

###
full.length <- dim(orfhits)[1] #n rows. length() gives n cols.
if(benchmark) {
    orfhits <- head(orfhits, benchmark.size)
}
#remember r vectors are 1 indexed
sprintf("Using %i of %i features", dim(orfhits)[1], full.length)

#2) Select appropriate columns of orfhits with design frame's rownames()

sprintf("Using %i of %i samples", dim(design.frame)[1], dim(orfhits)[2])
orfhits <- orfhits[,rownames(design.frame)]
print(dim(orfhits))
gc()

#using the modular functions so I can parallelize them & adjust memory/time
#gamma throws error, figure it out
x <- aldex.clr(orfhits, design.frame$conditions, mc.samples=128, 
                denom="all", verbose=T, useMC=run.parallel)#, gamma=0.25)
print("CLR complete")

rm(orfhits) #assuming aldex.clr object no longer needs this
gc(verbose=T)
print(object.size(x))
saveRDS(x, file = "_out_aldex_clr.data", compress = "gzip")
