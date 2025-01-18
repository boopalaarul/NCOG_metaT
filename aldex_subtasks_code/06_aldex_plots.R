#Preprocessing notebook

#step 1: adding personal library to path
personal.lib <- file.path(getwd(), "R_lib")
.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out
#library(data.table)
library(ALDEx2)

x.tt <- readRDS("_out_aldex_ttest.data")
x.effect <- readRDS("_out_aldex_effectsizes.data")

x.all <- data.frame(x.tt,x.effect)
print(object.size(x.all))

#par(mfrow=c(1,2))
#next time read the code before making assumptions about arguments
#why this failed: if "test" is an unexpected value, "called" is never 
#calculated and function call fails
#valid [graph] "type": MW, MA, volcano, volcano.var

#more lenient cutoff for significance: t 
aldex.plot(x.all, type="volcano", test="welch") #t test on plot
aldex.plot(x.all, type="volcano.var", test="welch") #only t test on plot

#stricter cutoffs: absolute value of effect size has to be >1
#welch t test p value has to be greater than 0.05
aldex.plot(x.all, type="volcano", test="both") #t test on plot
aldex.plot(x.all, type="volcano.var", test="both") #only t test on plot



