dir = '~/Work/m33/16summer/mwupdt/periods_all/period_may26_2016/inputs_it3/'
fs = list.files(dir, pattern='.*.ipt$')
n = length(fs)
span = nobs = rep(NA, n)

for (i in 1:n) {
    f = paste0(dir, fs[i])
    d = read.table(f, skip=1)
    nobs[i] = nrow(d)
    span[i] = max(d[,1]) - min(d[,1])
}

par(mfrow=c(1,2))
hist(nobs)
hist(span)
mn = mean(nobs)
ms = mean(span)
print(mn)
print(ms/365)
