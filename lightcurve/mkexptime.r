rdir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/'
outdir = '~/Work/mega/mwceph/lightcurve/20160303/exptimes/'
dir1 = '~/Work/mega/mwceph/pphot/'
dir2 = '~/Work/mega/mwceph/pphot_bf_2016_02_16/'


fs.rlc = list.files(rdir, pattern='.*.rlc$')
ids = substr(fs.rlc,1,7)
n = length(ids)
exps = rep(NA,n)

f.tmp = paste0(outdir,'head.tmp')
for (i in 1:n) {
    id = ids[i]
    print(id)
    sid = substr(id,1,5)
    band = substr(id,7,7)
    dir.new = paste0(dir1,sid,'/phot',band,'/')
    dir.old = paste0(dir2,sid,'/phot',band,'/')
    if (sid == 'lcarl')
        dir.old = paste0(dir2,'l-car/photnl/')
    if (sid == 'lcarr')
        dir.old = paste0(dir2,'l-car/photnr/')
    if (file.exists(dir.new)) {
        cmd = paste0('imhead ',dir.new,'??????????.fits | grep EXPTIME > ',f.tmp)
        system(cmd)
    } else if(file.exists(dir.old)) {
        cmd = paste0('imhead ',dir.old,'??????????.fits | grep EXPTIME > ',f.tmp)
        system(cmd)
    } else {
        stop(paste0(id,' not found'))
    }
    dat = read.table(f.tmp)
    exps[i] = median(dat[,3])
}

dat = cbind(ids,exps)
f.out = paste0(outdir,'exps.dat')
write.table(dat,f.out,quote=F,col.names=F,row.names=F, sep='   ')
print(exps)
