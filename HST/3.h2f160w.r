lcdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.par = paste0(lcdir, 'mw_ceph_pars.dat')
par = read.table(f.par, stringsAsFactors=F)
npar = nrow(par)
dir = '~/Work/mega/mwceph/HST/colorcorr/'
if (F) {
for (i in 1:npar) {
    id = par[i,1]
    obj = par[i,3]
    f.1 = paste0(dir,'JHtemps/',id,'_col.dat')
    f.2 = paste0(dir,'JHcols/',obj,'_color.dat')
    cmd = paste0('cp ',f.1,' ',f.2)
    system(cmd)
}
}
tpldir = '~/Work/mega/mwceph/HST/colorcorr/JHcols/'
outdir = '~/Work/mega/mwceph/HST/colorcorr/crt_lcs/'

## (1) match the zeropoints of the phses and correct for the color term
f.pdf = paste0(dir,'figs/correct_ground_obs.pdf')
pdf(f.pdf)
source('fitfuns/fun.fit.Inno15.r')
load.pars()
xc = seq(0, 1, 0.001)
for (i in 1:npar) {
    id = par[i,1]
    obj = par[i,3]
    period = par[i,4]
    a0 = get.a0(period)
    phis = get.phis(period)
    amps = get.amps(period)
    t0 = par[i,5] - 2450000
    M = par[i,6]
    L = par[i,8]
    PHI = par[i,10]
    yc = calt(xc, PHI, M, L, a0)
    ylim = c(max(yc), min(yc)) + c(5,-1)*0.1
    par(mfrow=c(2,1), mar=c(0,5,2,2))
    plot(xc, yc, type='l', ylim=ylim, col=4, xlab='Phase', ylab='H [mag]', main=obj)

    f.lc = paste0(lcdir,id,'_h.clc')
    if (!file.exists(f.lc)) f.lc = paste0(lcdir,id,'_n.clc')
    if (!file.exists(f.lc)) stop(id)
    lc = read.table(f.lc)
    xp = lc[,1]
    yp = lc[,2]
    ep = lc[,3]
    xp = ((xp - t0)/period) %% 1
    points(xp, yp, pch=19, cex=0.5, col='grey')
    arrows(xp, yp-ep, xp, yp+ep, col='grey', code=3, angle=90, length=0.02)
    
    f.tpl = paste0(tpldir,obj,'_color.dat')
    tpl = read.table(f.tpl)
    ## lines(tpl[,1:2], col='grey', lty=2)
    max.inno = xc[which.min(yc)]
    max.pejc = tpl[which.min(tpl[,2]),1]

    dphi = max.pejc - max.inno
    x = tpl[,1] - dphi
    y = tpl[,2]
    x = x %% 1
    tpl[,1] = x
    idx = order(x)
    tpl = tpl[idx,]
    lines(tpl[,1:2], col=2)
    lines(tpl[,c(1,3)], col=3)
    legend('bottomleft', c('Ondrej - H', 'Ondrej - J', 'Inno - H'), lty=1, col=c(2,3,4))

    nlc = nrow(lc)
    for (j in 1:nlc) {
        idx = which.min(abs(xp[j] - tpl[,1]))
        col = tpl[idx,4]
        lc[j,2] = lc[j,2] + 0.16*col
    }
    xp = lc[,1]
    yp = lc[,2]
    ep = lc[,3]
    xp = ((xp - t0)/period) %% 1
    points(xp, yp, pch=19, cex=0.5, col=1)
    arrows(xp, yp-ep, xp, yp+ep, col=1, code=3, angle=90, length=0.02)
    
    par(mar=c(5,5,3,2))
    plot(tpl[,1], tpl[,4], type='l', xlab='Phase', ylab='J - H [mag]')

    lc[,1] = lc[,1] + 2450000 - 2400000.5
    out = do.call('sprintf', c('%12.5f%9.3f%9.3f',lc))
    f.out = paste0(outdir,obj,'_crted.dat')
    write('#    MJD          H      sigma',f.out)
    write(out, f.out, append=T)
}
dev.off()    




