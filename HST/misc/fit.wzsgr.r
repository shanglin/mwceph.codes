f.par = '~/Work/mega/mwceph/HST/colorcorr/crt_lcs/updated_bestfit_pars.dat'
par = read.table(f.par, stringsAsFactors=F)

dir = '~/Work/mega/mwceph/HST/colorcorr/'
figdir = '~/Work/mega/mwceph/HST/misc/'
lcdir = paste0(dir,'crt_lcs/')
f.hst = '~/Work/mega/mwceph/HST/misc/wzsgr.dat'

hst = read.table(f.hst, skip=0, stringsAsFactors=F, header=F)
odate = hst[,2]
hst[,2] = hst[,2]
ids = tolower(hst[,1])
idx = nchar(ids) == 6
ids[idx] = gsub('-','',ids[idx])
hst[,1] = ids
id = hst[1,1]

oldhst = hst[hst[,2]!=56578.249,]

source('fitfuns/fun.fit.Inno15.r')
load.pars()
amp = 0.32
width = 8.27

f.pdf = '~/Work/mega/mwceph/HST/misc/wzsgr.pdf'
pdf(f.pdf, width=6, height=11)
par(mfrow=c(2,1))

idx = par[,1] == id
ts = par[idx,]
idx = oldhst[,1] == id
sub = oldhst[idx,]

obj = ts[1, 3]
period = ts[1, 4]
t0 = ts[1, 5] - 2400000.5
M = ts[1, 6]
eM = ts[1, 7]
L = ts[1, 8]
eL = ts[1, 9]
PHI = ts[1, 10]
ePHI = ts[1, 11]
zp.2mass = ts[1, 12]
zp.nd4 = ts[1, 13]

a0 = get.a0(period)
phis = get.phis(period)
amps = get.amps(period)

f.slc = paste0(lcdir, obj, '_crted.dat')
if (!file.exists(f.slc)) stop(id)
lc = read.table(f.slc)
x = ((lc[,1]-t0)/period) %% 1
y = lc[,2]
e = lc[,3]
x = c(x, x + 1)
y = c(y, y)
e = c(e, e)

xc = seq(0, 1, by = 0.001)
yc = calt(xc, PHI, M, L, a0)
xc = c(xc, xc + 1)
yc = c(yc, yc)

xhst = ((sub[,2]-t0)/period) %% 1
yhst = sub[,3]
model.y = calt(xhst, PHI, M, L, a0)
off = yhst - model.y
xhst = c(xhst, xhst + 1)
yhst = c(yhst, yhst)

xlim = c(0,2)
midmag = 0.5 * (max(yc) + min(yc))
ylim = c(midmag + amp, midmag - amp)
thiszp = mean(off)
main = sprintf('%11s%7s%6.3f%4s',obj,'     ZP =',thiszp,' mag')
main = gsub('V0', 'V', main)
if (id == 'betad') main = expression(paste(beta,'-DOR      ','     P = 9.842922'))
if (id == 'lcarl') main = sprintf('%11s%7s%10.6f','l-CAR','     P =',period)
plot(xc, yc, xlab='Phase', ylab='H [mag]', xlim = xlim, ylim = ylim, type = 'l',
     main = main, font.main = 1, cex.main = 0.9, col = 'black',
     cex.axis = 1, xaxt = 'n')
axis(1, at = seq(0,2,0.5), labels = c('0', '0.5', '1', '0.5', '1'))
points(x, y, pch = 19, cex = 1)
arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)

points(xhst, yhst-thiszp, col=2, pch=19)


################################

idx = par[,1] == id
ts = par[idx,]
idx = hst[,1] == id
sub = hst[idx,]

obj = ts[1, 3]
period = ts[1, 4]
t0 = ts[1, 5] - 2400000.5
M = ts[1, 6]
eM = ts[1, 7]
L = ts[1, 8]
eL = ts[1, 9]
PHI = ts[1, 10]
ePHI = ts[1, 11]
zp.2mass = ts[1, 12]
zp.nd4 = ts[1, 13]

a0 = get.a0(period)
phis = get.phis(period)
amps = get.amps(period)

f.slc = paste0(lcdir, obj, '_crted.dat')
if (!file.exists(f.slc)) stop(id)
lc = read.table(f.slc)
x = ((lc[,1]-t0)/period) %% 1
y = lc[,2]
e = lc[,3]
x = c(x, x + 1)
y = c(y, y)
e = c(e, e)

xc = seq(0, 1, by = 0.001)
yc = calt(xc, PHI, M, L, a0)
xc = c(xc, xc + 1)
yc = c(yc, yc)

xhst = ((sub[,2]-t0)/period) %% 1
yhst = sub[,3]
model.y = calt(xhst, PHI, M, L, a0)
off = yhst - model.y
xhst = c(xhst, xhst + 1)
yhst = c(yhst, yhst)

xlim = c(0,2)
midmag = 0.5 * (max(yc) + min(yc))
ylim = c(midmag + amp, midmag - amp)
thiszp = mean(off)
main = sprintf('%11s%7s%6.3f%4s',obj,'     ZP =',thiszp,' mag')
main = gsub('V0', 'V', main)
if (id == 'betad') main = expression(paste(beta,'-DOR      ','     P = 9.842922'))
if (id == 'lcarl') main = sprintf('%11s%7s%10.6f','l-CAR','     P =',period)
plot(xc, yc, xlab='Phase', ylab='H [mag]', xlim = xlim, ylim = ylim, type = 'l',
     main = main, font.main = 1, cex.main = 0.9, col = 'black',
     cex.axis = 1, xaxt = 'n')
axis(1, at = seq(0,2,0.5), labels = c('0', '0.5', '1', '0.5', '1'))
points(x, y, pch = 19, cex = 1)
arrows(x, y-e, x, y+e, code=3, length=0.01, angle=90)

idx = yhst != 4.82
points(xhst[idx], yhst[idx]-thiszp, col=2, pch=19)

points(xhst[!idx], yhst[!idx]-thiszp, col=2, pch=17)

dev.off()
