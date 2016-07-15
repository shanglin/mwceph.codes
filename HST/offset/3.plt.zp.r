f.par = '~/Work/mega/mwceph/HST/colorcorr/crt_lcs/updated_bestfit_pars.dat'
par = read.table(f.par, stringsAsFactors=F)

cdir = '~/Work/mega/mwceph/HST/colorcorr/'
figdir = '~/Work/mega/mwceph/HST/offsets/figs/'
lcdir = paste0(cdir,'crt_lcs/')

dir = '~/Work/mega/mwceph/HST/offsets/'
f.hst = paste0(dir,'hst4.dat')
hst = read.table(f.hst, skip=0, stringsAsFactors=F, header=T)
odate = hst[,2]
ids = tolower(hst[,1])
idx = nchar(ids) == 6
ids[idx] = gsub('-','',ids[idx])
hst[,1] = ids
uids = unique(ids)

source('fitfuns/fun.fit.Inno15.r')
load.pars()
amp = 0.32
width = 8.27

zps = as.data.frame(matrix(NA, nrow=1e3, ncol=10))
icount = 0

for (id in uids) {
    idx = par[,1] == id
    if (id == 'bet-dor') idx = par[,1] == 'betad'
    if (id == 'v0339-cen') idx = par[,1] == 'vjcen'
    if (id == 'v0340-ara') idx = par[,1] == 'vjara'
    if (sum(idx) != 1) stop(id)
    ts = par[idx,]
    idx = hst[,1] == id
    sub = hst[idx,]

    obj = ts[1, 3]
    period = ts[1, 4]
    t0 = ts[1, 5] - 2400000.5
    M = ts[1, 6]
    eM = ts[1, 7]
    L = ts[1, 8]
    eL = ts[1, 9]
    PHI = ts[1, 10]
    ePHI = ts[1, 11]
    zp.2mass = ts[1, 12]
    zp.nd4 = ts[1, 13]
    
    a0 = get.a0(period)
    phis = get.phis(period)
    amps = get.amps(period)

    xhst = ((sub[,2]-t0)/period) %% 1
    yhst = sub[,3]
    model.y = calt(xhst, PHI, M, L, a0)
    off = yhst - model.y
    xhst = c(xhst, xhst + 1)
    yhst = c(yhst, yhst)
   
    for (j in (icount+1):(icount+length(off))) {
        zps[j,1] = obj
        zps[j,2] = off[j-icount]
        zps[j,3] = eM
        zps[j,4] = zp.2mass
        zps[j,5] = zp.nd4
        zps[j,7] = period
        zps[j,8] = sub[j-icount,2]
        zps[j,9] = L
        zps[j,10] = M
    }
    icount = icount + length(off)
}


idx = !is.na(zps[,2])
zps = zps[idx,]
zps[,6] = sqrt(zps[,3]^2 + zps[,4]^2 + zps[,5]^2)

dfzps = zps

xlim = c(0, nrow(zps)+1)
ylim = c(-0.1,0.3)
idx = zps[,5] > 0
sub = zps[idx,]
n = nrow(sub)
x = 1:n
y = sub[,2]
e = sub[,6]
## par(mar=c(3, 6,3,3))
ylab = expression(paste(italic(H)[HST] - italic('H\'')[model],' [mag]'))
## plot(x, y, col=1, xlim=xlim, ylim=ylim, xaxt='n', xlab='', ylab=ylab)
## arrows(x, y-e, x, y+e, code=3, angle=90, length=0.02, col=1)

## sub = zps[!idx,]
## m = nrow(sub)
## x = (n+1):(n+m)
## y = sub[,2]
## e = sub[,6]
## points(x, y, col=2, xlim=xlim, ylim=ylim)
## arrows(x, y-e, x, y+e, code=3, angle=90, length=0.02, col=2)

## uobj = unique(zps[,1])
## at = c()
## label = c()
## colcount = 1
## for (obj in uobj) {
##     idx = which(zps[,1] == obj)
##     n = length(idx)
##     xs = idx
##     ys = rep(-0.03,n)
##     lines(xs, ys, col=colcount)
##     ## colcount = colcount + 1
##     text(mean(xs), -0.07, obj, srt=90)
## }

## zp = mean(zps[,2])
## sigma = sd(zps[,2])
## abline(h=c(zp, zp+sigma, zp-sigma), lty=c(1,2,2), col='grey')
## zp = round(zp,3)
## sigma = round(sigma,3)
## text(3, 0.29, paste0('Mean = ',zp, ' mag'), adj = 0)
## text(3, 0.27, paste0('Standard deviation = ',sigma, ' mag'), adj = 0)

f.eps = paste0(figdir,'zeropoint_all.eps')
setEPS()
postscript(f.eps, width=6, height=6*0.618)
par(mar=c(5,5,3,3))
xlab = expression(paste(italic(H), ' [mag]'))
x = dfzps[,10]
y = dfzps[,2]
e = dfzps[,6]
plot(x, y, xlab=xlab, ylab=ylab)
## arrows(x, y-e, x, y+e, code=3, angle=90, length=0.02)
out = dfzps[,c(1,8,2,6,10,7,9)]
f.out = paste0(dir, 'zeropoint_all.dat')
ts = '#   object   epoch    zeropoint   sigma_zeropoint   mean_H_mag_CTIO   period   amplitude'
write(ts, f.out)
fmt = '%12s%12.3f%8.3f%8.3f%9.4f%11.6f%9.4f'
out = do.call('sprintf',c(out, fmt))
write(out, f.out, append=T)
## write.table(out, f.out, append=T, col.names=F, row.names=F, quote =F, sep='   ')
dev.off()
