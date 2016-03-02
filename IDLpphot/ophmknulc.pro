pro ophmknulc

!quiet=1
  
fmt_ulc = '(A21,F12.5,F9.5,F9.3,F9.3,I5,F6.2,F8.2,F8.2,F9.3,F9.3,F9.3,F9.3,I4,F10.4,4f12.4,I4)'
str_ulc = {img:'',mjd:0.d,ph:0.d,dm:0.,stdd:0.,dof:0,sigma:0.,blim:0.,flim:0.,cx:0.,cy:0.,cm:0.,ce:0.,dit:0,p:0.,mndm:0.,errdm:0.,mncm:0.,mnce:0.,flag:0}
spawn,'cp ../photh/*.ulc ./hulc.ulc'
f_ulc = 'hulc.ulc'
rdfile,f_ulc,str_ulc,fmt_ulc,1,ulc,nl_ulc
ulc.img = rmfgspc(ulc.img)
ulc = ulc(where(ulc.flag le 1))
ulc = ulc(where(ulc.dm ne -99,cnt))
nl_ulc = cnt - 1

f_cpt = 'cepheid_table.cpt'
fmt_cpt = '(a21,f12.5,f9.5,f10.4,a3,52f9.3)'
str_cpt = {img:'',mjd:0.d,ph:0.d,p:0.,pol:'',x:0.,y:0.,M1:0.,M2:0.,M3:0.,M4:0.,M5:0.,M6:0.,M7:0.,M8:0.,M9:0.,M10:0.,M11:0.,M12:0.,M13:0.,M14:0.,M15:0.,M16:0.,M17:0.,M18:0.,M19:0.,M20:0.,M21:0.,M22:0.,M23:0.,M24:0.,E1:0.,E2:0.,E3:0.,E4:0.,E5:0.,E6:0.,E7:0.,E8:0.,E9:0.,E10:0.,E11:0.,E12:0.,E13:0.,E14:0.,E15:0.,E16:0.,E17:0.,E18:0.,E19:0.,E20:0.,E21:0.,E22:0.,E23:0.,E24:0.,sky:0.,skyerr:0.}
rdfile,f_cpt,str_cpt,fmt_cpt,2,cpt,nl_cpt
cpt.pol = rmfgspc(cpt.pol)
cpt.img = rmfgspc(cpt.img)
apertures = [6.5, 6.6, 6.7, 6.8, 6.9, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8]

sym_a = findgen(17) * (!pi*2/16.)
usersym, cos(sym_a), sin(sym_a),/fill

str_lc = {img:'',ph:0.d,flag:0,m:0.,e:0.,dm:0.,edm:0.}
lc = replicate(str_lc,nl_cpt+1)
f_nulc = 'nulc.nulc'
fmt_nulc = '(a21,f12.5,f9.5,f10.4,a3,10f9.3,i4)'
openw,l_nulc,f_nulc,/get_lun
printf,l_nulc,'        img               mjd         ph        p    pol    x        y        m         e      sky      esky      dm       edm     cm       ce   flag'
for i_lc = 0,nl_cpt do begin

for apr=6,6 do begin
   aperture = apertures[apr-1]
   mcol = apr + 6
   ecol = mcol + 24
   for i=0,nl_cpt do begin
      ts = cpt[i]
      ind = where(abs(ts.mjd-ulc.mjd) lt 0.15,cnt)
      if (cnt ge 1) then begin
         ind = ind[0]
         tt = ulc[ind]
         lc[i].img = ts.img
         lc[i].ph = ts.ph
         lc[i].m = ts.(mcol) - tt.mndm
         lc[i].e = sqrt(ts.(ecol)^2 + tt.errdm^2)
         lc[i].dm = tt.mndm
         lc[i].edm = tt.errdm
      endif else begin
         lc[i].img = ts.img
         lc[i].ph = ts.ph
         lc[i].m = ts.(mcol) - 99
         lc[i].e = sqrt(ts.(ecol)^2 + 99^2)
         lc[i].dm = 99
         lc[i].edm = 99
      endelse
      if ts.pol eq 'N' then flag=10
      if ts.pol eq 'S' then flag=20
      if ts.pol eq 'Y' then flag=30
      lc[i].flag = flag
   endfor
   x = lc.ph
   y = lc.m
   yerr = lc.e
   x = [x,x+1]
   y = [y,y]
   yerr = [yerr,yerr]
   sigmaclip1once,y,kp,mny,stddy,3,rj,yerr
   yrange = [mny+2*stddy,mny-2*stddy]

   plot,x,y,psym=8,xtit='Phase',ytit='Instrumental H+ND4 (mag)',color=0,title='Aper = '+flt2digitstr(aperture),xrange=[-0.06,2.06],yrange=yrange,background='ffffff'x,/xst,/yst
   errplot,x,y+yerr,y-yerr,color=0
 
   ind = where(lc.dm - min(lc.dm) gt 0.5,cnt)
   if cnt ge 1 then begin
      grey = lc(ind)
      x = [grey.ph,grey.ph+1]
      y = [grey.m,grey.m]
      yerr = [grey.e,grey.e]
      oplot,x,y,psym=8,color='aaaaaa'x
      errplot,x,y+yerr,y-yerr ,color='aaaaaa'x   
   endif
   ind = where(lc.flag eq 20,cnt)
   if cnt ge 1 then begin
      blue = lc(ind)
      x = [blue.ph,blue.ph+1]
      y = [blue.m,blue.m]
      yerr = [blue.e,blue.e]
      oplot,x,y,psym=8,color='00ff00'x
      errplot,x,y+yerr,y-yerr,color='00ff00'x
   endif
   ind = where(lc.flag eq 30,cnt)
   if cnt ge 1 then begin
      red = lc(ind)
      x = [red.ph,red.ph+1]
      y = [red.m,red.m]
      yerr = [red.e,red.e]
      oplot,x,y,psym=8,color='0000ff'x
      errplot,x,y+yerr,y-yerr,color='0000ff'x  
   endif
endfor
ts = lc[i_lc]
x = [ts.ph,ts.ph+1]
y = [ts.m,ts.m]
yerr = [ts.e,ts.e]
oplot,x,y,psym=8,color='ff0000'x,symsize=2
errplot,x,y+yerr,y-yerr,color='ff0000'x
askfoo:
foo = ''
if (ts.dm-min(lc.dm)) gt 0.5 then p1 = 'Cloudy' else p1 = 'Fair'
if ts.flag eq 20 then p2 = 'slight polluted'
if ts.flag eq 30 then p2 = 'serious polluted'
if ts.flag eq 10 then p2 = 'good'
read,foo,prompt=p1+',  '+p2+' (0 for keep/1 for reject): '
if ~(foo eq '0' or foo eq '1') then goto,askfoo
nflag = float(foo)
if ts.flag eq 30 then nflag = nflag + 20
if (ts.dm-min(lc.dm)) gt 0.5 then nflag = nflag + 10
ind = where(ts.img eq cpt.img,cnt)
if cnt eq 0 then message,ts.img+' not found in '+f_cpt
tt = cpt[ind]
printf,l_nulc,tt.img,tt.mjd,tt.ph,tt.p,tt.pol,tt.x,tt.y,tt.(mcol),tt.(ecol),tt.sky,tt.skyerr,ts.dm,ts.edm,ts.m,ts.e,nflag,format=fmt_nulc
endfor
cf,l_nulc
end
