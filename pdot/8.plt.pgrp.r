dir = '~/Work/mega/mwceph/pdot/cal.pdot/peps/'
fs = list.files(dir)
n = length(fs)


pdf('Rplots.pdf', width=8, height=4)
for (i in 1:n) {
    f = fs[i]
    lf = paste0(dir, f)
    dat = read.table(lf)
    x = dat[,1]
    y = dat[,2]
    e = dat[,3]
    ylim = c(min(y-e)-1e-2, max(y+e)+1e-2)
    xlim = c(min(x)-900, max(x)+900)
    plot(x, y, pch=1, cex=1, ylim = ylim, xlim=xlim, main=f, xlab='JD-2400000', ylab='Period [day]')
    arrows(x, y-e, x, y+e, code=3, angle=90, length=0.01)
    dx = 0
    dy = (ylim[2] - ylim[1])*0.1
    dys = rep(dy, nrow(dat))
    dys[y > mean(ylim)] = -1*dy
    text(x+dx, y+dys, dat[,4], adj=0.5, col='grey')
    points(x, y)
}
dev.off()


eplim = 0.006
f.tmp = 'tmp.pep'
write('# obj  period    eperiod    type', f.tmp)
figdir = '~/Work/mega/mwceph/pdot/cal.pdot/figs/'
f.pdf = paste0(figdir, 'periods.pdf')
pdf(f.pdf, width=8, height=4)
for (i in 1:n) {
    f = fs[i]
    obj = substr(f, 1,5)
    lf = paste0(dir, f)
    dat = read.table(lf)
    dat = dat[order(dat[,1]),]

    x = dat[,1]
    y = dat[,2]
    e = dat[,3]
    ylim = c(min(y-e)-1e-2, max(y+e)+1e-2)
    if (max(e)>90)
        ylim = c(min(y)-1e-2, max(y)+1e-2)
    xlim = c(min(x)-900, max(x)+900)

    
    idx = dat[,3] < eplim
    god = dat[idx,]
    bad.exist = 0
    if (sum(idx) < nrow(dat)) {
        bad = dat[!idx,]
        bad.exist = 1
    }
    
    x = god[,1]
    y = god[,2]
    e = god[,3]
    plot(x, y, pch=1, cex=1, ylim = ylim, xlim=xlim, main=obj, xlab='JD-2400000', ylab='Period [day]')
    arrows(x, y-e, x, y+e, code=3, angle=90, length=0.01)
    dx = 0
    dy = (ylim[2] - ylim[1])*0.1
    dys = rep(dy, nrow(god))
    dys[y > mean(ylim)] = -1*dy
    if (length(dys) >= 3)
        dys[length(dys)-1] = 2 * dys[length(dys)-1]
    text(x+dx, y+dys, god[,4], adj=0.5, col='black')
    points(x, y)

    if (bad.exist == 1) {
        x = bad[,1]
        y = bad[,2]
        e = bad[,3]
        ## ylim = c(min(y-e)-1e-2, max(y+e)+1e-2)
        xlim = c(min(x)-900, max(x)+900)
        points(x, y, pch=1, cex=1, col='grey')
        arrows(x, y-e, x, y+e, code=3, angle=90, length=0.01, col='grey')
        dx = 0
        dy = (ylim[2] - ylim[1])*0.1
        dys = rep(dy, nrow(bad))
        dys[y > mean(ylim)] = -1*dy
        text(x+dx, y+dys, bad[,4], adj=0.5, col='grey')
        points(x, y, col='grey')
    }

    idx = god[,4] == 'asas_old' | god[,4] == 'iomc' | god[,4] == 'asas_new'
    if (sum(idx) == 1) {
        period = god[idx,2]
        eperiod = god[idx,3]
        points(god[idx,1],period, pch=19, cex=0.5, col=2)
        abline(h=period, col=4, lty=2)
        ts = paste(obj, period, eperiod, 'a', sep='    ')
    }
    if (sum(idx) > 1) {
        sub = god[idx,]
        period = sum(1/sub[,3]^2 * sub[,2]) / sum(1/sub[,3]^2)
        eperiod = sd(sub[,2])
        if (is.na(eperiod)) eperiod = max(sub[,2]) - min(sub[,2])
        points(sub[,1], sub[,2], pch=19, cex=0.5, col=2)
        abline(h=period, col=4, lty=2)
        ts = paste(obj, period, eperiod, 'b', sep='    ')
    }
    if (sum(idx) == 0) {
        sub = god
        if (nrow(sub) == 1) {
            period = sub[1,2]
            eperiod = NA
            ts = paste(obj, period, eperiod, 'c', sep='    ')
        } else {
            period = sum(1/sub[,3]^2 * sub[,2]) / sum(1/sub[,3]^2)
            eperiod = sd(sub[,2])
            ## eperiod = NA
            ts = paste(obj, period, eperiod, 'd', sep='    ')
        }
        points(sub[,1], sub[,2], pch=19, cex=0.5, col=2)
        abline(h=period, col=4, lty=2)
    }
    write(ts, f.tmp, append=T)
}
dev.off()

pep = read.table(f.tmp)
pep[,1] = as.character(pep[,1])
pep[,4] = as.character(pep[,4])
idx = which(pep[,4] == 'c')
for (i in idx) {
    tsobj = pep[i,1]
    lf = paste0(dir, tsobj, '_pep_group.dat')
    dat = read.table(lf)
    dat[,4] = as.character(dat[,4])
    tsidx = dat[,3] < eplim
    dat = dat[tsidx,]
    grp = dat[1,4]
    sub = pep[pep[,4] == 'a' | pep[,4] == 'b',]
    diffs = rep(NA, nrow(sub))
    for (isub in 1:nrow(sub)) {
        obj = sub[isub,1]
        lf = paste0(dir, obj, '_pep_group.dat')
        odat = read.table(lf)
        odat[,4] = as.character(odat[,4])
        tsidx = odat[,3] < eplim
        odat = odat[tsidx,]
        tsidx = odat[,4] == grp
        if (sum(tsidx) == 1) {
            diffs[isub] = odat[tsidx,2] - sub[isub,2]
        }
    }
    pep[i,3] = sd(diffs, na.rm=T)
}

idx = which(pep[,4] == 'd')
for (i in idx) {
    tsobj = pep[i,1]
    sdperiod = pep[i,3]
    lf = paste0(dir, tsobj, '_pep_group.dat')
    dat = read.table(lf)
    dat[,4] = as.character(dat[,4])
    tsidx = dat[,3] < eplim
    dat = dat[tsidx,]
    grps = dat[,4]
    sub = pep[pep[,4] == 'a' | pep[,4] == 'b',]
    diffs = rep(NA, nrow(sub))
    for (isub in 1:nrow(sub)) {
        obj = sub[isub,1]
        lf = paste0(dir, obj, '_pep_group.dat')
        odat = read.table(lf)
        odat[,4] = as.character(odat[,4])
        tsidx = odat[,3] < eplim
        odat = odat[tsidx,]
        tsidx = odat[,4] %in% grps
        if (sum(tsidx) == length(grps)) {
            operiod = sum(1/odat[tsidx,3]^2 * odat[tsidx,2]) / sum(1/odat[tsidx,3]^2)
            diffs[isub] = operiod - sub[isub,2]
        }
    }
    diffs = diffs[!is.na(diffs)]
    if (length(diffs)==1) eperiod = abs(diffs[1])
    if (length(diffs)==2) eperiod = abs(diffs[1] - diffs[2])
    if (length(diffs)>2) eperiod = sd(diffs)
    pep[i,3] = max(sdperiod,eperiod)
}

f.out = '~/Work/mega/mwceph/pdot/cal.pdot/period_eperiod.dat'
ts = '#   id     period    eperiod    type'
write(ts, f.out)
out = do.call('sprintf', c('%7s%12.6f%11.6f%4s',pep))
write(out, f.out, append=T)



## pep = read.table(f.tmp)
## pep[,1] = as.character(pep[,1])
## pep[,4] = as.character(pep[,4])
## idx = which(is.na(pep[,3]))
## for (i in idx) {
##     tsobj = pep[i,1]
##     lf = paste0(dir, tsobj, '_pep_group.dat')
##     dat = read.table(lf)
##     dat[,4] = as.character(dat[,4])
##     idx = dat[,3] < eplim
##     dat = dat[idx,]
##     if (nrow(dat) == 1) {
##         grp = dat[1,4]
##         sub = pep[pep[,4] == 'a' | pep[,4] == 'b',]
##         diffs = rep(NA, nrow(sub))
##         for (isub in 1:nrow(sub)) {
##             obj = sub[isub,1]
##             lf = paste0(dir, obj, '_pep_group.dat')
##             odat = read.table(lf)
##             odat[,4] = as.character(odat[,4])
##             idx = odat[,3] < eplim
##             odat = odat[idx,]
##             idx = odat[,4] == grp
##             if (sum(idx) == 1) {
##                 diffs[isub] = odat[idx,2] - sub[isub,2]
##             }
##         }
##     } else {
##         grps = dat[,4]
##         sub = pep[pep[,4] == 'a' | pep[,4] == 'b',]
##         diffs = rep(NA, nrow(sub))
##         for (isub in 1:nrow(sub)) {
##             obj = sub[isub,1]
##             lf = paste0(dir, obj, '_pep_group.dat')
##             odat = read.table(lf)
##             odat[,4] = as.character(odat[,4])
##             idx = odat[,3] < eplim
##             odat = odat[idx,]
##             idx = odat[,4] %in% grps
##             if (sum(idx) == length(grps)) {
##                 operiod = sum(1/odat[idx,3]^2 * odat[idx,2]) / sum(1/odat[idx,3]^2)
##                 diffs[isub] = operiod - sub[isub,2]
##             }
##         }
##         print(diffs)
##     }
##     eperiod = sd(diffs, na.rm=T)
##     pep[i,3] = eperiod
## }
