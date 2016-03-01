pro zscale,imin,imout,con,z1,z2

if (n_elements(z1) eq 0) then begin
 z1=0
 z2=0
endif else begin
 goto,scl 
endelse

pix=fltarr(4096)
np=0l
si=size(imin)
sx=si(1)
sy=si(2)
fx=si(1)/64
fy=si(2)/64

rj=where(imin eq -32767,nrj,complement=kp)
if (nrj ge 1) then begin
 iminc=imin(kp)
 sky,iminc,skmod,sksig,/silent
endif else begin
 sky,imin,skmod,sksig,/silent
endelse

for i=0,63 do begin
    for j=0,63 do begin
        pix(np)=imin(i*fx,j*fy)
        np=np+1
    endfor
endfor
k=where(pix ge (skmod-5.0*sksig) and pix lt (skmod+10.0*sksig),ct)
if (ct eq 0) then begin
 print,'No valid pixels!'
 stop
endif
pix=pix(k)
srt=sort(pix)
pixs=pix(srt)
npt=ct
for it=0,4 do begin
    res=linfit(indgen(npt),pixs,yfit=pixy)
    rsd=abs(pixy-pixs)
    keep=where(rsd lt 3.0*stdev(rsd),nk)
    br=keep(0)
    tr=keep(nk-1)
;    zap=where(rsd gt 3.0*stdev(rsd))
;    npl=where(zap le (npt/2),sl)
;    npu=where(zap gt (npt/2),su)
;    br=0
;    tr=npt
;    if (sl gt 0) then $
;      br=zap(npl(sl-1))
;    if (su gt 0) then $
;      tr=zap(npu(0))
;    if (tr eq n_elements(pixs)) then tr--
    pixs=pixs(br:tr)
    npt=n_elements(pixs)
endfor

mdpt=pixs(npt/2)
;z1=max([mdpt-(res(1)*2.*con*float(npt)),min(pixs)])
;z2=min([mdpt+(res(1)*2.*con*float(npt)),max(pixs)])
ag:z1=mdpt-(res(1)*2.*con*float(npt))
z2=mdpt+(res(1)*2.*con*float(npt))
if (abs(z2-z1) lt 10) then begin
 con=con*2
 goto,ag
endif
scl:imout=!d.table_size*(z1-imin)/(z1-z2)
k=where(imout lt 0,ct)
if (ct ge 1) then $
 imout(k)=0
k=where(imout gt !d.table_size-1,ct)
if (ct ge 1) then $
 imout(k)=!d.table_size
imout=!d.table_size-imout
kp=where(imin eq -32767,nz)
if (nz gt 0) then $
 imout(kp)=!d.table_size-1

return
end
