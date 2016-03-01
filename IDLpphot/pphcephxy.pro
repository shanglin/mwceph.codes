pro pphcephxy

!quiet=1

rad = 13
thick = 3
fits = file_search('n????n????.fits',count=nfits)
for i_fit=0,nfits-1 do begin
   f_fit = fits[i_fit]
   mess = f_fit
   showprogress,i_fit+1,nfits,mess
   print,''
   fit_a = readfits(f_fit,head,/silent)

   f_smt = '../ophn/'+repstr(f_fit,'.fits','_smt.fits')
   if ~file_test(f_smt) then begin
;---------------

   f_coo = repstr(f_fit,'.fits','.coo')
   str_coo = {id:0l,x:0.,y:0.,flux:0.d,sharp:0.,round:0.}
   fmt_coo = '(I8,2F10.3,F15.3,2F9.3)'
   rdfile,f_coo,str_coo,fmt_coo,2,coo,nl_coo
   

   window,0,xs=512,ys=512
   zscale,fit_a,img,1;,10,50
   img = bytscl(alog10(img>1))
   tv,img
   
   ceph_x = -1
   ceph_y = -1
   for i=0,min([nl_coo,10]) do begin
      xc = coo[i].x
      yc = coo[i].y
      img2 = img
      for x=max([0,xc-2*rad]),min([xc+2*rad,510]) do for y=max([0,yc-2*rad]),min([yc+2*rad,510]) do $
         if (x-xc)^2 + (y-yc)^2 ge rad^2 and (x-xc)^2 + (y-yc)^2 le (rad+thick)^2 then img2[x,y]=0
      img3 = img2
      for x=0,80 do for y=0,100 do if (x-50)^2+(y-50)^2 ge 37^2 and (x-50)^2+(y-50)^2 le 50^2 then img3[x,y]=255
      tv,img3
      
      isceph:
      satans = ''
      print,' '+f_fit+' Is this the Cepheid? (y/n): '
      satans = get_kbrd()
      if satans eq 'b' then begin
         i_fit = max([-1,i_fit-2])
         goto,next
      endif
      if satans eq 'f' then begin
         goto,next
      endif      
      if ~(satans eq 'n' or satans eq 'N' or satans eq 'y' or satans eq 'Y') then goto,isceph
      if satans eq 'y' or satans eq 'Y' then begin
         ceph_x = xc
         ceph_y = yc
         break
      endif
   endfor
   if ceph_x eq -1 or ceph_y eq -1 then begin
      ceph_x = ''
      ceph_y = ''
      print,' '+f_fit+' Cepheid not found? Enter them by hand!'
      notright:
      read,ceph_x,prompt=' X = '
      read,ceph_y,prompt=' Y = '
      if float(ceph_x) lt 30 or float(ceph_x) gt 490 then goto,notright
      if float(ceph_y) lt 30 or float(ceph_y) gt 490 then goto,notright
      satans=''

      xc = ceph_x
      yc = ceph_y
      img2 = img
      for x=max([0,xc-2*rad]),min([xc+2*rad,510]) do for y=max([0,yc-2*rad]),min([yc+2*rad,510]) do $
         if (x-xc)^2 + (y-yc)^2 ge rad^2 and (x-xc)^2 + (y-yc)^2 le (rad+thick)^2 then img2[x,y]=0
      img3 = img2
      for x=0,80 do for y=0,100 do if (x-50)^2+(y-50)^2 ge 37^2 and (x-50)^2+(y-50)^2 le 50^2 then img3[x,y]=255
      tv,img3

      read,satans,prompt=' X='+ceph_x+', Y='+ceph_y+' Is this right? ',format='(a)'
      if ~(satans eq 'y' or satans eq 'Y') then goto,notright
      ceph_x = float(ceph_x)
      ceph_y = float(ceph_y)
   endif
   
isclean:
   pollute = 'N'
   img4 = img2
   for x=0,100 do for y=80,100 do img4(x,y)=255
   for x=40,60 do for y=0,80 do img4(x,y)=255
   tv,img4
   print,' '+f_fit+' Is this Cepheid contaminated? (y/n): '
   pollute = get_kbrd()
   if pollute eq 'b' then begin
      i_fit = max([-1,i_fit-2])
      goto,next
   endif
   if pollute eq 'f' then begin
      goto,next
   endif 
   pollute = strupcase(pollute)
;-----------------
endif else begin
   shead = headfits(f_smt)
   ceph_x = sxpar(shead,'CEPHX')
   ceph_y = sxpar(shead,'CEPHY')
   pollute = sxpar(shead,'POLLUT')

   window,0,xs=512,ys=512
   zscale,fit_a,img,1;,10,50
   img = bytscl(alog10(img>1))
   img2 = img
   xc = ceph_x
   yc = ceph_y
   for x=max([0,xc-2*rad]),min([xc+2*rad,510]) do for y=max([0,yc-2*rad]),min([yc+2*rad,510]) do $
      if (x-xc)^2 + (y-yc)^2 ge rad^2 and (x-xc)^2 + (y-yc)^2 le (rad+thick)^2 then img2[x,y]=0
   img3 = img2
   for x=0,80 do for y=0,100 do if (x-50)^2+(y-50)^2 ge 37^2 and (x-50)^2+(y-50)^2 le 50^2 then img3[x,y]=255
   tv,img3
   wait,0.5
endelse

   sxaddpar,head,'CEPHX',ceph_x
   sxaddpar,head,'CEPHY',ceph_y
   sxaddpar,head,'POLLUT',pollute

   f_smt = repstr(f_fit,'.fits','_smt.fits')
   modfits,f_smt,0,head
   next:
endfor
wdelete,0
end

