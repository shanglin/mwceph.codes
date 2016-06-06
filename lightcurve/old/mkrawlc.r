dir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/tmp/'
outdir = '~/Work/mega/mwceph/lightcurve/20160303/rawlcs/'
figdir = paste0(outdir,'figs/')
fs = list.files(dir,pattern='.*.slc$')
objs = unique(substr(fs,1,5))
n.objs = length(objs)

f.cat = '~/Work/mega/mwceph/pphot/mw_new_info.dat'
cat = read.table(f.cat, header=T)
source('fitfuns/fun.fit.Inno15.r')
load.pars()

for (i in 7:n.objs) {
    obj = objs[i]
    f.dm = paste0('~/Work/mega/mwceph/pphot/',obj,'/2mass/dh_aper-2mass.txt')
    if (!file.exists(f.dm)) {
        f.dm = paste0('~/Work/mega/mwceph/pphot_bf_2016_02_16/',obj,'/2mass/dh_aper-2mass.txt')
    }
    if (obj == 'lcarl')
        f.dm = '~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/2massl/dh_aper-2mass.txt'
    if (obj == 'lcarr')
        f.dm = '~/Work/mega/mwceph/pphot_bf_2016_02_16/l-car/2massr/dh_aper-2mass.txt'
    dm = read.table(f.dm)[1,1]
    
    alias = gsub('-','',obj)
    alias = toupper(alias)
    if (obj == 'lcarl') {
        alias = 'LCAR'
    }
    if (obj == 'lcarr') {
        alias = 'LCAR'
    }
    period = cat[cat[,'alias']==alias,'period']
    
    f.h = paste0(obj,'_h.slc')
    f.n = paste0(obj,'_n.slc')
    lf.h = paste0(dir,f.h)
    lf.n = paste0(dir,f.n)
    
    if (file.exists(lf.h)) {
        lc = read.table(lf.h,header=T)
        t.ref = round(median(lc[,1]))
        phase = ((lc[,1]-t.ref)/period) %% 1
        mag = lc[,3] - dm
        err = lc[,4]
        pars = fit.Inno15(phase,mag,err)

        xpnts = c(phase,phase+1)
        ypnts = c(mag,mag)
        sd = c(err,err)
        xc = seq(0,1,by=0.001)
        yc = calt(xc,pars[3],pars[1],pars[2],a0)
        yc = c(yc,yc)
        xc = c(xc,xc+1)

        rlc = lc[,c(1,3,4,5)]
        rlc[,4] = 1
        
        for (ibad in 1:nrow(lc)) {
            plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=obj,xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
            arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
            abline(h=6.9,col=2,lwd=2)
            lines(xc,yc,col=4)
            idx = ypnts == mag[ibad] & sd == err[ibad]
            points(xpnts[idx],ypnts[idx],cex=2.5,col=2,pch=12)
            keep = ''
            while (!(keep == 'y' | keep == 'n')) {
                keep = readline(' Is this observation good? (y/n)   ')
            }
            if (keep == 'n') rlc[ibad,4] = 0
        }
        if (sum(rlc[,4]==0)>0) {
            rlc = rlc[rlc[,4] == 1,]
            t.ref = round(median(rlc[,1]))
            phase = ((rlc[,1]-t.ref)/period) %% 1
            mag = rlc[,2] - dm
            err = rlc[,3]
            pars = fit.Inno15(phase,mag,err)
            xpnts = c(phase,phase+1)
            ypnts = c(mag,mag)
            sd = c(err,err)
            xc = seq(0,1,by=0.001)
            yc = calt(xc,pars[3],pars[1],pars[2],a0)
            yc = c(yc,yc)
            xc = c(xc,xc+1)
        }
        f.png = paste0(figdir,f.h,'.png')
        png(f.png)
        plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=obj,xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
        arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
        abline(h=6.9,col=2,lwd=2)
        lines(xc,yc,col=4)
        dev.off()
        plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=obj,xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
        arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
        abline(h=6.9,col=2,lwd=2)
        lines(xc,yc,col=4)
        keep = 'y'
        while (!(keep == 'y' | keep == 'n')) {
            keep = readline(' Keep this light curve (y/n)   ')
        }
        if (keep == 'y') {
            f.rlc = paste0(outdir,gsub('.slc','.rlc',f.h))
            write.table(rlc[,1:3],f.rlc,sep='   ',row.names=F,col.names=F)
        }
    }

    ## take care of ND4 light curves
    if (file.exists(lf.n)) {
        lc = read.table(lf.n,header=T)
        t.ref = round(median(lc[,1]))
        phase = ((lc[,1]-t.ref)/period) %% 1
        mag = lc[,3] - dm
        err = lc[,4]
        pars = fit.Inno15(phase,mag,err)

        xpnts = c(phase,phase+1)
        ypnts = c(mag,mag)
        sd = c(err,err)
        xc = seq(0,1,by=0.001)
        yc = calt(xc,pars[3],pars[1],pars[2],a0)
        yc = c(yc,yc)
        xc = c(xc,xc+1)

        rlc = lc[,c(1,3,4,5)]
        rlc[,4] = 1
        for (ibad in 1:nrow(lc)) {
            plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=paste(obj,'ND4'),xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
            arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
            abline(h=6.9,col=2,lwd=2)
            lines(xc,yc,col=4)
            idx = ypnts == mag[ibad] & sd == err[ibad]
            points(xpnts[idx],ypnts[idx],cex=2.5,col=2,pch=12)
            keep = ''
            while (!(keep == 'y' | keep == 'n')) {
                keep = readline(' Is this observation good? (y/n)   ')
            }
            if (keep == 'n') rlc[ibad,4] = 0
        }
        if (sum(rlc[,4]==0)>0) {
            rlc = rlc[rlc[,4] == 1,]
            t.ref = round(median(rlc[,1]))
            phase = ((rlc[,1]-t.ref)/period) %% 1
            mag = rlc[,2] - dm
            err = rlc[,3]
            pars = fit.Inno15(phase,mag,err)
            xpnts = c(phase,phase+1)
            ypnts = c(mag,mag)
            sd = c(err,err)
            xc = seq(0,1,by=0.001)
            yc = calt(xc,pars[3],pars[1],pars[2],a0)
            yc = c(yc,yc)
            xc = c(xc,xc+1)
        }
        f.png = paste0(figdir,f.n,'.png')
        png(f.png)
        plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=paste(obj,'ND4'),xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
        arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
        abline(h=6.9,col=2,lwd=2)
        lines(xc,yc,col=4)
        dev.off()
        plot(xpnts,ypnts,pch=19,cex=0.8,ylim=c(max(yc)+0.2,min(yc)-0.2),main=paste(obj,'ND4'),xlim=c(0,2),xlab='Phase',ylab='Instrumental I (mag)')
        arrows(xpnts,ypnts-sd,xpnts,ypnts+sd, code=3, length=0.02, angle = 90)
        abline(h=6.9,col=2,lwd=2)
        lines(xc,yc,col=4)
        keep = 'y'
        while (!(keep == 'y' | keep == 'n')) {
            keep = readline(' Keep this light curve (y/n)   ')
        }
        if (keep == 'y') {
            f.rlc = paste0(outdir,gsub('.slc','.rlc',f.n))
            write.table(rlc[,1:3],f.rlc,sep='   ',row.names=F,col.names=F)
        }
    }
}
