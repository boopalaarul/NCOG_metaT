#Preprocessing notebook

###FLAGS
run.parallel <- T

#step 1: adding personal library to path
personal.lib <- file.path(getwd(), "R_lib")
.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out
#library(data.table)
library(ALDEx2)

x <- readRDS("_out_aldex_clr.data")

x.effect <- aldex.effect(x, CI=T, verbose=T, include.sample.summary=F, 
  paired.test=FALSE, glm.conds=NULL, useMC=run.parallel)
print("Effect sizes complete")
gc(verbose=T)

print(object.size(x.effect))

#serialize aldex object & reload when needed
#doing this before the graph stuff to avoid errors
saveRDS(x.effect, file = "_out_aldex_effectsizes.data", compress = "gzip")
