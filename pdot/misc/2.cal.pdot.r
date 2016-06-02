This model does not work well.

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

obj = 'aqpup'
f.dat = paste0(dir, obj, '_v.dat')
idx = par[,1] == obj
period = par[idx,4]
frequency = 1/period
dat = read.table(f.dat)

time = dat[,1] - min(dat[,1])
mag = dat[,2]

par(mfrow=c(2,1))
phase = (time * frequency) %% 1
ylim = rev(range(dat[,2]))
x = c(phase-1, phase, phase+1)
y = c(dat[,2], dat[,2], dat[,2])
plot(x, y, pch=19, cex=0.5, ylim=ylim)

spl = smooth.spline(x,y)
nx = seq(0, 1, 0.001)
ny = predict(spl, nx)$y
lines(nx, ny, col=2, lwd=3)

## take this a our light curve shape kernel

##### below is our mathematical model with changing period. The phase equation can be proved with mathematical induction
## model: f(t) = f0 + fd*t, where f is frequency (1/period)
## f0 = 1  
## fd = 0.1
## t = seq(0, 20, 0.1)
## phase = f0 * t + 0.5 * fd * t^2
## y = sin(phase)
## plot(t, y, type='l')
################################################################

nf0 = 50
ndf = 50
f0.range = 0.01
df.range = 0.5e-5
freqs = seq(frequency - f0.range, frequency + f0.range, length=nf0)
dfreqs = seq(-1*df.range, df.range, length=ndf)
chisqrs = matrix(NA, nrow=nf0, ncol=ndf)

for (i in 1:nf0) {
    msg = paste0('   >> ',round(i*100/nf0, 1), ' %     \r')
    message(msg, appendLF=F)
    for (j in 1:ndf) {
        freq = freqs[i]
        dfreq = dfreqs[j]
        phase = (freq * time + 0.5 * dfreq * time^2) %% 1
        x = c(phase-1, phase, phase+1)
        y = c(dat[,2], dat[,2], dat[,2])
        spl = smooth.spline(x,y)
        chisqrs[i,j] = sum((predict(spl, phase)$y - mag)^2)
    }
}
print('')

library(rgl)
## colorlut = terrain.colors(zlen)
## z = chisqrs
## zlim = range(y)
## zlen = zlim[2] - zlim[1] + 1
## col = colorlut[ z - zlim[1] + 1 ]
open3d()
col = grey.colors(1)
persp3d(freqs, dfreqs, chisqrs*-1, col='#dddddd')

idx = which(chisqrs == min(chisqrs), arr.ind=T)
freq.hat = freqs[idx[1]]
dfreq.hat = dfreqs[idx[2]]

phase = (freq.hat * time + 0.5 * dfreq.hat * time^2) %% 1
x = c(phase-1, phase, phase+1)
y = c(dat[,2], dat[,2], dat[,2])
plot(x, y, pch=19, cex=0.5, ylim=ylim)
spl = smooth.spline(x,y)
nx = seq(0, 1, 0.001)
ny = predict(spl, nx)$y
lines(nx, ny, col=2, lwd=3)

