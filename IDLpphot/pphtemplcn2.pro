function hlctem,x,p
  as=[0.433,0.094,0.046,0.023,0.022,0.021,0.016]
  ps=[1.397,2.543,3.266,3.886,3.813,4.380,5.245]
  t = 0
  for i=0,6 do t+=as[i]*cos(2*!pi*(i+1)*(x+p[1])+ps[i])
  t = p[0]*t + p[2]
  return,t
end
function caltpltc,x,phi
  as=[0.433,0.094,0.046,0.023,0.022,0.021,0.016]
  ps=[1.397,2.543,3.266,3.886,3.813,4.380,5.245]
  t = 0
  for i=0,6 do t+=as[i]*cos(2*!pi*(i+1)*(x+phi)+ps[i])
  return,t
end


pro pphtemplcn2,obj

  itlim = 15

  if n_elements(obj) eq 0 then begin
     getwd,wd
     obj = repstr(strmid(wd,strlen(wd)-11,6),'/','')
     print,obj
  endif
  f_nulc = 'nulc.nulc'
  fmt_nulc = '(a21,f12.5,f9.5,f10.4,a3,10f9.3,i4)'
  str_nulc = {img:'',mjd:0.d,ph:0.d,p:0.d,pol:'',x:0.,y:0.,m:0.,e:0.,sky:0.,esky:0.,dm:0.,edm:0.,cm:0.,ce:0.,flag:0}
  rdfile,f_nulc,str_nulc,fmt_nulc,1,nulc,nl_nulc
  nulc = nulc(where(nulc.flag eq 0))

  ngts = rmfgspc(nulc.img)
  ngtsimg = strmid(ngts,0,5)
  ngts = ngtsimg
  ngts = ngts[uniq(ngts,sort(ngts))]
  nngts = n_elements(ngts)

  str_slc = {mjd:0.d,ph:0.d,m:0.,e:0.,p:0.d}
  slc = replicate(str_slc,nngts)

  for ingt=0,nngts-1 do begin
     ind = where(ngtsimg eq ngts[ingt],cnt)
     tss = nulc[ind]
     if max(tss.mjd) - min(tss.mjd) ge 0.7 then message,' This script failed. Please try ophtemplcn2.pro'
     slc[ingt].ph = mean(tss.ph)
     slc[ingt].mjd = mean(tss.mjd)
     slc[ingt].p = nulc[0].p
     sigmaclip1once,tss.cm,kp,mncm,stdd,30,rj,tss.ce
     slc[ingt].m = mncm
     if cnt ge 3 then slc[ingt].e = stdd/sqrt(cnt-1) else slc[ingt].e = mean([tss.ce,tss.ce])
  endfor
  slc = slc[sort(slc.ph)]
  nl_slc = nngts - 1

     start = [0.6,0.5,18.0]
     pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},3)
     x=slc.ph
     y=slc.m
     yerr=slc.e
     nobs = n_elements(x)
     design_mat = make_array(2,nobs)
     design_mat[0,0:(nobs-1)] = 1.d
     tobs = transpose(y)
     nerr = yerr/mean(yerr)
     invc = make_array(nobs,nobs)
     for ic = 0,nobs-1 do invc[ic,ic] = 1.d/nerr[ic]^2
     iit = 0
     while (iit lt itlim) do begin
      ; (1) Use MPFIT to estimate optimal phase shift
      pars = mpfitfun('hlctem',x,y,yerr,start,perr=ep,bestnorm=bre,/quiet,parinfo=pi)
      if pars[0] lt 0 then begin
         pars[0] = abs(pars[0])
         pars[1] = pars[1] + 0.5
      endif
      while pars[1] lt 0 do pars[1]++
      pars[1] = pars[1] mod 1
      phase_shift = pars[1]
      
      ; (2) Use linear regression model to find best fit
      design_mat[1,0:(nobs-1)] = caltpltc(x,phase_shift)
      tdmat = transpose(design_mat)
      beta = invert(tdmat##invc##design_mat)##(tdmat##invc##tobs)
      meanmag = beta[0]
      amptitude = beta[1]

      ; (3) Fix <H> and Amp, find optimal phase_shift. Repeat this process
      start = [amptitude,phase_shift,meanmag]
      pi[0].fixed = 1
      pi[2].fixed = 1
      iit++
   endwhile

     pars = start
     x = [x,x+1]
     y = [y,y]
     yerr = [yerr,yerr]
     
     contx = findgen(1000)/1000
     conty = hlctem(contx,pars)
     contx = [contx,contx+1]
     conty = [conty,conty]
     
     window,0
     for i_chk=0,nl_slc do begin
        plot,contx,conty,yrange=[mean(y)+0.65,mean(y)-0.63],/yst
        oplot,x,y,psym=2
        errplot,x,y+yerr,y-yerr
        xchk = [slc[i_chk].ph,slc[i_chk].ph+1]
        ychk = [slc[i_chk].m,slc[i_chk].m]
        echk = [slc[i_chk].e,slc[i_chk].e]
        oplot,xchk,ychk,psym=2,color='0000ff'x
        errplot,xchk,ychk+echk,ychk-echk,color='0000ff'x
        askign:
        ign = 'n'
        read,ign,prompt=' Ignore this datum? (y/n) '
        if ~(ign eq 'y' or ign eq 'n') then goto,askign
        if ign eq 'y' then slc[i_chk].p = -1
     endfor
     
     ; print out the slc file
     openw,l_nsc,obj+'_n.slc',/get_lun
     printf,l_nsc,'       mjd      phase      m        e     period'
     for ifoo=0,nl_slc do printf,l_nsc,slc[ifoo],format='(f12.5,f9.5,2f9.3,f10.4)'
     cf,l_nsc

     nslc = slc(where(slc.p gt 0.,cnt,complement=idb))
     nl_nslc = cnt-1
     
     start = pars
     x=nslc.ph
     y=nslc.m
     yerr=nslc.e
     nobs = n_elements(x)
     design_mat = make_array(2,nobs)
     design_mat[0,0:(nobs-1)] = 1.d
     tobs = transpose(y)
     nerr = yerr/mean(yerr)
     invc = make_array(nobs,nobs)
     for ic = 0,nobs-1 do invc[ic,ic] = 1.d/nerr[ic]^2
     iit = 0
     while (iit lt itlim) do begin
      ; (1) Use MPFIT to estimate optimal phase shift
      pars = mpfitfun('hlctem',x,y,yerr,start,perr=ep,bestnorm=bre,/quiet,parinfo=pi)
      if pars[0] lt 0 then begin
         pars[0] = abs(pars[0])
         pars[1] = pars[1] + 0.5
      endif
      while pars[1] lt 0 do pars[1]++
      pars[1] = pars[1] mod 1
      phase_shift = pars[1]
      
      ; (2) Use linear regression model to find best fit
      design_mat[1,0:(nobs-1)] = caltpltc(x,phase_shift)
      tdmat = transpose(design_mat)
      beta = invert(tdmat##invc##design_mat)##(tdmat##invc##tobs)
      meanmag = beta[0]
      amptitude = beta[1]

      ; (3) Fix <H> and Amp, find optimal phase_shift. Repeat this process
      start = [amptitude,phase_shift,meanmag]
      pi[0].fixed = 1
      pi[2].fixed = 1
      iit++
   endwhile
     pars = start
     x = [x,x+1]
     y = [y,y]
     yerr = [yerr,yerr]
     contx = findgen(5000)/5000
     conty = hlctem(contx,pars)


     openw,l_cont,obj+'_ntemp.dat',/get_lun
     printf,l_cont,'     phase       mag'
     for icont = 0,n_elements(contx)-1 do begin
        printf,l_cont,contx[icont],conty[icont],format='(f12.5,f11.5)'
     endfor
     cf,l_cont


     contx = [contx,contx+1]
     conty = [conty,conty]

     plot,contx,conty,yrange=[mean(y)+0.35,mean(y)-0.3],/yst
     oplot,x,y,psym=2
     errplot,x,y+yerr,y-yerr
     if cnt-1 ne nl_slc then begin
        bad = slc(idb)
        badx=bad.ph
        bady=bad.m
        badyerr=bad.e
        badx = [badx,badx+1]
        bady = [bady,bady]
        badyerr = [badyerr,badyerr]
        oplot,badx,bady,psym=2,color='aaaaaa'x
        errplot,badx,bady+badyerr,bady-badyerr,color='aaaaaa'x
     endif
     wdelete,0
     p = plot(contx,conty,color='black',yrange=[mean(y)+0.35,mean(y)-0.3],xrange=[-0.05,2.05],xtit='Phase',ytit='H (mag)',tit=strupcase(obj)+'         P='+flt3digitstr(nslc[0].p))
     p2 = errorplot(x,y,yerr,'o',color='black',sym_filled=1,errorbar_capsize=0.17,errorbar_color='black',/overplot)
     if cnt-1 ne nl_slc then begin
        p3 = errorplot(badx,bady,badyerr,'o',color='grey',sym_filled=0,errorbar_capsize=0.17,errorbar_color='grey',/overplot)
     endif
     p.save,'./'+obj+'_n.png'
     p.close

     p = plot(contx,conty,color='black',yrange=[mean(y)+0.35,mean(y)-0.3],xrange=[-0.05,2.05],xtit='Phase',ytit='H (mag)',tit=strupcase(obj)+'         P='+flt3digitstr(nslc[0].p))
     p2 = errorplot(x,y,yerr,'o',color='black',sym_filled=1,errorbar_capsize=0.17,errorbar_color='black',/overplot)
     if cnt-1 ne nl_slc then begin
        p3 = errorplot(badx,bady,badyerr,'o',color='grey',sym_filled=0,errorbar_capsize=0.17,errorbar_color='grey',/overplot)
     endif
     p.xticklen=1
     p.xsubgridstyle=1
     p.xgridstyle=1 
     p.save,'./'+obj+'_ng.png'
     p.close
end
