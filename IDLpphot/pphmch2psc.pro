pro pphmch2psc,sigma_hold,fit_low_lim,fit_high_lim

if n_elements(sigma_hold) eq 0 then sigma_hold = 2.5

fitlim = [9.5,13.5]
root = 'master_smt'

spawn,'cp ../psf/master_smt.als .'
spawn,'cp ../photh/master_smt.alf .'
;; spawn,'cp ../photh/fit_result.log .'
if n_elements(fit_low_lim) eq 0 then begin
   if ~file_test('../phothh/fit_result.log') then begin
      fit_low_lim = -99.
      fit_high_lim = 99.
   endif else begin
      readcol,'fit_result.log',foo1,foo2,fit_low_lim,fit_high_lim,skipline=1,/silent
   endelse
endif
if n_elements(fit_high_lim) eq 0 and n_elements(fit_low_lim) ne 0 then begin
   if ~file_test('../phothh/fit_result.log') then begin
      fit_low_lim = -99.
      fit_high_lim = 99.
   endif else begin
      readcol,'fit_result.log',foo1,foo2,foo3,fit_high_lim,skipline=1,/silent
   endelse
endif

openw,l_do,'domch.do',/get_lun
spawn,'rm -f *.mch *.tfr *.mtr'
printf,l_do,'master_smt.alf'
printf,l_do,''
printf,l_do,'psc.alf'
printf,l_do,''
printf,l_do,''
printf,l_do,'e'
printf,l_do,''
cf,l_do
spawn,'daomatch < domch.do > domch.log'
openw,l_do,'domch.do',/get_lun
printf,l_do,'master_smt'
printf,l_do,'2,1,2'
printf,l_do,'0.25'
printf,l_do,'20'
printf,l_do,'-5'
for ifoo=0,10 do printf,l_do,'5'
for ifoo=0,10 do printf,l_do,'4'
for ifoo=0,10 do printf,l_do,'3'
for ifoo=0,10 do printf,l_do,'2'
printf,l_do,'0'
for ifoo=1,4 do printf,l_do,'n'
printf,l_do,'y'
for ifoo=1,2 do printf,l_do,''
printf,l_do,'y'
printf,l_do,''
printf,l_do,'n'
printf,l_do,'y'
cf,l_do
spawn,'daomaster < domch.do >> domch.log'

openw,l_do,'domch.do',/get_lun
spawn,'rm -f *.mch *.mtr'
printf,l_do,'psc.alf'
printf,l_do,''
printf,l_do,'master_smt.als'
printf,l_do,''
printf,l_do,''
printf,l_do,'e'
printf,l_do,''
cf,l_do
spawn,'daomatch < domch.do >> domch.log'
openw,l_do,'domch.do',/get_lun
printf,l_do,'psc'
printf,l_do,'2,1,2'
printf,l_do,'0.25'
printf,l_do,'20'
printf,l_do,'-5'
for ifoo=0,10 do printf,l_do,'5'
for ifoo=0,10 do printf,l_do,'4'
for ifoo=0,10 do printf,l_do,'3'
for ifoo=0,10 do printf,l_do,'2'
;for ifoo=0,10 do printf,l_do,'1'
printf,l_do,'0'
for ifoo=1,4 do printf,l_do,'n'
printf,l_do,'y'
for ifoo=1,2 do printf,l_do,''
printf,l_do,'y'
printf,l_do,''
printf,l_do,'n'
printf,l_do,'y'
cf,l_do
spawn,'daomaster < domch.do >> domch.log'

f_cmp = root + '.cmp'
str_cmp = {id1:0l,x1:0.,y1:0.,m1:0.,e1:0.,id2:0l,x2:0.,y2:0.,m2:0.,e2:0.}


fmt_al = '(I7,3(F9.3),F9.4)'
str_al = {id:0l,x:0.,y:0.,m:0.,e:0.}
fmt_tfr = '(I7,2(F9.3),2(I7))'
str_tfr = {id:0l,x:0.,y:0.,f1:0l,f2:0l}
f_tfr = root + '.tfr'
if (~file_test(f_tfr)) then begin
   stop,'Match by hand and use pphmch2psc_byhand.pro'
endif
rdfile,f_tfr,str_tfr,fmt_tfr,3,tfr,nl_tfr
cmp = replicate(str_cmp,nl_tfr+1)
qs = fltarr(nl_tfr+1)

;f_als = root + '.als'
f_als = 'psc.alf'
f_alf = root + '.alf'
rdfile,f_alf,str_al,fmt_al,3,alf,nl_alf
rdfile,f_als,str_al,fmt_al,3,als,nl_als

for i = 0, nl_tfr do begin
   ts = tfr[i]
   id = ts.id
   nl1 = tfr(i).f1
   nl2 = tfr(i).f2
   cmp[i].id1 = alf[nl1-1].id
   cmp[i].x1 = alf[nl1-1].x
   cmp[i].y1 = alf[nl1-1].y
   cmp[i].m1 = alf[nl1-1].m
   cmp[i].e1 = alf[nl1-1].e
   cmp[i].id2 = als[nl2-1].id
   cmp[i].x2 = als[nl2-1].x
   cmp[i].y2 = als[nl2-1].y
   cmp[i].m2 = als[nl2-1].m
   cmp[i].e2 = als[nl2-1].e
endfor
y = cmp.m1-cmp.m2
yrange = [mean(y)-0.5,mean(y)+0.5]
ind = where(cmp.y1 gt 240 and cmp.y1 lt 260,cnt)
if cnt ge 1 then qs[ind] = 1
ind = where(cmp.m1 eq max(cmp.m1))
xc = cmp[ind].x1
yc = cmp[ind].y1
ind = where((cmp.x1-xc)^2+(cmp.y1-yc)^2 le 625,cnt)
if cnt ge 1 then qs[ind] = 2
ind = where(cmp.e1 ge 0.1 or cmp.e1 ge 0.1,cnt)
if cnt ge 1 then qs[ind] = 3

ind = where(qs eq 0,cnt)
god = cmp[ind]

x = god.m2 ; 2MASS H
y = god.m1 - god.m2 ; Aper - 2MASS
xerr = god.e2
yerr = sqrt(god.e1^2+god.e2^2)
ind = where(x ge fitlim[0] and x le fitlim[1] and x+y ge fit_low_lim[0] and x+y le fit_high_lim[0],cnt)
fit = god[ind]
x2 = fit.m2
y2 = fit.m1 - fit.m2
yerr2 = sqrt(fit.e1^2+fit.e2^2)
xerr2 = fit.e2
sigmaclip1once,y2,kp,mn,stdd,sigma_hold,rj,yerr2
x2 = x2[kp]
y2 = y2[kp]
xerr2 = xerr2[kp]
yerr2 = yerr2[kp]
replotaper:
sigmaclip1once,y2,kp,mn,stdd,sigma_hold+30,rj,yerr2
gray = 'aaaaaa'x
xrange = [5,16.5]
capsize = 0.
p = errorplot(x,y,xerr,yerr,'o',linestyle='',color=gray,sym_filled=0,sym_size=0.7,errorbar_color=gray,xrange=xrange,errorbar_capsize=capsize)
p.title = 'Aperture Photometry'
p.xtitle='2MASS H (mag)'
p.ytitle='$\Delta$H (mag)'
p2 = errorplot(x2,y2,xerr2,yerr2,'o',sym_filled=1,sym_size=0.7,color='black',errorbar_color='black',/overplot,errorbar_capsize=capsize)
dh = mn
edh = stdd/sqrt(n_elements(kp)-1)
p3 = plot(xrange,[dh,dh],color='red',/overplot)
p3 = plot(xrange,[dh,dh]+stdd,color='blue',linestyle='--',/overplot)
p3 = plot(xrange,[dh,dh]-stdd,color='blue',linestyle='--',/overplot)
p.yrange = [dh-5*stdd,dh+5*stdd]
t = text(0.2,0.78,'<$\Delta$H> = '+flt3digitstr(dh)+' $\pm$ '+flt3digitstr(edh))
askrejaper:
sat = 'y'
print,'Are you satisfied with the cut? (y/u/l)'
read,sat
if ~(sat eq 'y' or sat eq 'u' or sat eq 'l') then goto,askrejaper
if sat eq 'u' then begin
   point_y = max(y2,point_ind)
   remove,point_ind,x2,y2,yerr2,xerr2
endif else begin
   if sat eq 'l' then begin
      point_y = min(y2,point_ind)
      remove,point_ind,x2,y2,yerr2,xerr2
   endif
endelse
if sat ne 'y' then begin
   p.close
   goto,replotaper
endif

p.save,'aper-zp.png'
p.save,'aper-zp.eps'
p.close

openw,lun,'dh_aper-2mass.txt',/get_lun
printf,lun,dh,edh,format='(f9.3,f9.4)'
cf,lun

root = 'master_smt'

f_cmp = root + '.cmp'
str_cmp = {id1:0l,x1:0.,y1:0.,m1:0.,e1:0.,id2:0l,x2:0.,y2:0.,m2:0.,e2:0.}


fmt_al = '(I7,3(F9.3),F9.4)'
str_al = {id:0l,x:0.,y:0.,m:0.,e:0.}
fmt_tfr = '(I7,2(F9.3),2(I7))'
str_tfr = {id:0l,x:0.,y:0.,f1:0l,f2:0l}

f_tfr = 'psc.tfr'
rdfile,f_tfr,str_tfr,fmt_tfr,3,tfr,nl_tfr
cmp = replicate(str_cmp,nl_tfr+1)
qs = fltarr(nl_tfr+1)

f_als = root + '.als'
f_alf = 'psc.alf'
rdfile,f_alf,str_al,fmt_al,3,alf,nl_alf
rdfile,f_als,str_al,fmt_al,3,als,nl_als

for i = 0, nl_tfr do begin
   ts = tfr[i]
   id = ts.id
   nl1 = tfr(i).f1
   nl2 = tfr(i).f2
   cmp[i].id1 = alf[nl1-1].id
   cmp[i].x1 = alf[nl1-1].x
   cmp[i].y1 = alf[nl1-1].y
   cmp[i].m1 = alf[nl1-1].m
   cmp[i].e1 = alf[nl1-1].e
   cmp[i].id2 = als[nl2-1].id
   cmp[i].x2 = als[nl2-1].x
   cmp[i].y2 = als[nl2-1].y
   cmp[i].m2 = als[nl2-1].m
   cmp[i].e2 = als[nl2-1].e
endfor

ind = where(cmp.y1 gt 240 and cmp.y1 lt 260,cnt)
if cnt ge 1 then qs[ind] = 1
ind = where(cmp.m1 eq max(cmp.m1))
xc = cmp[ind].x1
yc = cmp[ind].y1
ind = where((cmp.x1-xc)^2+(cmp.y1-yc)^2 le 625,cnt)
if cnt ge 1 then qs[ind] = 2
ind = where(cmp.e1 ge 0.1 or cmp.e1 ge 0.1,cnt)
if cnt ge 1 then qs[ind] = 3

ind = where(qs eq 0,cnt)
god = cmp[ind]

x = god.m1 ; 2MASS H
y = god.m2 - god.m1 ; PSF - 2MASS
yerr = sqrt(god.e1^2+god.e2^2)
xerr = god.e1
ind = where(x ge fitlim[0] and x le fitlim[1] and y+x ge fit_low_lim[0] and y+x le fit_high_lim[0],cnt)
fit = god[ind]
x2 = fit.m1
y2 = fit.m2 - fit.m1
yerr2 = sqrt(fit.e1^2+fit.e2^2)
xerr2 = fit.e2
sigmaclip1once,y2,kp,mn,stdd,sigma_hold,rj,yerr2
x2 = x2[kp]
y2 = y2[kp]
xerr2 = xerr2[kp]
yerr2 = yerr2[kp]
replotpsf:
sigmaclip1once,y2,kp,mn,stdd,sigma_hold+30,rj,yerr2
gray = 'aaaaaa'x
xrange = [5,16.5]
capsize = 0.
p = errorplot(x,y,xerr,yerr,'o',linestyle='',color=gray,sym_filled=0,sym_size=0.7,errorbar_color=gray,xrange=xrange,errorbar_capsize=capsize)
p.title = 'PSF Photometry'
p.xtitle='2MASS H (mag)'
p.ytitle='$\Delta$H (mag)'
p2 = errorplot(x2,y2,xerr2,yerr2,'o',sym_filled=1,sym_size=0.7,color='black',errorbar_color='black',/overplot,errorbar_capsize=capsize)
dh = mn
edh = stdd/sqrt(n_elements(kp)-1)
p3 = plot(xrange,[dh,dh],color='red',/overplot)
p3 = plot(xrange,[dh,dh]+stdd,color='blue',linestyle='--',/overplot)
p3 = plot(xrange,[dh,dh]-stdd,color='blue',linestyle='--',/overplot)
p.yrange = [dh-5*stdd,dh+5*stdd]
t = text(0.2,0.78,'<$\Delta$H> = '+flt3digitstr(dh)+' $\pm$ '+flt3digitstr(edh))
askrejpsf:
sat = 'y'
print,'Are you satisfied with the cut? (y/u/l)'
read,sat
if ~(sat eq 'y' or sat eq 'u' or sat eq 'l') then goto,askrejpsf
if sat eq 'u' then begin
   point_y = max(y2,point_ind)
   remove,point_ind,x2,y2,yerr2,xerr2
endif else begin
   if sat eq 'l' then begin
      point_y = min(y2,point_ind)
      remove,point_ind,x2,y2,yerr2,xerr2
   endif
endelse
if sat ne 'y' then begin
   p.close
   goto,replotpsf
endif

p.save,'psf-zp.png'
p.save,'psf-zp.eps'
p.close
openw,lun,'dh_psf-2mass.txt',/get_lun
printf,lun,dh,edh,format='(f9.3,f9.4)'
cf,lun

end
