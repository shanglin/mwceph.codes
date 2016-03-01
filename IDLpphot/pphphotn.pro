pro pphphotn

!quiet=1

; this will fix bad pixels first then detect objects
fits = file_search('n????n????.fits',count=nfits)
for i=0,nfits-1 do begin
   showprogress,i+1,nfits,'Detecting star positions'
   ophfindnd,fits[i]
endfor
print,''

print,' Find Cepheid postions by EYE!!!'
pphcephxy

fits = file_search('n????n????_smt.fits',count=nfits)
for i=0,nfits-1 do begin
   f_fit= fits(i)
   showprogress,i+1,nfits,'Update XY position for '+f_fit
   ophcalfwhmhnd,f_fit
endfor
print,''


ophaperhnd

spawn,'cp ../photh/dm_table.dmt .'
;ophmkhndlc


end
