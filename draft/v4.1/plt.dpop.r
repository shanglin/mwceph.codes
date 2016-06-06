f.per = '~/Work/mega/mwceph/pdot/cal.pdot/period_eperiod.dat'
per = read.table(f.per)
per[,1] = as.character(per[,1])

f.eha = '~/Work/mega/mwceph/pphot/period_all/ehat.dat'
dat = read.table(f.eha,header=T)
dat[,1] = as.character(dat[,1])

idx = dat[,1] %in% per[,1]
dat = dat[idx,]
idx = match(per[,1], dat[,1])
dat = dat[idx,]

outdir = '~/Work/mega/mwceph/draft/v4.1/figures/'
f.eps = paste0(outdir,'dpop.eps')
setEPS()
golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))

gcvsP = dat[,4]
thisP = per[,2]
dp = thisP - gcvsP
odp = dp
edp = per[,3]
ylim = c(-0.12,0.15)
xlim = range(gcvsP)
colidx = per[,4] == 'c' | per[,4] == 'd'
colids = per[colidx,1]
plot(gcvsP[!colidx], dp[!colidx], pch=19, cex=1, xlab='GCVS period [day]',ylab=expression(paste(Delta,italic('P'),' [day]')), cex.lab=1.5, cex.axis=1.3, ylim=ylim, xlim=xlim)
points(gcvsP[colidx], dp[colidx], pch=1, cex=1, col=4)
abline(h=0,lty=2,col='black')
arrows(gcvsP[!colidx],dp[!colidx]-edp[!colidx],gcvsP[!colidx],dp[!colidx]+edp[!colidx],length=0.015,angle=90,code=3)
arrows(gcvsP[colidx],dp[colidx]-edp[colidx],gcvsP[colidx],dp[colidx]+edp[colidx],length=0.015,angle=90,code=3, col=4)

dplim = 0.01
idx = abs(dp)>dplim
if (sum(idx) > 0) {
    p = dat[idx,4]
    objs = dat[idx,1]
    colidx = objs %in% colids
    dp = per[idx,2] - dat[idx,4]
    objs = gsub('u-car','U Car',objs)
    objs = gsub('vycar','VY Car',objs)
    objs = gsub('aqpup','AQ Pup',objs)
    objs = gsub('x-pup','X Pup',objs)
    objs = gsub('lcarl','l Car',objs)
    objs = gsub('kncen','KN Cen',objs)
    text(p[!colidx]-0.3,dp[!colidx]+0.005,objs[!colidx],col=1,cex=1.3, adj=1)
    text(p[colidx]-0.3,dp[colidx]+0.005,objs[colidx],cex=1.3, adj=1, col=4)
}

## mobjs = colids[!(colids %in% per[odp>dplim,1])]
## idx = per[,1] %in% mobjs
## gcvsP = dat[,4]
## thisP = per[,2]
## dp = thisP - gcvsP
## edp = per[,3]
## objs = per[,1]
## text(gcvsP[idx]+0.3,dp[idx]-c(0.001,0.002,0.003), objs[idx],cex=1.5, adj=0, col=4)

aavso.p.ucar = 38.829
aavso.p.vycar = 18.890
aavso.p.aqpup = 30.149
idx = per[,1] == 'vycar'
aavso.ps = c(aavso.p.vycar)
points(dat[idx,4], aavso.ps - dat[idx,4], pch=4)
idx = per[,1] == 'u-car'
aavso.ps = c(aavso.p.ucar)
points(dat[idx,4], aavso.ps - dat[idx,4], pch=4)
idx = per[,1] == 'aqpup'
aavso.ps = c(aavso.p.aqpup)
points(dat[idx,4], aavso.ps - dat[idx,4], pch=4)

x1 = 7.5
x2 = 15.2
y1 = -0.004
y2 = 0.004
lines(c(x1,x2,x2,x1,x1),c(y1,y1,y2,y2,y1), col=4)
lines(c(x1,8.7),c(y2,0.039), col=4, lty=3)
lines(c(x2,23.9),c(y2,0.039), col=4, lty=3)
p = dat[,4]
dp = per[,2] - dat[,4]
edp = per[,3]
par(new=T)
par(mar=c(15.5,7.3,2.7,18))
ylim = c(y1, y2)
xlim = c(x1, x2)
colidx = per[,4] == 'c' | per[,4] == 'd'
plot(p[!colidx],dp[!colidx],pch=19,cex=0.5,ylim=ylim,xaxt='n',xlim=xlim, xlab='',ylab='', cex.axis=0.8)
box(col=4)
abline(h=0,lty=5,col='black', lwd=0.7)
arrows(p[!colidx],dp[!colidx]-edp[!colidx],p[!colidx],dp[!colidx]+edp[!colidx],length=0.01,angle=90,code=3)
points(p[colidx],dp[colidx],pch=1,cex=0.5,col=4)
arrows(p[colidx],dp[colidx]-edp[colidx],p[colidx],dp[colidx]+edp[colidx],length=0.01,angle=90,code=3, col=4)

dev.off()


con = file(f.eps, 'r')
eps = readLines(con)
close(con)
idx = which(grepl('l Car', eps))
neps = eps[1:(idx+3)]
neps[idx] = gsub('l Car','  Car',neps[idx])
neps[idx+1] = '/Palatino-Italic findfont 16 s'
x.image = as.numeric(substr(neps[idx],1,6)) - 31
y.image = as.numeric(substr(neps[idx],7,12))
neps[idx+2] = paste(x.image, y.image, '(l) 1 0 t')
neps[idx+3] = '/Font1 findfont 16 s'
neps = c(neps, eps[(idx+1):length(eps)])
write(neps, f.eps)


## stop()


## outdir = '~/Work/mega/mwceph/draft/v3.1/figures/'
## f.eps = paste0(outdir,'dpop.eps')
## setEPS()
## golden.ratio = 1.61803398875
## fig.height = 5 # inches
## fig.width = fig.height * golden.ratio
## postscript(f.eps,height = fig.height, width = fig.width)
## par(mar=c(5,5,2,2))


## p = dat[,4]
## dp = dat[,2] - dat[,4]
## edp = dat[,3]
## ylim = c(-0.12,0.15)
## plot(p,dp,pch=19,cex=1,xlab='GCVS period [day]',ylab=expression(paste(Delta,'P [day]')),ylim=ylim, cex.lab=1.5, cex.axis=1.3)
## abline(h=0,lty=2,col='black')
## arrows(p,dp-edp,p,dp+edp,length=0.005,angle=90,code=3)
## idx = abs(dp)>0.03
## if (sum(idx) > 0) {
##     lar = dat[idx,]
##     p = lar[,4]
##     objs = lar[,1]
##     dp = lar[,2] - lar[,4]
##     objs = gsub('u-car','U Car',objs)
##     objs = gsub('vycar','VY Car',objs)
##     text(p-c(2.5,3),dp,objs,col=1,cex=1.5)
## }

## aavso.p.ucar = 38.829
## aavso.p.vycar = 18.890
## aavso.ps = c(aavso.p.ucar, aavso.p.vycar)
## ## abline(h = aavso.ps-lar[,4], lty=3, col=4)
## points(p, aavso.ps - lar[,4], pch=4)


## x1 = 7.5
## x2 = 15.2
## y1 = -0.003
## y2 = 0.003
## lines(c(x1,x2,x2,x1,x1),c(y1,y1,y2,y2,y1), col=4)
## lines(c(x1,8.75),c(y2,0.04), col=4, lty=3)
## lines(c(x2,24.),c(y2,0.04), col=4, lty=3)
## p = dat[,4]
## dp = dat[,2] - dat[,4]
## edp = dat[,3]
## par(new=T)
## par(mar=c(15.5,7.3,2.7,18))
## ylim = c(y1, y2)
## xlim = c(x1, x2)
## plot(p,dp,pch=19,cex=0.5,ylim=ylim,xaxt='n',xlim=xlim, xlab='',ylab='', cex.axis=0.8)
## box(col=4)
## abline(h=0,lty=5,col='black', lwd=0.7)
## arrows(p,dp-edp,p,dp+edp,length=0.01,angle=90,code=3)


## dev.off()
