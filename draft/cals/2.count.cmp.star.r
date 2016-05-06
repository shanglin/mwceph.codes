f.dat = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
dat = read.table(f.dat)
dat[,1] = as.character(dat[,1])
n = nrow(dat)

cntIDLepspnts = function(f, noopen=0) {
    con = file(f,'r')
    dat = readLines(con)
    close(con)
    if (noopen==0) {
        idx = which(dat == '(Aperture Photometry)')
        sub = dat[idx:length(dat)]
    } else {
        sub = dat
    }
    npnts = 0
    n = length(sub)
    flag = 0
    for (i in 1:n) {
        ts = sub[i]
        nc = nchar(ts)
        x = nc - 5
        y = nc
        if (flag == 0 & substr(ts,x,y) == 'L CP F') {
            flag = 1
            npnts = npnts + 1
        } else if (flag == 1 & substr(ts,x,y) == 'L CP F') {
            flag = 1
        } else {
            flag = 0
        }
    }
    return(npnts)
}

nps = rep(NA, n)
for (i in 1:n) {
    id = dat[i,1]
    dir = paste0('~/Work/mega/mwceph/pphot/',id,'/2mass/')
    f.eps = paste0(dir,'aper-zp.eps')
    if (id == 'lcarl')
        f.eps = '~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/2massl/aper-zp.eps'
    if (!file.exists(f.eps)) {
        dir = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/',id,'/2mass/')
        f.eps = paste0(dir,'aper-zp.eps')
        if (!file.exists(f.eps)) stop(id)
    }
    nps[i] = cntIDLepspnts(f.eps)
    if (nps[i] == 0) nps[i] = cntIDLepspnts(f.eps,1)
}

out = cbind(dat[,1],nps)
f.out = '2.out.dat'
write.table(out, f.out, quote=F, row.names=F, col.names=F, sep='   ')
print(mean(nps))

