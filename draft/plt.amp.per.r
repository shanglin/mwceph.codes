dir = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/'
f.dat = paste0(dir, 'mw_ceph_pars.dat')
dat = read.table(f.dat)
dat = dat[order(dat[,4]),]
dat[,1] = as.character(dat[,1])
dat[,2] = as.character(dat[,2])
dat[,3] = as.character(dat[,3])

outdir = '~/Work/mega/mwceph/draft/v2.2/figures/'
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
f.eps = paste0(outdir,'amp_p.eps')
setEPS()
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))

idx = which(dat[,1] == 'lcarl')
god = dat[-idx,]
bad = dat[idx,]

x = god[,4]
y = god[,8]
e = god[,9]
ylim = c(0.13,0.55)
plot(x, y, pch=19, cex=0.7, xlab='Period (day)', ylab='Amplitude (mag)', ylim=ylim, cex.lab=1.5, cex.axis=1.5)
arrows(x, y+e, x, y-e, code=3, length=0.02, angle=90)
x = bad[,4]
y = bad[,8]
e = bad[,9]
col = 'grey'
points(x, y, pch=1, cex=0.7, col=col)
arrows(x, y+e, x, y-e, code=3, length=0.02, angle=90, col=col)
text(x+2, y, 'l-Car', col=col, cex=1.3)

x = god[,4]
y = god[,8]
e = god[,9]
data = as.data.frame(cbind(x, y))
library(stats)
fit = lm(y ~ x, data=data, weights=1/e^2)
b = coef(fit)[1]
a = coef(fit)[2]
xc = seq(0, 80, by=5)
yc = a * xc + b
lines(xc, yc, col=4)
sig.a = summary(fit)$coefficients[2,2]
sig.b = summary(fit)$coefficients[1,2]

sd = sd(y - (a*x + b))
lines(xc, yc + sd, col=4, lty=2)
lines(xc, yc - sd, col=4, lty=2)

text(7, ylim[2]-0.01, paste0('Slope = ',round(a,4),' (',round(sig.a,4),')'), adj=0, cex=1.3)
text(7, ylim[2]-0.04, paste0('Intercept = ',round(b,4),' (',round(sig.b,4),')'), adj=0, cex=1.3)
text(7, ylim[2]-0.07, paste0('Standard Deviation = ',round(sd,3), ' mag'), adj=0, cex=1.3)
dev.off()




## plot with log10(P)
dat[,4] = log10(dat[,4])
outdir = '~/Work/mega/mwceph/draft/v2.2/figures/'
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
f.eps = paste0(outdir,'amp_lp.eps')
setEPS()
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))

idx = which(dat[,1] == 'lcarl')
god = dat[-idx,]
bad = dat[idx,]

x = god[,4]
y = god[,8]
e = god[,9]
ylim = c(0.13,0.55)
xlim = c(min(x)-0.1, max(x)+0.1)
plot(x, y, pch=19, cex=0.7, xlab='Log (Period)', ylab='Amplitude (mag)', ylim=ylim, xlim=xlim, cex.lab=1.5, cex.axis=1.5)
arrows(x, y+e, x, y-e, code=3, length=0.02, angle=90)
x = bad[,4]
y = bad[,8]
e = bad[,9]
col = 'grey'
points(x, y, pch=1, cex=0.7, col=col)
arrows(x, y+e, x, y-e, code=3, length=0.02, angle=90, col=col)
text(x+0.02, y, 'l-Car', col=col, cex=1.3, adj=0)

x = god[,4]
y = god[,8]
e = god[,9]
data = as.data.frame(cbind(x, y))
library(stats)
fit = lm(y ~ x, data=data, weights=1/e^2)
b = coef(fit)[1]
a = coef(fit)[2]
xc = seq(0, 80, by=5)
yc = a * xc + b
lines(xc, yc, col=4)
sig.a = summary(fit)$coefficients[2,2]
sig.b = summary(fit)$coefficients[1,2]

sd = sd(y - (a*x + b))
lines(xc, yc + sd, col=4, lty=2)
lines(xc, yc - sd, col=4, lty=2)

xp = xlim[1] + 0.01
text(xp, ylim[2]-0.01, paste0('Slope = ',round(a,4),' (',round(sig.a,4),')'), adj=0, cex=1.3)
text(xp, ylim[2]-0.04, paste0('Intercept = ',round(b,4),' (',round(sig.b,4),')'), adj=0, cex=1.3)
text(xp, ylim[2]-0.07, paste0('Standard Deviation = ',round(sd,3), ' mag'), adj=0, cex=1.3)
dev.off()

con = file(f.eps, 'r')
eps = readLines(con)
close(con)
idx = which(grepl('l-Car', eps))
neps = eps[1:(idx+3)]
neps[idx] = gsub('l-Car',' -Car',neps[idx])
neps[idx+1] = '/Palatino-Italic findfont 16 s'
x.image = as.numeric(substr(neps[idx],1,6)) + 2.5
y.image = as.numeric(substr(neps[idx],7,12))
neps[idx+2] = paste(x.image, y.image, '(l) 1 0 t')
neps[idx+3] = neps[idx-1]
neps = c(neps, eps[(idx+1):length(eps)])
write(neps, f.eps)

