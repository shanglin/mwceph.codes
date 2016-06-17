f.par = '~/Work/mega/mwceph/HST/colorcorr/crt_lcs/updated_bestfit_pars.dat'
par = read.table(f.par, stringsAsFactors=F)

dir = '~/Work/mega/mwceph/HST/offsets/'
cdir = '~/Work/mega/mwceph/HST/colorcorr/'
figdir = '~/Work/mega/mwceph/HST/offsets/figs/'
lcdir = paste0(cdir,'crt_lcs/')
f.hst = paste0(dir,'hst4.dat')

