pro pphcaldm,skip_ids
  !quiet=1

  if n_elements(skip_ids) eq 0 then skip_ids = []

  i_m0 = 9                      ; aperture=7.3pix
  i_m = i_m0 + 2
  ceph_radius = 25
  if file_test('fit_result.log') then begin
     readcol,'fit_result.log',foo1,foo2,fit_low_lim,fit_high_lim,skipline=1,/silent
     default_blim = fit_low_lim[0]
     default_flim = fit_high_lim[0]
  endif else begin
     default_blim = 16.0
     default_flim = 18.5
  endelse
  default_sigma = 3.

  f_alf = 'master_smt.alf'
  fmt_alf = '(I7,3(F9.3),F9.4,F9.2,F9.0,F9.2,F9.3)'
  str_alf = {id:0l,x:0.,y:0.,m:0.,e:0.,s:0.,n:0.,ch:0.,sh:0.}
  rdfile,f_alf,str_alf,fmt_alf,3,alf,nl_alf


  f_fit = repstr(f_alf,'.alf','.fits')
  img_arr = readfits(f_fit,header,/silent)
  zscale,img_arr,img_arr2,1.0
  size = size(img_arr2)
  window,0,xsize=size[1],ysize=size[2]
  fkalf = alf(where(abs(alf.m) lt 90.))
  fkalf = fkalf(sort(fkalf.m))
  for ifk=0,10 do begin
     ts = fkalf[ifk]
     ceph_mx = ts.x
     ceph_my = ts.y
     ceph_master_id = ts.id
     for ij=0,size[1]-1 do for ik=0,size[2]-1 do $
        if (ceph_mx-ij)^2+(ceph_my-ik)^2 ge 10^2 and (ceph_mx-ij)^2+(ceph_my-ik)^2 le 13^2 then $
           img_arr2(ij,ik) = 255
     tv,img_arr2
isceph:
     satans = ''
     read,satans,prompt=' Is this the Cepheid? (y/n) If Cepheid not in frame, press -1: '
     if ~(satans eq 'n' or satans eq 'N' or satans eq 'y' or satans eq 'Y' or satans eq '-1') then goto,isceph
     if satans eq '-1' then begin
        ceph_mx = -99
        ceph_my = -99
        ceph_master_id = -1
        break
     endif
     if satans eq 'y' or satans eq 'Y' then break
  endfor
  wdelete,0

  period = float(sxpar(header,'PERIOD',count=cnt))

  window,0
  fmt_dmt = '(a21,f12.5,f9.5,2f9.3,i5,f6.2,2f8.2,4f9.3,i4,f12.6)'
  f_dmt = 'dm_table.dmt'
  openw,l_dmt,f_dmt,/get_lun
  printf,l_dmt,'         image            mjd       phase       dm      stdd  dof sigma  brilim  fntlim   cephx    cephy    cephm     cephe dither period'

  fprs = file_search('h????n????_smt.fpr',count=nfprs)
  for i_fpr=0,nfprs-1 do begin
     f_fpr = fprs[i_fpr]
     showprogress,i_fpr+1,nfprs,'Calculate '+f_fpr
     print,''

     f_fit = repstr(f_fpr,'.fpr','.fits')
     head = headfits(f_fit,/silent)
     jd = sxpar(head,'JD',count=njds)
     if njds ne 1 then begin
        print,' Warning: Keyword JD not found in '+f_fit
     endif
     if njds eq 1 then mjd = jd - 2450000.d else mjd = 0.d
     phase = mjd/period - floor(mjd/period) ; zero point at mjd = 0

     fmt_fpr = '(I7,2F9.3,24F9.3,24F9.3,2F9.3)'
     str_fpr = {id:0l,x:0.,y:0.,M1:0.,M2:0.,M3:0.,M4:0.,M5:0.,M6:0.,M7:0.,M8:0.,M9:0.,M10:0.,M11:0.,M12:0.,M13:0.,M14:0.,M15:0.,M16:0.,M17:0.,M18:0.,M19:0.,M20:0.,M21:0.,M22:0.,M23:0.,M24:0.,E1:0.,E2:0.,E3:0.,E4:0.,E5:0.,E6:0.,E7:0.,E8:0.,E9:0.,E10:0.,E11:0.,E12:0.,E13:0.,E14:0.,E15:0.,E16:0.,E17:0.,E18:0.,E19:0.,E20:0.,E21:0.,E22:0.,E23:0.,E24:0.,sky:0.,skyerr:0.}
     rdfile,f_fpr,str_fpr,fmt_fpr,2,fpr,nl_fpr

     if ceph_master_id ne -1 then begin
        ceph_ind = where(fpr.id eq ceph_master_id,cephcnt)
        if cephcnt ne 1 then begin
           print,' Cepheid id not found in '+f_fpr
           ceph_ind = 0
           print,' Please enter the index of cepheid in '+f_fpr
           print,' One can enter -1 if use ND4 to measure Cepheid brightness'
           read,ceph_ind
        endif
        ceph_x = fpr(ceph_ind).x
        ceph_y = fpr(ceph_ind).y
        ceph_m = fpr(ceph_ind).(i_m)
        ceph_e = fpr(ceph_ind).(i_m + 24)
        if ceph_ind eq '-1' then begin
           ceph_x = -99.99
           ceph_y = -99.99
           ceph_m = 99.99
           ceph_e = 9.99
        endif
     endif else begin
        ceph_x = -99.99
        ceph_y = -99.99
        ceph_m = 99.99
        ceph_e = 9.99
     endelse

     str_com = {id:0l,x:0.,y:0.,m:0.,e:0.,mm:0.,me:0.,sky:0.,skyerr:0.,chip:0,q:0,nbadpix:0}
     com = replicate(str_com,nl_fpr+1)
     for i_com=0,nl_fpr do begin
        com[i_com].id = fpr[i_com].id
        com[i_com].x = fpr[i_com].x
        com[i_com].y = fpr[i_com].y
        com[i_com].m = fpr[i_com].(i_m)
        com[i_com].e = fpr[i_com].(i_m + 24)
        com[i_com].sky = fpr[i_com].sky
        com[i_com].skyerr = fpr[i_com].skyerr
        ind = where(alf.id eq fpr[i_com].id,cnt)
        if cnt ne 1 then message,' Oops! '+fpr[i_com].id+' not found in master list'
        com[i_com].mm = alf[ind].m
        com[i_com].me = alf[ind].e
        x = com[i_com].x
        y = com[i_com].y
        if x lt 255 and y lt 255 then chip = 3
        if x lt 255 and y ge 255 then chip = 1
        if x ge 255 and y lt 255 then chip = 4
        if x ge 255 and y ge 255 then chip = 2
        com[i_com].chip = chip
        if (ceph_x-x)^2 + (ceph_y-y)^2 lt ceph_radius^2 then com[i_com].q = 1
                                ; exclude the hot regions at y=250+\-10
        if y gt 240 and y lt 260 then com[i_com].q = 2
                                ; exclude those too close to each other
        alldists = (fpr.x - x)^2 + (fpr.y - y)^2
        alldists = alldists[sort(alldists)]
        smalldist = alldists[1]
        if smalldist lt 225 then com[i_com].q = 3
                                ;if smalldist lt 225 then print,x,y
        foo_ind = where(com[i_com].id eq skip_ids,foo_cnt)
        if foo_cnt eq 1 then com[i_com].q = 4 ; ignore some bad objects
     endfor

;loadct,13,/silent
replot:
     god = com(where(com.q eq 0 and abs(com.m) lt 90. and abs(com.mm) lt 90,cnt))
     x = god.mm
     y = god.m - god.mm
     xrange = [min(x)-0.5,max(x)+0.5]
     yrange = [min(y)-0.3,max(y)+0.3]
     yerr = sqrt(god.e^2 + god.me^2)
     sym_A = FINDGEN(17) * (!PI*2/16.)
     USERSYM, COS(sym_A), SIN(sym_A), /FILL
     plot,x,y,psym=8,yrange=yrange,/ystyle,xrange=xrange,/xstyle,background='ffffff'x,color=0,$
          ytitle='H(this image) - H(master image)',xtitle='H (mag)',title = repstr(f_fpr,'.fpr','.fits')
     errplot,x,y-yerr,y+yerr,color=0

askblim:
     bri_lim = ''
     read,bri_lim,prompt=' Enter a bright limit cut (<65 please): [default '+rmfgspc(default_blim)+'] '
     if bri_lim eq '' then bri_lim = default_blim
     if max(byte(bri_lim)) ge 65 then goto,askblim
     bri_lim = float(bri_lim)
     default_blim = bri_lim
     oplot,[bri_lim,bri_lim],[-100,100],color='00ff00'x
askflim:
     fat_lim = ''
     read,fat_lim,prompt=' Enter a faint limit cut (<65 please): [default '+rmfgspc(default_flim)+'] '
     if fat_lim eq '' then fat_lim = default_flim
     if max(byte(fat_lim)) ge 65 then goto,askflim
     fat_lim = float(fat_lim)
     if bri_lim ge fat_lim then goto,askblim
     default_flim = fat_lim
     oplot,[fat_lim,fat_lim],[-100,100],color='0000ff'x

     god = com(where(com.q eq 0 and abs(com.m) lt 90. and abs(com.mm) lt 90 and com.mm lt fat_lim and com.mm gt bri_lim,cnt))
     if cnt le 1 then begin
        inc_or_del = ''
        read,inc_or_del,prompt = ' Too few stars included. Increase the range (i) or delete this frame (d)?'
        if inc_or_del eq 'i' then begin
           goto,replot
        endif else begin
           meany = -99
           stddy = -99
           dof = 0
           sigma = 0
           ditherpos = 0
           goto,write_result
        endelse
     endif
     wait,0.6

     x = god.mm
     y = god.m - god.mm
     xrange = [min(x)-0.5,max(x)+0.5]
     yrange = [min(y)-0.3,max(y)+0.3]
     yerr = sqrt(god.e^2 + god.me^2)
     sym_A = FINDGEN(17) * (!PI*2/16.)
     USERSYM, COS(sym_A), SIN(sym_A), /FILL
     plot,x,y,psym=8,yrange=yrange,/ystyle,xrange=xrange,/xstyle,background='ffffff'x,color=0,$
          ytitle='H(this image) - H(master image)',xtitle='H (mag)',title = repstr(f_fpr,'.fpr','.fits')
     errplot,x,y-yerr,y+yerr,color=0

satisfy:
     satans = ''
     read,satans,prompt=' Are you satisfied? (y/n) [default y]: '
     if ~(satans eq 'n' or satans eq 'N' or satans eq 'y' or satans eq 'Y' or satans eq '') then goto,satisfy
     if satans eq 'n' or satans eq 'N' then goto,replot

asksigma:
     sigma = ''
     read,sigma,prompt=' Enter a sigma for clip bad data (<65 please): [default '+rmfgspc(default_sigma)+'] '
     if sigma eq '' then sigma = default_sigma
     if max(byte(sigma)) ge 65 then goto,asksigma
     sigma = float(sigma)
     if sigma lt 1.39 then goto,asksigma
     default_sigma = sigma
     x = god.mm
     y = god.m - god.mm
     yerr = sqrt(god.e^2 + god.me^2)
     if n_elements(y) ge 3 then begin
        sigmaclip1once,y,indkp,meany,stddy,sigma,indrj,yerr,/silent
     endif else begin
        indkp = findgen(n_elements(y))
        meany = poly_fit(indkp,y,0,measure_errors=yerr)
        stddy = (max(y)-min(y))/2
        indrj = []
     endelse
     ngd = god(indkp)
     x = ngd.mm
     y = ngd.m - ngd.mm
     yerr = sqrt(ngd.e^2 + ngd.me^2)
     xrange = [min(x)-0.5,max(x)+0.5]
     yrange = [meany-5*stddy,meany+5*stddy]
     sym_A = FINDGEN(17) * (!PI*2/16.)
     USERSYM, COS(sym_A), SIN(sym_A),/fill
     plot,x,y,psym=8,yrange=yrange,/ystyle,xrange=xrange,/xstyle,background='ffffff'x,color=0,$
          ytitle='H(this image) - H(master image)',xtitle='H (mag)',title = repstr(f_fpr,'.fpr','.fits')
     errplot,x,y-yerr,y+yerr,color=0
     oplot,xrange,[meany-0*stddy,meany-0*stddy],color='ffaa00'x
     oplot,xrange,[meany+1*stddy,meany+1*stddy],color='00aaff'x
     oplot,xrange,[meany-1*stddy,meany-1*stddy],color='00aaff'x
     if n_elements(indrj) ge 2 then begin
        sym_A = FINDGEN(17) * (!PI*2/16.)
        USERSYM, COS(sym_A), SIN(sym_A)
        oplot,god(indrj).mm,god(indrj).m - god(indrj).mm,color='bbbbbb'x,psym=8
        errplot,god(indrj).mm,god(indrj).m-god(indrj).mm-sqrt(god(indrj).e^2+god(indrj).me^2),$
                god(indrj).m-god(indrj).mm+sqrt(god(indrj).e^2+god(indrj).me^2),color='bbbbbb'x
     endif

satisfy2:
     satans = ''
     read,satans,prompt=' Are you satisfied? (y/n) [default y] If change limit, press back: '
     if ~(satans eq 'n' or satans eq 'N' or satans eq 'y' or satans eq 'Y' or satans eq '' or satans eq 'back') then goto,satisfy2
     if satans eq 'n' or satans eq 'N' then goto,asksigma
     if satans eq 'back' then goto,replot

     dof = n_elements(ngd.m) - 1
     ditherpos = 0

write_result:
     printf,l_dmt,f_fit,mjd,phase,meany,stddy,dof,sigma,bri_lim,fat_lim,ceph_x,ceph_y,ceph_m,ceph_e,ditherpos,period,$
            format = fmt_dmt

; write the reference star list
     f_ref = repstr(f_fit,'.fits','_refstar.lst')
     openw,l_ref,f_ref,/get_lun
     printf,l_ref,'   id       x        y        m         e'
     if dof ne 0 then begin
        for iref=0,n_elements(ngd.m)-1 do begin
           printf,l_ref,ngd[iref].id,ngd[iref].x,ngd[iref].y,ngd[iref].m,ngd[iref].e,format='(i7,4f9.3)'
        endfor
     endif
     cf,l_ref

  endfor
  wdelete,0
  cf,l_dmt
end
