pro pphphoth

!quiet=1
; this will fix bad pixels first then detect objects
fits = file_search('h????n????.fits',count=nfits)
for i=0,nfits-1 do begin
   showprogress,i+1,nfits,'Detecting star positions'
   ophfind,fits[i]
endfor
print,''


fits = file_search('h????n????_smt.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   showprogress,i_fit+1,nfits,'Do rough photometry '+f_fit
   ophaper1,f_fit
endfor
print,''


fits = file_search('h????n????_smt.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   showprogress,i_fit+1,nfits,'Calculate the FWHM and update positions'
   f_fit = fits[i_fit]
   pphcalfwhm,f_fit;,/plotfwhm
endfor
print,''

fits = file_search('h????n????_smt.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   showprogress,i_fit+1,nfits,'Do photometry '+f_fit
   ophaper2,f_fit
endfor
print,''

i_m0 = 9 ; aperture=7.3pix
nprs = file_search('h????n????_smt.npr',count=nnprs)
for i_npr=0,nnprs-1 do begin
   f_npr = nprs[i_npr]
   showprogress,i_npr+1,nnprs,'Generating ALF files for '+f_npr
   pphnpr2alf,f_npr,i_m0
endfor
print,''

end
