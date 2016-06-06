set.seed(101)

nB = 20

outdir = '~/Work/mega/mwceph/pdot/cal.pdot/peps/'
figdir = '~/Work/mega/mwceph/pdot/cal.pdot/figs/'
dir = '~/Work/mega/mwceph/pdot/cal.pdot/'
datdir = '~/Work/mega/mwceph/pdot/allobs/'
fort.periodogram = '~/Work/mega/mwceph.codes/pdot/pejcha.f/period'
f.par = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
for (ifoo in 1:3) par[,ifoo] = as.character(par[,ifoo])
npar = nrow(par)

groups = c('b70','70s','80s','90s','asas_old','asas_new','iomc','this')

calphat = function(d, prange=1, rfactor=1, nphase=10, resolution=1e-4, phat=period, plot=T) {
    f.ipt = paste0(dir,'tmp.ipt')
    ts = paste(nrow(d), phat, 0, sep='   ')
    write(ts, f.ipt)
    write.table(d, f.ipt, append=T, col.names=F, row.names=F, sep='   ')
    f.sh = paste0(dir, 'tmp.sh')
    ts = '#!/bin/tcsh -f'
    write(ts, f.sh)
    ts = paste0(fort.periodogram,' < infile > tmp.out')
    write(ts, f.sh, append=T)
    ts = 'rm -f fort.13 fort.14 fort.15 tmp.out tmp.ipt infile'
    ## write(ts, f.sh, append=T)
    dir.current = getwd()
    setwd(dir)
    cmd = paste0('echo "',round(prange,7),'" > infile')
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
    info = file.info(f.chi)
    if (info$size == 0) {
        ret = c(-1, phat)
        return(ret)
    }
    chi = read.table(f.chi)
    if (nrow(chi) < 10) {
        ret = c(-1, phat)
        return(ret)
    }
    if (plot) 
        plot(chi[,1:2],pch=19,cex=0.5,col='black', main=paste(obj, group), xlab='Period [day]', ylab='Chi square')
    spl = smooth.spline(chi[,1],chi[,2])
    newx = seq(min(chi[,1]),max(chi[,1]),by=resolution)
    newxy = predict(spl,newx)
    if (plot)
        lines(newxy,col='green')
    phat = newxy$x[which.min(newxy$y)]
    
    #### Find next prange
    idx = chi[,1] < phat
    hchi = chi[idx,]
    idx = order(phat-hchi[,1])
    third = min(3, length(idx))
    dist1 = hchi[idx[third],1]
    idx = chi[,1] > phat
    hchi = chi[idx,]
    idx = order(hchi[,1]-phat)
    third = min(3, length(idx))
    dist2 = hchi[idx[third],1]
    dist = dist2 - dist1
    
    if (abs(phat - chi[1,1]) < 2*resolution)
        dist = -1
    if (abs(phat - chi[nrow(chi),1]) < 2*resolution)
        dist = -1
    abline(v=phat, col=2)
    cmd = paste0('rm -f ', f.sh, ' ', f.chi)
    system(cmd)
    ret = c(dist, phat)
    return(ret)
}
calehat = function(d) {
    ndata = nrow(d)
    pstars = rep(NA, ndata)
    idx = order(d[,1])
    d = d[idx,]
    for (iB in 1:nB) {
        msg = paste0('  >> [',obj,', ',group,']: Calculate uncertainties of P...',round(iB*100/nB), ' %   \r')
        message(msg, appendLF=F)
        idx = sample(1:ndata, replace=T)
        idx = unique(idx)
        if (length(idx) > 10) {
            b = d[idx,]
            if (sum(b[,4] > 0) > 10) {
                ret = calphat(b, prange0,  5, 10, 1e-4, period, plot=F)
                prange = ret[1]
                pstar = ret[2]
                iwhile = 2
                while (prange == -1) {
                    prangel = prange0*2^iwhile
                    ret = calphat(b, prangel, 5, 10, 1e-4, period, plot=F)
                    prange = ret[1]
                    pstar = ret[2]
                    iwhile = iwhile + 1
                }
                while (prange > 1e-6) {
                    ret = calphat(b, prange, prange*10, 30, prange*0.01, pstar, plot=F)
                    prange = ret[1]
                    pstar = ret[2]
                }
                pstars[iB] = pstar
            }
        }
    }
    sigma = sd(pstars, na.rm=T)
    if (is.na(sigma)) sigma = 99.99
    return(sigma)
    print('')
}

rjoutlier = function(d) {
    x = (d[,1] / phat) %% 1
    y = d[,2]
    ## plot(x, y, pch=19)
    spl = smooth.spline(x,y)
    ## nx = seq(0,1,0.002)
    ny = predict(spl, x)$y
    ## lines(nx, ny, col=2, lwd=2)
    idx = abs(ny - y) < 3*sd(ny - y)
    g = d[idx,]
    b = d[!idx,]
    
    x = (g[,1] / phat) %% 1
    y = g[,2]
    plot(x, y, pch=19, ylim=range(d[,2]), main=paste(obj, group), xlab='Phase', ylab='V [mag]')
    x = (b[,1] / phat) %% 1
    y = b[,2]
    points(x, y, col=4)
    return(g)
}

for (ipar in 1:npar) {
    obj = par[ipar,1]
    period = par[ipar,4]
    f.dat = paste0(datdir, obj, '_g.dat')
    dat = read.table(f.dat)
    f.out = paste0(outdir, obj, '_pep_group.dat')
    ts = '#    JD-2400000   Period   ePeriod   group    Nobs'
    write(ts, f.out)
    f.pdf = paste0(figdir, obj, '_peplog.pdf')
    pdf(f.pdf)
    for (group in groups) {
        idx = dat[,5] == group
        if (sum(idx) > 30) {
            sub = dat[idx,]
            prange0 = 0.01
            prange = prange0
            ret = calphat(sub, prange0, 5, 10, 1e-4, period)
            prange = ret[1]
            iwhile = 2
            msg = paste0('  >> [',obj,', ',group,']: Calculate P...')
            print(msg)
            while (prange == -1) {
                prangel = prange0*2^iwhile
                ret = calphat(sub, prangel, 5, 10, 1e-4, period)
                prange = ret[1]
                phat = ret[2]
                iwhile = iwhile + 1
            }
            while (prange > 1e-6) {
                ret = calphat(sub, prange, prange*10, 30, prange*0.01, phat)
                prange = ret[1]
                phat = ret[2]
            }
            if (group == 'asas_old' | group == 'asas_new' | group == 'iomc') {
                msg = paste0('  >> [',obj,', ',group,']: Rejecting outliers...')
                print(msg)
                new = rjoutlier(sub)
                new = rjoutlier(new)
                prange = prange0
                ret = calphat(new, prange0, 5, 10, 1e-4, period)
                prange = ret[1]
                while (prange == -1) {
                    prangel = prange0*2^iwhile
                    ret = calphat(new, prangel, 5, 10, 1e-4, period)
                    prange = ret[1]
                    phat = ret[2]
                    iwhile = iwhile + 1
                }
                while (prange > 1e-6) {
                    ret = calphat(new, prange, prange*10, 30, prange*0.01, phat)
                    prange = ret[1]
                    phat = ret[2]
                }
                ehat = calehat(new)
                time = mean(new[,1])
                ndata = nrow(new)
            } else {
                ehat = calehat(sub)
                time = mean(sub[,1])
                ndata = nrow(sub)
            }
            time = round(time, 5)
            phat = round(phat, 6)
            ehat = round(ehat, 6)
            ts = paste(time, phat, ehat, group, ndata, sep='    ')
            write(ts, f.out, append=T)
        }
    }
    dev.off()
}
