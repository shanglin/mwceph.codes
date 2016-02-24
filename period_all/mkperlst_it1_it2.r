dir = '~/Work/mega/mwceph/pphot/period_all/model_per/calphat_it1/'
outdir = '~/Work/mega/mwceph/pphot/period_all/model_per/inputs_it2/'
dats = list.files(dir,'.*_chi_sqr.dat$')
f.per = paste0(outdir,'objper_it2.lst')
system(paste0('rm -f ',f.per))
for (i in 1:length(dats)) {
    f.dat = paste0(dir,dats[i])
    dat = read.table(f.dat)
    obj = dats[i]
    obj = gsub('_chi_sqr.dat','',obj)
    period = dat[which.min(dat[,2]),1]
    p2 = dat[which.min(dat[,2])-1,1]
    p3 = dat[which.min(dat[,2])+1,1]
    ts = paste(obj,period,p2,p3,sep='   ')
    write(ts,f.per,append=T)
    plot(dat[,1:2],pch=19,cex=0.2,main=obj)
    abline(v=period,col=2)
    Sys.sleep(2)
}

dat = read.table(f.per)
png(paste0(outdir,'resolution_it1.png'))
hist((dat[,4]-dat[,3])/2,breaks=30,main='resolution')
dev.off()
