f.old = '~/Work/mega/mwceph/draft/v3.1/tables/obslist.tex'
f.new = '~/Work/mega/mwceph/draft/v4.1/tables/obslist.tex'

old = read.table(f.old, colClasses='character')
V1 = paste(old[,1],old[,2], sep='~')
new = cbind(V1, old[,3:8])

fmt = '%-12s%3s%9s%3s%10s%3s%-5s'
new = do.call('sprintf', c(new, fmt))
write(new, f.new)
