rdir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/'
outdir = '~/Work/mega/mwceph/draft/v3.1/figures/'

f.exp = '~/Work/mega/mwceph/lightcurve/20160303/exptimes/exps.dat'
exptime = read.table(f.exp)

fs.rlc = list.files(rdir, pattern='.*.rlc$')
ids = unique(substr(fs.rlc,1,5))
gids = c()

for (i in 1:length(ids)) {
    id = ids[i]
    fh = paste0(rdir,id,'_h.rlc')
    fn = paste0(rdir,id,'_n.rlc')
    if (file.exists(fh) & file.exists(fn) & id != 'betad' & id != 'w-sgr') {
        gids = c(gids, id)
    }
}

nd4 = data.frame(obj = character(),
    mjd = numeric(),
    h = numeric(),
    eh = numeric(),
    n = numeric(),
    en = numeric(),
    th = numeric(),
    tn = numeric())
nd4[,1] = as.character(nd4[,1])
icount = 1
for (id in gids) {
    fh = paste0(rdir,id,'_h.rlc')
    fn = paste0(rdir,id,'_n.rlc')
    hdat = read.table(fh)
    ndat = read.table(fn)
    for (i in 1:nrow(ndat)) {
        mjd = ndat[i,1]
        idx = abs(hdat[,1] - mjd) < 0.2
        if (sum(idx) == 1) {
            nd4[icount,1] = id
            nd4[icount,2:6] = c(mjd, hdat[idx,2], hdat[idx,3], ndat[i,2], ndat[i,3])
            th = exptime[exptime[,1]==paste0(id,'_h'),2]
            nd4[icount,7] = th
            tn = exptime[exptime[,1]==paste0(id,'_n'),2]
            nd4[icount,8] = tn
            icount = icount + 1
        }
    }
}

golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
f.eps = paste0(outdir,'nd4.eps')
setEPS()
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))


bri.lim = 11
fnt.lim = 100
col.pnt = 'black'
x = nd4[,'h']
y = nd4[,'n'] - nd4[,'h'] - 2.5*(log10(nd4[,'th']) - log10(nd4[,'tn']))
e = sqrt(nd4[,'eh']^2 + nd4[,'en']^2)
idx = x > bri.lim & x < fnt.lim
xsol = x[idx]
ysol = y[idx]
esol = e[idx]
idx = x < bri.lim | x > fnt.lim
xopn = x[idx]
yopn = y[idx]
eopn = e[idx]
xlab = expression(paste('Instrumental ',italic(H),' magnitude'))
ylab = 'ND4 attenuation [mag]'
plot(xsol,ysol,pch = 19, cex=0.5, xlab=xlab, ylab=ylab,col=col.pnt, xlim=c(9.6,11.9),ylim=c(8.9,9.5), cex.lab=1.5, cex.axis=1.5)
arrows(xsol, ysol+esol, xsol, ysol-esol, code=3, angle=90, length=0.02,col=col.pnt)
points(xopn,yopn,pch = 1, cex=0.5, col='grey')
arrows(xopn, yopn+eopn, xopn, yopn-eopn, code=3, angle=90, length=0.02, col='grey')


col.nd4 = 'blue'
abline(v=bri.lim,col=col.nd4,lty=2)
abline(v=fnt.lim,col=col.nd4,lty=2)
idx = x > bri.lim & x < fnt.lim
ys = y[idx]
es = e[idx]
nd4factor = sum(1/es^2*ys)/sum(1/es^2)
end4 = sd(ys)
abline(h=nd4factor,col=col.nd4)
## text = paste0('Att. (ND4) = ',round(nd4factor,3), '(', round(end4,3),') mag')
text = expression(paste('mean = ',9.324 %+-% 0.038,' mag'))
text(9.6,9.45,text, cex=1.5, adj=0)
dev.off()

## nd4 = 9.324 +/- 0.038
