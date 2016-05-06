f.dat = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
dat = read.table(f.dat)
dat[,1] = as.character(dat[,1])
n = nrow(dat)
dir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/'

dts = c()
for (i in 1:n) {
    id = dat[i,1]
    f.hr = paste0(dir,id,'_h.rlc')
    f.nr = paste0(dir,id,'_n.rlc')
    if (file.exists(f.hr) & file.exists(f.nr)) {
        hr = read.table(f.hr)[,1]
        nr = read.table(f.nr)[,1]
        hr = hr[order(hr)]
        nr = nr[order(nr)]
        hrr = round(hr)
        nrr = round(nr)
        idx = match(hrr, nrr)
        nr = nr[idx]
        idx = !is.na(nr)
        hr = hr[idx]
        nr = nr[idx]
        dts = c(dts, hr - nr)
    }
}
dts = dts[dts>0]
dss = dts * 24 * 3600
print(mean(dss))
