pro pphnpr2alf,f_npr,i_m0
i_m = i_m0 + 2

fmt_npr = '(I7,2F9.3,24F9.3,24F9.3,2F9.3)'
str_npr = {id:0l,x:0.,y:0.,M1:0.,M2:0.,M3:0.,M4:0.,M5:0.,M6:0.,M7:0.,M8:0.,M9:0.,M10:0.,M11:0.,M12:0.,M13:0.,M14:0.,M15:0.,M16:0.,M17:0.,M18:0.,M19:0.,M20:0.,M21:0.,M22:0.,M23:0.,M24:0.,E1:0.,E2:0.,E3:0.,E4:0.,E5:0.,E6:0.,E7:0.,E8:0.,E9:0.,E10:0.,E11:0.,E12:0.,E13:0.,E14:0.,E15:0.,E16:0.,E17:0.,E18:0.,E19:0.,E20:0.,E21:0.,E22:0.,E23:0.,E24:0.,sky:0.,skyerr:0.}
rdfile,f_npr,str_npr,fmt_npr,2,npr,nl_npr
; M13=1.5 M14=1.6 M15=1.7 M16=1.8 M17=1.9 M18=2.0

f_alf = repstr(f_npr,'.npr','.alf')
fmt_alf = '(I7,3(F9.3),F9.4,F9.2,F9.0,F9.2,F9.3)'
str_alf = {id:0l,x:0.,y:0.,m:0.,e:0.,s:0.,n:0.,ch:0.,sh:0.}
spawn,'head -3 ~/Work/bin/templates/template.alf > '+f_alf
openw,lun,f_alf,/get_lun,/append
for i_alf=0,nl_npr do begin
   ts = npr[i_alf]
   if ts.m18 ge 0.1 and ts.m18 le 90.1 and ts.e18 le 0.5 then begin
      printf,lun,ts.id,ts.x,ts.y,ts.(i_m),ts.(i_m + 24),ts.sky,1,1,0,format=fmt_alf
   endif
endfor
cf,lun
end
