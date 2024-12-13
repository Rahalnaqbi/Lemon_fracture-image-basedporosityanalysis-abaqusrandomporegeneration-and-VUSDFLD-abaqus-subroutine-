c Read only - 
      
      subroutine vusdfld(nblock,nstatev,nfieldv,nprops,ndir,
     &	                 nshr,jElem,kIntPt,kLayer,kSecPt, 
     &                   stepTime,totalTime,dt,cmname, 
     &                   coordMp,direct,T,charLength,props, 
     &                    stateOld,stateNew,field)

      include 'vaba_param_dp.inc'


      
      ! Declare variables and array dimensions
      integer nblock, nstatev, nfieldv, nprops, ndir, nshr
      integer jElem(nblock), kIntPt, kLayer, kSecPt
      real*8 stepTime, totalTime, dt
      real*8 coordMp(nblock,*), direct(nblock,3,3), T(nblock,3,3)
      real*8 charLength(nblock), props(nprops)
      real*8 stateOld(nblock,nstatev), stateNew(nblock,nstatev)
      real*8 field(nblock,nfieldv)
      character*80 cmname

      ! Parameters for data retrieval
      integer jStatus, maxblk
      parameter (nrData=6)  ! Adjust the number of data points as needed
      real*8 rData(maxblk*nrData)
      integer jData(maxblk*nrData)
      character*3 cData(maxblk*nrData)

      ! Declare variables for calculations
      real*8 sigmaNew(6)
      real*8 Critical_Strain, MaxStress
      real*8 term1, term2, term3, term4, term5
      real*8 maxprincipalE, minprincipalE
      real*8 StrainE11, StrainE22, StrainE33, StrainE12

      ! Set a critical strain threshold
      Critical_Strain = 0.3000

      ! Get the strain values using VGETVRM
      jStatus = 1
      call vgetvrm('LE', rData, jData, cData, jStatus)
      if (jStatus .ne. 0) then
         call xplb_abqerr(-2, 'Utility routine VGETVRM fail', 
     &                    0, 0.0d0, '')
         call xplb_exit
      end if

      ! Loop through each block to compute new state variables
      do k = 1, nblock
         StrainE11 = rData(k)
         StrainE22 = rData(nblock+k)
         StrainE33 = rData(2*nblock+k)
         StrainE12 = rData(3*nblock+k)

         ! Principal strain calculations
         term1 = (StrainE11 + StrainE22) / 2.0
         term2 = (StrainE11 - StrainE22) / 2.0
         term3 = StrainE12 / 2.0
         term4 = term2**2 + term3**2
         term5 = sqrt(term4)
         maxprincipalE = term1 + term5
         minprincipalE = term1 - term5

         ! Set stateNew based on Critical Strain
         if (maxprincipalE >= Critical_Strain) then
            stateNew(k,1) = 0.0
         end if
      end do

      return
      end