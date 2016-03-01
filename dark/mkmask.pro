pro mkmask
!quiet = 1
print,''
print,' It is better to include these information when do photometry'
print,' 1. Fix pixels using IDL'
print,' 2. For each object, record the number of bad pixels in the aperture'
print,' 3. measure the flux of the fixed pixels'
print,' 4. calculate the errors due to the bad pixels for each measurement'
print,''

;; low = 402.5
;; high = 412.0 ; These values are at the 3-sigma boundary
;; For consistency, use old low and high values
low = 404
high = 417

fits = file_search('dark??????.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   f_fit = fits(i_fit)
   a = readfits(f_fit,header,/silent)
   good = where(a gt low and a lt high, complement = bad)
   a(good) = 1
   a(bad) = 0
   cen_x = 457.
   cen_y = 277.
   radius = 9
   for x=0l,511l do for y=0l,511l do if (x-cen_x)^2+(y-cen_y)^2 le radius^2 then a(x,y)=0
   writefits,repstr(f_fit,'dark','mask'),a,header
endfor
;spawn,'cp mask140622.fits mask140605.fits' ;; dark140605 is not present
spawn,'cp mask140830.fits mask140901.fits' ;; Use a better one for the nearby dates
end
