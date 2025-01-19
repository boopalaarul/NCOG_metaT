#Plotting - customizing aldex.plot version since current version is behind (most likely because R version is behind, 4.2 instead of 4.4.)
#current release of aldex is 1.30, latest release is 1.38 or 1.39

#step 1: adding personal library to path
personal.lib <- file.path(getwd(), "R_lib")
.libPaths( c( .libPaths(), personal.lib))

#imports - no longer need data.table since non-mixo reads filtered out
#library(data.table)
library(ALDEx2)

#enough code for one plot: volcano.
#code copied & modified from ALDEx_bioc/blob/master/R/plot.aldex.r
#' Plot an \code{aldex} Object
#'
#' @title Plot an \code{aldex} Object
#'
#' @description Create \code{MW}- or \code{MA}-type plots from the given \code{aldex} object.
#'
#' @param x an object of class \code{aldex} produced by the \code{aldex} function
#' @param ... optional, unused arguments included for compatibility with the S3 method signature
#' @param type which type of plot is to be produced. \code{MA} is a Bland-Altman style plot; \code{MW} is a
#' difference between to a variance within plot as described in:
#' http://dx.doi.org/10.1080/10618600.2015.1131161; \code{volcano} is a volcano plot
#' of either the difference or variance type: http://dx.doi.org/10.1186/gb-2003-4-4-210
#' @param test the method of calculating significance, one of:
#' \code{welch} = welch's t test - here a posterior predictive p-value;
#' \code{wilcox} = wilcox rank test;
#' \code{effect} = effect size
#' @param cutoff.pval the Benjamini-Hochberg fdr cutoff, default 0.05
#' @param cutoff.effect the effect size cutoff for plotting, default 1
#' @param xlab the x-label for the plot, as per the parent \code{plot} function
#' @param ylab the y-label for the plot, as per the parent \code{plot} function
#' @param xlim the x-limits for the plot, as per the parent \code{plot} function
#' @param ylim the y-limits for the plot, as per the parent \code{plot} function
#' @param all.col the default colour of the plotted points
#' @param all.pch the default plotting symbol
#' @param all.cex the default symbol size
#' @param called.col the colour of points with false discovery rate, q <= 0.1
#' @param called.pch the symbol of points with false discovery rate, q <= 0.1
#' @param called.cex the character expansion of points with false discovery rate, q <= 0.05
#' @param thres.line.col the colour of the threshold line where within and between group variation is equivalent
#' @param thres.lwd the width of the threshold line where within and between group variation is equivalent
#' @param rare relative abundance cutoff for rare features, default 0 or the mean abundance
#' @param rare.col color for rare features, default black
#' @param rare.pch the default symbol of rare features
#' @param rare.cex the default symbol size of rare points
#' @param main the main label for the plot
#' @details This particular specialization of the \code{plot} function is relatively simple and provided for convenience.
#' For more advanced control of the plot is is best to use the values returned by \code{summary(x)}.
#'
#' @return None.
#'
#' @references Please use the citation given by \code{citation(package="ALDEx")}.
#'
#' @seealso \code{\link{aldex}}, \code{\link{aldex.effect}}, \code{\link{aldex.ttest}}, \code{\link{aldex.glm}}
#'
#' @examples # See the examples for 'aldex'
#' @export
volcano.plot<-function (x, xlab = NULL, ylab = NULL,
    xlim = NULL, ylim = NULL, all.col = rgb(0, 0, 0, 0.2), all.pch = 19,
    all.cex = 0.4, called.col = "red", called.pch = 20, called.cex = 0.6,
    thres.line.col = "darkgrey", thres.lwd = 1.5,
    cutoff.pval = 0.05, cutoff.effect = 1, rare.col = "black", 
    rare = 0, rare.pch = 20,
    rare.cex = 0.2, main=NULL)
{
    #assertions 
    if (length(x$effect) == 0)
        stop("Please run aldex.effect before plotting")
    if (length(x$we.eBH) == 0)
        stop("t test results not in dataset")
        
    #smallest nonzero p value divided by 10, used as an adjustment of some kind?
    p.add <- min(x$we.eBH[x$we.eBH > 0])/10
        	
    deg.called <- x$we.eBH <= cutoff.pval #anything with a p value below 0.05 is a DEG
    all.p <- x$we.eBH + p.add #adjustment to p values
    
    #axis labels if none supplies
    if (is.null(ylab))
        ylab <- expression("-1 * Median Log"[10]~" q value")
    if (is.null(xlab))
        xlab <- expression("Median Log"[2]~" Difference")
        
    #between group differences on x axis, p value on y axis
    plot(x$diff.btw, -1*log10(all.p), xlab = xlab, ylab = ylab,
            col = all.col, pch = all.pch, cex = all.cex, ylim=ylim, 
            xlim=xlim, main=main)
    
    #plot over the points from before with new ones: new ones cover up old.    
    points(x$diff.btw[deg.called], -1*log10(all.p)[deg.called], col = called.col,
            pch = called.pch, cex = called.cex)
        
    #this gets the vector indices that match the pattern: only indices of cols "rab.win.A" and "rab.win.B",
    #median CLR value in each group.
    #again, these values are used to index colnames(x)
    median.CLR.col.indexes <- grep("rab.win", colnames(x))

    #log2 difference cutoff...? but this doesn't factor into our deg calling.
    abline(v=1.5, col='grey', lty=2)
    abline(v=-1.5, col='grey', lty=2)

    #horizonal cutoff for p values on y axis
    abline(h=-1*log10(cutoff.pval), col='grey', lty=2)
        
    #i feel like this won't look that good but sure draw it
    #for each column of per feature median clr... we draw the name of that column at x position of
    #the minimum x value, or at the max x value. is it just to have it on diff. sides
    mtext(colnames(x)[median.CLR.col.indexes[1]], 1, line = 2, at = min(x$diff.btw),
        col = "grey", cex = 0.8)
    mtext(colnames(x)[median.CLR.col.indexes[2]], 1, line = 2, at = max(x$diff.btw),
        col = "grey", cex = 0.8)

}

#x.all <- data.frame(x.tt,x.effect)
x.all <- readRDS("aldex_object.data")
print(object.size(x.all))
volcano.plot(x.all)

#par(mfrow=c(1,2))
#next time read the code before making assumptions about arguments
#why this failed: if "test" is an unexpected value, "called" is never 
#calculated and function call fails
#valid [graph] "type": MW, MA, volcano, volcano.var

#more lenient cutoff for significance: t 
#aldex.plot(x.all, type="volcano", test="welch") #t test on plot
#aldex.plot(x.all, type="volcano.var", test="welch") #only t test on plot

#stricter cutoffs: absolute value of effect size has to be >1
#welch t test p value has to be greater than 0.05
#aldex.plot(x.all, type="volcano", test="both") #t test on plot
#aldex.plot(x.all, type="volcano.var", test="both") #only t test on plot



