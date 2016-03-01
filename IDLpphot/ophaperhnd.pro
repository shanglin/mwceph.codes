pro ophaperhnd

!quiet=1  

apertures1 = findgen(12)/10. + 6.5
apertures2 = findgen(12)/10. + 7.7

phpadu = 7.
skyradii = [18,40]
badpix = [0,0]
silent = 1
readnoise = 1.57
exact = 0

aperstr = strmid(rmfgspc(apertures1),0,3)
aperstr1 = ''
for ifoo=0,n_elements(aperstr)-2 do aperstr1 = aperstr1+aperstr[ifoo]+', '
aperstr1 = aperstr1 + aperstr[n_elements(aperstr)-1]

aperstr = strmid(rmfgspc(apertures2),0,3)
aperstr2 = ''
for ifoo=0,n_elements(aperstr)-2 do aperstr2 = aperstr2+aperstr[ifoo]+', '
aperstr2 = aperstr2 + aperstr[n_elements(aperstr)-1]


fmt_apr1 = '(I7,2F9.3,12F9.3,12F9.3,2F9.3)'
fmt_apr2 = '(I7,2F9.3,12F9.3,12F9.3,2F9.3)'
fmt_apr = '(I7,2F9.3,24F9.3,24F9.3,2F9.3)'
str_apr = {id:0l,x:0.,y:0.,m1:0.,m2:0.,m3:0.,m4:0.,m5:0.,m6:0.,m7:0.,m8:0.,m9:0.,m10:0.,m11:0.,m12:0.,e1:0.,e2:0.,e3:0.,e4:0.,e5:0.,e6:0.,e7:0.,e8:0.,e9:0.,e10:0.,e11:0.,e12:0.,sky:0.,skyerr:0.}

f_cpt = 'cepheid_table.cpt'
fmt_cpt = '(a21,f12.5,f9.5,f10.4,a3,52f9.3)'
openw,lun,f_cpt,/get_lun
printf,lun,'#A4 APERTURES = ['+aperstr1+', '+aperstr2+']'
printf,lun,'         image             mjd      phase     period pollute x       y         M1      M2       M3        M4      M5       M6       M7       M8       M9       M10       M11      M12      M13     M14      M15       M16     M17      M18      M19      M20      M21      M22       M23      M24      E1       E2       E3       E4       E5       E6       E7       E8       E9       E10      E11      E12     E13      E14      E15      E16      E17      E18      E19      E20      E21      E22      E23      E24     SKY     SKYERR' 
fits = file_search('n????n????_smt.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   image = readfits(f_fit,head,/silent)
   xc = float(sxpar(head,'CEPHX',count=cnt))
   if cnt ne 1 then message,' CEPHX not found in '+f_fit
   yc = float(sxpar(head,'CEPHY',count=cnt))
   if cnt ne 1 then message,' CEPHY not found in '+f_fit
   pollute = rmfgspc(sxpar(head,'POLLUT',count=cnt))
   if cnt ne 1 then message,' POLLUT not found in '+f_fit
   mjd = sxpar(head,'JD',count=cnt) - 2450000
   if cnt ne 1 then message,' JD not found in '+f_fit
   period = sxpar(head,'PERIOD',count=cnt)
   if cnt ne 1 then message,' PERIOD not found in '+f_fit
   phase = mjd/period - floor(mjd/period) ; zero point at mjd = 0

   aper,image,xc,yc,mags,errap,sky,skyerr,phpadu,apertures1,skyradii,badpix,silent=silent,exact=exact,/no_warning
   errap = errap<100
   skyerr = skyerr<100

   mags1 = mags
   errs1 = errap
   sky1 = sky
   skyerr1 = skyerr
   
   aper,image,xc,yc,mags,errap,sky,skyerr,phpadu,apertures2,skyradii,badpix,silent=silent,exact=exact,/no_warning
   errap = errap<100
   skyerr = skyerr<100

   mags2 = mags
   errs2 = errap
   sky2 = sky
   skyerr2 = skyerr

   printf,lun,f_fit,mjd,phase,period,pollute,xc,yc,mags1,mags2,errs1,errs2,sky1,skyerr1,format=fmt_cpt   
endfor
cf,lun
end
