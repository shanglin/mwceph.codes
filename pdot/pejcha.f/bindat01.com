        parameter (NCMAX=36)

c dependence vectors
c filter names
        character*10 fname(NCMAX)
c filter wavelengths and widths
c        real*8 flam(NCMAX),fdlam(NCMAX)
        common /filters1/fname
c        common /filters2/flam,fdlam
c Temperature derivative
        real*8 b0(NCMAX)
        common /model1/b0

c temperature and radius templates
c   ctt=cosine part of temperature, stt=sine part of temperature
c   crt=cosine part of radius     , srt=sine part of radius
        real*8 ctt(20,20),stt(20,20)
        real*8 crt(20,20),srt(20,20)
c log(P/10) for template i = tlp(i) 
        real*8 tlp(20)
        common /template1/ctt,stt,crt,srt,tlp


c useful constants: ln(10) and pi
        real*8 ln10,pi,pexp

c ln(10.0), pi, velocity projection factor,
        common /constants/ln10,pi,pexp

c set the template being used for the current period
        integer itemp0,itemp1
        real tw(20)
        common /weights/tw,itemp0,itemp1

c individual cepheids being fit
c   ncol  = total number of colors being fit
c   ncos  = Fourier order of the periods
c   ntempl= Order of polynomial series in period for template
        integer*2 ncol,ncos,ntempl
        common /model4/ncol,ncos,ntempl

           



