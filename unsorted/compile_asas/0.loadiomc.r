library(FITSio)
bary2jd = 2451544.5

f.cat = 'Cepheid_visual.txt'
f.tmp = 'compact_cat.tmp'
cmd = paste0("awk 'NR>1 {print $1,$2,$21}' ",f.cat,' > ',f.tmp)
system(cmd)
cat = read.table(f.tmp, header=T, colClasses=c('character','character','numeric'))

f.pdf = 'lc_raw.pdf'
pdf(f.pdf, width=10, height=5)
for (i in 1:nrow(cat)) {
    ## par(mfrow=c(1,2))
    f.dat = paste0('IOMC_',cat[i,'id'],'.fits')
    period = cat[i,'period']
    obj = cat[i,1]
    dat = readFITS(f.dat)
    jd = dat$col[[which(dat$colNames == 'BARYTIME')]] + bary2jd
    v = dat$col[[which(dat$colNames == 'MAG_V')]]
    ev = dat$col[[which(dat$colNames == 'ERRMAG_V')]]
    exptime = dat$col[[which(dat$colNames == 'EXPOSURE')]]
    ## hist(exptime, col='skyblue', breaks=20)
    flag = dat$col[[which(dat$colNames == 'PROBLEMS')]]

    idx = which(flag == 0)
    jd = jd[idx]
    v = v[idx]
    ev = ev[idx]
    exptime = exptime[idx]
    
    phase = (jd/period) %% 1
    ylim = rev(range(v)) + c(0.1,-0.1)
    plot(phase,v, pch=19, ylim=ylim, cex=0.3, main=obj)
    arrows(phase, v+ev, phase, v-ev, angle=90, length=0.002, code=3)

    ## lphase = c(phase-1, phase, phase+1)
    ## lv = c(v, v, v)
    ## smt.spl = smooth.spline(lphase, lv, df=35)
    ## nx = seq(0, 1, 0.01)
    ## ny = predict(smt.spl, nx)$y
    ## lines(nx, ny, col=2)
    ## py = predict(smt.spl, phase)$y
    ## residual = py - v
    ## plot(residual,exptime, pch=19)
}
dev.off()
