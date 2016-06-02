crocus2jd = 2400000 ## No .5 at the end
asas2jd = 2450000
ts2jd = 2400000  ## To avoid negative number or bad phase calculation
vid = 3
hid = 12
    
dir = '~/Work/mega/mwceph/pdot/allobs/'
dirold = '~/Work/mega/mwceph/period_search/inputs_it3/'
dirold2 = '~/Work/mega/mwceph/pphot/period_all/model_per/inputs_it3/'
diras = '~/Work/mega/mwceph/asas_related/cmb_data/'
figdir = '~/Work/mega/mwceph/pdot/figs/'
hdir = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/'

f.par = paste0('~/Work/mega/mwceph/lightcurve/20160527/calilcs/', 'mw_ceph_pars.dat')
par = read.table(f.par)
for (ifoo in 1:3) par[,ifoo] = as.character(par[,ifoo])
nper = nrow(par)

for (i in 1:nper) {
    obj = par[i,1]
    period = par[i,4]
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

    
    dat[,1] = round(dat[,1] - crocus2jd,5)
    idx = order(dat[,1])
    dat = dat[idx,]
    
    f.out = paste0(dir, obj, '.dat')
    write.table(dat, f.out, append=F, col.names=F, row.names=F, sep='   ')

}
