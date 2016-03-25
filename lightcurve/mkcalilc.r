
dir.base = '~/Work/mega/mwceph/lightcurve/20160303/'
raw.dir = paste0(dir.base, 'rawlcs/')
cal.dir = paste0(dir.base, 'calilcs/')
qua.dir = paste0(dir.base, 'quality/')
zp.dir = paste0(dir.base, 'zeropoints/')
nd4.dir = paste0(dir.base, 'calnd4/')

f.qua = paste0(qua.dir, 'quality.csv')
f.tim = paste0(zp.dir, 'exposure_time.dat')
f.mas = paste0(zp.dir, 'zp_2mass.dat')
f.nd4 = paste0(nd4.dir, 'nd4factor.dat')

qua = read.table(f.qua, sep=',', skip=1)
tim = read.table(f.tim)
mas = read.table(f.mas)
nd4 = read.table(f.nd4)

n.obj = nrow(qua)
for (i in 1:n.obj) {
    use = qua[i, 5]
    id = qua[i, 1]
    zp.mas = mas[mas[,1] == id, 2]
    if (use == 'H') {
        f.rlc = paste0(raw.dir, id, '_h.rlc')
        f.clc = paste0(cal.dir, id, '_h.clc')
        zp.tim = 0
        zp.nd4 = 0
    } else if (use == 'N') {
        f.rlc = paste0(raw.dir, id, '_n.rlc')
        f.clc = paste0(cal.dir, id, '_n.clc')
        idx = tim[,1] == id
        if (tim[idx, 3] == -1) stop(paste0(id,': exposure time not found.'))
        zp.tim = 2.5 * log10(tim[idx,3] / tim[idx,2])
        zp.nd4 = nd4[1,1]
    } else {
        next
    }
    rlc = read.table(f.rlc)
    clc = rlc
    clc[,2] = rlc[,2] - zp.mas + zp.tim - zp.nd4
    clc[,2] = round(clc[,2], 3)
    write.table(clc, f.clc, row.names=F, col.names=F, sep='   ')
}

f.par = paste0(cal.dir,'mw_ceph_pars.dat')
ts = '#  ID    alias     object     period     t_ref      M        eM       L        eL      PHI      ePHI  ezp_2mass  ezp_nd4'
write(ts, f.par)
f.cat = '~/Work/mega/mwceph/pphot/mw_new_info.dat'
cat = read.table(f.cat, header=T)
cat[,'alias'] = as.character(cat[,'alias'])
cat[,'obj'] = as.character(cat[,'obj'])
source('fitfuns/fun.fit.Inno15.r')
load.pars()

fs.clc = list.files(cal.dir, pattern = '.*.clc$')
nfs.clc = length(fs.clc)
for (i in 1:nfs.clc) {
    f.clc = fs.clc[i]
    lf.clc = paste0(cal.dir, f.clc)
    clc = read.table(lf.clc)
    t = clc[,1]
    m = clc[,2]
    e = clc[,3]
    id = gsub('_h.clc','',f.clc)
    id = gsub('_n.clc','',id)
    alias = toupper(id)
    alias = gsub('-','',alias)
    alias = gsub('LCARL','LCAR', alias)
    object = cat[cat[,'alias'] == alias, 'obj']
    ezp.mas = mas[mas[,1] == id, 3]
    use = qua[qua[,1] == id, 5]
    if (use == 'N') {
        ezp.nd4 = nd4[1,2]
    } else {
        ezp.nd4 = 0
    }
    period = cat[cat[,'alias'] == alias, 'period']
    t0 = round(median(t))
    phase = ((t - t0) / period) %% 1
    pars = fit.Inno15(phase, m, e)
    M = round(pars[1],4)
    L = round(pars[2],4)
    PHI = round(pars[3],4)
    eM = round(pars[4],4)
    eL = round(pars[5],4)
    ePHI = round(pars[6],4)

    x = c(phase, phase + 1)
    y = c(m, m)
    e = c(e, e)
    xc = seq(0, 1, by = 0.001)
    yc = calt(xc, PHI, M, L, a0)
    xc = c(xc, xc + 1)
    yc = c(yc, yc)
    amp = 0.3
    ylim = c(mean(yc)+amp, mean(yc)-amp)
    xlim = c(0,2)
    plot(xc, yc, type='l', xlim=xlim, ylim=ylim, xlab='Phase', ylab='H (mag)')
    points(x, y, pch=19)
    arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)
    ## ts = paste(alias, object, period, t0, M, eM, L, eL, PHI, ePHI, ezp.mas, ezp.nd4, sep='   ')
    ts = sprintf('%7s%7s%13s%11.6f%10i%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f',
        id, alias, object, period, t0+2450000, M, eM, L, eL, PHI, ePHI, ezp.mas, ezp.nd4)
    write(ts, f.par, append = T)
    print(object)
}
