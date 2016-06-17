outdir = '~/Work/mega/mwceph/HST/colorcorr/JHtemps/'
f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
f.main = '~/Work/mega/mwceph.codes/lightcurve/20160604/hst/pejcha.f/main'
lcdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
par = read.table(f.par, stringsAsFactors=F)
npar = nrow(par)

for (i in 1:npar) {
    id = par[i,1]
    period = par[i,4]
    cmd = paste0('echo ',period,' > inpars.txt')
    system(cmd)
    cmd = 'echo 12 >> inpars.txt'
    system(cmd)
    cmd = paste0(f.main, '< inpars.txt')
    system(cmd)
    dat = read.table('fort.13')
    dat[,1] = dat[,1] / (2*pi)
    dat[,4] = dat[,4] / 25
    dat = dat[,c(1,4)]
    f.out = paste0(outdir,id,'_H.dat')
    write.table(dat, f.out, col.names=F, row.names=F, sep='   ')

    cmd = paste0('echo ',period,' > inpars.txt')
    system(cmd)
    cmd = 'echo 11 >> inpars.txt'
    system(cmd)
    cmd = paste0(f.main, '< inpars.txt')
    system(cmd)
    dat = read.table('fort.13')
    dat[,1] = dat[,1] / (2*pi)
    dat[,4] = dat[,4] / 25
    dat = dat[,c(1,4)]
    f.out = paste0(outdir,id,'_J.dat')
    write.table(dat, f.out, col.names=F, row.names=F, sep='   ')
 
    ## plot(xc, yc, type='l', ylim=rev(range(yc)))
    ## f.lc = paste0(lcdir,id,'_h.clc')
    ## if (!file.exists(f.lc)) f.lc = paste0(lcdir,id,'_n.clc')
    ## if (!file.exists(f.lc)) stop(id)
    ## lc = read.table(f.lc)
    ## x = lc[,1]
    ## y = lc[,2]
    ## y = y - mean(y)
    ## phase = (x/period) %% 1
    ## points(phase, y, pch=19)
    ## stop()
    ## Sys.sleep(2)
    
}
