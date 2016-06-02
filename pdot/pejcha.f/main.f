
	program main
        implicit real*8 (a-h,o-z)


c plotting variables
        real*8 tphi(360)
        real*8 lpuse,betause

c the radius, temperature and velocity templates, two versions of a template magnitude
        real*8 rmod,tmod,vmod,mmod1,mmod2
c this is needed to compute velocities
        real*8 vcon

	integer*2 fltno


c READ IN THE TEMPLATES AND VECTORS DESCRIBING THE CEPHEIDS
c vcon is a constant needed for velocity calculations
        call cepheidinit(vcon)

c read in period and filter number 
	print*,'enter period in days'
	read*,puse
	print*,'enter filter number'
	read*,fltno
	lpuse = log10(puse/10.0)

c if filter number is invalid, ask user for a beta 
c	print*,'fltno is', fltno
        betause = cepheidgetbeta(fltno)
        if (betause.lt.0.0) then
          print*,'you have asked for an invalid filter ',fltno
          print*,'   enter the beta value you wish to use '
          read*,betause
          endif

c SET THE CEPHEID TEMPLATE FOR THE CURRENT PERIOD
        call setcepheidtemplate(lpuse)

c this is just a grid of phases in RADIANS
        print*,'setting phase grid '
        pi   = 4.0*atan(1.0)
        nplt = 360
        dphi = 2.0*pi/float(nplt)
        do i=1,nplt
          tphi(i) = dphi*float(i-1)
          enddo


      do i=1,nplt
c loop over the phase points, getting the template at each phase -- REMEMBER PHASE IS IN RADIANS
c rmod = radius template, tmod = temperature template, vmod = velocity template, mmod = magnitude template for betuse
c note, if you want a different filter,  mag = -5*rmod + -2.5*beta*tmod, so here, mmod2 = mmod1
c    rmod = delta rho(phi)
c    tmod = delta tau(phi)
c    mmod1= -5*rmod - 2.5*betuse*tmod = light curve with unit amplitude A^2
c    vmod = drmod/dphi 
        call getcepheidtemplate(tphi(i),betuse,rmod,tmod,vmod,mmod1)
        mmod2 = -5.0*rmod - 2.5*betause*tmod
c to get an actual velocity in km/s, you need an amplitude (A^2) and a radius (rhobar) 
c          v1    = vcon*aramp*10.0**(rbar+aramp*aramp*rt(1))
c          vmod  =  v1*aramp*dva(1)
c        a2    = 1.0
c        rhobar= comes from either fit or the mean period--radius relation (see our paper for details)
c        vkms  = XX

        write(13,'(4(1x,f13.6))')tphi(i),rmod,tmod,mmod2
        enddo


        end
