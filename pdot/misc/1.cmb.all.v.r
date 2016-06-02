crocus2jd = 2400000 ## No .5 at the end
asas2jd = 2450000
ts2jd = 2400000  ## To avoid negative number or bad phase calculation
vid = 3

dir = '~/Work/mega/mwceph/pdot/bvobs/'
dirold = '~/Work/mega/mwceph/period_search/inputs_it3/'
dirold2 = '~/Work/mega/mwceph/pphot/period_all/model_per/inputs_it3/'
diras = '~/Work/mega/mwceph/asas_related/cmb_data/'
figdir = '~/Work/mega/mwceph/pdot/figs/'

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
    dat[,1] = dat[,1] - crocus2jd
    
    idx = dat[,4] == 3
    sub = dat[idx,]

    ## phase = (sub[,1] / period) %% 1
    ## ylim = rev(range(sub[,2]))
    ## x = c(phase-1, phase, phase+1)
    ## y = c(sub[,2], sub[,2], sub[,2])
    ## plot(x, y, pch=19, cex=0.5, ylim=ylim)

    ## spl = smooth.spline(x,y)
    ## nx = seq(0, 1, 0.001)
    ## ny = predict(spl, nx)$y
    ## lines(nx, ny, col=2, lwd=3)

    sub[,1] = round(sub[,1],5)
    f.out = paste0(dir, obj, '_v.dat')
    write.table(sub, f.out, col.names=F, row.names=F)

    
    idx = dat[,4] == 2
    sub = dat[idx,]
    sub[,1] = round(sub[,1],5)
    f.out = paste0(dir, obj, '_b.dat')
    write.table(sub, f.out, col.names=F, row.names=F)

}
