#T tests for differences in distributions

#step 1: adding personal library to path
personal.lib <- file.path(getwd(), "R_lib")
.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out?
#want to try running it with, might even save space.
#library(data.table)
library(ALDEx2)

x <- readRDS("_out_aldex_clr.data")
sprintf("Loaded CLR data of size %s", object.size(x))

#Error in aldex.ttest(x, hist.plot = F, paired.test = FALSE, verbose = T) :
#Please define the aldex.clr object for a vector of two unique 'conditions'.

x.tt <- aldex.ttest(x, hist.plot=F, paired.test=FALSE, verbose=T)
print("T tests complete")
gc(verbose=T)
object.size(x.tt)
saveRDS(x.tt, file = "_out_aldex_ttest.data", compress = gzip)
