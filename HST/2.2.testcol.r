outdir = '~/Work/mega/mwceph/HST/colorcorr/figs/'
dir = '~/Work/mega/mwceph/HST/colorcorr/JHtemps/'
f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
par = read.table(f.par, stringsAsFactors=F)
idx = order(par[,4])
par = par[idx,]
npar = nrow(par)
f.pdf = paste0(outdir, 'JHcolors.pdf')
pdf(f.pdf, width=6, height=6)
for (i in 1:npar) {
    id = par[i,1]
    period = par[i,4]
    f.h = paste0(dir,id,'_H.dat')
    f.j = paste0(dir,id,'_J.dat')
    hdat = read.table(f.h)
    jdat = read.table(f.j)

    hdat[,2] = 12.819 - 3.169*(log10(period)-1) + hdat[,2]
    jdat[,2] = 13.185 - 3.140*(log10(period)-1) + jdat[,2]

    mu = mean(hdat[,2]) - par[i,6]
    hdat[,2] = hdat[,2] - mu
    jdat[,2] = jdat[,2] - mu
    
    col = jdat[,2] - hdat[,2]
    par(mfrow=c(3,1), mar=c(3,3,2,1), tck=0.02, mgp=c(1.5,0.3,0))
    ylim = c(0.25,-0.25) + mean(jdat[,2])
    main = paste0(par[i,3],'    P = ', period)
    plot(jdat, type='l', xlab='Phase', ylab='J [mag]', main=main, ylim=ylim)
    ylim = c(0.25,-0.25) + mean(hdat[,2])
    plot(hdat, type='l', xlab='Phase', ylab='H [mag]', ylim=ylim)
    ylim = c(-0.1,0.1) + mean(col)
    plot(jdat[,1], col, type='l', xlab='Phase', ylab='J-H [mag]', ylim=ylim, col=4, lwd=2)

    dat = cbind(hdat[,1], hdat[,2], jdat[,2], col)
    f.out = paste0(dir,id,'_col.dat')
    ts = '#phase     H      J     J-H'
    write(ts, f.out)
    write.table(round(dat,5), f.out, append=T, col.names=F, row.names=F, sep='   ')
}
dev.off()
