pro showprogress,a,b,string
  if n_elements(string) eq 0 then string1 = '  >>> ' else string1 = '  >>> ['+string+'] ~ '
  statusline,string1+flt3digitstr(100.*a/b,/no_warning)+' %'
end
