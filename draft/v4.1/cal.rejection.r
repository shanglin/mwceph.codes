dir1 = '~/Work/mega/mwceph/pphot/'
dir2 = '~/Work/mega/mwceph/pphot_bf_2016_02_16/'
f.par = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
for (i in 1:3) par[,i] = as.character(par[,i])
idx = par[,13] == 0
par = par[idx,]
n = nrow(par)
nall = 0
nrej = 0
for (i in 1:n) {
    obj = par[i,1]
    f.dat = paste0(dir1,obj,'/photh/',obj,'_hlc.dat')
    if (!file.exists(f.dat)) f.dat = paste0(dir2,obj,'/photh/',obj,'_hlc.dat')
    if (!file.exists(f.dat)) stop(obj)
    dat = read.table(f.dat, header=T)
    idx = dat[, 'flag'] > 0
    nall = nall + nrow(dat)
    nrej = nrej + sum(idx)
}
rej = 100*nrej/nall
msg = paste0('In epoch-to-epoch offset, rejected ',round(rej,2),'% images')
print(msg)

#################################################################################
dir1 = '~/Work/mega/mwceph/pphot/'
dir2 = '~/Work/mega/mwceph/pphot_bf_2016_02_16/'
f.par = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
for (i in 1:3) par[,i] = as.character(par[,i])
idx = par[,13] > 0
par = par[idx,]
n = nrow(par)
nall = 0
nrej = 0
for (i in 1:n) {
    obj = par[i,1]
    f.dat = paste0(dir1,obj,'/photn/nulc.nulc')
    if (!file.exists(f.dat)) f.dat = paste0(dir2,obj,'/photn/nulc.nulc')
    if (obj == 'lcarl') f.dat = '~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/photnl/nulc.nulc'
    if (!file.exists(f.dat)) stop(obj)
    dat = read.table(f.dat, header=T)
    idx = dat[, 'flag'] > 0 | dat[,'pol'] != 'N'
    nall = nall + nrow(dat)
    nrej = nrej + sum(idx)
}
rej = 100*nrej/nall
msg = paste0('For H+ND4 images, rejected ',round(rej,2),'% images')
print(msg)

################################################################################
dir = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/'
dir1 = '~/Work/mega/mwceph/pphot/'
dir2 = '~/Work/mega/mwceph/pphot_bf_2016_02_16/'
f.par = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
for (i in 1:3) par[,i] = as.character(par[,i])
n = nrow(par)
nall = 0
nrej = 0
errs = c()
errs2 = c()
for (i in 1:n) {
    obj = par[i,1]
    f.clc = paste0(dir, obj, '_h.clc')
    band = 'h'
    if (!file.exists(f.clc)) {
        f.clc = paste0(dir, obj, '_n.clc')
        band = 'n'
    }
    if (!file.exists(f.clc)) stop(obj)
    clc = read.table(f.clc)
    if (band == 'h') {
        f.slc = paste0(dir1,obj,'/photh/',obj,'_h.slc')
        if (!file.exists(f.slc)) f.slc = paste0(dir2,obj,'/photh/',obj,'_h.slc')
        if (!file.exists(f.slc)) stop(obj)
    } else {
        f.slc = paste0(dir1,obj,'/photn/',obj,'_n.slc')
        if (!file.exists(f.slc)) f.slc = paste0(dir2,obj,'/photn/',obj,'_n.slc')
        if (obj == 'lcarl') f.slc = '~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/photnl/-carp_n.slc'
        if (!file.exists(f.slc)) stop(obj)
    }
    slc = read.table(f.slc, header=T)
    nall = nall + nrow(slc)
    idx = !(round(slc[,1],2) %in% round(clc[,1],2))
    nrej = nrej + sum(idx)
    errs = c(errs, slc[idx,4])
    errs2 = c(errs2, slc[!idx,4])
}
rej = 100*nrej/nall
msg = paste0('For all images, rejected ',round(rej,2),'% measurements')
print(msg)
## par(mfrow=c(2,1))
## xlim = range(errs)
## hist(errs, breaks=30, col='skyblue', xlim=xlim, main='Rejected', xlab='Uncertainty')
## abline(v=max(errs2), col=2)
## hist(errs2, breaks=10, col='skyblue', xlim=xlim, main='Kept', xlab='Uncertainty')
rej = 100*sum(errs<=0.11)/(nall-sum(errs>0.11))
msg = paste0('For all images, rejected ',round(rej,2),'% measurements with sigma<=0.11')
print(msg)
################################################################################
rdir = '~/Work/mega/mwceph/lightcurve/20160527/rawlcs/'

fs.rlc = list.files(rdir, pattern='.*.rlc$')
ids = unique(substr(fs.rlc,1,5))
gids = c()
for (i in 1:length(ids)) {
    id = ids[i]
    fh = paste0(rdir,id,'_h.rlc')
    fn = paste0(rdir,id,'_n.rlc')
    if (file.exists(fh) & file.exists(fn) & id != 'betad' & id != 'w-sgr') {
        gids = c(gids, id)
    }
}
f.par = '~/Work/mega/mwceph/lightcurve/20160527/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
for (i in 1:3) par[,i] = as.character(par[,i])
idx = par[,13] == 0
par = par[idx,]
idx = gids %in% par[,1]
a.gids = gids[idx]
rtio = length(a.gids) / nrow(par) * 100
msg = paste0('ND4 calculation used additional ',length(a.gids),' objects in group A')
print(msg)
