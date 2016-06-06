dir = '~/Work/mega/mwceph/lightcurve/20160604/rawlcs/tmp/'
outdir = '~/Work/mega/mwceph/lightcurve/20160604/rawlcs_w_out/'
cdir = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/'
fs = list.files(dir,pattern='.*.slc$')
objs = unique(substr(fs,1,5))
n.objs = length(objs)
f.par = paste0(cdir,'mw_ceph_pars.dat')
par = read.table(f.par)
npar = nrow(par)
for (i in 1:3) par[,i] = as.character(par[,i])

for (i in 1:npar) {
    obj = par[i,1]
    if (par[i,13] == 0) band = 'h' else band = 'n'
    f.slc = paste0(dir, obj, '_', band, '.slc')
    if (!file.exists(f.slc)) stop(obj)
    slc = read.table(f.slc, header=T)
    f.clc = paste0(cdir, obj, '_', band, '.clc')
    clc = read.table(f.clc)

    idx = slc[,4] <= 0.11
    wlc = slc[idx,c(1,3,4,5)]
    wlc[,4] = 0

    idx = !(round(wlc[,1],3) %in% round(clc[,1],3))
    if (sum(idx)>0) wlc[idx,4] = 1

    f.out = paste0(outdir, obj, '_', band, '.wlc')
    ts = '# mjd      m        e      outlier'
    write(ts, f.out)
    write.table(wlc, f.out, append=T, col.names=F, row.names=F)
}
