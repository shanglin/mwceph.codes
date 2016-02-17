library(FITSio)

sigma.clip = 5
sigma.mask = 3
dir = '~/Work/mega/mwceph/pphot/dark/'
baddir = paste0(dir,'bad_darks/')
figdir = paste0(dir,'figures/')

fs.fits = list.files(dir,pattern = '^binir.*.fits$')
nfs = length(fs.fits)

f.med = paste0(dir,'all.dark.median.vals.dat')
write('# median standard_deviation',f.med)

for (i in 1:nfs) {
    print(paste(i,nfs))
    f.fits = fs.fits[i]
    lf.fits = paste0(dir,f.fits)
    x = readFITS(lf.fits)
    ax1 = axVec(1, x$axDat)
    ax2 = axVec(2, x$axDat)
    xlab = 'X'
    ylab = 'Y'
    values = as.vector(x$imDat)

    for (ifoo in 1:5) {
        median = median(values)
        sd = sd(values)
        idx = values < median + sigma.clip*sd & values > median - sigma.clip*sd
        values = values[idx]
    }

    median = median(values)
    sd = sd(values)
    mask.lim.1 = median - sd * sigma.mask
    mask.lim.2 = median + sd * sigma.mask

    f.png = paste0(figdir,f.fits,'.png')
    png(filename = f.png,width=600,height=600)
    hist(values, main = paste0(median,' +/- ',round(sd,2)), xlab=f.fits)
    abline(v = mask.lim.1, col = 2)
    abline(v = mask.lim.2, col = 2)
    dev.off()
    ts = paste(median, round(sd,3), sep='   ')
    write(ts, f.med, append = T)
    if (median < 406.2 | median > 408.0 | sd > 1.7) {
        cmd = paste0('mv ',lf.fits,' ',baddir)
        system(cmd)
    }
}

dat = read.table(f.med)
f.png = paste0(figdir,'median.png')
png(filename = f.png,width=900,height=800)
par(mfrow = c(2,1))
hist(dat[,1],breaks = 50, main = 'histogram of median values of each dark image', xlab='median value', col='skyblue')
god = dat[dat[,1] < 420 & dat[,1] > 390,1]
hist(god,breaks = 30, main = 'Zoomed in all good regions', xlab='median value', col='skyblue')
abline(v=406.2,col=2)
abline(v=408.0,col=2)
dev.off()
