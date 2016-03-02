pro ophmkhulc

dats = file_search('./*_hlc.dat',count=ndats)

 fmt_dat = '(A21,F12.5,F9.5,F9.3,F9.3,I5,F6.2,F8.2,F8.2,F9.3,F9.3,F9.3,F9.3,I4,F10.4,4f12.4,I4)'
  str_dat = {img:'',mjd:0.d,ph:0.d,dm:0.,stdd:0.,dof:0,sigma:0.,blim:0.,flim:0.,cx:0.,cy:0.,cm:0.,ce:0.,dit:0,p:0.,mndm:0.,errdm:0.,mncm:0.,mnce:0.,flag:0}

  str_dmt = {img:'',mjd:0.d,ph:0.d,dm:0.,stdd:0.,dof:0,sigma:0.,blim:0.,flim:0.,cx:0.,cy:0.,cm:0.,ce:0.,dit:0,p:0.}
  fmt_dmt = '(A21,F12.5,F9.5,F9.3,F9.3,I5,F6.2,F8.2,F8.2,F9.3,F9.3,F9.3,F9.3,I4,F12.6)'
  
  for i_dat=0,ndats-1 do begin
     f_dat = dats(i_dat)
     f_dmt = './dm_table.dmt'
     rdfile,f_dat,str_dat,fmt_dat,1,dat,nl_dat
     rdfile,f_dmt,str_dmt,fmt_dmt,1,dmt,nl_dmt
     if nl_dat ne nl_dmt then begin
        print,f_dat
        print,'  >>>>>>>>>>>>>>>>>>>>'
        print,f_dat
        print,'  >>>>>>>>>>>>>>>>>>>>'
        print,'  Add missing lines to <obj>_hlc.dat and cp it as <obj>.ulc'
     endif else begin
        f_ulc = repstr(f_dat,'_hlc.dat','.ulc')
        spawn,'cp '+f_dat+' '+f_ulc
     endelse
     
  endfor
end
