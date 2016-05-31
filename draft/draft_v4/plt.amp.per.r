dir = '~/Work/m33/16summer/mwupdt/lightcurve_may27_2016/20160527/calilcs/'
f.dat = paste0(dir, 'mw_ceph_pars.dat')
dat = read.table(f.dat)
dat = dat[order(dat[,4]),]
dat[,1] = as.character(dat[,1])
dat[,2] = as.character(dat[,2])
dat[,3] = as.character(dat[,3])




## plot with log10(P)
dat[,4] = log10(dat[,4])
outdir = '~/Work/mega/mwceph/draft/v4/figures/'
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
f.eps = paste0(outdir,'amp_lp.eps')
setEPS()
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))

## idx = which(dat[,1] == 'lcarl')
## god = dat[-idx,]
## bad = dat[idx,]
god = dat

x = god[,4]
y = god[,8]
e = god[,9]
ylim = c(0.13,0.55)
xlim = c(min(x)-0.1, max(x)+0.1)
xlab = expression(paste('log ', italic(P), ' [day]'))
ylab = expression(paste(italic(L), ' [mag]'))
plot(x, y, pch=19, cex=0.7, xlab=xlab, ylab=ylab, ylim=ylim, xlim=xlim, cex.lab=1.5, cex.axis=1.5)
arrows(x, y+e, x, y-e, code=3, length=0.02, angle=90)
## x = bad[,4]
## y = bad[,8]
## e = bad[,9]
## col = 'grey'
## points(x, y, pch=1, cex=0.7, col=col)
## arrows(x, y+e, x, y-e, code=3, length=0.02, angle=90, col=col)
## text(x+0.02, y, 'l-Car', col=col, cex=1.3, adj=0)

x = god[,4] - 1
y = god[,8]
e = god[,9]
data = as.data.frame(cbind(x, y))
library(stats)
fit = lm(y ~ x, data=data, weights=1/e^2)
b = coef(fit)[1]
a = coef(fit)[2]
xc = seq(0, 80, by=5)
yc = a * (xc - 1) + b
lines(xc, yc, col=4)
sig.a = summary(fit)$coefficients[2,2]
sig.b = summary(fit)$coefficients[1,2]

sd = sd(y - (a*x + b))
lines(xc, yc + sd, col=4, lty=2)
lines(xc, yc - sd, col=4, lty=2)

xp = xlim[1] - 0.02
t1 = expression(paste(italic(L),' = ',0.255 %+-% scriptstyle(0.009), ' + ', 0.335 %+-% scriptstyle(0.042) %.% '[log ', italic(P) - 1,']')) # replace with b, sig.b, a, sig.a
text(xp, ylim[2]-0.01, t1, adj=0, cex=1.4)
t2 = expression(paste(sigma,' = 0.053 mag')) ## replace with sd
text(xp, ylim[2]-0.06, t2, adj=0, cex=1.4)
dev.off()

print(paste(b, sig.b, a, sig.a, sd))
