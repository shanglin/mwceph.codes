pro imatch2img,fit_1,fit_2,f_out

  fmt_mch = '(A20,A23,F10.2,F10.2,F10.5,F10.5,F10.5,F10.5,F10.3,F10.3)'

  ref = readfits(fit_1,header,/silent)-30
  zscale,ref,ref_arr,1.0
  size = size(ref_arr)
  xdim = size[1]
  ydim = size[2]
  window,0,xsize=xdim,ysize=ydim,xpos=0,ypos=900
  tv,ref_arr

  openw,lun,f_out,/get_lun
  printf,lun,"'"+repstr(fit_1,'.fits','.alf'),"'",0.,0.,1.,0.,0.,1.,0.,0.,format=fmt_mch
  
  f_fit = fit_2
  dxo = 0
  dyo = 0
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
     print,' >> 4-left, 6-right, 8-up, 5-down'
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
     printf,lun,"'"+repstr(fit_1,'.fits','.alf'),"'",dx,dy,1.,0.,0.,1.,0.,0.,format=fmt_mch
     wdelete,0
     wdelete,1
     wdelete,2
  cf,lun
end
