import numpy as np
import sys,os,glob

outdir = '/Users/wenlong/Work/mega/mwceph/pphot/period_all/model_per/inputs_it1/'
cmd = 'rm -f '+outdir+'*.ipt'
os.system(cmd)

f_lst = outdir+'slc.lst'
cmd = 'ls /Users/wenlong/Work/mega/mwceph/pphot/period_all/data/?????/*.slc > '+f_lst
os.system(cmd)
f_per = '/Users/wenlong/Work/mega/mwceph/pphot/period_all/gcvs_per/gcvs_per.dat'
per = np.loadtxt(f_per,dtype=object, skiprows=1)
perobjs = ['' for i in range(len(per))]
perpers = ['' for i in range(len(per))]
for i in range(len(per)):
    line = per[i]
    perobjs[i] = line[0]
    perpers[i] = line[1]
perobjs = np.asarray(perobjs)
perpers = np.asarray(perpers)

lst = np.loadtxt(f_lst,dtype=object)
for f_slc in lst:
    dat = np.loadtxt(f_slc,dtype=object,skiprows=1)
    obj = f_slc[54:59]
    f_ipt = outdir + obj + '.ipt'
    h_ipt = open(f_ipt,'w')
    ndat = len(dat)
    if obj != 'w-sgr':
        lobj = obj[0:2]+'_'+obj[2:5]
    else:
        lobj = 'w_sgr'
    if obj == 's-nor':
        lobj = 's_nor'
    period = perpers[perobjs == lobj]
    if float(period[0]) >= 0:
        reftime = 0
        tsline = str(ndat) + '   '+period[0]+'   '+str(reftime)+'\n'
        h_ipt.write(tsline)
        for i in range(ndat):
            line = dat[i]
            filter_id = line[3]
            if filter_id == '23' or filter_id == '24' or filter_id == '25' or filter_id == '26' or filter_id == '27':
                line[1] = str(float(line[1]) * (-2.5))
            h_ipt.write(line[0]+'  '+line[1]+'   '+line[2]+'   '+line[3]+'\n')
        h_ipt.close()
        
