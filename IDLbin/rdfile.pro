pro rdfile,f_file2read,str_file2read,fmt_file2read,n_foo,file2read,nl_file2read,small_data=small_data
;if keyword_set(small_data) then max_lines_file2read = 5e3 else max_lines_file2read = 5e6
max_lines_file2read = file_lines(f_file2read) + 5
file2read = replicate(str_file2read,max_lines_file2read)
nl_file2read = 0l
foo = ''
openr,l_file2read,f_file2read,/get_lun
if (n_elements(n_foo) eq 0) then n_foo = 0
if (n_foo lt 0) then n_foo = 0
if (n_foo gt 0) then for i_file2read = 1, n_foo do readf,l_file2read,foo
while not eof(l_file2read) do begin
   readf,l_file2read,str_file2read,format = fmt_file2read
   file2read(nl_file2read) = str_file2read
   nl_file2read++
endwhile
close,l_file2read
free_lun,l_file2read
nl_file2read--
file2read = file2read(0:nl_file2read)
end

;+
; Edit history:
; Corrected max_lines to make it more convenient and efficient. July 08,2014 
;-
