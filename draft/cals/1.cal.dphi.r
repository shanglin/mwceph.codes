f.dat = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
lcdir = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/'
dat = read.table(f.dat)
dat[,1] = as.character(dat[,1])
n = nrow(dat)

dps = c()
hhs = c()
nhs = c()
for (i in 1:n) {
    id = dat[i,1]
    p = dat[i,4]
    useh = 1
    f.lc = paste0(lcdir, id, '_h.clc')
    if (!file.exists(f.lc)) {
        f.lc = paste0(lcdir, id, '_n.clc')
        useh = 0
    }
    if (!file.exists(f.lc)) stop(id)
    t = read.table(f.lc)[,1]
    phase = (t / p) %% 1
    m = length(phase)
    phase = phase[order(phase)]
    dp = phase[2:m] - phase[1:(m-1)]
    dps = c(dps,dp)
    if (useh == 1) {
        hhs = c(hhs,dat[i,6])
    } else {
        nhs = c(nhs,dat[i,6])
    }
}

## hist(dps)
## abline(v = median(dps), col=2)
## print(median(dps))
      
## 2, where to use ND4
h1 = hist(hhs, breaks=10)
h2 = hist(nhs, breaks=10)
plot(h1$mids, h1$counts, col=2, type='s', xlim=c(1,12))
lines(h2$mids, h2$counts, col=4, type='s')
