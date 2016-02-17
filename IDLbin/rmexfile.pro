pro rmexfile,exfile
 if file_test(exfile) then $
   spawn,'rm -f ' + exfile
end
