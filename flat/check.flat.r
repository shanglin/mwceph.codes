library(FITSio)

sigma.clip = 5

dir = '~/Work/mega/mwceph/pphot/flat/'
baddir = paste0(dir,'bad_flats/')
figdir = paste0(dir,'figures/')

fs.fits = list.files(dir,pattern = '^ir.*.flath.fits$')
nfs = length(fs.fits)

f.med = paste0(dir,'all.flat.median.vals.dat')
if (T) {
    write('# median standard_deviation',f.med)

    for (i in 1:nfs) {
        print(paste(i,nfs))
        f.fits = fs.fits[i]
        lf.fits = paste0(dir,f.fits)
        x = readFITS(lf.fits)
        values = as.vector(x$imDat)
        for (ifoo in 1:5) {
            median = median(values)
            sd = sd(values)
            idx = values < median + sigma.clip*sd & values > median - sigma.clip*sd
            values = values[idx]
        }
        median = median(values)
        sd = sd(values)
        f.png = paste0(figdir,f.fits,'.png')
        png(filename = f.png,width=600,height=600)
        hist(values, main = paste0(round(median,2),' +/- ',round(sd,2)), xlab=f.fits)
        dev.off()
        ts = paste(f.fits, round(median,2), round(sd,3), sep='   ')
        write(ts, f.med, append = T)
        if (median < 3700 | median > 4900) {
            cmd = paste0('mv ',lf.fits,' ',baddir)
            system(cmd)
        }
    }
}
dat = read.table(f.med)
f.png = paste0(figdir,'median.png')
png(filename = f.png,width=900,height=800)
par(mfrow = c(2,1))
hist(dat[,2],breaks = 50, main = 'histogram of median values of each flat image', xlab='median value', col='skyblue')
god = dat[dat[,2] < 99420 & dat[,2] > 2000,2]
## god = dat[,2]
hist(god,breaks = 20, main = 'Zoomed in all good regions', xlab='median value', col='skyblue')
abline(v=3700,col=2)
abline(v=4900,col=2)
text(3700,8,'3700')
text(4900,8,'4900')
dev.off()
