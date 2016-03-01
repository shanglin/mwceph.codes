pro pphmch2psc_byhand

f_psc = 'psc.alf'
f_mst = 'master_smt.alf'
fmt_alf = '(I7,3(F9.3),F9.4,F9.2,F9.0,F9.2,F9.3)'
str_alf = {id:0l,x:0.,y:0.,m:0.,e:0.,s:0.,n:0.,ch:0.,sh:0.}

rdfile,f_psc,str_alf,fmt_alf,3,psc,nl_psc
rdfile,f_mst,str_alf,fmt_alf,3,mst,nl_mst

str_cmp = {id:0l,x:0.,y:0.,m:0.,e:0.,id2:0l,x2:0.,y2:0.,m2:0.,e2:0.}
f_mch = 'eyemch.dat'
readcol,f_mch,mstids,pscids,skipline=1,format='i,i',/silent
cmp = replicate(str_cmp,n_elements(mstids))
for i=0,n_elements(mstids)-1 do begin
   mstid = mstids[i]
   pscid = pscids[i]
   ind1 = where(mst.id eq mstid,cnt1)
   if cnt1 ne 1 then message,'bad'
   ind2 = where(psc.id eq pscid,cnt2)
   if cnt2 ne 1 then message,'bad'
   cmp[i].id = mst[ind1].id
   cmp[i].x = mst[ind1].x  
   cmp[i].y =  mst[ind1].y  
   cmp[i].m =  mst[ind1].m 
   cmp[i].e =  mst[ind1].e 
   cmp[i].id2 =  psc[ind2].id  
   cmp[i].x2 =  psc[ind2].x 
   cmp[i].y2 =  psc[ind2].y 
   cmp[i].m2 =  psc[ind2].m  
   cmp[i].e2 =  psc[ind2].e
endfor
cmp = cmp[where(cmp.m2 ge 9.5 and cmp.m2 le 13.5)]
xrange = [12.,12.8]
x = cmp.m2
xe = cmp.e2
y = cmp.m - cmp.m2
ye = sqrt(cmp.e^2 + cmp.e2^2)
sigmaclip1once,y,kp,mn,stdd,3,rj,ye
capsize = 0.
p = errorplot(x,y,xe,ye,'o',linestyle='',sym_filled=1,sym_size=0.7,xrange=xrange,errorbar_capsize=capsize)
dh = mn
edh = stdd/sqrt(n_elements(kp)-1)
p3 = plot(xrange,[dh,dh],color='red',/overplot)
p3 = plot(xrange,[dh,dh]+stdd,color='blue',linestyle='--',/overplot)
p3 = plot(xrange,[dh,dh]-stdd,color='blue',linestyle='--',/overplot)
p.yrange = [dh-5*stdd,dh+5*stdd]
t = text(0.2,0.78,'<$\Delta$H> = '+flt3digitstr(dh)+' $\pm$ '+flt3digitstr(edh))
p.title = 'Aperture Photometry'
p.xtitle='2MASS H (mag)'
p.ytitle='$\Delta$H (mag)'
p.save,'aper-zp.png'
p.save,'aper-zp.eps'
openw,lun,'dh_aper-2mass.txt',/get_lun
printf,lun,dh,edh,format='(f9.3,f9.4)'
cf,lun
end
