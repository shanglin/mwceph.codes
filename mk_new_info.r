
## str_dat = {id:0,obj:'',alias:'',ra:'',dec:'',p:0.}
## fmt_dat = '(I4,A11,A11,A10,A11,F9.4)'
f.dat = '~/Work/mega/mwceph/pphot_bf_2016_02_16/mw_info.dat'
dat = read.table(f.dat,header=T)
dat[,2] = as.character(dat[,2])
dat[,3] = as.character(dat[,3])
dat[,4] = as.character(dat[,4])
dat[,5] = as.character(dat[,5])
d2 = dat[1,]
d2[1,1] = 47
d2[1,2] = 'W-SGR'
d2[1,3] = 'WSGR'
d2[1,4] = '18:04:36'
d2[1,5] = '-29:32:17'
d2[1,6] = -1
dat = rbind(dat,d2)

f.phat1 = '~/Work/mega/mwceph/pphot/period_all/ehat.dat.part1'
phat1 = read.table(f.phat1,skip=1)

f.phat2 = '~/Work/mega/mwceph/pphot/period_all/model_per/phat/objper_it3.lst'
phat2 = read.table(f.phat2)

phat = rbind(phat1[,1:2],phat2)
phat[,1] = as.character(phat[,1])
phat[,1] = toupper(phat[,1])

dat[,'period'] = -1
for (i in 1:nrow(phat)) {
    id = phat[i,1]
    id = gsub('-','',id)
    if (id == 'LCARL') {
        id = 'LCAR'
    }
    idx = dat[,'alias'] == id
    if (sum(idx) == 1) {
        dat[idx,'period'] = phat[i,2]
    }
}

f.new = '~/Work/mega/mwceph/pphot/mw_new_info.dat'
ts = '  id      obj        alias     ra        dec     period'
write(ts,f.new)
fmt = '%4i%11s%11s%10s%11s%12.6f'
for (i in 1:nrow(dat)) {
    ts = sprintf(fmt,dat[i,1],dat[i,2],dat[i,3],dat[i,4],dat[i,5],dat[i,6])
    write(ts,f.new,append=T)
}
