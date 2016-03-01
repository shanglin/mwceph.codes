function cuti4,num
  if (num le 9) then begin
     return,'000'+strtrim(num,1)
  endif else begin
     if (num le 99) then begin
        return,'00'+strtrim(num,1)
     endif else begin
        if (num le 999) then begin
           return,'0'+strtrim(num,1)
        endif else begin
           if (num le 9999) then begin
              return,strtrim(num,1)
           endif else begin
              return,'Error! Too many bins, please keep less than 1000 bins'
              return,'Program stopped'
              stop
           endelse
        endelse
     endelse
  endelse
end
