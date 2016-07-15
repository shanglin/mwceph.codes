f.old = '~/Work/mega/mwceph/draft/v3.1/tables/obslist.tex'
f.new = '~/Work/mega/mwceph/draft/v4.1/tables/obslist_m.txt'

old = read.table(f.old, colClasses='character', stringsAsFactors=F)
V1 = paste(old[,1],old[,2], sep=' ')
new = cbind(V1, old[,3:8])

new = new[,c(1,3,5,7)]
new[,4] = gsub('\\\\','',new[,4])
new[,1] = gsub('[$]','',new[,1])
new[,1] = gsub('\\\\','',new[,1])
new[,1] = gsub('beta','BET',new[,1])




fmt = '%8s%9s%10s%4s'
new = do.call('sprintf', c(new, fmt))
f.hed = '~/Work/mega/mwceph/draft/v4.1/tables/obslist_m_h.dat'
cmd = paste0('cat ',f.hed,' > ',f.new)
system(cmd)
write(new, f.new, append=T)

