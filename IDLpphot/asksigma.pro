function asksigma,presigma
if n_elements(presigma) eq 0 then presigma = 3.
asksigma:
   sigma = ''
   read,sigma,prompt=' Enter a sigma for clipping: [default = '+rmfgspc(presigma)+'] '
   if sigma eq '' then sigma = presigma
   if max(byte(sigma)) ge 65 then goto,asksigma
   sigma = float(sigma)
   if sigma eq -1 then goto,ret
   if sigma lt 1.39 then goto,asksigma
   ret:
   return,sigma
end
