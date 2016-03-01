pro pphmkfco,f_alf,f_alf2

;f_alf = 'master_smt.alf'
;f_alf2 = 'h0056n0129_smt.alf'

rmexfile,repstr(f_alf2,'.alf','_mch.mch')
spawn,'echo '+f_alf+' > intdo.do'
spawn,'echo '+repstr(f_alf2,'.alf','_mch.mch')+' >> intdo.do'
spawn,'echo '+f_alf2+' >> intdo.do'
spawn,'echo e >> intdo.do'
spawn,'daomatch < intdo.do > intdo.out'
rmexfile,repstr(f_alf2,'.alf','_mst.mch')
spawn,'echo '+repstr(f_alf2,'.alf','_mch.mch')+' > intdo.do'
spawn,'echo 2,1,2 >> intdo.do'
spawn,'echo 0.25 >> intdo.do'
spawn,'echo 2 >> intdo.do'
spawn,'echo 5 >> intdo.do'
for ifooloop=1,5 do spawn,'echo 3 >> intdo.do'
for ifooloop=1,5 do spawn,'echo 2 >> intdo.do'
spawn,'echo 0 >> intdo.do'
for ifooloop=1,4 do spawn,'echo n >> intdo.do'
spawn,'echo y >> intdo.do'
spawn,'echo '+repstr(f_alf2,'.alf','_mst.mch')+' >> intdo.do'
spawn,'echo e >> intdo.do'
spawn,'daomaster < intdo.do > intdo.out'
rmexfile,repstr(f_alf2,'.alf','_mch.mch')
rmexfile,'intdo.do'
rmexfile,'intdo.out'

fmt_alf = '(I7,3(F9.3),F9.4,F9.2,F9.0,F9.2,F9.3)'
str_alf = {id:0l,x:0.,y:0.,m:0.,e:0.,s:0.,n:0.,ch:0.,sh:0.}
rdfile,f_alf,str_alf,fmt_alf,3,alf,nl_alf

if file_test(repstr(f_alf2,'.alf','_mst.mch')) then begin
   readcol,repstr(f_alf2,'.alf','_mst.mch'),fooname,fooname2,xshft,yshft,format='a,a,f,f',/silent
   xshft = xshft[1]
   yshft = yshft[1]
   x2 = alf.x - xshft ; Well, it does not matter whether the first pixel is (0,0) or (0.5,0.5)
   y2 = alf.y - yshft ; because only relative shifts used, and ALF files from IDL, which has (0,0) convention
endif else begin ; using imatch ...
; Feb 09, 2015. 
   print,'  '+f_alf2+' used other dx and dy'
   rmexfile,repstr(f_alf2,'.alf','_mch.mch')
   readcol,'master.mch',imgnames,primesym,xshfts,yshfts,format='a,a,f,f',/silent
   imgnames = rmfgspc(repstr(imgnames,"'",''))

   f_alf3 = imgnames[0]
   f_fit_1 = repstr(f_alf3,'.alf','.fits')
   f_fit_2 = repstr(f_alf2,'.alf','.fits')
   readcol,repstr(f_alf3,'.alf','_mst.mch'),fooname3,fooname32,xshft3,yshft3,format='a,a,f,f',/silent
; delta xy between master and ref image
   xshft3 = xshft3[1]
   yshft3 = yshft3[1]
; delta xy between ref image and this image
   imatch2img,f_fit_1,f_fit_2,'foo_mch.mch'
   rmexfile,'foo_mst.mch'
   spawn,'echo foo_mch.mch > intdo.do'
   spawn,'echo 2,1,2 >> intdo.do'
   spawn,'echo 0.25 >> intdo.do'
   spawn,'echo 2 >> intdo.do'
   spawn,'echo 5 >> intdo.do'
   for ifooloop=1,5 do spawn,'echo 3 >> intdo.do'
   for ifooloop=1,5 do spawn,'echo 2 >> intdo.do'
   spawn,'echo 0 >> intdo.do'
   for ifooloop=1,4 do spawn,'echo n >> intdo.do'
   spawn,'echo y >> intdo.do'
   spawn,'echo foo_mst.mch >> intdo.do'
   spawn,'echo e >> intdo.do'
   spawn,'daomaster < intdo.do > intdo.out'
   rmexfile,'foo_mch.mch'
   rmexfile,'intdo.do'
   rmexfile,'intdo.out'
   readcol,'foo_mst.mch',fooname,fooname2,xshft4,yshft4,format='a,a,f,f',/silent
   xshft4 = xshft4[1]
   yshft4 = yshft4[1]
   xshft = xshft3 + xshft4
   yshft = yshft3 + yshft4
   x2 = alf.x - xshft
   y2 = alf.y - yshft
endelse
f_nco = repstr(f_alf2,'.alf','.nco')
spawn,'head -2 '+f_nco+' > '+repstr(f_alf2,'.alf','.fco')
openw,l_fco,repstr(f_alf2,'.alf','.fco'),/get_lun,/append
for i_fco=0,nl_alf do begin
   if (x2[i_fco] gt 5 and x2[i_fco] lt 507 and y2[i_fco] gt 5 and y2[i_fco] lt 507) then begin
      printf,l_fco,alf[i_fco].id,x2[i_fco],y2[i_fco],alf[i_fco].m,format='(I8,3F9.3)'
   endif
endfor
cf,l_fco
end
