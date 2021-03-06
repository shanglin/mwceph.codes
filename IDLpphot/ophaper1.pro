pro ophaper1,f_fit


;apr1 = [3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5]
;apr2 = [9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5]
apertures1 = findgen(12)/2. + 3.
apertures2 = findgen(12)/2. + 9.
fmt_apr1 = '(I7,2F9.3,12F9.3,12F9.3,2F9.3)'
fmt_apr2 = '(I7,2F9.3,12F9.3,12F9.3,2F9.3)'
fmt_apr = '(I7,2F9.3,24F9.3,24F9.3,2F9.3)'
str_apr = {id:0l,x:0.,y:0.,m1:0.,m2:0.,m3:0.,m4:0.,m5:0.,m6:0.,m7:0.,m8:0.,m9:0.,m10:0.,m11:0.,m12:0.,e1:0.,e2:0.,e3:0.,e4:0.,e5:0.,e6:0.,e7:0.,e8:0.,e9:0.,e10:0.,e11:0.,e12:0.,sky:0.,skyerr:0.}

;for i_fit=0,nfits-1 do begin
;   showprogress,i_fit+1,nfits
;   f_fit = fits[i_fit]
   f_coo = repstr(repstr(f_fit,'_smt.fits','.fits'),'.fits','.coo')
   str_coo = {id:0l,x:0.,y:0.,flux:0.d,sharp:0.,round:0.}
   fmt_coo = '(I8,2F10.3,F15.3,2F9.3)'
   rdfile,f_coo,str_coo,fmt_coo,2,coo,nl_coo
   
   xc = coo.x
   yc = coo.y
   phpadu = 7.
   skyradii = [15,25]
   badpix = [0,0]
   silent = 1
   readnoise = 1.57
   exact = 0
   
   image = readfits(f_fit,head,/silent)
   aper,image,xc,yc,mags,errap,sky,skyerr,phpadu,apertures1,skyradii,badpix,silent=silent,exact=exact,/no_warning
   errap = errap<99.99
   skyerr = skyerr<99.99
   errap = errap>(-99.99)
   skyerr = skyerr>(-99.99)

   f_apr1 = repstr(f_fit,'.fits','_1.apr')
   openw,lun,f_apr1,/get_lun
   printf,lun,'#A1 APERTURES = [3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5]'
   printf,lun,'   ID       X       Y         M1      M2       M3        M4      M5       M6       M7       M8       M9       M10       M11      M12      E1       E2       E3       E4       E5       E6       E7       E8       E9       E10      E11      E12     SKY     SKYERR'
   for i=0,n_elements(xc)-1 do begin
      printf,lun,i+1,xc(i),yc(i),mags(*,i),errap(*,i),sky(i),skyerr(i),format=fmt_apr1
   endfor
   cf,lun


   image = readfits(f_fit,head,/silent)
   aper,image,xc,yc,mags,errap,sky,skyerr,phpadu,apertures2,skyradii,badpix,silent=silent,exact=exact,/no_warning
   errap = errap<99.99
   skyerr = skyerr<99.99
   errap = errap>(-99.99)
   skyerr = skyerr>(-99.99)

   f_apr2 = repstr(f_fit,'.fits','_2.apr')
   openw,lun,f_apr2,/get_lun
   printf,lun,'#A1 APERTURES = [9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5]'
   printf,lun,'   ID       X       Y         M1      M2       M3        M4      M5       M6       M7       M8       M9       M10       M11      M12      E1       E2       E3       E4       E5       E6       E7       E8       E9       E10      E11      E12     SKY     SKYERR'
   for i=0,n_elements(xc)-1 do begin
      printf,lun,i+1,xc(i),yc(i),mags(*,i),errap(*,i),sky(i),skyerr(i),format=fmt_apr2
   endfor
   cf,lun

   
   rdfile,f_apr1,str_apr,fmt_apr1,2,apr1,nl_apr1
   rdfile,f_apr2,str_apr,fmt_apr2,2,apr2,nl_apr2
   f_apr = repstr(f_fit,'.fits','.apr')
   openw,lun,f_apr,/get_lun
   printf,lun,'#A2 APERTURES = [3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5]'
   printf,lun,'   ID       X       Y         M1      M2       M3        M4      M5       M6       M7       M8       M9       M10       M11      M12      M13     M14      M15       M16     M17      M18      M19      M20      M21      M22       M23      M24      E1       E2       E3       E4       E5       E6       E7       E8       E9       E10      E11      E12     E13      E14      E15      E16      E17      E18      E19      E20      E21      E22      E23      E24     SKY     SKYERR'
   for i_new=0,nl_apr1 do begin
      mags1 = []
      mags2 = []
      errs1 = []
      errs2 = []
      ts1 = apr1(i_new)
      ts2 = apr2(i_new)
      for jj=3,14 do mags1 = [mags1,ts1.(jj)]
      for jj=15,26 do errs1 = [errs1,ts1.(jj)]
      for jj=3,14 do mags2 = [mags2,ts2.(jj)]
      for jj=15,26 do errs2 = [errs2,ts2.(jj)]
      printf,lun,ts1.id,ts1.x,ts1.y,mags1,mags2,errs1,errs2,ts1.sky,ts1.skyerr,format=fmt_apr
   endfor
   cf,lun
   rmexfile,f_apr1
   rmexfile,f_apr2
   rmexfile,f_coo
;endfor
end
