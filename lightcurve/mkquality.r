outdir = '~/Work/mega/mwceph/lightcurve/20160303/quality/'
rlcdir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/'
fs.rlc = list.files(rlcdir,pattern='.*.rlc$')
nfs.rlc = length(fs.rlc)

source('fitfuns/fun.fit.Inno15.r')
load.pars()
f.cat = '~/Work/mega/mwceph/pphot/mw_new_info.dat'
cat = read.table(f.cat, header=T)
f.cor = '~/Work/mega/mwceph/lightcurve/20160303/calnd4/nonlinear.correction.dat'
cor = read.table(f.cor)

objs = unique(substr(fs.rlc,1,5))
n.objs = length(objs)

plotlc = function(lc, clc=0) {
    if (length(clc)==1) {
        plot.cor = F
    } else {
        plot.cor = T
    }
        t.ref = round(median(lc[,1]))
        phase = ((lc[,1]-t.ref)/period) %% 1
        mag = lc[,2]
        err = lc[,3]
        pars = fit.Inno15(phase,mag,err)
        xpnts = c(phase,phase+1)
        ypnts = c(mag,mag)
        sd = c(err,err)
        xc = seq(0,1,by=0.001)
        yc = calt(xc,pars[3],pars[1],pars[2],a0)
        yc = c(yc,yc)
        xc = c(xc,xc+1)
        plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=obj,xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
        arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
        abline(h=11.0,col=2,lwd=1)
        abline(h=10.5,col=2,lwd=1,lty=2)
        lines(xc,yc,col=4)
    if (plot.cor) {
        idx = clc[,2] < 11.0 & clc[,2] >= 9
        if (sum(idx) > 0) {
            t.ref = round(median(clc[,1]))
            phase = ((clc[,1]-t.ref)/period) %% 1
            mag = clc[,2]
            err = clc[,3]
            pars = fit.Inno15(phase,mag,err)
            xpnts = c(phase[idx],phase[idx]+1)
            ypnts = c(mag[idx],mag[idx])
            sd = c(err[idx],err[idx])
            xc = seq(0,1,by=0.001)
            yc = calt(xc,pars[3],pars[1],pars[2],a0)
            yc = c(yc,yc)
            xc = c(xc,xc+1)
            points(xpnts,ypnts,pch=19,cex=0.8,col=3)
            arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90,col=3)
            lines(xc,yc,col=3,lty=2)
        }
    }
}

correctlc = function(lc) {
    clc = lc
    n.ts = nrow(lc)
    for (i in 1:n.ts) {
        if (lc[i,2] < 11.0 & lc[i,2] >= 9) {
            idx = which.min(abs(lc[i,2]-cor[,1]))
            mag.cor = cor[idx,2]
            clc[i,2] = lc[i,2] - mag.cor
        }
    }
    return(clc)
}

for (i in 1:n.objs) {
    obj = objs[i]
    print(obj)
    alias = gsub('-','',obj)
    alias = toupper(alias)
    if (obj == 'lcarl') {
        alias = 'LCAR'
    }
    if (obj == 'lcarr') {
        alias = 'LCAR'
    }
    period = cat[cat[,'alias']==alias,'period']

    
    f.h = paste0(obj,'_h.rlc')
    f.n = paste0(obj,'_n.rlc')
    lf.h = paste0(rlcdir,f.h)
    lf.n = paste0(rlcdir,f.n)
    f.pdf = paste0(outdir,obj,'.pdf')
    pdf(f.pdf,width=6,height=9)
    par(mfrow=c(2,1))
    if (file.exists(lf.h) & file.exists(lf.n)) {
        lc = read.table(lf.h)
        clc = correctlc(lc)
        plotlc(lc,clc)
        lc = read.table(lf.n)
        plotlc(lc)
    } else {
        if (file.exists(lf.h)) {
            lc = read.table(lf.h)
            clc = correctlc(lc)
            plotlc(lc,clc)
        } else {
            lc = read.table(lf.n)
            plotlc(lc)
        }
    }
    dev.off()
}
