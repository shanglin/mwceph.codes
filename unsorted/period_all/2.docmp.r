figdir = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/figs/'

f.par = '~/Work/m33/16summer/mwupdt/periods_all/calilcs/mw_ceph_pars.dat'
f.per = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/ehat/ehat.dat'

par = read.table(f.par)
for (i in 1:3) par[,i] = as.character(par[,i])
per = read.table(f.per,skip=1)
per[,1] = as.character(per[,1])

idx = match(par[,1], per[,1])
per = per[idx,]

ppar = par[,4]
pper = per[,2]

f.eps = paste0(figdir, 'pold_pnew.eps')
setEPS()
postscript(f.eps, width=8, height=4.5)
xlim = range(ppar)
plot(ppar, pper-ppar, pch=19, xlab='Period [day]', ylab='P(new) - P(old)',ylim=c(-0.015,0.018), xlim=xlim)
x = ppar
y = pper-ppar
e = per[,3]
arrows(x, y+e, x, y-e, code=3, angle=90, length=0.01)

dat = cbind(per[,1:2], par[,4], par[,3])
colnames(dat) = c('obj','pnew','pold','o2')
idx = abs(dat[,'pnew'] - dat[,'pold']) > 0.01
sub = dat[idx,]

text(sub[,3]+1,sub[,2]-sub[,3],sub[,4], adj=0)
dev.off()


############ Remove those without ASAS observations #########

figdir = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/figs/'

f.par = '~/Work/m33/16summer/mwupdt/periods_all/calilcs/mw_ceph_pars.dat'
f.per = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/ehat/ehat.dat'

par = read.table(f.par)
for (i in 1:3) par[,i] = as.character(par[,i])
per = read.table(f.per,skip=1)
per[,1] = as.character(per[,1])
idx = per[,1] %in% c('betad', 'lcarl', 'w-sgr', 's-nor', 'vycar', 'u-car')
per = per[!idx,]
idx = par[,1] %in% c('betad', 'lcarl', 'w-sgr', 's-nor', 'vycar', 'u-car')
par = par[!idx,]

idx = match(par[,1], per[,1])
per = per[idx,]

ppar = par[,4]
pper = per[,2]

f.eps = paste0(figdir, 'pold_pnew_asas.eps')
setEPS()
postscript(f.eps, width=8, height=4.5)

plot(ppar, pper-ppar, pch=19, xlab='Period [day]', ylab='P(new) - P(old)',ylim=c(-0.015,0.018), xlim=xlim)
x = ppar
y = pper-ppar
e = per[,3]
arrows(x, y+e, x, y-e, code=3, angle=90, length=0.01)

dat = cbind(per[,1:2], par[,4], par[,3])
colnames(dat) = c('obj','pnew','pold','o2')
idx = abs(dat[,'pnew'] - dat[,'pold']) > 0.01
sub = dat[idx,]

text(sub[,3]+1,sub[,2]-sub[,3],sub[,4], adj=0)
dev.off()
