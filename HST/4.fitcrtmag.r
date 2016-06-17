dir = '~/Work/mega/mwceph/HST/colorcorr/crt_lcs/'
f.old = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
f.par = paste0(dir, 'updated_bestfit_pars.dat')

old = read.table(f.old, stringsAsFactors=F)
par = old
npar = nrow(par)

for (i in 6:11) par[,i] = 0

source('fitfuns/fun.fit.Inno15.r')
load.pars()
for (i in 1:npar) {
    id = par[i,1]
    print(id)
    obj = par[i,3]
    period = par[i,4]
    t0 = par[i,5] - 2400000.5
    lf.clc = paste0(dir,obj,'_crted.dat')
    clc = read.table(lf.clc)
    t = clc[,1]
    m = clc[,2]
    e = clc[,3]
    phase = ((t - t0) / period) %% 1
    pars = fit.Inno15(phase, m, e)
    M = round(pars[1],4)
    L = round(pars[2],4)
    PHI = round(pars[3],4)
    eM = round(pars[4],4)
    eL = round(pars[5],4)
    ePHI = round(pars[6],4)
    
    par[i,6] = M
    par[i,7] = eM
    par[i,8] = L
    par[i,9] = eL
    par[i,10] = PHI
    par[i,11] = ePHI
}

ts = '#  ID    alias     object     period     t_ref      M        eM       L        eL      PHI      ePHI  ezp_2mass  ezp_nd4'
write(ts, f.par)
fmt = '%7s%7s%13s%11.6f%10i%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f%9.4f'
out = do.call('sprintf', c(fmt, par))
write(out, f.par, append=T)
