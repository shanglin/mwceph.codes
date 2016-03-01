# Load the psc file and filter out bad observations
import numpy as np

f_psc = './psc.tbl'
psc = np.loadtxt(f_psc,skiprows=103,dtype=object)
ph_qual = psc[:,20]
rd_flg = psc[:,21]
bl_flg = psc[:,22]
cc_flg = psc[:,23]

ra = psc[:,0]
dec = psc[:,1]
uid = psc[:,7]

h = psc[:,12]
eh = psc[:,14]

h_csv = open('psc.csv','w')
h_csv.write('UID,RA,DEC,H,E\n')
for i in range(ra.size):
    rd_god = rd_flg[i][1:2] == '1' or rd_flg[i][1:2] == '2' or rd_flg[i][1:2] == '4'
    ph_god = ph_qual[i][1:2] == 'A' or ph_qual[i][1:2] == 'B'
    cc_god = cc_flg[i][1:2] == '0'
    bl_god = bl_flg[i][1:2] == '1' or bl_flg[i][1:2] == '2'
    good = rd_god and ph_god and cc_god and bl_god
    if good:
        h_csv.write(uid[i]+','+ra[i]+','+dec[i]+','+h[i]+','+eh[i]+'\n')
h_csv.close()

# load the clean table and project to a fake XY plane
import matplotlib.pyplot as plt
f_csv = './psc.csv'
csv = np.loadtxt(f_csv,skiprows=1,dtype=object,delimiter=',')
ra = csv[:,1]
dec = csv[:,2]
h = csv[:,3]
eh = csv[:,4]
ra = ra.astype(np.float)
dec = dec.astype(np.float)
h = h.astype(np.float)
eh = eh.astype(np.float)

# Update these two or three parameters
ra0 = 96.30417
dec0 = 7.08571
xylim = 230

# a for ra in radius, d for dec in radius
a = ra*np.pi/180
d = dec*np.pi/180
a0 = ra0*np.pi/180
d0 = dec0*np.pi/180

x = (a-a0)*np.cos(d)
y = d-d0
x = x*500000
y = y*500000
p = plt.scatter(y,x,s=(100./h)**3/10.,marker='o')
plt.xlim(-1*xylim,xylim)
plt.ylim(-1*xylim,xylim)
for k in range(len(x)):
    plt.text(y[k]+10,x[k],str(k))
plt.show()

# generate a fake .ALF file
h_alf = open('psc.alf','w')
h_alf.write(' NL    NX    NY  LOWBAD HIGHBAD  THRESH     AP1  PH/ADU  RNOISE    FRAD\n  1   512   512  -146.1 150000.    3.00    7.00   7.000   1.570    2.47\n\n')
for i in range(x.size):
    if x[i] > -1*xylim and x[i] < xylim and y[i] > -1*xylim and y[i] < xylim:
        h_alf.write('%7i%9.3f%9.3f%9.3f%9.4f%9.2f%9.0f%9.2f%9.3f\n' % (i,x[i],y[i],h[i],eh[i],0,0,0,0))
h_alf.close()
                    
