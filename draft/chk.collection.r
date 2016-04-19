f.par = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
idx = order(par[,4])
par = par[idx,]
n.par = nrow(par)
par[,3] = as.character(par[,3])
par[,2] = as.character(par[,2])
par[,1] = as.character(par[,1])

n.par = nrow(par)
t.min = t.max = rep(NA, n.par)
n.msr = rep(NA, n.par)

for (i in 1:n.par) {
    obj = par[i,1]
    f.ipt = paste0('~/Work/mega/mwceph/period_search/inputs_it1/',obj,'.ipt')
    if (!file.exists(f.ipt))
        f.ipt = paste0('~/Work/mega/mwceph/pphot/period_all/model_per/inputs_it1/',obj,'.ipt')
    if (!file.exists(f.ipt))
        stop(obj)
    ipt = read.table(f.ipt, skip=1)
    n.msr[i] = nrow(ipt)
    t.min[i] = min(ipt[,1])
    t.max[i] = max(ipt[,1])
}

dat = as.data.frame(cbind(par[,1],n.msr,t.min,t.max))
dat[,2] = as.numeric(as.character(dat[,2]))
dat[,3] = as.numeric(as.character(dat[,3]))
dat[,4] = as.numeric(as.character(dat[,4]))
