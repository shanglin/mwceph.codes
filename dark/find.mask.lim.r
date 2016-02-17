library(FITSio)

dir = '~/Work/mega/mwceph/pphot/dark/'
fs.fits = list.files(dir,pattern = '^binir.*.fits$')
nfs = length(fs.fits)
f.all = paste0(dir,'all.vals.dat')
if (F) {
    write('#',f.all)
    for (i in 1:nfs) {
        print(paste(i,nfs))
        f.fits = fs.fits[i]
        lf.fits = paste0(dir,f.fits)
        x = readFITS(lf.fits)
        values = as.vector(x$imDat)
        write.table(values, f.all, append = T, col.names=F, row.names=F)
    }
}

dat = read.table(f.all)
values = dat[,1]

sigma.clip = 5
for (ifoo in 1:5) {
    median = median(values)
    sd = sd(values)
    idx = values < median + sigma.clip*sd & values > median - sigma.clip*sd
    values = values[idx]
}

height = 6
width = height * 1.618
f.eps = paste0(dir,'mask_lim.eps')
setEPS()
postscript(f.eps,height = height,width=width)

sigma.mask = 3
hist(values, xlab='Dark frame pixel values',main='',col='skyblue',freq=F)
median = median(values)
sd = sd(values)
mask.lim.1 = median - sd * sigma.mask
mask.lim.2 = median + sd * sigma.mask

lines(rep(mask.lim.1,2),c(0,0.1), col = 2)
lines(rep(mask.lim.2,2),c(0,0.1), col = 2)
text(mask.lim.1,0.11,paste(round(mask.lim.1,1)))
text(mask.lim.2,0.11,paste(round(mask.lim.2,1)))
dev.off()
