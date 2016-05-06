f.par = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
idx = order(par[,4])
par = par[idx,]
n.par = nrow(par)
par[,3] = as.character(par[,3])
par[,2] = as.character(par[,2])
par[,1] = as.character(par[,1])


f.eha = '~/Work/mega/mwceph/pphot/period_all/ehat.dat'
dat = read.table(f.eha,header=T)
dat[,1] = as.character(dat[,1])

idx = dat[,1] %in% par[,1]
dat = dat[idx,]

outdir = '~/Work/mega/mwceph/draft/v3.1/figures/'
f.eps = paste0(outdir,'dpop.eps')
setEPS()
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))


p = dat[,4]
dp = dat[,2] - dat[,4]
edp = dat[,3]
ylim = c(-0.12,0.15)
plot(p,dp,pch=19,cex=1,xlab='GCVS period [day]',ylab=expression(paste(Delta,'P [day]')),ylim=ylim, cex.lab=1.5, cex.axis=1.3)
abline(h=0,lty=2,col='black')
arrows(p,dp-edp,p,dp+edp,length=0.005,angle=90,code=3)
idx = abs(dp)>0.03
if (sum(idx) > 0) {
    lar = dat[idx,]
    p = lar[,4]
    objs = lar[,1]
    dp = lar[,2] - lar[,4]
    objs = gsub('u-car','U Car',objs)
    objs = gsub('vycar','VY Car',objs)
    text(p-c(2.5,3),dp,objs,col=1,cex=1.5)
}

aavso.p.ucar = 38.829
aavso.p.vycar = 18.890
aavso.ps = c(aavso.p.ucar, aavso.p.vycar)
## abline(h = aavso.ps-lar[,4], lty=3, col=4)
points(p, aavso.ps - lar[,4], pch=4)


x1 = 7.5
x2 = 15.2
y1 = -0.003
y2 = 0.003
lines(c(x1,x2,x2,x1,x1),c(y1,y1,y2,y2,y1), col=4)
lines(c(x1,8.75),c(y2,0.04), col=4, lty=3)
lines(c(x2,24.),c(y2,0.04), col=4, lty=3)
p = dat[,4]
dp = dat[,2] - dat[,4]
edp = dat[,3]
par(new=T)
par(mar=c(15.5,7.3,2.7,18))
ylim = c(y1, y2)
xlim = c(x1, x2)
plot(p,dp,pch=19,cex=0.5,ylim=ylim,xaxt='n',xlim=xlim, xlab='',ylab='', cex.axis=0.8)
box(col=4)
abline(h=0,lty=5,col='black', lwd=0.7)
arrows(p,dp-edp,p,dp+edp,length=0.01,angle=90,code=3)


dev.off()
