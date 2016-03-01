;+
; NAME:
;
;
;
; PURPOSE:
; 1. Calculate average fwhm for each image
; 2. Update the XY coordinates for those converged
; 3. Original ID reserved
;
; CATEGORY:
;  mwceph_lib
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-
pro pphcalfwhm,f_fit,plotfwhm=plotfwhm
!except=0

image = readfits(f_fit,head,/silent)

f_apr = repstr(f_fit,'.fits','.apr')
fmt_apr = '(I7,2F9.3,24F9.3,24F9.3,2F9.3)'
str_apr = {id:0l,x:0.,y:0.,M1:0.,M2:0.,M3:0.,M4:0.,M5:0.,M6:0.,M7:0.,M8:0.,M9:0.,M10:0.,M11:0.,M12:0.,M13:0.,M14:0.,M15:0.,M16:0.,M17:0.,M18:0.,M19:0.,M20:0.,M21:0.,M22:0.,M23:0.,M24:0.,E1:0.,E2:0.,E3:0.,E4:0.,E5:0.,E6:0.,E7:0.,E8:0.,E9:0.,E10:0.,E11:0.,E12:0.,E13:0.,E14:0.,E15:0.,E16:0.,E17:0.,E18:0.,E19:0.,E20:0.,E21:0.,E22:0.,E23:0.,E24:0.,sky:0.,skyerr:0.}
rdfile,f_apr,str_apr,fmt_apr,2,apr,nl_apr

str_nco = {id:0l,x:0.,y:0.,mag:0.}
nco = replicate(str_nco,nl_apr+1)
icount = 0
fwhms = []
for i_apr=0,nl_apr,1 do begin
   ts = apr[i_apr]
   mags = []
   for jj=3,26 do mags = [mags,ts.(jj)]
   ind = where(mags ge 0.1 and mags le 90.1,ngood)
   if ngood ge 12 then begin
      goodmags = mags(ind)
      meanmag = mean(goodmags)
      nco[icount].mag = meanmag
      starfit,image,ts.x,ts.y,xc,yc,FWHM1
      if abs(ts.x-xc) lt 0.5 and abs(ts.y-yc) lt 0.5 and fwhm1 lt 10. then begin
         fwhms = [fwhms,fwhm1]
         nco[icount].id = ts.id
         nco[icount].x = xc
         nco[icount].y = yc
      endif else begin
         nco[icount].id = ts.id
         nco[icount].x = ts.x
         nco[icount].y = ts.y
      endelse
      icount++
   endif
endfor
icount--
nco = nco[0:icount]
if n_elements(fwhms) ge 30 then fwhms = fwhms[0:round(n_elements(fwhms)*0.5)]
if n_elements(fwhms) ge 2 then begin
   sigmaclip1once,fwhms,indkp,meanfwhm,stddfwhm,3,/ignore_error
   fwhms = fwhms[indkp]
endif else begin
   meanfwhm = fwhms[0]
   stddfwhm = 99.99
endelse
if keyword_set(plotfwhm) then begin
   window,0
endif
if keyword_set(plotfwhm) then begin
   plot,findgen(n_elements(fwhms)),fwhms,psym=2,yrange = [min(fwhms)-0.5,max(fwhms)+0.5],/ystyle,tit='Distribution of FWHM for '+f_fit,xrange=[-1,n_elements(fwhms)],/xstyle
   oplot,[-10,580],[meanfwhm,meanfwhm],color='0000ff'x
   oplot,[-10,580],[meanfwhm,meanfwhm]+stddfwhm
   oplot,[-10,580],[meanfwhm,meanfwhm]-stddfwhm
   wait,2
endif

f_nco = repstr(f_fit,'.fits','.nco')
fmt_nco = '(I8,3F9.3)'
openw,lun,f_nco,/get_lun
printf,lun,'#C2 FWHM = '+flt3digitstr(meanfwhm)
printf,lun,'#  ID       X        Y       MAG'
for ifoo=0,icount do begin
   printf,lun,nco[ifoo],format=fmt_nco
endfor
cf,lun
if keyword_set(plotfwhm) then begin
   wdelete,0
endif
end
