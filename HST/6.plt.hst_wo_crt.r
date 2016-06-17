f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
par = read.table(f.par, stringsAsFactors=F)

dir = '~/Work/mega/mwceph/HST/colorcorr/'
figdir = '~/Work/mega/mwceph/HST/colorcorr/figs/'
lcdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.hst = paste0(dir,'hst3.dat')

hst = read.table(f.hst, skip=0, stringsAsFactors=F, header=T)
odate = hst[,2]
hst[,2] = hst[,2]
ids = tolower(hst[,1])
idx = nchar(ids) == 6
ids[idx] = gsub('-','',ids[idx])
hst[,1] = ids
uids = unique(ids)

source('fitfuns/fun.fit.Inno15.r')
load.pars()
amp = 0.32
width = 8.27

zps = as.data.frame(matrix(NA, nrow=1e3, ncol=9))
icount = 0

f.pdf = paste0(figdir, 'lc_wo_crted.pdf')
pdf(f.pdf)
for (id in uids) {
    idx = par[,1] == id
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

    f.slc = paste0(lcdir, id, '_h.clc')
    if (!file.exists(f.slc))
        f.slc = paste0(lcdir, id, '_n.clc')
    if (!file.exists(f.slc)) stop(id)
    lc = read.table(f.slc)
    lc[,1] = lc[,1] + 2450000 - 2400000.5
    x = ((lc[,1]-t0)/period) %% 1
    y = lc[,2]
    e = lc[,3]
    x = c(x, x + 1)
    y = c(y, y)
    e = c(e, e)
    
    xc = seq(0, 1, by = 0.001)
    yc = calt(xc, PHI, M, L, a0)
    xc = c(xc, xc + 1)
    yc = c(yc, yc)

    xhst = ((sub[,2]-t0)/period) %% 1
    yhst = sub[,3]
    model.y = calt(xhst, PHI, M, L, a0)
    off = yhst - model.y
    xhst = c(xhst, xhst + 1)
    yhst = c(yhst, yhst)
    
    xlim = c(0,2)
    midmag = 0.5 * (max(yc) + min(yc))
    ylim = c(midmag + amp, midmag - amp)
    thiszp = mean(off)
    main = sprintf('%11s%7s%6.3f%4s',obj,'     ZP =',thiszp,' mag')
    ## main = obj
    main = gsub('V0', 'V', main)
    if (id == 'betad') main = expression(paste(beta,'-DOR      ','     P = 9.842922'))
    if (id == 'lcarl') main = sprintf('%11s%7s%10.6f','l-CAR','     P =',period)
    plot(xc, yc, xlab='Phase', ylab='H [mag]', xlim = xlim, ylim = ylim, type = 'l',
         main = main, font.main = 1, cex.main = 0.9, col = 'black',
         cex.axis = 1, xaxt = 'n')
    axis(1, at = seq(0,2,0.5), labels = c('0', '0.5', '1', '0.5', '1'))
    points(x, y, pch = 19, cex = 1)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)

    points(xhst, yhst-thiszp, col=2, pch=19)

    
    for (j in (icount+1):(icount+length(off))) {
        zps[j,1] = obj
        zps[j,2] = off[j-icount]
        zps[j,3] = eM
        zps[j,4] = zp.2mass
        zps[j,5] = zp.nd4
        zps[j,7] = period
        zps[j,8] = sub[j-icount,2]
        zps[j,9] = L
    }
    icount = icount + length(off)
}
dev.off()

f.pdf = paste0(figdir,'zeropoints_wo_crted.pdf')
pdf(f.pdf, width=12, height=6.5)
idx = !is.na(zps[,2])
zps = zps[idx,]
zps[,6] = sqrt(zps[,3]^2 + zps[,4]^2 + zps[,5]^2)
xlim = c(0, nrow(zps)+1)
ylim = c(-0.1,0.3) + 0.06
idx = zps[,5] > 0
sub = zps[idx,]
n = nrow(sub)
x = 1:n
y = sub[,2]
e = sub[,6]
par(mar=c(3, 6,3,3))
ylab = expression(paste(italic(H)[HST] - italic(H)[model],' [mag]'))
plot(x, y, col=1, xlim=xlim, ylim=ylim, xaxt='n', xlab='', ylab=ylab)
arrows(x, y-e, x, y+e, code=3, angle=90, length=0.02, col=1)

sub = zps[!idx,]
m = nrow(sub)
x = (n+1):(n+m)
y = sub[,2]
e = sub[,6]
points(x, y, col=2, xlim=xlim, ylim=ylim)
arrows(x, y-e, x, y+e, code=3, angle=90, length=0.02, col=2)

uobj = unique(zps[,1])
at = c()
label = c()
colcount = 1
for (obj in uobj) {
    idx = which(zps[,1] == obj)
    n = length(idx)
    xs = idx
    ys = rep(-0.03,n) + 0.06
    lines(xs, ys, col=colcount)
    ## colcount = colcount + 1
    text(mean(xs), -0.07 + 0.06, obj, srt=90)
}

zp = mean(zps[,2])
sigma = sd(zps[,2])
abline(h=c(zp, zp+sigma, zp-sigma), lty=c(1,2,2), col='grey')
zp = round(zp,3)
sigma = round(sigma,3)
text(3, 0.29 + 0.06, paste0('Mean = ',zp, ' mag'), adj = 0)
text(3, 0.27 + 0.06, paste0('Standard deviation = ',sigma, ' mag'), adj = 0)
dev.off()



f.tbl = paste0(dir,'wo_crted_residuals.dat')
ts = '#  Cepheid      Date      H_(hst)-H  sigma(H)'
write(ts, f.tbl)
fmt = '%10s%14.5f%9.3f%9.3f'
tbl = do.call('sprintf',c(fmt, zps[,c(1,8,2,3)]))
write(tbl, f.tbl, append=T)

