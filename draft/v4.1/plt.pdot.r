dir = '~/Work/mega/mwceph/pdot/cal.pdot/peps/'
f.dat = paste0(dir, 'xycar_pep_group.dat')
dat = read.table(f.dat)

f.pep = '~/Work/mega/mwceph/pdot/cal.pdot/period_eperiod.dat'
pep = read.table(f.pep)
pep[,1] = as.character(pep[,1])
period = pep[pep[,1]=='xycar',2]

dat = dat[order(dat[,1]),]
dat[,4] = as.character(dat[,4])

x = dat[,1]
y = dat[,2]
e = dat[,3]
ylim = c(period-1e-2, period+1e-2)
xlim = c(min(x)-1100, max(x)+1100)


eplim = 0.006
idx = dat[,3] < eplim
god = dat[idx,]
bad.exist = 0
if (sum(idx) < nrow(dat)) {
    bad = dat[!idx,]
    bad.exist = 1
}

useidx = nchar(god[,4]) > 3

outdir = '~/Work/mega/mwceph/draft/v4.1/figures/'
f.eps = paste0(outdir,'pdot.eps')
setEPS()
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
postscript(f.eps,height = fig.height, width = fig.width)

par(mar=c(5,5,2,2))
## x = god[,1]
## y = god[,2]
## e = god[,3]
## dx = c(0, 0, -700, 700)
## dy = c(-3e-3, 3e-3, -3e-3, 3e-3)*0.5
## xlab = 'JD - 2.4E6'
## ylab = expression(paste(italic('P'),' [day]'))
## plot(x[useidx], y[useidx], pch=19, cex=1, ylim = ylim, xlim=xlim, xlab=xlab, ylab=ylab,cex.lab=1.5, cex.axis=1.3)
## points(x[!useidx], y[!useidx])
## arrows(x, y-e, x, y+e, code=3, angle=90, length=0.01)
## t1 = c('1970s','1980s','ASAS','OMC')
## text(x+dx, y+dy, t1, adj=0.5, col='black', cex=1.3)


x1 = mean(god[1:2,1])
y1 = sum(1/god[1:2,3]^2 * god[1:2,2]) / sum(1/god[1:2,3]^2)
e1 = mean(god[1:2,2] - y1)
x = c(x1, god[3:4,1]) - 0.5
y = c(y1, god[3:4,2])
e = c(e1, god[3:4,3])
dx = c(0, -700, 700)
dy = c(6e-3, -3e-3, 3e-3)*0.5
xlab = 'MJD'
ylab = expression(paste(italic('P'),' [day]'))
useidx = c(F,T,T)
plot(x[useidx], y[useidx], pch=19, cex=1, ylim = ylim, xlim=xlim, xlab=xlab, ylab=ylab,cex.lab=1.5, cex.axis=1.3)
points(x[!useidx], y[!useidx])
arrows(x, y-e, x, y+e, code=3, angle=90, length=0.01)
t1 = c('1970-1990','ASAS','OMC')
text(x+dx, y+dy, t1, adj=0.5, col='black', cex=1.3)



if (bad.exist == 1) {
    x = bad[,1] - 0.5
    y = bad[,2]
    e = bad[,3]
    xlim = c(min(x)-900, max(x)+900)
    points(x, y, pch=1, cex=1, col='grey')
    arrows(x, y-e, x, y+e, code=3, angle=90, length=0.01, col='grey')
    dx = 200
    dy = 0
    text(x+dx, y+dy, 'Before 1970', adj=0, col='grey', cex=1.3)
    points(x, y, col='grey')
}
abline(h=period, lty=2, col=4)

dev.off()
