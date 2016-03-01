function flt3digitstr,fltnum_in,no_warning=no_warning

fltnum_in = double(fltnum_in)
str_num_in = strcompress(string(fltnum_in),/remove_all)
dotpos = strpos(str_num_in, '.')
foodig = float(strmid(str_num_in,dotpos+4,1))
if fltnum_in gt 0 and foodig lt 5 then return_str = strmid(str_num_in,0,dotpos+4)
if fltnum_in gt 0 and foodig ge 5 then return_str = strmid(strcompress(string(fltnum_in+0.001),/remove_all),0,dotpos+4)
if fltnum_in lt 0 and foodig lt 5 then return_str = strmid(str_num_in,0,dotpos+4)
if fltnum_in lt 0 and foodig ge 5 then return_str = strmid(strcompress(string(fltnum_in-0.001),/remove_all),0,dotpos+4)
if abs(fltnum_in) lt 0.0005 then return_str = '0.000'
if return_str eq '0.000' and ~keyword_set(no_warning) then print,'Warning: rounded to 0.000'
if abs(fltnum_in) gt 999.9999 and ~keyword_set(no_warning) then $
	print,'Warning: Out of IDL8.2 data type ability, result might not accurate'
return,return_str

end