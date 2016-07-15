f.hst = '~/Work/mega/mwceph/HST/offsets/hst4.dat'
hst = read.table(f.hst, skip=1, stringsAsFactors=F)
## hst = hst[,c(3,2,6)]
hst[,2] = hst[,2] + 0.5 - 50000
idx = substr(hst[,1],4,9) == 'AQ-CAR'
hst[idx,1] = 'aqcar'
idx = substr(hst[,1],4,9) == 'AQ-PUP'
hst[idx,1] = 'aqpup'
idx = substr(hst[,1],4,9) == 'HW-CAR'
hst[idx,1] = 'hwcar'
idx = substr(hst[,1],4,9) == 'XY-CAR'
hst[idx,1] = 'xycar'
hst[,1] = tolower(hst[,1])
hst[,1] = gsub('-','',hst[,1])


source('fitfuns/fun.fit.Inno15.r')
load.pars()
amp = 0.27
width = 8.27
golden.ratio = 1.61803398875
height = 5
width  = height * golden.ratio

f.eps = '~/Desktop/lc_hst_updated.eps'
setEPS()
postscript(f.eps, height = height, width = width)
## pdf('~/Desktop/lc_hst.pdf', width=width, height=height)
par(mar=c(5,5,2,2))
dir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.par = paste0(dir, 'mw_ceph_pars.dat')
par = read.table(f.par, stringsAsFactors=F)

ids = unique(hst[,1])
ids = 'xycar'
for (id in ids) {
    idx = par[,1] == id
    ts = par[idx,]
    idx = hst[,1] == id
    sub = hst[idx,]
    f.slc = paste0(dir, id, '_h.clc')
    if (!file.exists(f.slc))
        f.slc = paste0(dir, id, '_n.clc')
    if (!file.exists(f.slc)) stop(id)
    lc = read.table(f.slc)
    
    obj = ts[1, 3]
    period = ts[1, 4]
    t0 = ts[1, 5] - 2450000
    M = ts[1, 6]
    eM = ts[1, 7]
    L = ts[1, 8]
    eL = ts[1, 9]
    PHI = ts[1, 10]
    ePHI = ts[1, 11]
    a0 = get.a0(period)
    phis = get.phis(period)
    amps = get.amps(period)

 
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
    zp = mean(yhst - model.y)
    
    xhst = c(xhst, xhst + 1)
    yhst = c(yhst, yhst) - zp
    
    
    xlim = c(0,2)
    midmag = 0.5 * (max(yc) + min(yc))
    ylim = c(midmag + amp, midmag - amp)
    main = sprintf('%11s%7s%6.3f%4s',obj,'     ZP =',zp,' mag')
    main = gsub('V0', 'V', main)
    main = ''
    if (id == 'betad') main = expression(paste(beta,'-DOR      ','     P = 9.842922'))
    if (id == 'lcarl') main = sprintf('%11s%7s%10.6f','l-CAR','     P =',period)
    ylab = expression(paste(italic(H),' [mag]'))
    plot(xc, yc, xlab='Phase', ylab=ylab, xlim = xlim, ylim = ylim, type = 'l',
         main = main, font.main = 1, cex.main = 0.9, col = 'black',
         cex.axis = 1.3, xaxt = 'n', cex.lab=1.5)
    axis(1, at = seq(0,2,0.5), labels = c('0', '0.5', '1', '1.5', '2'))
    points(x, y, pch = 19, cex = 1)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)

    points(xhst, yhst, col=2, pch=19)

    
}

dev.off()
