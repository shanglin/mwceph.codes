dir = '~/Work/m33/16summer/mwupdt/cmb_data/'
figdir = paste0(dir, 'figs/')

f.par = paste0(dir,'old_mw_ceph_pars.dat')
par = read.table(f.par)
objs = tolower(par[,3])
objs = gsub('-','',objs)
objs = gsub('v0','v',objs)

fs.dat = list.files(dir, pattern='.*.cmb.dat$')
nfs = length(fs.dat)

sigma = 3

for (i in 1:nfs) {
    f.dat = fs.dat[i]
    lf.dat = paste0(dir, f.dat)
    dat = read.table(lf.dat)
    dat[,4] = as.character(dat[,4])
    idx = dat[,4] != 'iomc'
    dat = dat[idx,]
    cols = rep(NA, nrow(dat))
    idx = dat[,4] == 'asas_old'
    if (sum(idx) > 0) cols[idx] = 1
    idx = dat[,4] == 'asas_new'
    if (sum(idx) > 0) cols[idx] = 2
    dat = cbind(dat, cols)
    
    obj = gsub('_cmb.dat','',f.dat)
    idx = obj == objs
    if (sum(idx) != 1) stop(obj)
    period = par[idx,4]
    if (obj == 'aqpup') period = 30.15
    if (obj == 'sscma') period = 12.356
    OBJ = par[idx, 3]

    mjd = dat[,1]
    phase = (mjd / period) %% 1
    v = dat[,2]
    e = dat[,3]

    x = c(phase, phase+1)
    y = c(v,v)
    ye = c(e,e)
    ylim = c(max(y)+0.2, min(y)-0.2)
    plot(x, y, pch=19, ylim=ylim, xlim=c(0,2), cex=0.3, col=dat[,5])
    arrows(x, y+e, x, y-e, code=3, angle=90, length=0.0, col=dat[,5])


    lx = c(phase-1, phase, phase+1)
    ly = c(v,v,v)
    smt.spl = smooth.spline(lx, ly, df=50)
    nx = seq(0, 1, 0.01)
    ny = predict(smt.spl, nx)$y
    lines(nx, ny, col=3, lwd=2)

    py = predict(smt.spl, phase)$y
    residual = v - py
    idx.bad = residual > 0.3
    bad.exist = 0
    if (sum(idx.bad) > 0) {
        bad = dat[idx.bad,]
        god = dat[!idx.bad,]
        bad.exist = 1
    } else {
        god = dat
    }
    
    mjd = god[,1]
    phase = (mjd / period) %% 1
    v = god[,2]
    e = god[,3]

    x = c(phase, phase+1)
    y = c(v,v)
    ye = c(e,e)
    plot(x, y, pch=19, ylim=ylim, xlim=c(0,2), cex=0.3, col=god[,5])
    arrows(x, y+e, x, y-e, code=3, angle=90, length=0.0, col=god[,5])

    if (bad.exist == 1) {
        mjd = bad[,1]
        phase = (mjd / period) %% 1
        v = bad[,2]
        e = bad[,3]
        
        x = c(phase, phase+1)
        y = c(v,v)
        ye = c(e,e)
        points(x, y, pch=1, cex=0.3, col='grey')
        arrows(x, y+e, x, y-e, code=3, angle=90, length=0.0, col='grey')
    }


    mjd = god[,1]
    phase = (mjd / period) %% 1
    v = god[,2]
    e = god[,3]
    
    lx = c(phase-1, phase, phase+1)
    ly = c(v,v,v)
    smt.spl = smooth.spline(lx, ly, df=100)
    nx = seq(0, 1, 0.01)
    ny = predict(smt.spl, nx)$y
    lines(nx, ny, col=3, lwd=2)

    py = predict(smt.spl, phase)$y
    residual = v - py
    sd = sd(residual)

    mjd = dat[,1]
    phase = (mjd / period) %% 1
    v = dat[,2]
    e = dat[,3]
    py = predict(smt.spl, phase)$y
    residual = v - py
    idx = abs(residual) < sigma * sd

    godbad = rep(NA, nrow(dat))
    godbad[idx] = 1
    if (sum(!idx) > 0) godbad[!idx] = 2
    dat = cbind(dat, godbad)

    idx = dat[,'godbad'] == 1
    sub = dat[idx,]
    
    mjd = sub[,1]
    phase = (mjd / period) %% 1
    v = sub[,2]
    e = sub[,3]

    f.eps = paste0(figdir, obj, '_asas.eps')
    setEPS()
    postscript(f.eps, width=8, height=5)
    x = c(phase, phase+1)
    y = c(v,v)
    ye = c(e,e)
    ## ylim = c(max(y)+0.2, min(y)-0.2)
    xlab = 'Phase'
    ylab = 'V (mag)'
    plot(x, y, pch=19, ylim=ylim, xlim=c(0,2), cex=0.3, col=sub[,5], xlab=xlab, ylab=ylab, main=OBJ)
    arrows(x, y+e, x, y-e, code=3, angle=90, length=0.0, col=sub[,5])

    if (sum(!idx) > 0) {
        sub = dat[!idx,]
    
        mjd = sub[,1]
        phase = (mjd / period) %% 1
        v = sub[,2]
        e = sub[,3]
        
        x = c(phase, phase+1)
        y = c(v,v)
        ye = c(e,e)
        points(x, y, pch=19, cex=0.3, col='grey')
        arrows(x, y+e, x, y-e, code=3, angle=90, length=0.0, col='grey')
    }
    nx = c(nx, nx+1)
    ny = c(ny, ny)
    lines(nx, ny, col=3, lwd=1)

    f.out = paste0(dir, obj, '_labeled_asas_only.dat')
    write.table(dat, f.out, quote=F, row.names=F, col.names=T, sep = '   ')
    ## stop()
    ## Sys.sleep(2)
    dev.off()
}
