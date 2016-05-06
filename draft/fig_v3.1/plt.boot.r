f.dat = '~/Work/mega/mwceph/period_search/boot_residual/boot_residual.dat'
dat = read.table(f.dat, header=T)
dat = dat[dat[,1]=='xycar',]

f.par = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
idx = order(par[,4])
par = par[idx,]
n.par = nrow(par)
par[,3] = as.character(par[,3])
par[,2] = as.character(par[,2])
par[,1] = as.character(par[,1])


period = par[par[,1] == 'xycar',4]
periods = dat[,3]

outdir = '~/Work/mega/mwceph/draft/v3.1/figures/'
f.eps = paste0(outdir,'boot.eps')
setEPS()
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))

periods = (periods - period) * 1e4
h = hist(periods, plot=F, breaks=16)
xlab = expression(paste("P'-",P[best]," [",10^{-4}," day]"))
ylab = 'Frequency'
h$counts = h$counts/sum(h$counts)
plot(h, col='grey', xlab=xlab, main='', cex.lab=1.5, cex.axis=1.1, ylab=ylab, xlim=c(-2,2))
abline(v = mean(periods), col=4, lwd=4)
xfit=seq(-2,2,length=100) 
yfit=dnorm(xfit,mean=mean(periods),sd=sd(periods))
yfit = yfit/max(yfit)*max(h$counts)
lines(xfit, yfit, col="black", lwd=5)
lines(xfit, yfit, col=4, lwd=3)
dev.off()
