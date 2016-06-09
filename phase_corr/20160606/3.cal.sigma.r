dir = '~/Work/mega/mwceph/phase_corr/20160606/'
sigdir = paste0(dir,'sigs/')
f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
f.phs = paste0(dir, 'phase_ncyc.dat')
phs = read.table(f.phs, stringsAsFactors = F)

par = read.table(f.par, stringsAsFactors = F)
npar = nrow(par)
nphs = nrow(phs)
source('fitfuns/fun.fit.Inno15.r')
load.pars()

f.res = paste0(dir, 'model_residuals.dat')
res = read.table(f.res, stringsAsFactors = F)
f.eha = '~/Work/mega/mwceph/pdot/cal.pdot/period_eperiod.dat'
eha = read.table(f.eha, stringsAsFactors = F)
f.out = paste0(dir, 'sigma_correction.dat')
ts = '#     id     sigma.1   sigma.2   sigma.3 sigma.total  mag.corr'
write(ts, f.out)
for (i in 1:npar) {
    id = par[i,1]
    tref = par[i,5] - 2450000
    period = par[i,4]
    M = par[i, 6]
    eM = par[i, 7]
    L = par[i, 8]
    eL = par[i, 9]
    PHI = par[i, 10]
    ePHI = par[i, 11]
    a0 = get.a0(period)
    phis = get.phis(period)
    amps = get.amps(period)
    idx = phs[,1] == id
    if (sum(idx) == 0) stop(id)
    sub = phs[idx,]
    N = nrow(sub)
    tmp1 = tmp2 = 0
    for (j in 1:N) {
        phi.it = ((sub[j,4] - tref) / period) %% 1
        tmp1 = tmp1 + a0 + sum(amps*cos(2*pi*(1:7)*(phi.it + PHI) + phis))
        tmp2 = tmp2 + sum(amps*sin(2*pi*(1:7)*(phi.it + PHI) + phis) * 2*pi*(1:7))
    }       
    sigma.1 = eM + eL/N * abs(tmp1) + L*ePHI/N*abs(tmp2)

    sigma.2 = sd(res[res[,1] == id, 2]) / sqrt(N)

    tmp3 = 0
    for (j in 1:N) {
        phi.it = ((sub[j,4] - tref) / period) %% 1
        tmp3 = tmp3 + sum(amps*sin(2*pi*(1:7)*(phi.it + PHI) + phis) * 2*pi*(1:7) * sub[j,5] / period)
    }
    ePeriod = eha[eha[,1]==id,3]
    sigma.3 = L/N * abs(tmp3) * ePeriod

    sigma.total = sqrt(sigma.1^2 + sigma.2^2 + sigma.3^2)

    phase = ((sub[,4] - tref) / period) %% 1
    mt = calt(phase, PHI, M, L, a0)
    mag.corrs = M - mt
    mag.corr = sum(mag.corrs) / N
    
    ts = sprintf('%10s%10.5f%10.5f%10.5f%10.5f%12.5f',id, sigma.1, sigma.2, sigma.3, sigma.total, mag.corr)
    write(ts, f.out, append=T)
    if (N==1) print(ts)
}



## for (i in 1:nphs) {
##     id = phs[i,1]
##     hstid = phs[i,2]
##     phase = phs[i,3]
##     ncyc = phs[i,5]

##     idx = par[,1] == id
##     if (sum(idx) != 1) stop()

##     ## Sigma model, sigma phase, sigma period

##     ## Sigma model
##     period = par[idx,4]
##     M = par[idx, 6]
##     eM = par[idx, 7]
##     L = par[idx, 8]
##     eL = par[idx, 9]
##     PHI = par[idx, 10]
##     ePHI = par[idx, 11]
##     a0 = get.a0(period)
##     phis = get.phis(period)
##     amps = get.amps(period)
##     mt = calt(phase, PHI, M, L, a0)
##     mag.corr = M - mt ## one need add mag.corr to the HST observations

##     f.lc = paste0(lcdir, id, '_h.clc')
##     if (!file.exists(f.lc)) f.lc = paste0(lcdir, id, '_n.clc')
##     if (!file.exists(f.lc)) stop(obj)
##     lc = read.table(f.lc)
##     ts = c(lc[,1], phs[i,4])
##     t1 = min(ts) - 20
##     t2 = max(ts) + 20
##     tcnt = seq(t1, t2, length=1e4)
##     tref = par[idx,5] - 2450000
##     xcnt = ((tcnt - tref) / period) %% 1
##     ycnt = calt(xcnt, PHI, M, L, a0)
##     plot(tcnt, ycnt, type='l', main=hstid, xlab='JD - 2450000', ylab='H [mag]')
##     x = lc[,1]
##     y = lc[,2]
##     e = lc[,3]
##     points(x, y, pch=19)
##     arrows(x, y-e, x, y+e, angle=90, length=0.001, code=3)
##     points(phs[i,4], mt, col=2, pch=19)

## }

