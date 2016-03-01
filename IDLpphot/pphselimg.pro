pro pphselimg

  openw,lun,'good_psf.lst',/get_lun
  fits = file_search('h????n????_smt.fits',count=nfits)
  for ifit=0,nfits-1 do begin
     f_fit = fits[ifit]
     print,' >>'+rmfgspc(ifit+1)+'/'+rmfgspc(nfits)+':  '+f_fit
     cmd = 'ds9 '+f_fit+' -scale log -scale zscale &'
     spawn,cmd,ds9id
     cmdkill = 'kill '+strmid(ds9id,4,5)   
     ans = ''
     while ~(ans eq 'y' or ans eq 'n') do begin
        print,' Please hit y/n'
        ans = get_kbrd()
     endwhile
     if ans eq 'y' then printf,lun,repstr(f_fit,'.fits','.txt')
     spawn,cmdkill
  endfor
  cf,lun
end
