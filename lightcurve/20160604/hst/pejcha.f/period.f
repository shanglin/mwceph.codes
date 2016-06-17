

c this program will read a file containing photometry and velocity data for a 
c Cepheid and fit it all simultaneously to determine mean magnitudes and mean velocities
c while optimizing the period and phase to fit all the data if desired 
c uncertainties in the period and phase are not included in the uncertainties in the magnitudes etc
c that would best be done by using the getchi routine here as part of an MCMC chain in period and
c phase reference point to determine their contribution to the uncertainties.

	program main
        implicit real*8 (a-h,o-z)


ccccccccccccccccccccccccccccc
c  some parameters to control the fit
c  July 13, 2015
c  Period range in days to fit
	real*8 wl_Prange ! This will test from P0 - PR/2 to P0 + PR/2
	real*8 wl_Rfactor ! This will increase/decrease the resolution by a factor of RF
	character*50 wl_outfile ! This file <obj>_chi_sqr.dat will record the chi square and number of free parameters
	character*50 wl_object_name
ccccccccccccccccccccccccccccc


c this is needed to compute velocities
        real*8 vcon
 
c the data and filter numbers and beta values for the light curve
c jd    = date
c mag   = magnitude
c emag  = error in magnitude
c beta  = template beta value for this filter
c phase = phase of data point
c fid   = template filter id# for data point
c mmod  = model magnitude for this data point 
c npt   = number of photometric data points
        real*8 jd(5000),mag(5000),emag(5000),beta(5000),phase(5000),mmod(5000)
        integer fid(5000)
        integer npt

c these are to do accounting for what filters are being used
c iused(i) = 1 if filter i is being used
c id(i)    = filter id of numerical variable i
c ivar(i)  = numerical variable for filter i
        integer iused(50),id(50),ivar(50)

c input period, phase, log(period/10)
        real*8 per0,t0,lpuse

c vectors and matrix for the linear solution
c when done
c b(j)    = mean magnitude for filter id(j) except for last entry j=ndim
c b(ndim) = template templitude
c a(i,j)  = covariance matrix of the b values
c ndim    = number of variables associated with the mean magitudes
        real*8 b(50),a(50,50)
        integer ndim

c for velocities
c jdv    = date for velocities
c v      = velocity
c ev     = error in velocity
c vhpase = phase of velocity point
c vmod   = model of velocity
c after solution
c bv(1)  = mean velocity
c bv(2)  = radius in units of 10 rsun
c av(i,j)= covariance matrix of bv values
c nv     = number of velocity data points
        real*8 jdv(1000),v(1000),ev(1000),bv(2),av(2,2)
        real*8 vphase(1000),vmod(1000)
        integer nv

        real*8 pi,ln10

c input file
        character*50 infile


ccccccccccccccccccccccccccccc
c  some parameters to control the fit
c  July 13, 2015
c  Period range in days to fit
	wl_Prange = 1.5 ! This will test from P0 - PR/2 to P0 + PR/2
	wl_Rfactor = 2		! This will increase/decrease the resolution by a factor of RF
	wl_outfile = 'chi_sqr.dat'		! This file <obj>_chi_sqr.dat will record the chi square and number of free parameters
ccccccccccccccccccccccccccccc
	nphase = 3

	read(*,*) wl_Prange
	read(*,*) wl_Rfactor
	read(*,*) nphase

	
c useful constants
        pi   = 4.0*atan(1.0)
        ln10 = log(10.0)

c clear the filter use table - we need this to
c determine which of the allowed filters are in the photometry data table
        do i=1,36
          iused(i) = 0
          enddo


c READ IN THE TEMPLATES AND VECTORS DESCRIBING THE CEPHEIDS
c vcon is a constant needed for velocity calculations
        call cepheidinit(vcon)


c read data, split into photometry and velocity
        print*,'enter name of input file '
        print*,' expected format is '
        print*,' ndata period phase reference time '
        print*,'   date value error filterid (0 for velocity, otherwise matching vector.dat)' 
        read(*,'(a)')infile
        open(unit=13,file=infile,form='formatted',status='old')
        read(13,*)ndat,per0,t0
        tmin = 1.e32
        tmax = -1.e32
        npt  = 0
        nv   = 0
        do i=1,ndat
          read(13,*)tjd,tval,terr,idt
c if it is a photometry data point
          if (idt.gt.0) then
            npt             = npt + 1
            if (npt.gt.5000) then
              print*,'exceeded maximum allowed photometry points at ',npt
              stop
              endif
            jd(npt)         = tjd
            mag(npt)        = tval
            emag(npt)       = terr
            fid(npt)        = idt
c set a minimum photometric error
            emag(npt)       = max(0.03,emag(npt))
            beta(npt)       = cepheidgetbeta(fid(npt))
            iused(fid(npt)) = 1
c if it is a velocity data point
          else
            nv       = nv + 1
            if (nv.gt.1000) then
              print*,'exceeded maximum allowed velocity points at ',nv
              stop
              endif
            jdv(nv)  = tjd
            v(nv)    = tval
            ev(nv)   = terr
c set a minimum velocity error
            ev(nv)   = max(1.0,ev(nv))
            endif 
c variables to work out the maximum time range spanned by the data
          tmin = min(tmin,tjd)
          tmax = max(tmax,tjd)
          enddo
        close(unit=13)

    
        print*,'found ',npt,nv,' photometery and velocity points '


c this will stop working for too few photometric points -- just die since never tested 
        if (npt.lt.10) then
          print*,'total number of photometric data < 10 -- untested so dying! '
          stop
          endif

c the overall span of the data determines the sensitivity to period changes
c here dpest = change in period leading to a 10% phase change over the span of the data
        trange = tmax-tmin
        dpest  = per0*per0*0.1/trange*wl_Rfactor
        print*,'trange = ',trange
        print*,'period change sensitivity ',dpest

c count up the number of filters being used
        nused = 0
        do i=1,36
          if (iused(i).eq.1) then
            nused     = nused + 1
            id(nused) = i
            ivar(i)   = nused
            print*,' adding filter ',i,' to list of those used '
            endif
          enddo 
        print*,'total number of filters in use = ',nused
c this is now the dimension of the photometry fits: nused variables for the mean magnitudes
c plus one for the template amplitude
        ndim = 1 + nused
        if (ndim.gt.50) then
          print*,'dimension problem for photometry fit ' 
          print*,'this should never happen since there are too few defined filters '
          stop
          endif



c if you want to run a fit, set ifit = 1
c this is a somewhat clunky, brute force fit, but there was no particular reason to be elegant -- it
c is not meant to search for Cepheids but to refine fits and/or produce mean magnitudes
c essentially, we will step over a 1 day range centered on the input period p0
c    using period steps which should adjust the phase over the full time range of the data by only 1%
c for each period we will sample the allowed phase zero points first at a reasolution of 5%
c    then for an additional 2->nphase trials we will take the best fit phase point plus or
c    minuse one zone and redo that region at 5 times the original resolution (i.e. 10 new
c    zones spread over the old 2 zones) -- we are assuming that the chi^2(phase) at fixed period
c    is a pretty smooth function.  With nphase=3, the phase zero point is determined to dt=0.002*period
c    just increase nphase if you want to do better
         ! print*,' just run a fit with the input period/phase (0) or try to refit period/phase (1) '
         ! read*,ifit
	 ifit = 1
	 wl_object_name = infile(:5)
	 wl_outfile = trim(wl_object_name) // "_" // wl_outfile
	 open (unit = 101, file = wl_outfile)
         if (ifit.eq.1) then
c get a chi^2 value for the input period and phase
           chimin0 = getchi(jd,phase,mag,emag,beta,mmod,fid,npt,per0,t0,ivar,a,b,ndim,50,ndof,jdv,v,ev,nv,av,bv,vphase,vmod)
           pmin    = per0 - wl_Prange/2.
           pmax    = per0 + wl_Prange/2.
c this sets the period scan resolution -- dpest is defined so that a change in period by dpest
c produces a 10% phase change over the time span of the data -- so resetting it to 0.1*dpest
c means we will scan at a period resolution corresponding to a 1% phase change over the time span of the data
           dpest   = 0.1*dpest
           np      = (pmax-pmin)/dpest
           dp      = (pmax-pmin)/float(np-1)
           chimint= 1.e32
           do jj=1,np
             per = pmin + dp*float(jj-1)
             ! print*,'doing ',jj,' of ',np
             chimin = 1.e32
             tmin   = t0-per0/2.0
             tmax   = t0+per0/2.0
             nt     = 21
             dt     = (tmax-tmin)/float(nt-1)
             do k=1,nphase
               do i=1,nt
                 t = tmin + dt*float(i-1)
                 chi2 = getchi(jd,phase,mag,emag,beta,mmod,fid,npt,per,t,ivar,a,b,ndim,50,ndof,jdv,v,ev,nv,av,bv,vphase,vmod)
c keep track of the best phase point -- note, while everything will basically work with a negative
c amplitude, there is no reason to tolerate it, so only accept phases leading to positive amplitudes
                 if ((chi2.lt.chimin).and.(b(ndim).gt.0.0)) then
                   chimin = chi2
                   tbest  = t
                   endif
		enddo
		! print*,per,chi2,ndim
c reset the search space for the phase reference point to be the present best for the current period
c plus or minus one zone, then resample this into 10 zones and repeat
               tmin   = tbest-dt
               tmax   = tbest+dt
               nt     = 11
               dt     = (tmax-tmin)/float(nt-1)
               enddo
c if the best fit for the present period is better than that for any other period, save it
             write(15,'(3(1x,g15.9))')chimin,per,tbest
	     write (101,'(f12.8,f17.6,i10,i5)') per,chimin,ndof,ndim 
             if (chimin.lt.chimint) then
               chimint = chimin
               pbestt  = per
               tbestt  = tbest
               endif
             enddo
           chi2 = getchi(jd,phase,mag,emag,beta,mmod,fid,npt,pbestt,tbestt,ivar,a,b,ndim,50,ndof,jdv,v,ev,nv,av,bv,vphase,vmod)
           print*,'final chi ',chi2,' initial ',chimin0
           print*,'best: P, t0 ',pbestt,tbestt
           print*,'init: P, t0 ',per0,t0
         else
c if you are not doing a fit, just run with the input period and phase reference time
           chi2 = getchi(jd,phase,mag,emag,beta,mmod,fid,npt,per0,t0,ivar,a,b,ndim,50,ndof,jdv,v,ev,nv,av,bv,vphase,vmod)
           endif


c the last model run is either the best fit model if you did a fit, or the input model if you did not
c print out the final model light curves, the chi^2 and the mean magnitudes with their uncertainties
c write the photometry and its model out into fort.14
        do i=1,npt
c wrap the phase into the range 0 < phase < 1
          temp = phase(i)/2/pi
          temp = temp - int(temp)
          if (temp.lt.0.0) temp = temp + 1.0
          if (temp.gt.1.0) temp = temp - 1.0
          write(14,'(5(1x,f13.6),1x,i3)')temp,jd(i),mag(i),emag(i),mmod(i),fid(i)
          enddo
c write the velocity and its model out into fort.13
        do i=1,nv
          temp = vphase(i)/2/pi
          temp = temp - int(temp)
          if (temp.lt.0.0) temp = temp + 1.0
          if (temp.gt.1.0) temp = temp - 1.0
          write(13,'(4(1x,f13.6))')temp,jdv(i),v(i),ev(i),vmod(i)
          enddo

c final statistics
        print*,'chi2 = ',chi2
        print*,'chi2/ndof = ',chi2/float(ndof),' for dof = ',ndof
c the mean magnitudes and their uncertainties
        print*,'mean mags: filter id, mean mag, error '
        do i=1,ndim-1
          print*,id(i),b(i),sqrt(a(i,i))
          enddo
c the variability amplitude
        print*,'amplitude     ',b(ndim),sqrt(a(ndim,ndim))
c the mean velocity and the inferred radius
        print*,'mean velocity ',bv(1),sqrt(av(1,1))
        print*,'radius/10rsun ',bv(2),sqrt(av(2,2))

	close (101)
        end

      
        function getchi(jd,phase,mag,emag,beta,mmod,fid,npt,per,t,ivar,a,b,ndim,mdim,ndof,jdv,v,ev,nv,av,bv,vphase,vmod)
           implicit real*8 (a-h,o-z)
           real*8 jd(*),phase(*),mag(*),emag(*),beta(*),mmod(*)
           integer fid(*),ivar(*),npt,ndim,mdim
           real*8 per,t
           real*8 b(*),a(mdim,mdim)
           real*8 jdv(*),v(*),ev(*),av(2,2),bv(2)
           real*8 vphase(*),vmod(*)
           integer nv
           real*8 lpuse
         
     

           real*8 pi,ln10

           pi   = 4.0*atan(1.0)
           ln10 = log(10.0)

c remember setcepheidtemplate wants log10(per/10.0)!!!!
          lpuse = log10(per/10.0)
          call setcepheidtemplate(lpuse)
        

          do i1=1,ndim
            b(i1) = 0
            do i2=1,ndim
              a(i1,i2) = 0.0
              enddo
            enddo

          do i1=1,2
            bv(i1) = 0.0
            do i2=1,2
              av(i1,i2) = 0.0
              enddo
            enddo

          do i=1,npt
            phase(i) = 2.0*pi*(jd(i)-t)/per
            call getcepheidtemplate(phase(i),beta(i),rmod,tmod,tvmod,mmod(i))
            k = ivar(fid(i))
c mean magnitude for the filter of current point
            b(k)      = b(k)      +  mag(i)/emag(i)**2
            a(k,k)    = a(k,k)    +     1.0/emag(i)**2
            a(k,ndim) = a(k,ndim) + mmod(i)/emag(i)**2
c contribution to determination of the amplitude
            b(ndim)      = b(ndim)      +  mag(i)*mmod(i)/emag(i)**2
            a(ndim,ndim) = a(ndim,ndim) + mmod(i)*mmod(i)/emag(i)**2
            enddo

c fill in the rest of the a matrix by symmetry
          do i1=1,ndim
            do i2=i1,ndim
              a(i2,i1) = a(i1,i2)
              enddo
            enddo

c          print*,'vector '
c          write(*,'(10(1x,g13.6))')(b(i),i=1,ndim)
c          print*,'matrix '
c          do i=1,ndim
c            write(*,'(10(1x,g13.6))')(a(i,j),j=1,ndim)
c            enddo

          call gaussj(a,ndim,50,b,1,50)

c          print*,'solution '
c          write(*,'(10(1x,g13.6))')(b(i),i=1,ndim)

          chi2m = 0.0
          do i=1,npt
            k       = ivar(fid(i))
            mmod(i) = b(k) + b(ndim)*mmod(i)
            dchi    = ((mag(i)-mmod(i))/emag(i))**2
            chi2m   = chi2m + dchi
            enddo
          ndof = npt - ndim


          if (nv.eq.0) then
            chi2   = chi2m
            getchi = chi2m
            return
            endif
          if (nv.eq.1) then
            chi2      = chi2m
            vphase(i) = 2.0*pi*(jdv(1)-t)/per
            vmod(1)   = v(1)
            bv(1)     = v(1)
            av(1,1)   = ev(1)
            getchi    = chi2m
            return 
            endif

c if there are velocities to fit
c     v = vbar - (R/R0) (2 pi R_0/ P p) A^2 ln10 (dr/dphi) 10^(A^2 dr)
c where A^2 is the amplitude from the photometry fits 

c the 80.55 = (R0/10 Rsun)(day/P) in km/s
          amp  = abs(b(ndim))
          pexp = 1.36
          vcon = -80.55*2.0*Pi*ln10*amp/(pexp*per)
          btemp= 0.0
          do i=1,nv
            vphase(i) = 2.0*pi*(jdv(i)-t)/per
            call getcepheidtemplate(vphase(i),btemp,rmod,tmod,tvmod,tmmod)
            vmod(i)  = vcon*tvmod*10.0**(amp*rmod)
            bv(1)    = bv(1)   +             v(i)/ev(i)**2
            bv(2)    = bv(2)   +     vmod(i)*v(i)/ev(i)**2
            av(1,1)  = av(1,1) +              1.0/ev(i)**2
            av(1,2)  = av(1,2) +          vmod(i)/ev(i)**2
            av(2,2)  = av(2,2) +  vmod(i)*vmod(i)/ev(i)**2
            enddo
          av(2,1) = av(1,2)


          call gaussj(av,2,2,bv,1,2)

          chi2v = 0.0
          do i=1,nv
            vmod(i) = bv(1)  + bv(2)*vmod(i)
            chi2v   = chi2v + ((v(i)-vmod(i))/ev(i))**2
            enddo

c          print*,'photometry ',chi2m,ndof,chi2m/float(ndof)
c          print*,'velocity   ',chi2v,nv-2,chi2v/float(nv-2)
          chi2 = chi2m + chi2v
          ndof = ndof + nv - 2

          
          getchi = chi2


          return
          end




      SUBROUTINE gaussj(a,n,np,b,m,mp)
      implicit real*8 (a-h,o-z)
      INTEGER m,mp,n,np,NMAX
      REAL*8 a(np,np),b(np,mp)
      PARAMETER (NMAX=50)
      INTEGER i,icol,irow,j,k,l,ll,indxc(NMAX),indxr(NMAX),ipiv(NMAX)
      REAL*8 big,dum,pivinv
      do 11 j=1,n
        ipiv(j)=0
11    continue
      do 22 i=1,n
        big=0.
        do 13 j=1,n
          if(ipiv(j).ne.1)then
            do 12 k=1,n
              if (ipiv(k).eq.0) then
                if (abs(a(j,k)).ge.big)then
                  big=abs(a(j,k))
                  irow=j
                  icol=k
                endif
              else if (ipiv(k).gt.1) then
                pause 'singular matrix in gaussj'
              endif
12          continue
          endif
13      continue
        ipiv(icol)=ipiv(icol)+1
        if (irow.ne.icol) then
          do 14 l=1,n
            dum=a(irow,l)
            a(irow,l)=a(icol,l)
            a(icol,l)=dum
14        continue
          do 15 l=1,m
            dum=b(irow,l)
            b(irow,l)=b(icol,l)
            b(icol,l)=dum
15        continue
        endif
        indxr(i)=irow
        indxc(i)=icol
        if (a(icol,icol).eq.0.) pause 'singular matrix in gaussj'
        pivinv=1./a(icol,icol)
        a(icol,icol)=1.
        do 16 l=1,n
          a(icol,l)=a(icol,l)*pivinv
16      continue
        do 17 l=1,m
          b(icol,l)=b(icol,l)*pivinv
17      continue
        do 21 ll=1,n
          if(ll.ne.icol)then
            dum=a(ll,icol)
            a(ll,icol)=0.
            do 18 l=1,n
              a(ll,l)=a(ll,l)-a(icol,l)*dum
18          continue
            do 19 l=1,m
              b(ll,l)=b(ll,l)-b(icol,l)*dum
19          continue
          endif
21      continue
22    continue
      do 24 l=n,1,-1
        if(indxr(l).ne.indxc(l))then
          do 23 k=1,n
            dum=a(k,indxr(l))
            a(k,indxr(l))=a(k,indxc(l))
            a(k,indxc(l))=dum
23        continue
        endif
24    continue
      return
      END
