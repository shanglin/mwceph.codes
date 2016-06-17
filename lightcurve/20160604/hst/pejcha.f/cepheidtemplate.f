
	subroutine cepheidinit(vcon)
          implicit real*8 (a-h,o-z)
          include 'bindat01.com'

        ln10 = log(10.0D0)
        pi   = 4.0D0*atan(1.0D0)
c velocity expansion p-factor
        pexp = 1.36
        vcon = -80.55*ln10/pexp

        print*,'reading Cepheid vectors '
        open(unit=13,file='vector.dat',form='formatted',status='old')
        read(13,*)ncol
        do i=1,ncol
          read(13,*)b0(i),fname(i)
          enddo
        close(unit=13)

c read in the templates: ncos = Fourier order, ntempl = number of period terms
c tlp = defining periods for the templates
        open(unit=13,file='template.dat',form='formatted',status='old')
        read(13,*)ncos,ntempl
        read(13,*)(tlp(i),i=1,ntempl)
c read in templates for fundamental mode
        do j=1,ncos
          read(13,*)jj,(ctt(i,j),stt(i,j),i=1,ntempl)
          enddo
        do j=1,ncos
          read(13,*)jj,(crt(i,j),srt(i,j),i=1,ntempl)
          enddo
        close(unit=13)

        return
        end

c build template normalizations  at period tp=log(p/10.0) for variable class km
	function cepheidgetbeta(i)
          implicit real*8 (a-h,o-z)
          integer*2 i
          include 'bindat01.com'
          
          if ((i.le.32).and.(i.ge.28)) then
           print*,'filter ',i,' is currently not defined'
           cepheidgetbeta = -1.0
           return
           endif

          if ((i.lt.1).or.(i.gt.ncol)) then
            print*,'unknown filter ',i,' is not in range 1 to ',ncol
            cepheidgetbeta = -1.0
            return
            endif

          print*,'selected filter ',fname(i)
          cepheidgetbeta = b0(i)

          return
          end

          
c build template normalizations  at period tp=log(p/10.0) for variable class km
	subroutine setcepheidtemplate(lpuse)
          implicit real*8 (a-h,o-z)
          real*8 lpuse
          include 'bindat01.com'

           
c if too short a period set to shortest value but give warning
          if (lpuse.le.tlp(1)) then
c            print*,'warning, requested period shorter than minimum -- will use minimum '
c            print*,'requested is ',lpuse,' minimum in templates is ',tlp(1)
            itemp0 = 1
            itemp1 = 2
            tw(1)  = 1.0D0
            tw(2)  = 0.0D0
            return
            endif

c if too long a period, set to longest value but give warning
          if (lpuse.ge.tlp(ntempl)) then
            print*,'warning, requested period longer than maximum -- will use maximum '
            print*,'requested is ',lpuse,' maximum in templates is ',tlp(ntempl)
            itemp0      = ntempl-1
            itemp1      = ntempl
            tw(ntempl-1)= 0.0D0
            tw(ntempl)  = 1.0D0
            return
            endif
 
c if in allowed period range split, period range in 2, and then brute force 
          nmid = ntempl/2
          if (lpuse.le.tlp(nmid)) then
            istart = 2
            istop  = nmid
          else
            istart = nmid+1
            istop  = ntempl
            endif
          ifound = 0
          do i=istart,istop 
            if ((lpuse.ge.tlp(i-1)).and.(lpuse.lt.tlp(i))) then
              itemp0  = i-1
              itemp1  = i
              slope   = 1.0/(tlp(i)-tlp(i-1))
              tw(i)   = (lpuse-tlp(i-1))*slope
              tw(i-1) = 1.0-tw(i)
              ifound  = 1
              endif
            enddo
          if (ifound.eq.0) then
            print*,'failed to bracket period ',lpuse
            stop
            endif 
 
          return
          end


c get templates values for star k at point i using template type km
        subroutine getcepheidtemplate(usephase,beta,rmod,tmod,vmod,mmod)
          implicit real*8 (a-h,o-z)
          include 'bindat01.com'
          real*8 usephase,beta,rmod,tmod,vmod,mmod
c   storage of cosines and sines
          real*8 cost(20),sint(20)
c   radius/temperature template value and its first three phase derivatives
          real*8 rt(4),tt(4)


c set the phase
          cost(1) = cos(usephase)
          sint(1) = sin(usephase)

c clear the templates -- compute the velocities
          tt(1) = 0.0
          rt(1) = 0.0
          rt(2) = 0.0

c get the angles using a recurrance relation 
          do j=2,ncos
            jh  = j/2
            jhm = j-jh
            cost(j) = cost(jh)*cost(jhm)-sint(jh)*sint(jhm)
            sint(j) = cost(jh)*sint(jhm)+sint(jh)*cost(jhm)
            enddo

c compute the templates and their derivatives
          do j=1,ncos
            rj      = float(j)
            do ii=itemp0,itemp1
              st1   =  ctt(ii,j)*cost(j) + stt(ii,j)*sint(j)
              st2   = -ctt(ii,j)*sint(j) + stt(ii,j)*cost(j)
              sr1   =  crt(ii,j)*cost(j) + srt(ii,j)*sint(j)
              sr2   = -crt(ii,j)*sint(j) + srt(ii,j)*cost(j)
c template and the derivative of the radius template with respect to phase
              tt(1) = tt(1) + tw(ii)*st1
              rt(1) = rt(1) + tw(ii)*sr1
              rt(2) = rt(2) + tw(ii)*sr2*rj
              enddo
            enddo

          rmod = rt(1)
          tmod = tt(1)
          vmod = rt(2)
          mmod = -5.0*rmod - 2.5*beta*tmod

          return
          end
