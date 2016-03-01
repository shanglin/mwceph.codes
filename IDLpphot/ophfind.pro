;+
; NAME:
;  ophfind
;
; PURPOSE:
;  Find object positions in FITS image with bad pixels
;
; CATEGORY:
;  Astronomy 
;
; CALLING SEQUENCE:
;  ophfind,f_fit[,sigma_threshold,/keep_log]
;
; INPUTS:
;  f_fit: FITS file name
;
; OPTIONAL INPUTS:
;  sigma_threshold: 3. by default
;  /keep_log: keep the intermediate files
;
; KEYWORD PARAMETERS:
;  /keep_log
;
; OUTPUTS:
;  position file and image file with bad pixels fixed
;
; OPTIONAL OUTPUTS:
;  intermediate files
;
; EXAMPLE:
;  ophfind,'example.fits'
;
; MODIFICATION HISTORY:
;  Wenlong, 2014/12/05
;-
pro ophfind,f_fit,ophfind_sigma,keep_log=keep_log
!quiet = 1

if n_elements(f_fit) eq 0 then begin
   f_fit = ''
   read,f_fit,prompt=' Please input the image name: '
endif
if n_elements(ophfind_sigma) eq 0 then begin
   ophfind_sigma = 3.
endif


; 1. Fix bad pixels (-32767) using Dr. Leslie A. Young's code
f_msk = repstr(f_fit,'.fits','_msk.fits')
f_smt = repstr(f_fit,'.fits','_smt.fits')
ophfind_fixpix_log = repstr(f_fit,'.fits','_fixpix.log')
ophfind_a = readfits(f_fit,ophfind_h,/silent)
ophfind_bad = where(ophfind_a eq -32767,complement = ophfind_good)
ophfind_m = ophfind_a
ophfind_m(ophfind_good) = 1
ophfind_m(ophfind_bad) = 0
;writefits,f_msk,ophfind_m,ophfind_h
fixpix,ophfind_a,ophfind_m,ophfind_s,npix=8,/silent
writefits,f_smt,ophfind_s,ophfind_h

; 2. Find objects using the find.pro in astronomy library
f_ophfind_coo = repstr(f_fit,'.fits','.coo')
f_ophfind_coo_int = f_ophfind_coo+'int'
str_ophfind_coo = {id:0l,x:0.,y:0.,flux:0.d,sharp:0.,round:0.}
fmt_ophfind_coo = '(I8,2F10.3,F15.3,2F9.3)'
openw,l_ophfind_coo,f_ophfind_coo_int,/get_lun
printf,l_ophfind_coo,'#1 OPHFIND USED PARS: SIGMA='+flt2digitstr(ophfind_sigma)
printf,l_ophfind_coo,'#    ID      X          Y           FlUX       SHARP    ROUND'

ophfind_smt_arr = readfits(f_smt,ophfind_hsmt,/silent)
roundlim = [-1.0,1.0]
sharplim = [0.2,1.0]
ophfind_fwhms = [1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
id_start = 0
for i_fwhm=0,n_elements(ophfind_fwhms)-1 do begin
   ophfind_fwhm = ophfind_fwhms(i_fwhm)
   find,ophfind_smt_arr,ophfind_x,ophfind_y,ophfind_flux,ophfind_sharp,ophfind_round,ophfind_sigma,ophfind_fwhm,roundlim, sharplim,/silent
   for i_ophfind_coo=0,n_elements(ophfind_x)-1 do begin
      printf,l_ophfind_coo,id_start + i_ophfind_coo+1,ophfind_x[i_ophfind_coo],ophfind_y[i_ophfind_coo],ophfind_flux[i_ophfind_coo],ophfind_sharp[i_ophfind_coo],ophfind_round[i_ophfind_coo],format=fmt_ophfind_coo
   endfor
   id_start = id_start + n_elements(ophfind_x)
endfor
cf,l_ophfind_coo

; 3. Clean the results: remove duplicate objects, remove faint ones,
; sort by flux, assign new ID
rdfile,f_ophfind_coo_int,str_ophfind_coo,fmt_ophfind_coo,2,ophfind_coo,nl_ophfind_coo
if nl_ophfind_coo lt 0 then print,' Warning! No stars found in '+f_fit
ophfind_coo = ophfind_coo(reverse(sort(ophfind_coo.flux)))
if ophfind_sigma lt 5 then $
   ophfind_coo = ophfind_coo[0:round((nl_ophfind_coo+1)*(0.2*(ophfind_sigma-3.)+0.4))] 
if ophfind_sigma ge 5 and ophfind_sigma lt 10 then $
      ophfind_coo = ophfind_coo[0:round((nl_ophfind_coo+1)*0.8)]
iloop_start = 0
reloop:
for i_ophfind_coo=iloop_start,n_elements(ophfind_coo.x)-1 do begin
   foobarind = where((ophfind_coo[i_ophfind_coo].x - ophfind_coo.x)^2 + (ophfind_coo[i_ophfind_coo].y - ophfind_coo.y)^2 lt 4.,nfoobarind)
   if nfoobarind ge 2 then begin
      barfooind = where(ophfind_coo.id ne ophfind_coo[i_ophfind_coo].id)
      ophfind_coo = ophfind_coo[barfooind]
      iloop_start = i_ophfind_coo
      goto,reloop
   endif
endfor

openw,l_ophfind_coo,f_ophfind_coo,/get_lun
printf,l_ophfind_coo,'#C1 OPHFIND USED PARS: SIGMA='+flt2digitstr(ophfind_sigma)
printf,l_ophfind_coo,'#    ID      X          Y           FlUX       SHARP    ROUND'
for i_ophfind_coo=0,n_elements(ophfind_coo.x)-1 do begin
   ophfind_coo[i_ophfind_coo].id = i_ophfind_coo + 1
   printf,l_ophfind_coo,ophfind_coo[i_ophfind_coo],format=fmt_ophfind_coo
endfor
cf,l_ophfind_coo
if keyword_set(keep_log) then $
   spawn,"awk 'NR>2 {print "+'"image;circle("$2","$3","4")#color=green"}'+"' "+f_ophfind_coo+' > '+repstr(f_fit,'.fits','.reg') else $
      rmexfile,f_ophfind_coo_int
end
