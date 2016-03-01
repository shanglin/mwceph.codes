function closest, array, value
  if (n_elements(array) le 0) or (n_elements(value) le 0) then index=-1 $
  else if (n_elements(array) eq 1) then index=0 $
  else begin
     abdiff = abs(array-value)  ;form absolute difference
     mindiff = min(abdiff,index) ;find smallest difference
  endelse
  return,index
end


pro pphinired,objname
!quiet = 1 ; stop displaying the % Compiled Module xxx

;message,' Please run this script on Mac 10.9 for now... IRAF does not work properly.'
fits = file_search('./binir??????.????.fits',count=nfits)
if nfits eq 0 then message,' Please copy the images to the current directory'
cd, Current=theDirectory
if n_elements(objname) eq 0 then begin
   objname = repstr(theDirectory,'/Users/wenlong/Work/mega/mwceph/pphot/','')
   objname = strupcase(repstr(objname,'/inired',''))
endif
objname = strupcase(objname)
str_dat = {id:0,obj:'',alias:'',ra:'',dec:'',p:0.d}
fmt_dat = '(I4,A11,A11,A10,A11,F12.6)'
f_dat = '../../mw_new_info.dat'
rdfile,f_dat,str_dat,fmt_dat,1,dat,nl_dat
dat.obj = rmfgspc(dat.obj)
dat.alias = rmfgspc(dat.alias)
dat.ra = rmfgspc(dat.ra)
dat.dec = rmfgspc(dat.dec)

; **************************************
print,' 1. Checking image headers...'
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   head = headfits(f_fit,/silent)
   object = rmfgspc(sxpar(head,'OBJECT',count=cnt))
   if cnt ne 1 then message,'Keyword OBJECT not found in '+f_fit
   if object eq 'V0339CEN' then object = 'VJCEN'
   if object eq 'V0340ARA' then object = 'VJARA'
   if object ne objname then message,' Warning! '+f_fit+' has a wrong object name' else statusline,'           ... OBJECT KEYWORD GOOD'
   ind = where(objname eq dat.alias,cnt)
   if cnt ne 1 then message,'Keyword OBJECT not found in '+f_dat
   ts = dat[ind]
   ra = strmid(rmfgspc(sxpar(head,'RA',count=cnt1)),0,8)
   dec = strmid(rmfgspc(sxpar(head,'DEC',count=cnt2)),1,8)
   if cnt1 ne 1 or cnt2 ne 1 then message,'Keyword RA/DEC not found in '+f_fit
   foora = float(strmid(ra,0,2))*3600 + float(strmid(ra,3,2))*60 + float(strmid(ra,6,2))
   foora2 = float(strmid(ts.ra,0,2))*3600 + float(strmid(ts.ra,3,2))*60 + float(strmid(ts.ra,6,2))
   foodec = float(strmid(dec,0,2))*3600 + float(strmid(dec,3,2))*60 + float(strmid(dec,6,2))
   foodec2 = float(strmid(ts.dec,1,2))*3600 + float(strmid(ts.dec,4,2))*60 + float(strmid(ts.dec,7,2))
   if abs(foora-foora2) ge 60 or abs(foodec-foodec2) ge 80 then message,' Warning! '+f_fit+' has a wrong RA/DEC' else statusline,'           ... RA/DEC KEYWORD GOOD'
endfor
print,'           ... OBJECT KEYWORD GOOD'
print,'           ... RA/DEC KEYWORD GOOD'
darks = file_search('../../dark/dark??????.fits',count=ndarks)
flats = file_search('../../flat/flat??????.fits',count=nflats)
masks = file_search('../../dark/mask??????.fits',count=nmasks)
if ndarks eq 0 then message,'  Please make dark frames first'
if nflats eq 0 then message,'  Please make flat frames first'
if nmasks eq 0 then message,'  Please make mask frames first'
print,'           ... DARK/FLAT/MASK READY'
; **************************************


; **************************************
print,' 2. Give images shorter name...'
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   yr = long(strmid(f_fit,5,2))
   mn = long(strmid(f_fit,7,2))
   dy = long(strmid(f_fit,9,2))
   mn2dy = [0,31,28,31,30,31,30,31,31,30,31,30,31] 
   mn2dy_leap = [0,31,29,31,30,31,30,31,31,30,31,30,31] ; 2016 is a leap year
   if yr lt 16 then days = (yr-14)*365 + total(mn2dy[0:mn-1]) + dy ; days start at 2014/01/01 as day 1
   if yr eq 16 then days = (yr-14)*365 + total(mn2dy_leap[0:mn-1]) + dy
   if yr gt 16 and yr lt 20 then days = (yr-14)*365 + total(mn2dy[0:mn-1]) + dy + 1
   if yr ge 20 then message,' Error! Did not expect images taken after 2020.'
   days = cuti4(round(days))
   head = headfits(f_fit,/silent)
   filter_name = rmfgspc(sxpar(head,'IRFLTID',count=cnt))
   if cnt ne 1 then message,'Keyword IRFLTID not found in '+f_fit
   if filter_name eq 'H+ND4' then fname_start = 'n' else if filter_name eq 'H' then fname_start = 'h' else message,' Wrong filter name: '+filter_name
   newname = fname_start + days + 'n'+strmid(f_fit,12,9)
   file_move,f_fit,newname
endfor
print,'   ... hXXXXnxxxx.fits or nXXXXnxxxx.fits: XXXX-days start from 2014/01/01'
; **************************************



; **************************************
print,' 3. update keywords...'
fits = file_search('./?????n????.fits',count=nfits)
darks = file_search('../../dark/dark??????.fits',count=ndarks)
flats = file_search('../../flat/flat??????.fits',count=nflats)
dark_jds = dblarr(ndarks)
flat_jds = dblarr(nflats)
for i=0,ndarks-1 do begin
   f_dark = darks[i]
   head = headfits(f_dark,/silent)
   dark_jds[i] = double(sxpar(head,'JD',count=cnt))
   if cnt eq 0 then message,'Error! Keyword JD not found in '+f_dark
endfor
for i=0,nflats-1 do begin
   f_flat = flats[i]
   head = headfits(f_flat,/silent)
   flat_jds[i] = double(sxpar(head,'JD',count=cnt))
   if cnt eq 0 then message,'Error! Keyword JD not found in '+f_flat
endfor
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   head = headfits(f_fit,/silent)
   filter_name = rmfgspc(sxpar(head,'IRFLTID',count=cnt))
   if filter_name eq 'H+ND4' then fil = 'H4' else $
      if filter_name eq 'H' then fil = 'H' $
      else message,'Keyword IRFLTID not found in '+f_fit
   sxaddpar,head,'FILTER',fil
   sxaddpar,head,'IMAGETYP','object'
   ind = where(objname eq dat.alias,cnt)
   if cnt ne 1 then message,'Keyword OBJECT not found in '+f_dat
   period = dat[ind].p
   sxaddpar,head,'PERIOD',rmfgspc(period)
   fit_jddate = sxpar(head,'JD')
   f_dark = darks[closest(dark_jds,fit_jddate)]
   f_flat = flats[closest(flat_jds,fit_jddate)]
   sxaddpar,head,'DARKU',f_dark
   sxaddpar,head,'FLATU',f_flat
   modfits,f_fit,0,head
endfor
print,'   ... ADD KEYWORDS: FILTER,IMAGETYP,PERIOD,DARKU,FLATU'
; **************************************


; **************************************
print,' 4. dark correction and flat field...'
print,'    ... USE DARKS(20s) AS BIAS/ZERO; USE FLAT(20s) AS FLAT'
rmexfile,'zerocorlog.dat'
rmexfile,'flatcorlog.dat'
rmexfile,'logfile'
fits = file_search('./?????n????.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   showprogress,i_fit,nfits-1
   f_fit = fits[i_fit]
   head = headfits(f_fit,/silent)
   fit_jddate = sxpar(head,'JD')
   f_dark = sxpar(head,'DARKU')
   f_flat = sxpar(head,'FLATU')
   openw,lun,'zerocor.cl',/get_lun
   printf,lun,'noao'
   printf,lun,'imred'
   printf,lun,'ccdred'
   printf,lun,'unlearn ccdproc'
   printf,lun,'ccdproc(images="'+f_fit+'",zerocor+,'+$
          'darkcor-,flatcor-,oversca-,trim-,'+$
       'zero="'+f_dark+'")'
   printf,lun,'logout'
   cf,lun 
   spawn,'cl < '+'zerocor.cl >> zerocorlog.dat'
   spawn,'mv logfile logfile_zerocor'
   openw,lun,'flatcor.cl',/get_lun
   printf,lun,'noao'
   printf,lun,'imred'
   printf,lun,'ccdred'
   printf,lun,'unlearn ccdproc'
   printf,lun,'ccdproc(images="'+f_fit+'",zerocor-,'+$
          'darkcor-,flatcor+,oversca-,trim-,'+$
          'flat="'+f_flat+'")'
   printf,lun,'logout'
   cf,lun
   spawn,'cl < '+'flatcor.cl >> flatcorlog.dat'
   spawn,'mv logfile logfile_flatcor'
   rmexfile,'zerocor.cl'
   rmexfile,'flatcor.cl'
endfor
rmexfile,'uparmccdccdprc.par'
print,''
; **************************************


; **************************************
print,' 5. Mask off bad pixels & Average sky levels for 4 chips'
print,'    ... sky level was set to be 30 for all images'
fits = file_search('./?????n????.fits',count=nfits)
highbad = 60000 ; make sky function work for high bad
lowbad = -32767 ; make DAOPHOT work for bad pixel
for i_fit=0,nfits-1 do begin
   ;showprogress,i_fit,nfits-1
   f_fit = fits[i_fit]
   a = readfits(f_fit,head,/silent)
   f_mask = repstr(sxpar(head,'DARKU'),'/dark/dark','/dark/mask')
   mask = readfits(f_mask,hmask,/silent)
   bad = where(mask eq 0, nbad)
   if nbad ge 1 then begin
      a(bad) = highbad + 20000 ; make sky function work for high bad
   endif
   chip1 = a(0:255,0:255)
   chip2 = a(256:511,0:255)
   chip3 = a(0:255,256:511)
   chip4 = a(256:511,256:511)
   sky,chip1,sky1,/silent,highbad = highbad
   sky,chip2,sky2,/silent,highbad = highbad
   sky,chip3,sky3,/silent,highbad = highbad
   sky,chip4,sky4,/silent,highbad = highbad
   chip1 -= sky1
   chip2 -= sky2
   chip3 -= sky3
   chip4 -= sky4
   a(0:255,0:255) = chip1
   a(256:511,0:255) = chip2
   a(0:255,256:511) = chip3
   a(256:511,256:511) = chip4
   a += 30.
   if nbad ge 1 then begin
      a(bad) = lowbad ; make DAOPHOT work for bad pixel
   endif
   writefits,f_fit,a,head
endfor
; **************************************
print,'FINISHED'
end
