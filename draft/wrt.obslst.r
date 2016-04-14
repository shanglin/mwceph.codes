f.par = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/mw_ceph_pars.dat'
par = read.table(f.par)
f.dat = '~/Work/mega/mwceph/pphot/mw_new_info.dat'
dat = read.table(f.dat, header=T)
idx = order(par[,4])
par = par[idx,]
n.par = nrow(par)
par[,3] = as.character(par[,3])
par[,2] = as.character(par[,2])
dat[,3] = as.character(dat[,3])
dat[,4] = as.character(dat[,4])
dat[,5] = as.character(dat[,5])
idx = dat[,3] %in% par[,2]
dat = dat[idx,]
idx = order(dat[,'dec'])
dat = dat[idx,]
n.dat = nrow(dat)

f.qua = '~/Work/mega/mwceph/lightcurve/20160303/quality/quality.csv'
qua = read.table(f.qua, skip=1, sep=',')
qua[,1] = toupper(as.character(qua[,1]))
qua[,5] = as.character(qua[,5])
qua[,1] = gsub('-','',qua[,1])
qua[,1] = gsub('LCARL','LCAR',qua[,1])

lst = as.data.frame(cbind(rep(NA,n.dat),rep(NA,n.dat),rep(NA,n.dat),rep(NA,n.dat),rep(NA,n.dat)))
for (i in 1:n.dat) {
    alias = dat[i,'alias']
    idx = alias == par[,2]
    if (sum(idx) != 1) stop(alias)
    obj = par[idx,3]
    obj = paste0(substr(obj,0,nchar(obj)-2), tolower(substr(obj,nchar(obj)-1,nchar(obj))))
    obj = gsub('V0','V',obj)
    if (obj == 'L-Car') obj = '{\\it l}-Car'
    if (obj == 'BETA-Dor') obj = '$\\beta$-Dor'
    lst[i,1] = obj
    lst[i,2] = dat[i,'ra']
    lst[i,3] = dat[i,'dec']
    idx = alias == qua[,1]
    if (sum(idx) != 1) stop(alias)
    type = qua[idx,5]
    if (type=='H') type='A'
    if (type=='N') type='B'
    lst[i,4] = type
    lst[i,5] = alias
}
idx = lst[,5] %in% c('LCAR','BETAD','WSGR')
lst[idx,4] = 'C'

pos = floor(n.dat/2)
nlst = cbind(lst[1:pos,1:4],lst[(pos+1):n.dat,1:4])


f.tex = '~/Work/mega/mwceph/draft/v2.2/tables/obslist.tex'
system(paste0('rm -f ',f.tex))
for (i in 1:pos) {
    if (i < pos) {
        ts = paste0(nlst[i,1],'$^',nlst[i,4],'$ & ',nlst[i,2],' & ',nlst[i,3],' & ',nlst[i,5],'$^',nlst[i,8],'$ & ',nlst[i,6],' & ',nlst[i,7],' \\\\')
    } else {
        ts = paste0(nlst[i,1],'$^',nlst[i,4],'$ & ',nlst[i,2],' & ',nlst[i,3],' & ',nlst[i,5],'$^',nlst[i,8],'$ & ',nlst[i,6],' & ',nlst[i,7])
    }
    write(ts, f.tex, append=T)
}
