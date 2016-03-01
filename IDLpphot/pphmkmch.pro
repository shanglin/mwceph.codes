pro imatch3,f_mch

  fmt_mch = '(A20,A23,F10.2,F10.2,F10.5,F10.5,F10.5,F10.5,F10.3,F10.3)'
  str_mch = {img:'',prime:'',dx:0.,dy:0.,a:0.,b:0.,c:0.,d:0.,e:0.,f:0.}
  rdfile,f_mch,str_mch,fmt_mch,0,mch,nl_mch
  mch.img = rmfgspc(mch.img)
  imgs = strmid(mch.img,1,14)+'.fits'
  fits = imgs
  nfits = n_elements(fits)
  
  ref = readfits(imgs[0],header,/silent)-30
  zscale,ref,ref_arr,1.0
  size = size(ref_arr)
  xdim = size[1]
  ydim = size[2]
  window,0,xsize=xdim,ysize=ydim,xpos=0,ypos=900
  tv,ref_arr

  openw,lun,'n'+f_mch,/get_lun
  printf,lun,"'"+repstr(fits[0],'.fits','.alf'),"'",0.,0.,1.,0.,0.,1.,0.,0.,format=fmt_mch

for ifit=1,nfits-1 do begin
     f_fit = fits[ifit]
     ind = where(strmid(f_fit,0,14) eq strmid(mch.img,1,14),cnt)
     if cnt eq 1 then begin ; only match those in the mch file
     if cnt eq 1 then begin
        dxo = mch[ind].dx
        dyo = mch[ind].dy
        if abs(dxo) ge 130 or abs(dyo) ge 130 then begin
           dxo = 0
           dyo = 0
        endif
     endif else begin
        dxo = 0
        dyo = 0
     endelse
        
     mat = readfits(f_fit,header2,/silent)-30
     zscale,mat,mat_arr,1.0
     window,1,xsize=xdim,ysize=ydim,xpos=xdim,ypos=900
     tv,mat_arr

     resetxy:
     dx = round(dxo)
     dy = round(dyo)
     window,2,xsize=xdim,ysize=ydim,xpos=xdim*2,ypos=900
     add = ref
     if dx ge 0 and dy ge 0 then add[dx:xdim-1,dy:ydim-1] += mat[0:xdim-1-dx,0:ydim-1-dy]
     if dx ge 0 and dy lt 0 then add[dx:xdim-1,0:ydim-1+dy] += mat[0:xdim-1-dx,-dy:ydim-1]
     if dx lt 0 and dy ge 0 then add[0:xdim-1+dx,dy:ydim-1] += mat[-dx:xdim-1,0:ydim-1-dy]
     if dx lt 0 and dy lt 0 then add[0:xdim-1+dx,0:ydim-1+dy] += mat[-dx:xdim-1,-dy:ydim-1]
     zscale,add,add_arr,1.0
     tv,add_arr

     reshift:
     action = ''
     print,' >> 4-left, 6-right, 8-up, 5-down, e-exit'
     print,' >> j-left, l-right, i-up, k-down, e-exit (alternative)'
     while action ne 'e' do begin
        action = get_kbrd()
        if action eq '4' or action eq 'j' then dx--
        if action eq '6' or action eq 'l' then dx++
        if action eq '8' or action eq 'i' then dy++
        if action eq '5' or action eq 'k' then dy--
        if action eq '2' then dy--
        add = ref
        if dx ge 0 and dy ge 0 then add[dx:xdim-1,dy:ydim-1] += mat[0:xdim-1-dx,0:ydim-1-dy]
        if dx ge 0 and dy lt 0 then add[dx:xdim-1,0:ydim-1+dy] += mat[0:xdim-1-dx,-dy:ydim-1]
        if dx lt 0 and dy ge 0 then add[0:xdim-1+dx,dy:ydim-1] += mat[-dx:xdim-1,0:ydim-1-dy]
        if dx lt 0 and dy lt 0 then add[0:xdim-1+dx,0:ydim-1+dy] += mat[-dx:xdim-1,-dy:ydim-1]
        zscale,add,add_arr,1.0
        tv,add_arr
     endwhile
     print,''
     print,'dx = '+rmfgspc(dx)+' ,    dy = '+rmfgspc(dy)+' .  Are you happy? [y(es) / n(o) / r(eset) / o(riginal)]'
     askhappy:
     ans = get_kbrd()
     if ~(ans eq 'y' or ans eq 'n' or ans eq 'r' or ans eq 'o') then goto,askhappy
     if ans eq 'r' then goto,resetxy
     if ans eq 'n' then goto,reshift
     if ans eq 'o' then begin
        dx = dxo
        dy = dyo
     endif
     printf,lun,"'"+repstr(fits[ifit],'.fits','.alf'),"'",dx,dy,1.,0.,0.,1.,0.,0.,format=fmt_mch
  endif
  endfor
  cf,lun
  wdelete,0,1,2
end

pro pphmkmch,eye
if n_elements(eye) eq 0 then eye = 1

readcol,'good_psf.lst',txts,format='a'
alfs = repstr(txts,'.txt','.alf')
nalfs = n_elements(alfs)

f_mch = 'test.mch'
openw,ldo,'domch.do',/get_lun
printf,ldo,alfs[0]
printf,ldo,f_mch
for i=1,nalfs-1 do printf,ldo,alfs[i]+';'
cf,ldo
spawn,'rm -f '+f_mch
spawn,'daomatch < domch.do > log_'+f_mch
spawn,'rm -f domch.do'
if eye eq 1 then begin
   imatch3,f_mch
   spawn,'mv n'+f_mch+' '+f_mch
endif
openw,lun,'domst.do',/get_lun
printf,lun,f_mch
printf,lun,rmfgspc(floor(nalfs*0.8))+',0.8,'+rmfgspc(floor(nalfs*0.8))
printf,lun,'0.25'
printf,lun,'2'
printf,lun,'-5'
for i=0,10 do printf,lun,'5'
for i=0,10 do printf,lun,'4'
for i=0,10 do printf,lun,'3'
for i=0,10 do printf,lun,'2'
printf,lun,'0'
for i=1,4 do printf,lun,'n'
printf,lun,'y'
printf,lun,'s'+f_mch
printf,lun,'e'
cf,lun
spawn,'rm -f s'+f_mch
spawn,'daomaster < domst.do >> log_'+f_mch
spawn,'rm -f domst.do'
spawn,'mv s'+f_mch+' master.mch'
end
