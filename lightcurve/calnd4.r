rdir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/'
outdir = '~/Work/mega/mwceph/lightcurve/20160303/calnd4/'

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

f.pdf = paste0(outdir,'previous.res.pdf')
pdf(f.pdf)
x = nd4[,'h']
y = nd4[,'n'] - nd4[,'h'] - 2.5*(log10(nd4[,'th']) - log10(nd4[,'tn']))
e = sqrt(nd4[,'eh']^2 + nd4[,'en']^2)
plot(x,y,pch = 19, cex=0.5, xlab='Instrumental H (mag)', ylab='ND4 - H - (exptime correction) (mag)')
arrows(x, y+e, x, y-e, code=3, angle=90, length=0.02)
abline(h=9.302,col='red')
text(9.9,9.35,'9.302 mag (Previous result)',col='red')
dev.off()

golden.ratio = 1.61803398875
fig.height = 5 # inches
fig.width = fig.height * golden.ratio
f.eps = paste0(outdir,'nd4factor.eps')
setEPS()
postscript(f.eps,height = fig.height, width = fig.width)
par(mar=c(5,5,2,2))

col.pnt = 'black'
x = nd4[,'h']
y = nd4[,'n'] - nd4[,'h'] - 2.5*(log10(nd4[,'th']) - log10(nd4[,'tn']))
e = sqrt(nd4[,'eh']^2 + nd4[,'en']^2)
plot(x,y,pch = 19, cex=0.5, xlab='Instrumental H (mag)', ylab='ND4 Extinction (mag)',col=col.pnt)
arrows(x, y+e, x, y-e, code=3, angle=90, length=0.02,col=col.pnt)
bin.size = 0.2
bin.pos = seq(9,12,bin.size)
n = length(bin.pos)
newx = (bin.pos[1:(n-1)] + bin.pos[2:n]) / 2
newy = rep(NA,n-1)
newe = rep(NA,n-1)
for (i in 1:(n-1)) {
    idx = x > bin.pos[i] & x <= bin.pos[i+1]
    ys = y[idx]
    es = e[idx]
    newy[i] = sum(1/es^2*ys)/sum(1/es^2)
    newe[i] = sd(ys)
}
## col.bin = 'black'
## points(newx,newy,col=col.bin,pch=19)
## lines(newx,newy,col=col.bin)
## arrows(newx,newy+newe,newx,newy-newe,col=col.bin,code=3,length=0.05,angle=90)

col.nd4 = 'blue'
bri.lim = 11
fnt.lim = 100
abline(v=bri.lim,col=col.nd4,lty=2)
abline(v=fnt.lim,col=col.nd4,lty=2)
idx = x > bri.lim & x < fnt.lim
ys = y[idx]
es = e[idx]
nd4factor = sum(1/es^2*ys)/sum(1/es^2)
end4 = sd(ys)
abline(h=nd4factor,col=col.nd4)
text = paste0('Ext. (ND4) = ',round(nd4factor,3), '(', round(end4,3),') mag')
text(9.8,9.4,text)

col.cor = 'green'
correctable.lim = 10.5
abline(v=correctable.lim,col=col.cor,lty=2)
idx = x < bri.lim
xs = x[idx]
ys = y[idx]
es = e[idx]
fit = smooth.spline(xs,ys,w=1/es^2,df=4)
newx = seq(9,bri.lim,by=0.001)
newy = predict(fit,newx)$y
idx = newx > correctable.lim
idx2 = newx < correctable.lim
lines(newx[idx],newy[idx],col=col.cor,lwd=2)
lines(newx[idx2],newy[idx2],col=col.cor,lty=3,lwd=2)
dev.off()

f.cor = paste0(outdir,'nonlinear.correction.dat')
ts = '#  Instrumental_I   Correction (mag)'
write(ts,f.cor)
ycorr = nd4factor - newy
dat = cbind(newx,ycorr)
dat = round(dat,4)
order = rev(order(dat[,1]))
dat = dat[order,]
write.table(dat,f.cor,quote=F,col.names=F,row.names=F,append=T,sep='     ')

f.nd4 = paste0(outdir,'nd4factor.dat')
ts = '# delta H,   uncertainty'
write(ts,f.nd4)
ts = paste0(round(nd4factor,4),'    ',round(end4,4))
write(ts,f.nd4,append=T)
