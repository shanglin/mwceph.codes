dir = '~/Work/mega/mwceph/phase_corr/20160609/'
f.par = '~/Work/mega/mwceph/lightcurve/20160604/calilcs/mw_ceph_pars.dat'
f.hst = paste0(dir, 'query_result.csv')

par = read.table(f.par, stringsAsFactors = F)
hst = read.csv(f.hst, stringsAsFactors = F, header = T)

f.out = paste0(dir, 'obj_hst_jd.dat')
ts = '#  obj    HST_identification   JD-2450000'
write(ts, f.out)

calendar2jd = function(cal) {
    cal = as.numeric(cal)
    ret = 367*cal[1] -
        floor(7 * (cal[1] + floor((cal[2]+9)/12))/4) -
            floor(3 * floor(( cal[1] + (cal[2] - 9)/7)/100 + 1)/4) +
                floor(275 * cal[2]/9) + cal[3] +
                    1721028.5 +
                        cal[4]/24 + cal[5]/1440 + cal[6]/86400
    return(ret)
}

npar = nrow(par)
for (i in 1:npar) {
    obj = par[i,1]
    alias = par[i,3]
    if (obj == 'betad') alias = 'BET-DOR'
    idx = hst[,2] == alias | hst[,2] == paste0(alias, '-OFF') |  hst[,2] == paste0('V-',alias) | hst[,2] == paste0('V-', alias, '-OFF')
    if (sum(idx) < 1)
        stop(obj)
    sub = hst[idx,]
    for (k in 1:nrow(sub)) {
        t1 = sub[k, 'Start.Time']
        t2 = sub[k, 'Stop.Time']
        y = substr(t1,1,4)
        m = substr(t1,6,7)
        d = substr(t1,9,10)
        hh = substr(t1,12,13)
        mm = substr(t1,15,16)
        ss = substr(t1,18,19)
        calendar = c(y, m, d, hh, mm, ss)
        jd1 = calendar2jd(calendar)
        y = substr(t2,1,4)
        m = substr(t2,6,7)
        d = substr(t2,9,10)
        hh = substr(t2,12,13)
        mm = substr(t2,15,16)
        ss = substr(t2,18,19)
        calendar = c(y, m, d, hh, mm, ss)
        jd2 = calendar2jd(calendar)
        jd = 0.5 * (jd1 + jd2)
        mmjd = jd - 2450000
        ts = sprintf('%10s%15s%15.5f', obj, sub[k,2], mmjd)
        write(ts, f.out, append = T)
    }
}

