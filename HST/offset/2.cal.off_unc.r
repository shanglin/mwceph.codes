f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
par = read.table(f.par, stringsAsFactors=F)

dir = '~/Work/mega/mwceph/HST/offsets/'
f.out = paste0(dir, 'dm_wo_color_correction.dat')
ts = 'Name    #H_epochs   #F160W_epochs  ZP_offset   phase_correction_1   phase_correction_2   HST_phase'
write(ts, f.out)

figdir = '~/Work/mega/mwceph/HST/offsets/figs/'
lcdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.hst = paste0(dir,'hst4.dat')
hst = read.table(f.hst, skip=0, stringsAsFactors=F, header=T)

ids = tolower(hst[,1])
idx = nchar(ids) == 6
ids[idx] = gsub('-','',ids[idx])
ids = gsub('bet-dor','betad',ids)
ids = gsub('v0339-cen','vjcen',ids)
ids = gsub('v0340-ara','vjara',ids)
hst = cbind(hst, ids)
uids = unique(ids)

source('fitfuns/fun.fit.Inno15.r')
load.pars()
amp = 0.32

f.pdf = paste0(figdir, 'lcs_wo_color_correction.pdf')
pdf(f.pdf, width=8, height=6)
for (id in uids) {
    idx = par[,1] == id
    ts = par[idx,]
    idx = hst[,4] == id
    sub = hst[idx,]

    obj = sub[1,1]
    obj2 = ts[1, 3]
    period = ts[1, 4]
    t0 = ts[1, 5] - 2400000.5
    M = ts[1, 6]
    eM = ts[1, 7]
    L = ts[1, 8]
    eL = ts[1, 9]
    PHI = ts[1, 10]
    ePHI = ts[1, 11]
    zp.2mass = ts[1, 12]
    zp.nd4 = ts[1, 13]

    a0 = get.a0(period)
    phis = get.phis(period)
    amps = get.amps(period)

    ## f.slc = paste0(lcdir, obj2, '_crted.dat')
    f.slc = paste0(lcdir, id, '_n.clc')
    if (!file.exists(f.slc))  f.slc = paste0(lcdir, id, '_h.clc')
    if (!file.exists(f.slc)) stop(id)
    lc = read.table(f.slc)
    lc[,1] = lc[,1] + 2450000 - 2400000.5
    x = ((lc[,1]-t0)/period) %% 1
    y = lc[,2]
    e = lc[,3]
    x = c(x, x + 1)
    y = c(y, y)
    e = c(e, e)

    by = 1e-5
    lxc = seq(0, 1-by, by = by)
    lyc = calt(lxc, PHI, M, L, a0)
    
    xc = seq(0, 1, by = 1e-3)
    yc = calt(xc, PHI, M, L, a0)
    xc = c(xc, xc + 1)
    yc = c(yc, yc)

    xhst = ((sub[,2]-t0)/period) %% 1
    yhst = sub[,3]
    hst.phases = round(xhst,6)
    model.y = calt(xhst, PHI, M, L, a0)
    off = yhst - model.y
    xhst = c(xhst, xhst + 1)
    yhst = c(yhst, yhst)

    xlim = c(0,2)
    midmag = 0.5 * (max(yc) + min(yc))
    ylim = c(midmag + amp, midmag - amp)
    thiszp = mean(off)

    plot(xc, yc, xlab='Phase', ylab='H [mag]', xlim = xlim, ylim = ylim, type = 'l',
         main = obj, col = 'black', cex.axis = 1, xaxt = 'n')
    axis(1, at = seq(0,2,0.5), labels = c('0', '0.5', '1', '0.5', '1'))
    points(x, y, pch = 19, cex = 1)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)

    points(xhst, yhst-thiszp, col=2, pch=19)

    name = obj
    h.epochs = nrow(lc)
    f.epochs = nrow(sub)
    zp.offset = round(thiszp,4)
    phase.correction.1 = M - mean(model.y)
    phase.correction.2 = mean(lyc) - mean(model.y)
    phase.correction.1 = round(phase.correction.1, 4)
    phase.correction.2 = round(phase.correction.2, 4)
    hst.phases = paste(hst.phases, collapse=',')
    out = paste(name, h.epochs, f.epochs, zp.offset, phase.correction.1, phase.correction.2, hst.phases, sep='   ')
    out = sprintf('%-10s%7i%10i%16.4f%17.4f%22.4f       %-56s', name, h.epochs, f.epochs, zp.offset, phase.correction.1, phase.correction.2, hst.phases)
    write(out, f.out, append=T)
}
dev.off()

