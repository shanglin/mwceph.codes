### No outlier rejection at this time.

crocus2jd = 2400000 ## No .5 at the end
asas2jd = 2450000
ts2jd = 2400000  ## To avoid negative number or bad phase calculation
vid = 3
hid = 12

m70 = 2440587.5
m80 = 2444239.5
m90 = 2447892.5
    
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

    types = rep('NA', nrow(dat))
    idx = dat[,1] < m70
    if (sum(idx) > 0)
        types[idx] = 'b70'
    idx = dat[,1] > m70 & dat[,2] < m80
    if (sum(idx) > 0)
        types[idx] = '70s'
    idx = dat[,1] > m80 & dat[,2] < m90
    if (sum(idx) > 0)
        types[idx] = '80s'
    idx = dat[,1] > m90
    if (sum(idx) > 0)
        types[idx] = '90s'
    V5 = types
    dat = cbind(dat, V5)
    
    obj2 = obj
    obj2 = gsub('vjcen','v339cen',obj2)
    obj2 = gsub('vjara','v340ara',obj2)
    obj2 = gsub('-','',obj2)
    f.as = paste0(diras, obj2, '_cmb.dat')
    if (file.exists(f.as)) {
        as = read.table(f.as, skip=1)
        as[,1] = as[,1] + asas2jd
        V4 = rep(vid, nrow(as))
        V5 = as[,4]
        dat2 = cbind(as[,1:3],V4, V5)
        if (obj == 'hwcar')
            dat = dat2
        else 
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
    V5 = rep('this', nrow(clc))
    dat3 = cbind(dat3, V4, V5)
    dat = rbind(dat, dat3)

    
    dat[,1] = round(dat[,1] - crocus2jd,5)
    idx = order(dat[,1])
    dat = dat[idx,]
    
    f.out = paste0(dir, obj, '_g.dat')
    write.table(dat, f.out, append=F, col.names=F, row.names=F, sep='   ')

}
