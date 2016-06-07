source('fitfuns/fun.fit.Inno15.r')
load.pars()

wdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs_w_out/'
odir = '~/Work/mega/mwceph/draft/v4.1/figures/'
dir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.dat = paste0(dir, 'mw_ceph_pars.dat')
dat = read.table(f.dat)
dat = dat[order(dat[,4]),]
dat[,1] = as.character(dat[,1])
dat[,2] = as.character(dat[,2])
dat[,3] = as.character(dat[,3])

## update the last few lines of this script if the parameter changes
amp = 0.275
n.row = 7
n.col = 5
width = 8.27
height = width * n.row / n.col * 0.618

f.res = '~/Work/mega/mwceph/phase_corr/20160606/model_residuals.dat'
ts = '#    id        residual'
write(ts, f.res)

f.eps = paste0(odir,'extra.lc.residual.eps')
setEPS()
postscript(f.eps, width=width, height=height)

par(mfrow = c(n.row,n.col),mar = c(1,2,0,1)*0.4, tcl = 0.5, tck = 0.05, mgp = c(0,0.2,0), oma = c(3,3,1,1))
n.part1 = n.col * n.row
allresiduals = c()
for (i in 1:nrow(dat)) {
    if (i == 5) plot(1, type='n', axes=F, xlab='', ylab='')
    id = dat[i, 1]
    obj = dat[i, 3]
    period = dat[i, 4]
    t0 = dat[i, 5] - 2450000
    M = dat[i, 6]
    eM = dat[i, 7]
    L = dat[i, 8]
    eL = dat[i, 9]
    PHI = dat[i, 10]
    ePHI = dat[i, 11]
    a0 = get.a0(period)
    phis = get.phis(period)
    amps = get.amps(period)
    
    f.lc = paste0(dir, id, '_h.clc')
    if (!file.exists(f.lc))
        f.lc = paste0(dir, id, '_n.clc')
    lc = read.table(f.lc)

    dphi = PHI - 0.5

    dt = dphi * period
    x = ((lc[,1]-t0+dt)/period) %% 1
    y = lc[,2]
    e = lc[,3]

    xmodel = x
    ymodel = calt(xmodel, PHI - dphi, M, L, a0)
    residuals = y - ymodel
    allresiduals = c(allresiduals, residuals)

    for (residual in residuals) {
        ts = paste(id, round(residual,5), sep='   ')
        write(ts, f.res, append=T)
    }
    
    xlim = c(0,1)
    ylim = c(-1, 1) * -0.15
    obj = paste0(substr(obj,0,nchar(obj)-2), tolower(substr(obj,nchar(obj)-1,nchar(obj))))
    obj = gsub('V0','V',obj)
    if (id == 'lcarl') obj = 'l-Car'
    if (id == 'betad') obj = expression(paste(beta,'-DOR'))
    main = ''
    plot(x, residuals, xlab='', ylab='', xlim = xlim, ylim = ylim,
         main = main, font.main = 1, cex.main = 0.9, col = 'black',
         cex.axis = 0.7, xaxt = 'n', pch=19, yaxt = 'n')
    if (i >= 30)
        axis(1, at = seq(0,1,0.5), labels = c('0', '0.5', '1'))
    else
        axis(1, at = seq(0,1,0.5), labels = rep('',3))

    if (i %in% c(1,5,10,15,20,25,30))
        axis(2, at = seq(-0.1,0.1,0.1), labels = c('-0.1', '0', '0.1'))
    else
        axis(2, at = seq(-0.1,0.1,0.1), labels = rep('',3))

    
    arrows(x, residuals-e, x, residuals+e, code=3, length=0.01, angle=90)
    x.t = 1.6
    y.t = amp*0.89
    if (x.t < 0.7) x.t = x.t + 1
    objb = gsub('-',' ',obj)
    if (id == 'betad') objb = expression(paste(italic(beta),' Dor'))
    if (id == 'sscma') objb = 'SS CMa'
    text(0.025, -0.13, objb, col=1, adj=0)

    ######## plot outliers
    f.wot = paste0(wdir, id, '_h.wclc')
    if (!file.exists(f.wot))
        f.wot = paste0(wdir, id, '_n.wclc')
    wot = read.table(f.wot)
    widx = !(wot[,1] %in% lc[,1])
    if (sum(widx) > 0) {
        x = ((wot[widx,1]-t0+dt)/period) %% 1
        y = wot[widx,2]
        e = wot[widx,3]
        xmodel = x
        ymodel = calt(xmodel, PHI - dphi, M, L, a0)
        residuals = y - ymodel
        points(x, residuals, cex=0.9, col='grey')
        arrows(x, residuals-e, x, residuals+e, code=3, length=0.01, angle=90, col='grey')
    }
}

par(mfrow = c(1,1), new = T, oma = c(0,0,0,0), mar = c(1,1,1,1)*1.5)
## ylab = expression(paste(Delta, italic(H), ' [mag]'))
ylab = expression(paste(Delta, italic(H), ' [mag]'))
plot(1,1, type='n', xlab='Phase', ylab=ylab, axes = F)

dev.off()

con = file(f.eps, 'r')
eps = readLines(con)
close(con)
idx = which(grepl('l Car', eps))
neps = eps[1:(idx+2)]
neps[idx] = gsub('l Car','  Car',neps[idx])
neps[idx+1] = '/Palatino-Italic findfont 8 s'
x.image = as.numeric(substr(neps[idx],1,6))+2.5
y.image = as.numeric(substr(neps[idx],7,12))
neps[idx+2] = paste(x.image, y.image, '(l) 1 0 t')
neps = c(neps, eps[(idx+1):length(eps)])
write(neps, f.eps)


f.eps = paste0(odir,'extra.hist.residual.eps')
setEPS()
postscript(f.eps, width=width, height=height)
xlim = c(-1,1)*0.12
par(tck = -0.02)
hist(allresiduals, breaks=20, xlab=ylab, col='skyblue', main='', xlim=xlim, xaxt='n')
par(tck = -0.01)
at = seq(xlim[1],xlim[2],0.01)
axis(1, at = at, labels = rep('',length(at)))
par(tck = -0.02)
at = seq(-0.1,0.1,0.05)
axis(1, at = at, labels = at)
t1 = expression(paste(sigma, '(', Delta, italic(H), ') = ', 0.024, ' mag'))
text(xlim[1], 50, t1, cex=1.3, adj=0)
dev.off()
