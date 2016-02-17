pro mkflat

fits = file_search('ir??????.flath.fits',count=nfits)
; ###################################################
; ! Some flats maybe not good! Check the combined images 
;   and remove those by adding them to the following
;   bad dates array
    bad_dates = []
; ###################################################
for i=0,nfits-1 do begin
   f_fit = fits(i)
   newname = 'flat'+strmid(f_fit,2,6)+'.fits'
   spawn,'cp '+f_fit+' '+newname
   date = strmid(f_fit,2,6)
   ind = where(date eq bad_dates,nbad)
   if nbad ge 1 then spawn,'mv '+newname+' bad_'+newname
endfor
end
