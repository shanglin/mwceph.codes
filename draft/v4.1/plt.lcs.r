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

f.eps = paste0(odir,'lcs.eps')
setEPS()
postscript(f.eps, width=width, height=height)

par(mfrow = c(n.row,n.col),mar = c(1,2,0,1)*0.4, tcl = 0.5, tck = 0.05, mgp = c(0,0.2,0), oma = c(3,3,1,1))
n.part1 = n.col * n.row
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
    xc = seq(0, 1, by = 0.001)
    yc = calt(xc, PHI - dphi, M, L, a0)
    dy = 0.5 * (max(yc) + min(yc))
    dy = 0
    yc = yc - dy
    xc = c(xc, xc + 1)
    yc = c(yc, yc)

    dt = dphi * period
    x = ((lc[,1]-t0+dt)/period) %% 1
    y = lc[,2] - dy
    e = lc[,3]
    x = c(x, x + 1)
    y = c(y, y)
    e = c(e, e)

    xlim = c(0,2)
    midmag = 0.5 * (max(yc) + min(yc))
    ## midmag = 0
    ylim = c(midmag + amp, midmag - amp)
    obj = paste0(substr(obj,0,nchar(obj)-2), tolower(substr(obj,nchar(obj)-1,nchar(obj))))
    obj = gsub('V0','V',obj)
    if (id == 'lcarl') obj = 'l-Car'
    if (id == 'betad') obj = expression(paste(beta,'-DOR'))
    main = ''
    plot(xc, yc, xlab='', ylab='', xlim = xlim, ylim = ylim, type = 'l',
         main = main, font.main = 1, cex.main = 0.9, col = 'black',
         cex.axis = 0.7, xaxt = 'n')
    if (i >= 30)
        axis(1, at = seq(0,2,0.5), labels = c('0', '0.5', '1', '1.5', '2'))
    else
        axis(1, at = seq(0,2,0.5), labels = rep('',5))
    points(x, y, pch = 19, cex = 0.9)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)
    x.t = 1.6
    y.t = midmag+amp*0.89
    idx = which.min(yc)
    x.t = xc[idx]
    x.t = x.t[1]
    if (x.t < 0.7) x.t = x.t + 1
    objb = gsub('-',' ',obj)
    if (id == 'betad') objb = expression(paste(italic(beta),' Dor'))
    if (id == 'sscma') objb = 'SS CMa'
    text(0.05, midmag-0.24, objb, col=1, adj=0)

    ######## plot outliers
    f.wot = paste0(wdir, id, '_h.wclc')
    if (!file.exists(f.wot))
        f.wot = paste0(wdir, id, '_n.wclc')
    wot = read.table(f.wot)
    widx = !(wot[,1] %in% lc[,1])
    if (sum(widx) > 0) {
        x = ((wot[widx,1]-t0+dt)/period) %% 1
        y = wot[widx,2] - dy
        e = wot[widx,3]
        x = c(x, x + 1)
        y = c(y, y)
        e = c(e, e)
        points(x, y, cex=0.9, col='grey')
        arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90, col='grey')
    }
}

par(mfrow = c(1,1), new = T, oma = c(0,0,0,0), mar = c(1,1,1,1)*1.5)
## ylab = expression(paste(Delta, italic(H), ' [mag]'))
ylab = expression(paste(italic(H), ' [mag]'))
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
