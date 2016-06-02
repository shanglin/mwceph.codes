crocus2jd = 2400000 ## No .5 at the end
asas2jd = 2450000
ts2jd = 2400000  ## To avoid negative number or bad phase calculation
vid = 3

dir = '~/Work/mega/mwceph/pdot/cal.pdot/'
obsdir = '~/Work/mega/mwceph/pdot/allobs/'
dirold = '~/Work/mega/mwceph/period_search/inputs_it3/'
dirold2 = '~/Work/mega/mwceph/pphot/period_all/model_per/inputs_it3/'
diras = '~/Work/mega/mwceph/asas_related/cmb_data/'
figdir = '~/Work/mega/mwceph/pdot/figs/'

pit1 = '~/Work/mega/mwceph.codes/pdot/pejcha.f/period_it1'
pit2 = '~/Work/mega/mwceph.codes/pdot/pejcha.f/period_it2'
pit3 = '~/Work/mega/mwceph.codes/pdot/pejcha.f/period_it3'
pit0 = '~/Work/mega/mwceph.codes/pdot/pejcha.f/period'

f.par = paste0('~/Work/mega/mwceph/lightcurve/20160527/calilcs/', 'mw_ceph_pars.dat')
par = read.table(f.par)
for (ifoo in 1:3) par[,ifoo] = as.character(par[,ifoo])
npar = nrow(par)

findmaxgap = function(x) {
    x = x[order(x)]
    mgap = 0
    n = length(x)
    for (i in 2:n) {
        gap = x[i] - x[i-1]
        if (gap > mgap) mgap = gap
    }
    return(mgap)
}

for (i in 1:npar) {
    i = par[,1] == 'kncen'
    obj = par[i, 1]
    period = par[i, 4]
    f.dat = paste0(obsdir, obj, '.dat')
    idx = par[,1] == obj
    period = par[idx,4]
    frequency = 1/period
    dat = read.table(f.dat)
    idx = dat[,4] == 3
    dat = dat[idx,]

    t.range = c(min(dat[,1]), max(dat[,1]))
    t.width = 365*2
    t.box.shift = 200
    least.obs = 20
    npnts = round((t.range[2] - t.range[1])/t.box.shift)
    pts = tts = rep(NA, npnts)
    icounter = 1

    t.start = t.range[1]
    t.end = t.start + t.width
    while (t.end < t.range[2]) {
        idx = dat[,1] >= t.start & dat[,1] < t.end
        subtrange = t.width
        if (sum(idx) > 3) tblank = findmaxgap(dat[idx,1])
        if (sum(idx) >= least.obs & tblank < 0.3*t.width) {
            sub = dat[idx,]
            f.ipt = paste0(dir,'tmp.ipt')

            par(mfrow=c(2,1))
            ## First estimate of the period for this group of data
            pstar = period
            pranges = c(3.5, 0.001, 0.00002)
            rfactors = c(1, 0.001, 0.0001)
            nphases = c(10, 10, 30)
            resolutions = c(1e-5, 1e-6, 1e-7)
            for (ifoo in 1:2) {
                ts = paste(nrow(sub), pstar, 0, sep='   ')
                write(ts, f.ipt)
                write.table(sub, f.ipt, append=T, col.names=F, row.names=F, sep='   ')
                f.sh = paste0(dir, 'tmp.sh')
                ts = '#!/bin/tcsh -f'
                write(ts, f.sh)
                ts = paste0(pit0,' < infile > tmp.out')
                write(ts, f.sh, append=T)
                ts = 'rm -f fort.13 fort.14 fort.15 tmp.out tmp.ipt infile'
                write(ts, f.sh, append=T)
                dir.current = getwd()
                setwd(dir)
                prange = pranges[ifoo]
                rfactor = rfactors[ifoo] / (t.width / (max(sub[,1])-min(sub[,1])))
                nphase = nphases[ifoo]
                cmd = paste0('echo "',prange,'" > infile')
                system(cmd)
                cmd = paste0('echo "',rfactor,'" >> infile')
                system(cmd)
                cmd = paste0('echo "',nphase,'" >> infile')
                system(cmd)
                cmd = 'echo tmp.ipt >> infile'
                system(cmd)
                cmd = 'tcsh tmp.sh'
                system(cmd)
                setwd(dir.current)
                f.chi = paste0(dir, 'tmp.i_chi_sqr.dat')
                chi = read.table(f.chi)
                plot(chi[,1:2],pch=19,cex=0.5,col='black', main=obj)
                resolution = resolutions[ifoo]
                spl = smooth.spline(chi[,1],chi[,2])
                newx = seq(min(chi[,1]),max(chi[,1]),by=resolution)
                newxy = predict(spl,newx)
                lines(newxy,col='green')
                pstar = newxy$x[which.min(newxy$y)]
                if (abs(pstar - chi[1,1]) < 2*resolution)
                    stop(paste0(' >>>Alert! ',obj,' hit boundary. Increase dp range in period.f and make'))
                if (abs(pstar - chi[nrow(chi),1]) < 2*resolution)
                    stop(paste0(' >>>Alert! ',obj,' hit boundary. Increase dp range in period.f and make'))
                abline(v=pstar, col=2)
                cmd = paste0('rm -f ', f.sh, ' ', f.chi)
                system(cmd)
            }
            pts[icounter] = pstar
            tts[icounter] = 0.5*(t.end + t.start)
            icounter = icounter + 1
            ## Sys.sleep(3)
        }
        t.start = t.start + t.box.shift
        t.end = t.start + t.width
    }

    f.pdf = paste0(figdir, obj, '_pdot.pdf')
    pdf(f.pdf, width=9, height=9)
    par(mfrow = c(2,1))
    idx = !is.na(pts)
    pts = pts[idx]
    tts = tts[idx]
    xlim = range(dat[,1])
    plot(dat[,1:2], pch=19, xlim=xlim, xlab='JD - 2400000', ylab='V [mag]')
    f.asas = paste0('~/Work/mega/mwceph/asas_related/cmb_data/',obj,'_labeled_asas_only.dat')
    asas = read.table(f.asas, header=T)
    idx = asas[,6] == 1
    asas = asas[idx,]
    asas[,1] = asas[,1] + 50000
    points(asas[,1:2], pch=19, col=2)
    v1980 = 2444239.5 - 2400000
    abline(v=v1980, col=4)
    plot(tts, pts, pch=19, xlim = xlim, xlab='JD - 2400000', ylab='Period [day]')
    lines(tts, pts)
    dev.off()
    stop()
}
