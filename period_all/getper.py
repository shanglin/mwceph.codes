import urllib,urllib2,cookielib,socket,HTMLParser
import numpy as np
import time

f_dat = '/Users/wenlong/Work/mega/mwceph/pphot/period_all/obj2.lst'
urlbase = 'http://www.sai.msu.su/gcvs/cgi-bin/search.cgi?search='
dat = np.loadtxt(f_dat, dtype = object)
f_new = '/Users/wenlong/Work/mega/mwceph/pphot/period_all/gcvs_per/gcvs_per.dat'
h_new = open(f_new,'w')
h_new.write('  obj    period\n')
for i in range(0,len(dat)):
    period = -1
    objline = dat[i]
    obj = objline
    obj = obj.replace('_','+').lower()
    if obj == 'beta+dor':
        obj = 'bet+dor'
    if obj == 'vj+ara':
        obj = 'v340+ara'
    url = urlbase + obj
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookielib.CookieJar()))
    response = opener.open(url)
    text = response.read().split('\n')
    line = text[4]
    ipos = 0
    ipipe = 0
    for ipos in range(0,len(line)):
        if line[ipos] == '|':
            ipipe = ipipe + 1
            if ipipe == 10:
                period = float(line[(ipos+1):(ipos+20)])
    print objline,period
    h_new.write('  '+objline+'  %s\n' %period)
h_new.close()
