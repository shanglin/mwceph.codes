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
periods = rep(NA, n.dat)
dat = cbind(dat, periods)
for (i in 1:n.dat) {
    alias = dat[i,'alias']
    idx = alias == par[,2]
    if (sum(idx) != 1) stop(alias)
    dat[i,'periods'] = par[idx,4]
}
idx = order(dat[,'periods'])
dat = dat[idx,]

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

f.eha = '~/Work/mega/mwceph/pphot/period_all/ehat.dat'
eha = read.table(f.eha,header=T)
eha[,1] = as.character(eha[,1])
eha[,1] = toupper(eha[,1])
eha[,1] = gsub('-','',eha[,1])
eha[,1] = gsub('LCARL','LCAR',eha[,1])

f.tex = '~/Work/mega/mwceph/draft/v2.2/tables/pars.tex'
system(paste0('rm -f ',f.tex))
for (i.dat in 1:n.dat) {
    obj = lst[i.dat,1]
    alias = lst[i.dat,5]
    idx = alias == par[,2]
    if (sum(idx) != 1) stop(alias)
    tt = par[idx,]
    idx = alias == eha[,1]
    if (sum(idx) != 1) stop(alias)
    sig.p = eha[idx,3]
    
    ts.mid = sprintf('%3s%10.6f%3s%9.6f%3s%5i%3s%7.4f%3s%7.4f%3s%7.4f%3s%7.4f%3s%7.4f%3s%7.4f',
        ' & ',tt[1,4],' & ',sig.p,' & ',tt[1,5]-2.45e6,' & ',tt[1,8],' & ',tt[1,9],' & ',tt[1,6],' & ',tt[1,7],' & ',tt[1,10],' & ',tt[1,11])
    
    ## ts = paste(obj,tt[1,4],sig.p,tt[1,5],tt[1,8],tt[1,9],tt[1,6],tt[1,7],tt[1,10],tt[1,11], sep=' & ')
    if (i.dat < n.dat)
        ts = paste0(obj,ts.mid,' \\\\')
    else
        ts = paste0(obj,ts.mid)
    write(ts, f.tex, append=T)
}

