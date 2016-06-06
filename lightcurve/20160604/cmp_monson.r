dir = '~/Work/mega/mwceph/lightcurve/20160604/monson_north/'
f.dat = 't3_measure.dat'
lf.dat = paste0(dir, f.dat)

dat = read.fwf(lf.dat, width=c(9,12,5,7,6,7,6,7,6,2), skip=30)
idx = dat[,10] == 0
dat = dat[idx,]
ids = as.character(dat[,1])
ids = gsub(' ','',ids)

lcdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.sth = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
sth = read.table(f.sth)

idx = ids %in% sth[,2]
dat = dat[idx,]
ids = as.character(dat[,1])
ids = gsub(' ','',ids)
uids = names(table(ids))
nids = length(uids)

source('fitfuns/fun.fit.Inno15.r')
load.pars()
f.out = paste0(dir, 'monson_pars.dat')
ts = '#  ID     period       t0        M       eM        L       eL       PHI     ePHI'
write(ts, f.out)
dms = dls = ddls = edms = edls = eddls = rep(NA, nids)
edms2 = rep(NA,nids)
objs = c()
for (i in 1:nids) {
    uid = uids[i]
    idx = ids == uid
    lc = dat[idx,c(2,6,7)]
    period = sth[sth[,2]==uid, 4]
    t = lc[,1]
    m = lc[,2]
    oy = m
    e = lc[,3]
    t0 = round(median(t))
    t0 = round(period * 0.3)
    phase = ((t - t0) / period) %% 1
    pars = fit.Inno15(phase, m, e)
    M = round(pars[1],4)
    L = round(pars[2],4)
    PHI = round(pars[3],4)
    eM = round(pars[4],4)
    eL = round(pars[5],4)
    ePHI = round(pars[6],4)

    residual.monson = m - calt(phase, PHI, M, L, a0)
    x = c(phase, phase + 1)
    y = c(m, m)
    e = c(e, e)
    xc = seq(0, 1, by = 0.001)
    yc = calt(xc, PHI, M, L, a0)
    xc = c(xc, xc + 1)
    yc = c(yc, yc)
    amp = 0.3
    ylim = c(mean(yc)+amp, mean(yc)-amp)
    xlim = c(0,2)
    f.eps = paste0(dir,uid,'.eps')
    setEPS()
    postscript(f.eps)
    if (uid=='TMON') main='T Mon'
    if (uid == 'WZSGR') main='WZ Sgr'
    if (uid == 'YZSGR') main='YZ Sgr'
    objs = c(objs, main)
    plot(xc, yc, type='l', xlim=xlim, ylim=ylim, xlab='Phase', ylab='H (mag)', main=main)
    points(x, y, pch=19)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)
    ts = paste(uid, period, t0, M, eM, L, eL, PHI, ePHI,sep='   ')
    ts = sprintf('%5s%12.6f%10i%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f',
        uid, period, t0, M, eM, L, eL, PHI, ePHI)
    write(ts, f.out, append = T)

    tt = sth[sth[,2]==uid, ]
    M2 = tt[1,6]
    L2 = tt[1,8]
    ## PHI = tt[1,10]
    xc = seq(0, 1, by = 0.001)
    yc = calt(xc, PHI, M2, L2, a0)
    xc = c(xc, xc + 1)
    yc = c(yc, yc)
    lines(xc, yc, col=4, lty=2)
    dm = list(a = round(M2 - M, 4), b = round(L2-L,4), c = round((L2-L)/L,2))
    t1 = bquote(Delta ~ 'M ' == .(dm$a) ~ 'mag')
    text(0, mean(y)-0.3, t1, adj=0)
    t2 = bquote(Delta ~ 'L ' == .(dm$b) ~ 'mag')
    text(0, mean(y)-0.27, t2, adj=0)
    t3 = bquote(Delta ~ 'L / L' == .(dm$c))
    text(0, mean(y)-0.24, t3, adj=0)

    sid = as.character(tt[1,1])
    f.clc = paste0(lcdir, sid, '_h.clc')
    if (!file.exists(f.clc)) f.clc = paste0(lcdir, sid, '_n.clc')
    if (!file.exists(f.clc)) stop(sid)
    clc = read.table(f.clc)
    x = clc[,1]+2450000
    y = clc[,2]
    e = clc[,3]
    
    phase = ((x - t0) / period) %% 1
    residual.this = y - calt(phase, PHI, M2, L2, a0)
    x = c(phase, phase + 1)
    y = c(y, y)
    e = c(e, e)
    points(x, y, pch=1, col=4)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90, col=4)

    res = list(m = round(median(abs(residual.monson)),4), t = round(median(abs(residual.this)),4))
    t4 = bquote('median residual' == .(res$m) ~ 'mag')
    text(2.0, mean(oy)-0.3, t4, adj=1)
    t5 = bquote('median residual' == .(res$t) ~ 'mag')
    text(2.0, mean(oy)-0.27, t5, adj=1, col=4)

    legend('bottomright',c('Monson & Pierce', 'This work'), pch=c(19,1),col=c(1,4))
    ## print(uid)
    dev.off()
    dms[i] = dm$a
    dls[i] = dm$b
    ddls[i] = dm$c
    edms[i] = sqrt(eM^2 + tt[1,7]^2)
    edls[i] = sqrt(eL^2 + tt[1,9]^2)
    eddls[i] = edls[i] / L
    edms2[i] = sqrt(eM^2 + tt[1,7]^2 + tt[1,12]^2 + tt[1,13]^2)
}

setEPS()
f.eps = paste0(dir,'dm.eps')
postscript(f.eps, width=8, height=8*0.618)
x = 1:nids
ylab = expression(paste(Delta, 'M'))
plot(x, dms, pch=19, ylim=c(-0.06, 0.06), xaxt='n', ylab=ylab,xlab='', xlim=c(0.5, nids+0.5))
arrows(x, dms + edms, x, dms - edms, code=3, length=0.02, angle=90)
abline(h = 0, lty=2)
axis(1, at=1:nids, labels=objs)
dev.off()

setEPS()
f.eps = paste0(dir,'dl.eps')
postscript(f.eps, width=8, height=8*0.618)
x = 1:nids
ylab = expression(paste(Delta, 'L'))
plot(x, dls, pch=19, ylim=c(-0.06, 0.06)*1.5, xaxt='n', ylab=ylab, xlab='', xlim=c(0.5, nids+0.5))
arrows(x, dls + edls, x, dls - edls, code=3, length=0.02, angle=90)
abline(h = 0, lty=2)
axis(1, at=1:nids, labels=objs)
dev.off()



setEPS()
f.eps = paste0(dir,'dlol.eps')
postscript(f.eps, width=8, height=8*0.618)
x = 1:nids
ylab = expression(paste(Delta, 'L / L'))
plot(x, ddls, pch=19, ylim=c(-0.06, 0.06)*5.5, xaxt='n', ylab=ylab, xlab='', xlim=c(0.5, nids+0.5))
arrows(x, ddls + eddls, x, ddls - eddls, code=3, length=0.02, angle=90)
abline(h = 0, lty=2)
axis(1, at=1:nids, labels=objs)
dev.off()


setEPS()
f.eps = paste0(dir,'dm2.eps')
postscript(f.eps, width=8, height=8*0.618)
x = 1:nids
ylab = expression(paste(Delta, 'M\''))
plot(x, dms, pch=19, ylim=c(-0.06, 0.06)*1.5, xaxt='n', ylab=ylab,xlab='', xlim=c(0.5, nids+0.5))
arrows(x, dms + edms2, x, dms - edms2, code=3, length=0.02, angle=90)
abline(h = 0, lty=2)
axis(1, at=1:nids, labels=objs)
dev.off()
