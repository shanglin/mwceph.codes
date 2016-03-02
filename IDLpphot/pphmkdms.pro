pro pphmkdms

str_dmt = {img:'',mjd:0.d,ph:0.d,dm:0.,stdd:0.,dof:0,sigma:0.,blim:0.,flim:0.,cx:0.,cy:0.,cm:0.,ce:0.,dit:0,p:0.}
fmt_dmt = '(A21,F12.5,F9.5,F9.3,F9.3,I5,F6.2,F8.2,F8.2,F9.3,F9.3,F9.3,F9.3,I4,F12.6)'
f_dmt = 'dm_table.dmt'
rdfile,f_dmt,str_dmt,fmt_dmt,1,dmt,nl_dmt
idx = where(dmt.dm ne -99)
dmt = dmt[idx]
for i=0,n_elements(idx)-1 do begin
   if dmt[i].stdd eq 0 then dmt[i].stdd = 0.005
   if dmt[i].ce eq 0 then dmt[i].ce = 0.001
endfor

str_dms = {mjd:0.d,dm:0.,e:0.}
dms = replicate(str_dms,nl_dmt+1)
gaps = findgap(dmt.mjd,0.15)

cnts = 0
previous_sigma = 3.
for i=0,n_elements(gaps) do begin
   window,0
   plot,findgen(nl_dmt+1),dmt.mjd,psym=2,yrange=[min(dmt.mjd)-10,max(dmt.mjd)+10],$
        ytit='MJD',xtit='observations',/yst
   for j=0,n_elements(gaps)-1 do begin
      oplot,[0,100],[gaps(j),gaps(j)]
   endfor
   if i eq 0 then god = dmt(where(dmt.mjd le gaps[0],cnt)) else $
      if i le n_elements(gaps)-1 then $
         god = dmt(where(dmt.mjd le gaps[i] and dmt.mjd gt gaps[i-1],cnt)) else $
            god = dmt(where(dmt.mjd gt gaps[i-1],cnt))
   if cnt lt 2 then message,'gaps wrong'
   replot:
   x = god.mjd
   y = god.dm
   yerr = god.stdd/sqrt(god.dof)
   oplot,findgen(cnt)+cnts,x,psym=2,color='ff00aa'x
   cnts = cnts + cnt
   window,2
   plot,x,y,psym=2,xrange=[min(x)-0.0002,max(x)+0.0002],$
        /xst,yrange=[min(y)-0.01,max(y)+0.01],/yst,background='ffffff'x,color=0,$
        ytitle='dm',xtitle='MJD'
   errplot,x,y+yerr,y-yerr,color=0
asksigma:
   sigma = asksigma(previous_sigma)
   previous_sigma = sigma
   if sigma ne -1 then begin
      if n_elements(y) ge 3 then begin
         sigmaclip1once,y,indkp,meany,stddy,sigma,indrj,yerr,/silent
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
         cnts = cnts - cnt
         keepind = where(y ne max(y))
         god = god(keepind)
      endif else begin
         cnts = cnts - cnt
         keepind = where(y ne min(y))
         god = god(keepind)
      endelse
      goto,replot
   endelse
   ngd = god(indkp)
   nx = ngd.mjd
   ny = ngd.dm
   nyerr = ngd.stdd/sqrt(ngd.dof)
   xrange = [min(nx)-0.0002,max(nx)+0.0002]
   yrange = [meany-5*stddy,meany+5*stddy]
   sym_A = FINDGEN(17) * (!PI*2/16.)
   USERSYM, COS(sym_A), SIN(sym_A),/fill
   plot,nx,ny,psym=8,yran=yrange,/yst,xran=xrange,/xst,background='ffffff'x,color=0,$
     ytitle='dm',xtitle='MJD'
   errplot,nx,ny-nyerr,ny+nyerr,color=0
   oplot,xrange,[meany-0*stddy,meany-0*stddy],color='ffaa00'x
   oplot,xrange,[meany+1*stddy,meany+1*stddy],color='00aaff'x
   oplot,xrange,[meany-1*stddy,meany-1*stddy],color='00aaff'x
satisfy2:
   satans = ''
   read,satans,prompt=' Are you satisfied? (y/n): [default y] '
   if ~(satans eq 'n' or satans eq 'N' or satans eq 'y' or satans eq 'Y' or satans eq '') then goto,satisfy2
   if satans eq 'n' or satans eq 'N' then goto,asksigma
   dof = n_elements(ngd.dm) - 1
   if dof lt 1 then dof=1
   dms[i].dm = meany
   dms[i].e = stddy/sqrt(dof)
   dms[i].mjd = mean(ngd.mjd)
endfor

dms = dms(where(dms.mjd ne 0,ndms))
f_dms = repstr(f_dmt,'.dmt','.dms')
fmt_dms = '(f12.5,f12.4,f12.4)'
openw,lun,f_dms,/get_lun
printf,lun,'     mjd         mean_dm     error_dm'
for i=0,ndms-1 do begin
   printf,lun,dms[i],format=fmt_dms
endfor
cf,lun
wdelete,0
wdelete,2
end
