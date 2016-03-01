pro sigmaclip1once,array,index_kept,mean_array,stdd,n,index_deleted,orig_e,NOWEIGHT = noweight, silent = silent,ignore_error=ignore_error

; NOT FOR ERROR PROPAGATION!
; Please note that the variable *stdd* is the standard deviation of
; the output array, not an estimate of the variance of the output
; array which based on input errors. If you are interested in error
; propagation and you trust your input uncertainties, you might want
; to use this formula as an estimate of the variance:
;     sigma^2 = 1.0/(sum(1.0/sigma_i^2))
; where sigma_i is the uncertainty of each datum point.

if (n_elements(n) eq 0) then n = 3. else n = float(n)
if (n_elements(orig_e) eq 0) then error = 0 * array + 1 else error = orig_e
array = double(array)

dof = n_elements(array)
if (dof eq 1) then begin
   print,'% Array must contain at least two elements'
   stop
endif

index_kept = []
index_deleted = []

str_arr = {id:0l,dat:0.d,err:0.d}
arr = replicate(str_arr,dof)
for ifoobar=0l,dof-1 do begin
   arr(ifoobar).id = ifoobar
   arr(ifoobar).dat = array(ifoobar)
   arr(ifoobar).err = error(ifoobar)
endfor

new_arr = arr
flag_loop = 1

while flag_loop do begin
   dof = n_elements(new_arr.dat)
   if dof le 2 then begin
      if ~keyword_set(ignore_error) then begin
         message,'No objects left during sigma clipping'
      endif else begin
         index_kept = arr.id
         index_deleted = []
         mean_array = -99.999
         stdd = 0
         break
         goto,return_orig
      endelse
   endif
   if keyword_set( NOWEIGHT ) then begin
      mean_array = mean(new_arr.dat)
      stdd = stddev(new_arr.dat)
   endif else begin
      mean_array = total( new_arr.dat / new_arr.err^2) / total(1 / new_arr.err^2)
      stdd = sqrt(total((new_arr.dat - mean_array)^2) / (dof - 1))
   endelse
   hereresidual = abs(new_arr.dat - mean_array)
   if max(hereresidual) gt n*stdd then begin
      heremaxind = where(hereresidual eq max(hereresidual),cnt,complement=hererestind)
      new_arr = new_arr(hererestind)
      flag_loop = 1
   endif else begin
      flag_loop = 0
   endelse
endwhile
index_kept = new_arr.id
for ifoobar=0l,n_elements(array)-1 do begin
   fooind = where(ifoobar eq index_kept,cnt)
   if cnt eq 0 then begin
      if n_elements(index_deleted) eq 0 then $
         index_deleted = ifoobar else $
            index_deleted = [index_deleted,ifoobar]
   endif
endfor
dof = float(dof)
if dof/n_elements(array) lt 0.63212 then $
   print,'>>>>  Caution: '+flt2digitstr((1-dof/n_elements(array))*100.)+$
         '% objects were rejected as outliers'
if n_elements(index_deleted) eq 0 then index_deleted = []
return_orig:

end
