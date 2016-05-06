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
idx = order(dat[,'ra'])
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

clc.dir = '~/Work/mega/mwceph/lightcurve/20160303/calilcs/'
fs.clc = list.files(clc.dir, pattern='.*.clc$')
objs = gsub('.clc','',fs.clc)
objs = gsub('_h','',objs)
objs = gsub('_n','',objs)
objs = gsub('lcarl','lcar',objs)
objs = gsub('-','',objs)
objs = toupper(objs)

f.tex = '~/Work/mega/mwceph/draft/v3.1/tables/measure.tex'
system(paste0('rm -f ',f.tex))
line.count = 0
n.line = 20
for (i.dat in 1:n.dat) {
    alias = lst[i.dat,5]
    idx = alias == par[,2]
    if (sum(idx) != 1) stop(alias)
    err.2mass = as.character(round(par[idx,12]*1000))
    err.nd4 = as.character(round(par[idx,13]*1000))
    ## while (nchar(err.2mass) < 3) {
    ##     err.2mass = paste0('0',err.2mass)
    ## }
    ## while (nchar(err.nd4) < 3) {
    ##     err.nd4 = paste0('0',err.nd4)
    ## }
    err.nd4 = gsub('0','-',err.nd4)
    obj = lst[i.dat,1]
    idx = objs == alias
    if (sum(idx) != 1) stop(obj)
    f.clc = fs.clc[idx]
    lf.clc = paste0(clc.dir, f.clc)
    lc = read.table(lf.clc)
    lc = lc[order(lc[,1]),]
    for (i in 1:nrow(lc)) {
        line.count = line.count + 1
        mjd = lc[i,1]
        mjd = as.character(mjd)
        while (nchar(mjd) < 10) {
            mjd = paste0(mjd,'0')
        }
        mag = lc[i,2]
        mag = as.character(mag)
        while (nchar(mag) < 5) {
            mag = paste0(mag,'0')
        }
        err = lc[i,3]
        err = as.character(err*1000)
        ## while (nchar(err) < 3) {
        ##     err = paste0('0',err)
        ## }
        objb = gsub('-',' ',obj)
        objb = gsub('Cma','CMa',objb)
        if (line.count < n.line) {
            ts = paste0(objb,' & ',mjd,' & ',mag,' & ',err,' & ',err.2mass,' & ',err.nd4,'\\\\')
        }
        else {
            ts = paste0(objb,' & ',mjd,' & ',mag,' & ',err,' & ',err.2mass,' & ',err.nd4)
        }
        write(ts, f.tex, append=T)
        if (line.count >=n.line) break
    }
    if (line.count >=n.line) break
}

