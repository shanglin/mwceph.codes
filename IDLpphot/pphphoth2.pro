pro pphphoth2

!quiet=1
i_m0 = 9 ; aperture=7.3pix

print,' Photometry on master image'
f_fit = 'master.fits'
ophfindmaster,f_fit,2.
f_fit = 'master_smt.fits'
ophaper1,f_fit
pphcalfwhm,f_fit,/plotfwhm
ophaper2,f_fit
f_npr = repstr(f_fit,'.fits','.npr')
pphnpr2alf,f_npr,i_m0
spawn,'cp master_smt.alf bk_master_smt_raw.alf'

alfs = file_search('h????n????_smt.alf',count=nalfs)
skipones = [] ; finish the skipped ones by hand
for i=0,nalfs-1 do begin
   f_alf2 = alfs[i]
   showprogress,i+1,nalfs,'Generate .fco for '+f_alf2
   skipind = where(f_alf2 eq skipones,count_bad)
   if count_bad eq 0 then begin
      pphmkfco,'master_smt.alf',f_alf2
   endif
endfor
print,''

; x y positions updated in this phot to account for image distorsions.
fits = file_search('h????n????_smt.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   showprogress,i_fit+1,nfits,'Final photometry for '+f_fit
   pphaper3,f_fit
endfor
print,''
spawn,'cp -r ~/Work/mega/mwceph/pphot/psf ../'
spawn,'cp master_smt.fits ../psf/'
spawn,'mkdir ../2mass/'
spawn,'cp ~/Work/mega/mwceph.codes/loadpsc2.py ../2mass/'
end
