dt = 2 / 24 ## merge to one epoch for observations within 2 hours

dir = '~/Work/mega/mwceph/phase_corr/20160609/'
lcdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
par = read.table(f.par, stringsAsFactors = F)
f.sel = paste0(dir, 'obj_hst_jd.dat')
sel = read.table(f.sel, stringsAsFactors = F)

npar = nrow(par)
### Group observations based on time
for (i in 1:npar) {
    id = par[i,1]
    idx = sel[,1] == id
    sub = sel[idx,]
    idx = order(sub[,3])
    sub = sub[idx,]
    grp = rep(NA, nrow(sub))
    grp[1] = 1
    icount = 2
    if (nrow(sub) > 1) {
        idx = abs(sub[1,3] - sub[,3]) < dt
        grp[idx] = 1
        for (k in 2:nrow(sub)) {
            if (is.na(grp[k])) {
                grp[k] = icount
                idx = abs(sub[k,3] - sub[,3]) < dt
                grp[idx] = icount
                icount = icount + 1
            }
        }
    }
    sub = cbind(sub, grp)
    if (i == 1) all = sub else all = rbind(all, sub)
}


### Merge & derive phase
f.out = paste0(dir, 'phase_ncyc.dat')
ts = '#    ID     HST_identification    phase   JD-2450000     Ncycle'
write(ts, f.out)
for (i in 1:npar) {
    id = par[i,1]
    tref = par[i,5] - 2450000
    period = par[i,4]

    f.lc = paste0(lcdir, id, '_h.clc')
    if (!file.exists(f.lc)) f.lc = paste0(lcdir, id, '_n.clc')
    if (!file.exists(f.lc)) stop(obj)
    lc = read.table(f.lc)
    tmax = max(lc[,1])
    tmin = min(lc[,1])
    
    idx = all[,1] == id
    sub = all[idx,]
    grps = unique(sub[,4])
    for (grp in grps) {
        idx = sub[,4] == grp
        ssub = sub[idx,]
        mmjd = mean(ssub[,3])
        phase = ((mmjd - tref) / period) %% 1
        ncyc = 0
        if (mmjd < tmin)
            ncyc = (mmjd - tmin) / period
        else if (mmjd > tmax)
            ncyc = (mmjd - tmax) / period
        ts = sprintf('%10s%15s%15.7f%15.5f%15.7f',id, ssub[1,2], phase, mmjd, ncyc)
        write(ts, f.out, append=T)
    }
}

