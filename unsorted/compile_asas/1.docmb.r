library(FITSio)
bary2jd = 2451544.5


dir1 = '~/Work/m33/16summer/mwupdt/asas_download/'
dir2 = '~/Work/m33/16summer/mwupdt/iomc/'
dir3 = '~/Work/m33/16summer/mwupdt/asas/'
outdir = '~/Work/m33/16summer/mwupdt/'

f.cat = paste0(dir2, 'compact_cat.tmp')
cat = read.table(f.cat, header=T, colClasses=c('character','character','numeric'))


fs.dat = list.files(dir1, pattern='.*.dat$')
nfs = length(fs.dat)

for (i in 1:nfs) {
    f.dat = fs.dat[i]
    lf.dat = paste0(dir1, f.dat)
    dat = read.table(lf.dat)
    idx = dat[,12] == 'A'
    dat = dat[idx,]
    ## hjd = dat[,1]
    ## m = dat[,3]
    ## em = dat[,8]
    type = rep('asas_old', nrow(dat))

    obj = gsub('.dat','',f.dat)
    f.out = paste0(outdir, obj, '_cmb.dat')
    out = cbind(dat[,c(1,3,8)], type)
    write.table(out, f.out, quote=F, sep='   ', col.names=F, row.names=F)

    ID = toupper(obj)
    n = nchar(ID)
    ID = paste0(substr(ID,1,n-3), '_', substr(ID, n-2, n))
    f.lc = paste0(dir3, ID, '.lc')
    if (file.exists(f.lc)) {
        lc = read.table(f.lc)
        idx = lc[,12] == 'A'
        lc = lc[idx,]
        type = rep('asas_new', nrow(lc))
        out = cbind(lc[,c(1,3,8)], type)
        write.table(out, f.out, quote=F, sep='   ', col.names=F, row.names=F, append=T)
    }

    idx = obj == cat[,1]
    if (sum(idx) == 1) {
        iid = cat[idx,2]
        f.fits = paste0(dir2, 'IOMC_', iid, '.fits')
        dat = readFITS(f.fits)
        jd = dat$col[[which(dat$colNames == 'BARYTIME')]] + bary2jd
        v = dat$col[[which(dat$colNames == 'MAG_V')]]
        ev = dat$col[[which(dat$colNames == 'ERRMAG_V')]]
        exptime = dat$col[[which(dat$colNames == 'EXPOSURE')]]
        flag = dat$col[[which(dat$colNames == 'PROBLEMS')]]
        idx = which(flag == 0)
        jd = jd[idx]
        v = v[idx]
        ev = ev[idx]
        mjd = jd - 2450000
        mjd = round(mjd,5)
        v = round(v, 3)
        ev = round(ev, 3)
        out = as.data.frame(cbind(mjd, v, ev))
        type = rep('iomc', length(v))
        out = cbind(out, type)
        write.table(out, f.out, quote=F, sep='   ', col.names=F, row.names=F, append=T)
    }
}
