## zero points:
##     nd4 factor for N light curves
##     exposure time differences for N light curves
##     2MASS zero points for all the light curves


dir.base = '~/Work/mega/mwceph/lightcurve/20160604/'
zp.dir = paste0(dir.base, 'zeropoints/')
cmd = paste0('mkdir -p ', zp.dir)
system(cmd)
exp.dir = paste0(zp.dir, 'exp.tmp/')
cmd = paste0('mkdir -p ', exp.dir)
system(cmd)

## (1) Load ND4 factor
dir = paste0(dir.base,'calnd4/')
f.dat = paste0(dir.base,'calnd4/nd4factor.dat')
dat = read.table(f.dat)
nd4.factor = dat[1,1]
nd4.error = dat[1,2]

##  (2) Make the exposure times 
f.csv = '~/Work/mega/mwceph/lightcurve/20160604/quality/quality.csv'
csv = read.table(f.csv, sep=',', skip=1)
n.csv = nrow(csv)
dir.1 = '~/Work/mega/mwceph/pphot/'
dir.2 = '~/Work/mega/mwceph/pphot_bf_2016_02_16/'
f.tim = paste0(zp.dir, 'exposure_time.dat')
ts = '# id        H_time        N_time'
write(ts, f.tim)
for (i in 1:n.csv) {
    id = csv[i,1]
    dir = paste0(dir.1, id, '/')
    if (!file.exists(dir)) {
        dir = paste0(dir.2, id, '/')
    }
    h.dir = paste0(dir, 'photh/')
    if (id == 'lcarl')
        h.dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/', 'photl/')
    if (id == 'lcarr')
        h.dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/', 'photr/')
    fs.fits = list.files(h.dir, pattern = '^h....n.....fits$')
    nfs.fits = length(fs.fits)
    f.exp = paste0(exp.dir, id, '_h.exp')
    for (j in 1:nfs.fits) {
        f.fits = fs.fits[j]
        if (j == 1) {
            cmd = paste0('imhead ', h.dir, f.fits, ' | grep EXPTIME > ', f.exp)
        } else {
            cmd = paste0('imhead ', h.dir, f.fits, ' | grep EXPTIME >> ', f.exp)
        }
        system(cmd)
    }
    h.exp = median(read.table(f.exp)[,3])
    if (csv[i, 3] != '0') {
        n.dir = paste0(dir, 'photn/')
        if (id == 'lcarl')
            n.dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/', 'photnl/')
        if (id == 'lcarr')
            n.dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/', 'photnr/')
        fs.fits = list.files(n.dir, pattern = '^n....n.....fits$')
        nfs.fits = length(fs.fits)
        f.exp = paste0(exp.dir, id, '_n.exp')
        for (j in 1:nfs.fits) {
            f.fits = fs.fits[j]
            if (j == 1) {
                cmd = paste0('imhead ', n.dir, f.fits, ' | grep EXPTIME > ', f.exp)
            } else {
                cmd = paste0('imhead ', n.dir, f.fits, ' | grep EXPTIME >> ', f.exp)
            }
            system(cmd)
        }
        n.exp = median(read.table(f.exp)[,3])
    } else {
        n.exp = -1
    }
    ts = paste(id, h.exp, n.exp, sep='   ')
    write(ts, f.tim, append = T)
}

## (3) Make the 2MASS offsets
f.2mass = paste0(zp.dir, 'zp_2mass.dat')
ts = '# id     dH      err'
write(ts, f.2mass)
for (i in 1:n.csv) {
    id = csv[i,1]
    dir = paste0(dir.1, id, '/')
    if (!file.exists(dir)) {
        dir = paste0(dir.2, id, '/')
    }
    mass.dir = paste0(dir, '2mass/')
    if (id == 'lcarl')
        mass.dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/', '2massl/')
    if (id == 'lcarr')
        mass.dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/', '2massr/')
    f.txt = paste0(mass.dir, 'dh_aper-2mass.txt')
    txt = read.table(f.txt)
    zp.2mass = txt[1,1]
    err.2mass = txt[1,2]
    ts = paste(id, zp.2mass, err.2mass, sep = '   ')
    write(ts, f.2mass, append = T)
}
