pro mkdark
!quiet = 1

fits = file_search('binir??????dark.????.fits',count=cnt)
if cnt eq 0 then message,'Error: No dark image found' 
for ifoo=0,cnt-1 do begin
   foo = strmid(fits(ifoo),5,6)
   if n_elements(bar) eq 0 then bar=foo else bar=[bar,foo]
endfor
dates = bar(uniq(bar))
ndates = n_elements(dates)

; ###################################################
; delete single bad ones before combine
; ! Some darks are not good! Check the combined images 
;   and remove those by adding them to the following
;   bad dates array
;   bad_dates = ['140605','140820','140831','140901']
    bad_dates = ['141029','141124']
; ###################################################
rmexfile,'darkcombinelog.dat'
rmexfile,'logfile'
for idate=0,ndates-1 do begin
   showprogress,idate,ndates-1
   date = dates(idate)
   drks = file_search('binir'+date+'dark.????.fits',count=drkcnt)
   ndrks = drkcnt
   for idrk=0,drkcnt-1 do begin
      f_drk = drks(idrk)
      head = headfits(f_drk,/silent)
      sxaddpar,head,'IMAGETYP','dark'
      modfits,f_drk,0,head
   endfor
   lstfiles = drks
   rmexfile,'dark'+date+'.lst'
   for ifoo=0,ndrks-1 do spawn,'echo '+lstfiles(ifoo)+' >> dark'+date+'.lst' 

   openw,lun,'darkcomb_'+date+'.cl',/get_lun
   printf,lun,'noao'
   printf,lun,'imred'
   printf,lun,'ccdred'
   printf,lun,'unlearn zerocombine'
   printf,lun,'zerocombine(input="@dark'+date+$
          '.lst",output="dark'+date+$
          '",combine="average",ccdtype="dark"'
   printf,lun,'logout'
   close,lun
   free_lun,lun
   spawn,'cl < '+'darkcomb_'+date+'.cl >> darkcombinelog.dat'
   rmexfile,'darkcomb_'+date+'.cl'
   rmexfile,'dark'+date+'.lst'
   rmexfile,'uparmccdzeroce.par'
   
   ind = where(date eq bad_dates,nbad)
   if nbad ge 1 then spawn,'mv dark'+date+'.fits bad_dark'+date+'.fits'
endfor
print,''
spawn,'mv logfile logfile_dark'
end
