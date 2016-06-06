dir.base = '~/Work/mega/mwceph/lightcurve/20160604/'
raw.dir = paste0(dir.base, 'rawlcs_w_out/')
cal.dir = paste0(dir.base, 'calilcs_w_out/')
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
        f.rlc = paste0(raw.dir, id, '_h.wlc')
        f.clc = paste0(cal.dir, id, '_h.wclc')
        zp.tim = 0
        zp.nd4 = 0
    } else if (use == 'N') {
        f.rlc = paste0(raw.dir, id, '_n.wlc')
        f.clc = paste0(cal.dir, id, '_n.wclc')
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
