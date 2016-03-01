;+
; NAME:
;  findgap.pro
;
;
; PURPOSE:
;  for an array, there might be some gaps such as observation interval.
;  this function would return some values in those gaps to help group them
;
; CATEGORY:
;  math
;
;
; CALLING SEQUENCE:
;  gaps = findgap([1.1,1.3,1.2,4.5,4.2,4.3,10.2,10.1,10.2],2)
;
;
; INPUTS:
;  array variable and scalar
;
;
; OPTIONAL INPUTS:
;  no.
;
;
; KEYWORD PARAMETERS:
;  no.
;
;
; OUTPUTS:
;  if there are n groups, n-1 gap values will be in the output
;
;
; OPTIONAL OUTPUTS:
;  no
;
;
; COMMON BLOCKS:
;  no
;
;
; SIDE EFFECTS:
;  no
;
;
; RESTRICTIONS:
;  no
;
;
; PROCEDURE:
;  no
;
;
; EXAMPLE:
;  gaps = findgap([1.1,1.3,1.2,4.5,4.2,4.3,10.2,10.1,10.2],2)
;
;
; MODIFICATION HISTORY:
;  wenlong 2014
;-
function findgap,arr,gapwidth

narr = arr(sort(arr))
bcstart = narr[0]
footcnt = 0
ngaps = []
while bcstart lt max(narr) do begin
   bcend = bcstart + gapwidth
   fooind = where(narr ge bcstart and narr le bcend, foocnt)
   if foocnt gt 0 then footcnt++
   if foocnt eq 0 and footcnt gt 0 then begin
      if n_elements(ngaps) eq 0 then ngaps=[0.5*(bcstart+bcend)] else ngaps = [ngaps,0.5*(bcstart+bcend)]
      footcnt = 0
   endif
   bcstart+=float(gapwidth)/10.
endwhile
if n_elements(ngaps) eq 0 then begin
   print,'No gaps found for this array--Minimum of array returned'
   ngaps = [min(narr)]
endif
return,ngaps
end
