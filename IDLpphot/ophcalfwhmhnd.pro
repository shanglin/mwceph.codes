pro ophcalfwhmhnd,f_fit

!quiet=1  

fit_a = readfits(f_fit,head,/silent)
x = float(sxpar(head,'CEPHX',count=cnt))
if cnt ne 1 then message,'CEPHX not found in '+f_fit
y = float(sxpar(head,'CEPHY',count=cnt))
if cnt ne 1 then message,'CEPHY not found in '+f_fit

pol = sxpar(head,'POLLUT',count=cnt)
if cnt ne 1 then message,'POLLUT not found in '+f_fit

image = fit_a
starfit,image,x,y,xc,yc,fwhm

if abs(x-xc) lt 0.5 and abs(y-yc) lt 0.5 and fwhm lt 12 then begin
   newx = xc
   newy = yc
endif else begin
   newx = x
   newy = y
   fwhm = 4.
endelse

sxaddpar,head,'CEPHX',newx
sxaddpar,head,'CEPHY',newy
sxaddpar,head,'FWHM',fwhm

modfits,f_fit,0,head


end
