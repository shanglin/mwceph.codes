pro pphmontage2

f_mch = 'master.mch'
f_in1 = 'montage_input1.in'
f_out1 = 'montage_output1.out'

openw,lun,f_in1,/get_lun
printf,lun,f_mch
printf,lun,''
printf,lun,'e'
cf,lun

spawn,'rm -f master.fits'
spawn,'montage2 < '+f_in1+' > '+f_out1

cmd = "awk '$9=="+'"<<"'+"' montage_output1.out | head -3 | tail -1"
spawn,cmd,line

xrange = strmid(line,9,20)
yrange = strmid(line,25,20)

f_in2 = 'montage_input2.in'
f_out2 = 'montage_output2.out'

openw,lun,f_in2,/get_lun
printf,lun,f_mch
printf,lun,''
printf,lun,'3,0.5'
printf,lun,xrange
printf,lun,yrange
printf,lun,'1'
printf,lun,'y'
printf,lun,''
cf,lun

spawn,'montage2 < '+f_in2+' > '+f_out2

end
