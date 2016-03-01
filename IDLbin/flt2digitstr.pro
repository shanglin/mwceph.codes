function flt2digitstr,fltnum_in_o,no_warning=no_warning

;+
; history
;  July 10: Fixed bug: negative numbers returen zero
;-


fltnum_in = double(fltnum_in_o)
if fltnum_in ge 0 then begin
  if fltnum_in gt 1 then begin
     str_num_in = strcompress(string(round(fltnum_in*100.d)),/remove_all)
     return,strmid(str_num_in,0,strlen(str_num_in)-2)+'.'+strmid(str_num_in,strlen(str_num_in)-2,2)
  endif else begin
     if fltnum_in ge 0.1 then begin
        str_num_in = strcompress(string(round(fltnum_in*100.d)),/remove_all)
        return,'0.'+strmid(str_num_in,0,2)
     endif else begin
        if fltnum_in ge 0.01 then begin
           str_num_in = strcompress(string(round(fltnum_in*100.d)),/remove_all)
           return,'0.0'+strmid(str_num_in,0,1)
        endif else begin
           if ~keyword_set(no_warning) then print,' Warning: rounded to 0.00'
           return,'0.00'
        endelse
     endelse
  endelse
endif else begin
   new_fltnum_in = fltnum_in*(-1.0)
     if new_fltnum_in gt 1 then begin
     str_num_in = strcompress(string(round(new_fltnum_in*100.d)),/remove_all)
     return,'-'+strmid(str_num_in,0,strlen(str_num_in)-2)+'.'+strmid(str_num_in,strlen(str_num_in)-2,2)
  endif else begin
     if new_fltnum_in ge 0.1 then begin
        str_num_in = strcompress(string(round(new_fltnum_in*100.d)),/remove_all)
        return,'-0.'+strmid(str_num_in,0,2)
     endif else begin
        if new_fltnum_in ge 0.01 then begin
           str_num_in = strcompress(string(round(new_fltnum_in*100.d)),/remove_all)
           return,'-0.0'+strmid(str_num_in,0,1)
        endif else begin
           if ~keyword_set(no_warning) then print,' Warning: rounded to 0.00'
           return,'0.00'
        endelse
     endelse
  endelse
endelse
end
