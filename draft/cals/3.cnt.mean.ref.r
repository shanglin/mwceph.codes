f.dat = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
dat = read.table(f.dat)
dat[,1] = as.character(dat[,1])
n = nrow(dat)

nps = c()
for (i in 1:n) {
    id = dat[i,1]
    dir = paste0('~/Work/mega/mwceph/pphot/',id,'/photh/')
    f.ulc = paste0(dir,id,'.ulc')
    if (id == 'lcarl')
        f.ulc = '~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/photl/l-car.ulc'
    if (!file.exists(f.ulc)) {
        dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/',id,'/photh/')
        f.ulc = paste0(dir,id,'.ulc')
        if (!file.exists(f.ulc)) stop(id)
    }
    ulc = read.table(f.ulc, header=T)
    ulc = ulc[ulc[,'flag']==0,]
    nps = c(nps, ulc[,6]+1)
}
print(mean(nps))
