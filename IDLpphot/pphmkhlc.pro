pro pphmkhlc

str_dmt = {img:'',mjd:0.d,ph:0.d,dm:0.,stdd:0.,dof:0,sigma:0.,blim:0.,flim:0.,cx:0.,cy:0.,cm:0.,ce:0.,dit:0,p:0.}
fmt_dmt = '(A21,F12.5,F9.5,F9.3,F9.3,I5,F6.2,F8.2,F8.2,F9.3,F9.3,F9.3,F9.3,I4,F12.6)'
f_dmt = 'dm_table.dmt'
rdfile,f_dmt,str_dmt,fmt_dmt,1,dmt,nl_dmt

str_dms = {mjd:0.d,dm:0.,e:0.}
fmt_dms = '(f12.5,f12.4,f12.4)'
f_dms = repstr(f_dmt,'.dmt','.dms')
rdfile,f_dms,str_dms,fmt_dms,1,dms,nl_dms

sym_A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(sym_A), SIN(sym_A),/fill

wd = getwd()
obj = repstr(strmid(wd,strlen(wd)-11,6),'/','')
sobj = rmfgspc(obj)

fmt_dat = '(A21,F12.5,F9.5,F9.3,F9.3,I5,F6.2,F8.2,F8.2,F9.3,F9.3,F9.3,F9.3,I4,F10.4,4f12.4,I4)'

if 1 then begin
previous_sigma = 3.   
openw,l_dat,rmfgspc(obj)+'_hlc.dat',/get_lun
printf,l_dat,'         image            mjd       phase       dm      stdd  dof sigma  brilim  fntlim   cephx    cephy    cephm     cephe dither period     mean_dm    error_dm      mean_cm     mean_ce flag'
for i_dms=0,nl_dms do begin
   ts = dms[i_dms]
   god = dmt(where(abs(dmt.mjd-ts.mjd) le 0.5,cnt))
   if cnt lt 2 then message,' Observations less than 2 for '+ts.mjd
   replot:
   window,0
   x = god.mjd
   y = god.cm
   oy = y
   yerr = sqrt(god.ce^2+ts.e^2)
   oyerr = yerr
   plot,x,y,psym=8,xrange=[min(x)-0.0002,max(x)+0.0002],/xsty,$
        yrange=[min(y)-0.01,max(y)+0.01],/yst,background='ffffff'x,$
        color=0
   errplot,x,y+yerr,y-yerr,color=0
   asksigma:
   sigma = asksigma(previous_sigma)
   previous_sigma = sigma
   if sigma ne -1 then begin
      if n_elements(oy) ge 3 then begin
         sigmaclip1once,oy,indkp,meany,stddy,sigma,indrj,oyerr,/silent
      endif else begin
         indkp = findgen(n_elements(y))
         meany = poly_fit(indkp,y,0,measure_errors=yerr)
         stddy = (max(y)-min(y))/2
         indrj = []
      endelse
   endif else begin
      uporlow = ''
      while ~(uporlow eq 'u' or uporlow eq 'l') do begin
         read,uporlow,prompt=' Remove upper or lower point? (u/l): '
      endwhile
      if uporlow eq 'u' then begin
         keepind = where(y ne max(y))
         god = god(keepind)
      endif else begin
         keepind = where(y ne min(y))
         god = god(keepind)
      endelse
      goto,replot
   endelse
   ngd = god(indkp)
   x = ngd.mjd
   y = ngd.cm
   yerr = sqrt(ngd.ce^2+ts.e^2)
   xrange = [min(x)-0.0002,max(x)+0.0002]
   yrange = [min(y)-0.01,max(y)+0.01]
   plot,x,y,psym=8,yran=yrange,/yst,xran=xrange,/xst,background='ffffff'x,$
        color=0,ytitle='dm',xtitle='MJD'
   errplot,x,y-yerr,y+yerr,color=0
   oplot,xrange,[meany-0*stddy,meany-0*stddy],color='ffaa00'x
   oplot,xrange,[meany+1*stddy,meany+1*stddy],color='00aaff'x
   oplot,xrange,[meany-1*stddy,meany-1*stddy],color='00aaff'x
satisfy:
   satans = ''
   read,satans,prompt=' Are you satisfied? (y/n): [default y] '
   if ~(satans eq 'n' or satans eq 'N' or satans eq 'y' or satans eq 'Y' or satans eq '') $
   then goto,satisfy
   if satans eq 'n' or satans eq 'N' then goto,asksigma

   for j_god=0,n_elements(god.cm)-1 do begin
      tsd = god[j_god]
      if abs(tsd.cm-meany) gt sigma*stddy then flag=1 else flag=0
      printf,l_dat,tsd,ts.dm,ts.e,meany,stddy/sqrt(n_elements(indkp)-1),flag,format=fmt_dat
   endfor
endfor
cf,l_dat
endif


if 0 then begin
str_dat = {img:'',mjd:0.d,ph:0.d,dm:0.,stdd:0.,dof:0,sigma:0.,blim:0.,flim:0.,cx:0.,cy:0.,cm:0.,ce:0.,dit:0,p:0.,mndm:0.,mndme:0.,mncm:0.,mnce:0.,flag:0}
f_dat = rmfgspc(obj)+'_hlc.dat'
rdfile,f_dat,str_dat,fmt_dat,1,dat,nl_dat
god = dat(where(dat.flag eq 0 and dat.mndm-min(dat.mndm) lt 0.5,cnt,complement=indbad))
plotbad = 0
if cnt lt nl_dat+1 then begin
   bad = dat(indbad)
   plotbad = 1
endif

x = god.ph
y = god.cm - god.mndm
yerr = sqrt(god.ce^2 + god.mndme^2)
x = [x,x+1]
y = [y,y]
yerr = [yerr,yerr]
p1 = errorplot(x,y,yerr,'o',sym_filled=1,sym_size=0.5,xtit='Phase',ytit='Instrumental H (mag)',color='black',errorbar_capsize=0.1)
if plotbad then begin
   x = bad.ph
   y = bad.cm - bad.mndm
   yerr = sqrt(bad.ce^2 + bad.mndme^2)
   x = [x,x+1]
   y = [y,y]
   yerr = [yerr,yerr]
   p11 = errorplot(x,y,yerr,'o',sym_filled=0,sym_size=0.5,errorbar_color='grey',color='grey',/overplot,errorbar_capsize=0.1)
endif
t1 = text(0.2,0.8,strupcase(obj))
t2 = text(0.75,0.8,'P='+flt3digitstr(dat[0].p))
print,'  >>> Please flip the p1.yrange'
stop
p1.save,sobj+'_hlc_all.eps'
p1.save,sobj+'_hlc_all.png'
p1.close

if plotbad then begin
   x = bad.ph
   y = bad.mncm - bad.mndm
   yerr = sqrt(bad.mnce^2 + bad.mndme^2)
   x = [x,x+1]
   y = [y,y]
   yerr = [yerr,yerr]
   p11 = errorplot(x,y,yerr,'o',sym_filled=0,sym_size=0.7,errorbar_color='grey',color='grey',errorbar_capsize=0.1)
endif

x = god.ph
y = god.mncm - god.mndm
yerr = sqrt(god.mnce^2 + god.mndme^2)
x = [x,x+1]
y = [y,y]
yerr = [yerr,yerr]
p1 = errorplot(x,y,yerr,'o',sym_filled=1,sym_size=0.7,xtit='Phase',ytit='Instrumental H (mag)',color='black',errorbar_capsize=0.1,/overplot)

t1 = text(0.2,0.8,strupcase(obj))
t2 = text(0.75,0.8,'P='+flt3digitstr(dat[0].p))
print,'  >>> Please flip the p1.yrange'
stop
p1.save,sobj+'_hlc.eps'
p1.save,sobj+'_hlc.png'
p1.close
endif

ophmkhulc
end
