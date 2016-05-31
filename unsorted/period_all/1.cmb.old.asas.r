crocus2jd = 2400000 ## No .5 at the end
asas2jd = 2450000
ts2jd = 2400000  ## To avoid negative number or bad phase calculation
vid = 3
hid = 12
cal1980 = 2444239.5
cal1990 = 2447892.5
    
dir = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/inputs_it1/'
dirold = '~/Work/m33/16summer/mwupdt/periods_all/period_search/inputs_it3/'
dirold2 = '~/Work/m33/16summer/mwupdt/periods_all/model_per/inputs_it3/'
diras = '~/Work/m33/16summer/mwupdt/cmb_data/'
figdir = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/figs/'
hdir = '~/Work/m33/16summer/mwupdt/periods_all/calilcs/'

f.per = paste0(dir, 'objper_it1.lst')
per = read.table(f.per)
per[,1] = as.character(per[,1])
nper = nrow(per)

f.par = paste0(hdir, 'mw_ceph_pars.dat')
par = read.table(f.par)
for (ifoo in 1:3) par[,ifoo] = as.character(par[,ifoo])

f.eps = paste0(figdir, 'jd_1980.eps')
setEPS()
postscript(f.eps, width=9, height=7)
par(mfrow=c(5,7), mar=c(3,3,1,0))
for (i in 1:nper) {
    obj = per[i,1]
    period = per[i,2]
    f.ipt = paste0(dirold, obj, '.ipt')
    if (!file.exists(f.ipt)) {
        f.ipt = paste0(dirold2, obj, '.ipt')
    }
    if (!file.exists(f.ipt)) stop(obj)
    ipt = read.table(f.ipt, skip=1)
    ipt[,1] = ipt[,1] + crocus2jd
    dat = ipt
    obj2 = obj
    obj2 = gsub('vjcen','v339cen',obj2)
    obj2 = gsub('vjara','v340ara',obj2)
    obj2 = gsub('-','',obj2)
    f.as = paste0(diras, obj2, '_labeled_asas_only.dat')
    if (file.exists(f.as)) {
        as = read.table(f.as, skip=1)
        as[,1] = as[,1] + asas2jd
        as = as[as[,6]==1,]
        V4 = rep(vid, nrow(as))
        dat2 = cbind(as[,1:3],V4)
        dat = rbind(dat, dat2)
    }
    jds = dat[,1] - cal1980
    main = obj
    main = gsub('lcarl','l-car', main)
    hist(jds, main=main, xlab='', ylab='', breaks=30, col='skyblue')
    if (file.exists(f.as))
        abline(v = 0, col=2)
    ## stop()

    f.clc = paste0(hdir, obj, '_h.clc')
    if (!file.exists(f.clc)) f.clc = paste0(hdir, obj, '_n.clc')
    if (!file.exists(f.clc)) stop(f.clc)
    clc = read.table(f.clc)
    clc[,1] = clc[,1] + 2450000
    idx = par[,1] == obj
    if (sum(idx) != 1) stop(f.clc)
    e2 = par[idx, 12]
    e3 = par[idx, 13]
    eall = sqrt(clc[,3]^2 + e2^2 + e3^2)
    dat3 = clc
    V4 = rep(hid, nrow(clc))
    dat3 = cbind(dat3, V4)
    dat = rbind(dat, dat3)
    
    mdat = dat
    if (file.exists(f.as)) {
        idx = mdat[,1] - cal1980 > 0
    } else {
        idx = mdat[,1] != -1e19
    }
    mdat = mdat[idx,]
    mdat[,1] = round(mdat[,1] - ts2jd, 5)
    idx = order(mdat[,1])
    mdat = mdat[idx,]

    f.out = paste0(dir, obj, '.ipt')
    ts = paste(nrow(mdat), period, 0, sep='   ')
    write(ts, f.out)
    write.table(mdat, f.out, append=T, col.names=F, row.names=F, sep='   ')
}
dev.off()
