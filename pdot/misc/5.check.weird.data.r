crocus2jd = 2400000 ## No .5 at the end
asas2jd = 2450000
ts2jd = 2400000  ## To avoid negative number or bad phase calculation
vid = 3

dir = '~/Work/mega/mwceph/pdot/cal.pdot/'
obsdir = '~/Work/mega/mwceph/pdot/allobs/'
dirold = '~/Work/mega/mwceph/period_search/inputs_it3/'
dirold2 = '~/Work/mega/mwceph/pphot/period_all/model_per/inputs_it3/'
diras = '~/Work/mega/mwceph/asas_related/cmb_data/'
figdir = '~/Work/mega/mwceph/pdot/figs/'
pit0 = '~/Work/mega/mwceph.codes/pdot/pejcha.f/period'

f.par = paste0('~/Work/mega/mwceph/lightcurve/20160527/calilcs/', 'mw_ceph_pars.dat')
par = read.table(f.par)
for (ifoo in 1:3) par[,ifoo] = as.character(par[,ifoo])
npar = nrow(par)


idx = par[,1] == 'aqpup'
obj = par[idx, 1]
period = par[idx, 4]
f.dat = paste0(obsdir, obj, '.dat')
idx = par[,1] == obj
period = par[idx,4]
frequency = 1/period
dat = read.table(f.dat)
idx = dat[,4] == 3
dat = dat[idx,]


## plot(sub[,1:2], pch=19, main=obj)
god = dat[!idx,]

idx = dat[,1] < 48000
grp1 = dat[idx,]
idx = dat[,1] > 48000 & dat[,1] < 50000
grp2 = dat[idx,]
idx = dat[,1] > 50000
grp3 = dat[idx,]

par(mfrow=c(1,1))
x = grp1[,1]
x = (x/period) %% 1
plot(x, grp1[,2], pch=19, cex=0.3, col=2)
x = grp2[,1]
x = (x/period) %% 1
points(x, grp2[,2], pch=19, cex=0.3, col=4)
x = grp3[,1]
x = (x/period) %% 1
points(x, grp3[,2], pch=19, cex=0.3)


## Find period using only ASAS data
sub = grp3
pstar = period
pranges = c(1.5, 0.002, 0.00002)
rfactors = c(1, 0.001, 0.00001)
nphases = c(10, 10, 30)
resolutions = c(1e-5, 1e-6, 1e-7)
f.ipt = paste0(dir,'tmp.ipt')
par(mfrow=c(3,1))
for (ifoo in 1:3) {
    ts = paste(nrow(sub), pstar, 0, sep='   ')
    write(ts, f.ipt)
    write.table(sub, f.ipt, append=T, col.names=F, row.names=F, sep='   ')
    f.sh = paste0(dir, 'tmp.sh')
    ts = '#!/bin/tcsh -f'
    write(ts, f.sh)
    ts = paste0(pit0,' < infile > tmp.out')
    write(ts, f.sh, append=T)
    ts = 'rm -f fort.13 fort.14 fort.15 tmp.out tmp.ipt infile'
    write(ts, f.sh, append=T)
    dir.current = getwd()
    setwd(dir)
    prange = pranges[ifoo]
    rfactor = rfactors[ifoo] * 10
    nphase = nphases[ifoo]
    cmd = paste0('echo "',prange,'" > infile')
    system(cmd)
    cmd = paste0('echo "',rfactor,'" >> infile')
    system(cmd)
    cmd = paste0('echo "',nphase,'" >> infile')
    system(cmd)
    cmd = 'echo tmp.ipt >> infile'
    system(cmd)
    cmd = 'tcsh tmp.sh'
    system(cmd)
    setwd(dir.current)
    f.chi = paste0(dir, 'tmp.i_chi_sqr.dat')
    chi = read.table(f.chi)
    plot(chi[,1:2],pch=19,cex=0.5,col='black', main=obj)
    resolution = resolutions[ifoo]
    spl = smooth.spline(chi[,1],chi[,2])
    newx = seq(min(chi[,1]),max(chi[,1]),by=resolution)
    newxy = predict(spl,newx)
    lines(newxy,col='green')
    pstar = newxy$x[which.min(newxy$y)]
    if (abs(pstar - chi[1,1]) < 2*resolution)
        stop(paste0(' >>>Alert! ',obj,' hit boundary. Increase dp range in period.f and make'))
    if (abs(pstar - chi[nrow(chi),1]) < 2*resolution)
        stop(paste0(' >>>Alert! ',obj,' hit boundary. Increase dp range in period.f and make'))
    abline(v=pstar, col=2)
    cmd = paste0('rm -f ', f.sh, ' ', f.chi)
    system(cmd)
}

f.pdf = paste0(figdir, obj,'_grp.pdf')
pdf(f.pdf, height=8, width=6)
par(mfrow=c(2,1))
xlim = c(0,1)
period2 = round(pstar, 6)
x = grp1[,1]
x = (x/period2) %% 1
x = c(x-1,x,x+1)
y = c(grp1[,2],grp1[,2],grp1[,2])
ylim = rev(range(dat[,2]))
main = paste0(obj, ', using period from ASAS data')
plot(x, y, pch=19, cex=0.3, col=2, ylim = ylim, main=main, xlab='Phase', ylab='V [mag]', xlim=xlim)
x = grp2[,1]
x = (x/period2) %% 1
x = c(x-1,x,x+1)
y = c(grp2[,2],grp2[,2],grp2[,2])
points(x, y, pch=19, cex=0.3, col=4)
x = grp3[,1]
x = (x/period2) %% 1
x = c(x-1,x,x+1)
y = c(grp3[,2],grp3[,2],grp3[,2])
points(x, y, pch=19, cex=0.3)
legend('topright',c('ASAS','MJD~50000','MJD<48000'),col=c(1,4,2), pch=19)

dp = 0.3
x = grp1[,1]
x = (x/period) %% 1 + dp
x = c(x-1,x,x+1)
y = c(grp1[,2],grp1[,2],grp1[,2])
ylim = rev(range(dat[,2]))
main = paste0(obj, ', using period from all V-band data')
plot(x, y, pch=19, cex=0.3, col=2, ylim = ylim, main=main, xlab='Phase', ylab='V [mag]', xlim=xlim)
x = grp2[,1]
x = (x/period) %% 1 + dp
x = c(x-1,x,x+1)
y = c(grp2[,2],grp2[,2],grp2[,2])
points(x, y, pch=19, cex=0.3, col=4)
x = grp3[,1]
x = (x/period) %% 1 + dp
x = c(x-1,x,x+1)
y = c(grp3[,2],grp3[,2],grp3[,2])
points(x, y, pch=19, cex=0.3)
legend('topright',c('ASAS','MJD~50000','MJD<48000'),col=c(1,4,2), pch=19)
dev.off()
