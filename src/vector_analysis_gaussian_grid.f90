!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 1998 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                      SPHEREPACK                               *
!     *                                                               *
!     *       A Package of Fortran Subroutines and Programs           *
!     *                                                               *
!     *              for Modeling Geophysical Processes               *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *                  John Adams and Paul Swarztrauber             *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!
!
! ... file vhagc.f
!
!     this file contains code and documentation for subroutines
!     vhagc and vhagci
!
! ... files which must be loaded with vhagc.f
!
!     type_SpherepackAux.f, type_RealPeriodicTransform.f, compute_gaussian_latitudes_and_weights.f
!
!                                                                              
!     subroutine vhagc(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, 
!    +                 mdab, ndab, wvhagc, lvhagc, work, lwork, ierror)
!
!     subroutine vhagc performs the vector spherical harmonic analysis
!     on the vector field (v, w) and stores the result in the arrays
!     br, bi, cr, and ci. v(i, j) and w(i, j) are the colatitudinal
!     (measured from the north pole) and east longitudinal components
!     respectively, located at the gaussian colatitude point theta(i)
!     and longitude phi(j) = (j-1)*2*pi/nlon. the spectral
!     representation of (v, w) is given at output parameters v, w in 
!     subroutine vhsec.  
!
!     input parameters
!
!     nlat   the number of points in the gaussian colatitude grid on the
!            full sphere. these lie in the interval (0, pi) and are computed
!            in radians in theta(1) <...< theta(nlat) by subroutine compute_gaussian_latitudes_and_weights.
!            if nlat is odd the equator will be included as the grid point
!            theta((nlat+1)/2).  if nlat is even the equator will be
!            excluded as a grid point and will lie half way between
!            theta(nlat/2) and theta(nlat/2+1). nlat must be at least 3.
!            note: on the half sphere, the number of grid points in the
!            colatitudinal direction is nlat/2 if nlat is even or
!            (nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct londitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     ityp   = 0  no symmetries exist about the equator. the analysis
!                 is performed on the entire sphere.  i.e. on the
!                 arrays v(i, j), w(i, j) for i=1, ..., nlat and 
!                 j=1, ..., nlon.   
!
!            = 1  no symmetries exist about the equator. the analysis
!                 is performed on the entire sphere.  i.e. on the
!                 arrays v(i, j), w(i, j) for i=1, ..., nlat and 
!                 j=1, ..., nlon. the curl of (v, w) is zero. that is, 
!                 (d/dtheta (sin(theta) w) - dv/dphi)/sin(theta) = 0. 
!                 the coefficients cr and ci are zero.
!
!            = 2  no symmetries exist about the equator. the analysis
!                 is performed on the entire sphere.  i.e. on the
!                 arrays v(i, j), w(i, j) for i=1, ..., nlat and 
!                 j=1, ..., nlon. the divergence of (v, w) is zero. i.e., 
!                 (d/dtheta (sin(theta) v) + dw/dphi)/sin(theta) = 0. 
!                 the coefficients br and bi are zero.
!
!            = 3  v is symmetric and w is antisymmetric about the 
!                 equator. the analysis is performed on the northern
!                 hemisphere only.  i.e., if nlat is odd the analysis
!                 is performed on the arrays v(i, j), w(i, j) for 
!                 i=1, ..., (nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the analysis is performed on the the arrays
!                 v(i, j), w(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 4  v is symmetric and w is antisymmetric about the 
!                 equator. the analysis is performed on the northern
!                 hemisphere only.  i.e., if nlat is odd the analysis
!                 is performed on the arrays v(i, j), w(i, j) for 
!                 i=1, ..., (nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the analysis is performed on the the arrays
!                 v(i, j), w(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!                 the curl of (v, w) is zero. that is, 
!                 (d/dtheta (sin(theta) w) - dv/dphi)/sin(theta) = 0. 
!                 the coefficients cr and ci are zero.
!
!            = 5  v is symmetric and w is antisymmetric about the 
!                 equator. the analysis is performed on the northern
!                 hemisphere only.  i.e., if nlat is odd the analysis
!                 is performed on the arrays v(i, j), w(i, j) for 
!                 i=1, ..., (nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the analysis is performed on the the arrays
!                 v(i, j), w(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!                 the divergence of (v, w) is zero. i.e., 
!                 (d/dtheta (sin(theta) v) + dw/dphi)/sin(theta) = 0. 
!                 the coefficients br and bi are zero.
!
!            = 6  v is antisymmetric and w is symmetric about the 
!                 equator. the analysis is performed on the northern
!                 hemisphere only.  i.e., if nlat is odd the analysis
!                 is performed on the arrays v(i, j), w(i, j) for 
!                 i=1, ..., (nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the analysis is performed on the the arrays
!                 v(i, j), w(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 7  v is antisymmetric and w is symmetric about the 
!                 equator. the analysis is performed on the northern
!                 hemisphere only.  i.e., if nlat is odd the analysis
!                 is performed on the arrays v(i, j), w(i, j) for 
!                 i=1, ..., (nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the analysis is performed on the the arrays
!                 v(i, j), w(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!                 the curl of (v, w) is zero. that is, 
!                 (d/dtheta (sin(theta) w) - dv/dphi)/sin(theta) = 0. 
!                 the coefficients cr and ci are zero.
!
!            = 8  v is antisymmetric and w is symmetric about the 
!                 equator. the analysis is performed on the northern
!                 hemisphere only.  i.e., if nlat is odd the analysis
!                 is performed on the arrays v(i, j), w(i, j) for 
!                 i=1, ..., (nlat+1)/2 and j=1, ..., nlon. if nlat is
!                 even the analysis is performed on the the arrays
!                 v(i, j), w(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!                 the divergence of (v, w) is zero. i.e., 
!                 (d/dtheta (sin(theta) v) + dw/dphi)/sin(theta) = 0. 
!                 the coefficients br and bi are zero.
!
!
!     nt     the number of analyses.  in the program that calls vhagc, 
!            the arrays v, w, br, bi, cr, and ci can be three dimensional
!            in which case multiple analyses will be performed.
!            the third index is the analysis index which assumes the 
!            values k=1, ..., nt.  for a single analysis set nt=1. the
!            discription of the remaining parameters is simplified
!            by assuming that nt=1 or that all the arrays are two
!            dimensional.
!
!     v, w    two or three dimensional arrays (see input parameter nt)
!            that contain the vector function to be analyzed.
!            v is the colatitudnal component and w is the east 
!            longitudinal component. v(i, j), w(i, j) contain the
!            components at colatitude theta(i) = (i-1)*pi/(nlat-1)
!            and longitude phi(j) = (j-1)*2*pi/nlon. the index ranges
!            are defined above at the input parameter ityp.
!
!     idvw   the first dimension of the arrays v, w as it appears in
!            the program that calls vhagc. if ityp .le. 2 then idvw
!            must be at least nlat.  if ityp .gt. 2 and nlat is
!            even then idvw must be at least nlat/2. if ityp .gt. 2
!            and nlat is odd then idvw must be at least (nlat+1)/2.
!
!     jdvw   the second dimension of the arrays v, w as it appears in
!            the program that calls vhagc. jdvw must be at least nlon.
!
!     mdab   the first dimension of the arrays br, bi, cr, and ci as it
!            appears in the program that calls vhagc. mdab must be at
!            least min(nlat, nlon/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!     ndab   the second dimension of the arrays br, bi, cr, and ci as it
!            appears in the program that calls vhagc. ndab must be at
!            least nlat.
!
!     wvhagc an array which must be initialized by subroutine vhagci.
!            once initialized, wvhagc can be used repeatedly by vhagc
!            as long as nlon and nlat remain unchanged.  wvhagc must
!            not be altered between calls of vhagc.
!
!     lvhagc the dimension of the array wvhagc as it appears in the
!            program that calls vhagc. define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            then lvhagc must be at least
!
!               4*nlat*l2+3*max(l1-2, 0)*(2*nlat-l1-1)+nlon+l2+15
!
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls vhagc. define
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            if ityp .le. 2 then lwork must be at least
!
!               2*nlat*(2*nlon*nt+3*l2)
!
!            if ityp .gt. 2 then lwork must be at least
!
!               2*l2*(2*nlon*nt+3*nlat)
!
!
!
!     **************************************************************
!
!     output parameters
!
!     br, bi  two or three dimensional arrays (see input parameter nt)
!     cr, ci  that contain the vector spherical harmonic coefficients
!            in the spectral representation of v(i, j) and w(i, j) given 
!            in the discription of subroutine vhsec. br(mp1, np1), 
!            bi(mp1, np1), cr(mp1, np1), and ci(mp1, np1) are computed 
!            for mp1=1, ..., mmax and np1=mp1, ..., nlat except for np1=nlat
!            and odd mp1. mmax=min(nlat, nlon/2) if nlon is even or 
!            mmax=min(nlat, (nlon+1)/2) if nlon is odd. 
!      
!     ierror = 0  no errors
!            = 1  error in the specification of nlat
!            = 2  error in the specification of nlon
!            = 3  error in the specification of ityp
!            = 4  error in the specification of nt
!            = 5  error in the specification of idvw
!            = 6  error in the specification of jdvw
!            = 7  error in the specification of mdab
!            = 8  error in the specification of ndab
!            = 9  error in the specification of lvhagc
!            = 10 error in the specification of lwork
!
! ****************************************************************
!
!     subroutine vhagci(nlat, nlon, wvhagc, lvhagc, dwork, ldwork, ierror)
!
!     subroutine vhagci initializes the array wvhagc which can then be
!     used repeatedly by subroutine vhagc until nlat or nlon is changed.
!
!     input parameters
!
!     nlat   the number of points in the gaussian colatitude grid on the
!            full sphere. these lie in the interval (0, pi) and are computed
!            in radians in theta(1) <...< theta(nlat) by subroutine compute_gaussian_latitudes_and_weights.
!            if nlat is odd the equator will be included as the grid point
!            theta((nlat+1)/2).  if nlat is even the equator will be
!            excluded as a grid point and will lie half way between
!            theta(nlat/2) and theta(nlat/2+1). nlat must be at least 3.
!            note: on the half sphere, the number of grid points in the
!            colatitudinal direction is nlat/2 if nlat is even or
!            (nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct londitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     lvhagc the dimension of the array wvhagc as it appears in the
!            program that calls vhagci.  define
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            then lvhagc must be at least
!
!               4*nlat*l2+3*max(l1-2, 0)*(2*nlat-l1-1)+nlon+l2+15
!
!
!     dwork  a real work array that does not need to be saved
!
!     ldwork the dimension of the array dwork as it appears in the
!            program that calls vhagci. ldwork must be at least
!
!               2*nlat*(nlat+1)+1
!
!
!     **************************************************************
!
!     output parameters
!
!     wvhagc an array which is initialized for use by subroutine vhagc.
!            once initialized, wvhagc can be used repeatedly by vhagc
!            as long as nlat and nlon remain unchanged.  wvhagc must not
!            be altered between calls of vhagc.
!
!
!     ierror = 0  no errors
!            = 1  error in the specification of nlat
!            = 2  error in the specification of nlon
!            = 3  error in the specification of lvhagc
!            = 4  error in the specification of lwork
!
submodule(vector_analysis_routines) vector_analysis_gaussian_grid

contains

    module subroutine vhagc(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, &
        mdab, ndab, wvhagc, lvhagc, work, lwork, ierror)

        ! Dummy arguments
        integer(ip), intent(in)  :: nlat
        integer(ip), intent(in)  :: nlon
        integer(ip), intent(in)  :: ityp
        integer(ip), intent(in)  :: nt
        real(wp),    intent(in)  :: v(idvw, jdvw, nt)
        real(wp),    intent(in)  :: w(idvw, jdvw, nt)
        integer(ip), intent(in)  :: idvw
        integer(ip), intent(in)  :: jdvw
        real(wp),    intent(out) :: br(mdab,ndab,nt)
        real(wp),    intent(out) :: bi(mdab, ndab,nt)
        real(wp),    intent(out) :: cr(mdab,ndab,nt)
        real(wp),    intent(out) :: ci(mdab, ndab,nt)
        integer(ip), intent(in)  :: mdab
        integer(ip), intent(in)  :: ndab
        real(wp),    intent(in)  :: wvhagc(lvhagc)
        integer(ip), intent(in)  :: lvhagc
        real(wp),    intent(out) :: work(lwork)
        integer(ip), intent(in)  :: lwork
        integer(ip), intent(out) :: ierror

        ! Local variables
        integer(ip) :: imid, idv
        integer(ip) :: ist
        integer(ip) :: iw1
        integer(ip) :: iw2
        integer(ip) :: iw3
        integer(ip) :: iw4
        integer(ip) :: iw5
        integer(ip) :: jw1
        integer(ip) :: jw2
        integer(ip) :: jw3
        integer(ip) :: labc
        integer(ip) :: lnl
        integer(ip) :: lwzvin
        integer(ip) :: lzz1
        integer(ip) :: mmax

        ierror = 1
        if (nlat < 3) return
        ierror = 2
        if (nlon < 1) return
        ierror = 3
        if (ityp<0 .or. ityp>8) return
        ierror = 4
        if (nt < 0) return
        ierror = 5
        imid = (nlat+1)/2
        if ((ityp<=2 .and. idvw<nlat) .or. &
            (ityp>2 .and. idvw<imid)) return
        ierror = 6
        if (jdvw < nlon) return
        ierror = 7
        mmax = min(nlat, (nlon+1)/2)
        if (mdab < mmax) return
        ierror = 8
        if (ndab < nlat) return
        ierror = 9
        lzz1 = 2*nlat*imid
        labc = 3*(max(mmax-2, 0)*(nlat+nlat-mmax-1))/2
        if (lvhagc < 2*(lzz1+labc)+nlon+imid+15) return
        ierror = 10
        if (ityp<=2 .and. lwork <nlat*(4*nlon*nt+6*imid)) return
        if (ityp>2 .and. lwork <imid*(4*nlon*nt+6*nlat)) return
        ierror = 0
        idv = nlat
        if (ityp > 2) idv = imid
        lnl = nt*idv*nlon
        ist = 0
        if (ityp <= 2) ist = imid
        iw1 = ist+1
        iw2 = lnl+1
        iw3 = iw2+ist
        iw4 = iw2+lnl
        iw5 = iw4+3*imid*nlat
        lwzvin = lzz1+labc
        jw1 = (nlat+1)/2+1
        jw2 = jw1+lwzvin
        jw3 = jw2+lwzvin

        call vhagc_lower_routine(nlat, nlon, ityp, nt, imid, idvw, jdvw, v, w, mdab, ndab, &
            br, bi, cr, ci, idv, work, work(iw1), work(iw2), work(iw3), &
            work(iw4), work(iw5), wvhagc, wvhagc(jw1), wvhagc(jw2), wvhagc(jw3))

    end subroutine vhagc

    module subroutine vhagci(nlat, nlon, wvhagc, lvhagc, dwork, ldwork, ierror)

        ! Dummy arguments
        integer(ip), intent(in)  :: nlat
        integer(ip), intent(in)  :: nlon
        real(wp),    intent(out) :: wvhagc(lvhagc)
        integer(ip), intent(in)  :: lvhagc
        real(wp),    intent(out) :: dwork(ldwork)
        integer(ip), intent(in)  :: ldwork
        integer(ip), intent(out) :: ierror

        ! Local variables
        integer(ip) :: imid
        integer(ip) :: iw1
        integer(ip) :: iw2
        integer(ip) :: iw3
        integer(ip) :: iwrk
        integer(ip) :: jw1
        integer(ip) :: jw2
        integer(ip) :: jw3
        integer(ip) :: labc

        integer(ip) :: lwk
        integer(ip) :: lwvbin
        integer(ip) :: lzz1
        integer(ip) :: mmax
        type(SpherepackAux) :: sphere_aux

        ierror = 1
        if (nlat < 3) return
        ierror = 2
        if (nlon < 1) return
        ierror = 3
        imid = (nlat+1)/2
        lzz1 = 2*nlat*imid
        mmax = min(nlat, (nlon+1)/2)
        labc = 3*(max(mmax-2, 0)*(nlat+nlat-mmax-1))/2
        imid = (nlat+1)/2
        if (lvhagc < 2*(lzz1+labc)+nlon+imid+15) return
        ierror = 4
        if (ldwork < 2*nlat*(nlat+1)+1) return
        ierror = 0
        !
        !     compute gaussian points in first nlat+1 words of dwork
        !     real
        !
        lwk = nlat*(nlat+2)

        jw1 = 1
        !     jw2 = jw1+nlat+nlat
        !     jw3 = jw2+nlat+nlat
        jw2 = jw1+nlat
        jw3 = jw2+nlat
        call compute_gaussian_latitudes_and_weights(nlat, dwork(jw1), dwork(jw2), ierror)
        imid = (nlat+1)/2
        !
        !     set first imid words of real weights in dwork
        !     as single precision in first imid words of wvhagc
        !
        call copy_gaussian_weights(imid, dwork(nlat+1), wvhagc)
        !
        !     first nlat+1 words of dwork contain  double theta
        !
        !     iwrk = nlat+2
        iwrk = (nlat+1)/2 +1
        iw1 = imid+1
        lwvbin = lzz1+labc
        iw2 = iw1+lwvbin
        iw3 = iw2+lwvbin

        call sphere_aux%initialize_polar_components_gaussian_grid(nlat, nlon, dwork, wvhagc(iw1), dwork(iwrk))

        call sphere_aux%initialize_azimuthal_components_gaussian_grid(nlat, nlon, dwork, wvhagc(iw2), dwork(iwrk))

        call sphere_aux%hfft%initialize(nlon, wvhagc(iw3))

    end subroutine vhagci

    subroutine vhagc_lower_routine(nlat, nlon, ityp, nt, imid, idvw, jdvw, v, w, mdab, &
        ndab, br, bi, cr, ci, idv, ve, vo, we, wo, vb, wb, wts, wvbin, wwbin, wrfft)

        real(wp) :: bi
        real(wp) :: br
        real(wp) :: ci
        real(wp) :: cr
        real(wp) :: fsn
        integer(ip) :: i
        integer(ip) :: idv
        integer(ip) :: idvw
        integer(ip) :: imid
        integer(ip) :: imm1
        integer(ip) :: ityp

        integer(ip) :: iv
        integer(ip) :: iw
        integer(ip) :: j
        integer(ip) :: jdvw
        integer(ip) :: k
        integer(ip) :: m
        integer(ip) :: mdab
        integer(ip) :: mlat
        integer(ip) :: mlon
        integer(ip) :: mmax
        integer(ip) :: mp1
        integer(ip) :: mp2
        integer(ip) :: ndab
        integer(ip) :: ndo1
        integer(ip) :: ndo2
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nlp1
        integer(ip) :: np1
        integer(ip) :: nt
        real(wp) :: tsn
        real(wp) :: tv
        real(wp) :: tve1
        real(wp) :: tve2
        real(wp) :: tvo1
        real(wp) :: tvo2
        real(wp) :: tw
        real(wp) :: twe1
        real(wp) :: twe2
        real(wp) :: two1
        real(wp) :: two2
        real(wp) :: v
        real(wp) :: vb
        real(wp) :: ve
        real(wp) :: vo
        real(wp) :: w
        real(wp) :: wb
        real(wp) :: we
        real(wp) :: wo
        real(wp) :: wrfft
        real(wp) :: wts
        real(wp) :: wvbin
        real(wp) :: wwbin
        dimension v(idvw, jdvw, *), w(idvw, jdvw, *), br(mdab, ndab, *), &
            bi(mdab, ndab, *), cr(mdab, ndab, *), ci(mdab, ndab, *), &
            ve(idv, nlon, *), vo(idv, nlon, *), we(idv, nlon, *), &
            wo(idv, nlon, *), wts(*), wvbin(*), wwbin(*), wrfft(*), &
            vb(imid, nlat, 3), wb(imid, nlat, 3)

 type(SpherepackAux) :: sphere_aux

        nlp1 = nlat+1
        tsn = TWO/nlon
        fsn = FOUR/nlon
        mlat = mod(nlat, 2)
        mlon = mod(nlon, 2)
        mmax = min(nlat, (nlon+1)/2)

        select case (mlat)
            case (0)
                imm1 = imid
                ndo1 = nlat
                ndo2 = nlat-1
            case default
                imm1 = imid-1
                ndo1 = nlat-1
                ndo2 = nlat
        end select

        if (ityp <= 2) then
            do k=1, nt
                do i=1, imm1
                    do j=1, nlon
                        ve(i, j, k) = tsn*(v(i, j, k)+v(nlp1-i, j, k))
                        vo(i, j, k) = tsn*(v(i, j, k)-v(nlp1-i, j, k))
                        we(i, j, k) = tsn*(w(i, j, k)+w(nlp1-i, j, k))
                        wo(i, j, k) = tsn*(w(i, j, k)-w(nlp1-i, j, k))
                    end do
                end do
            end do
        else
            do k=1, nt
                do i=1, imm1
                    do j=1, nlon
                        ve(i, j, k) = fsn*v(i, j, k)
                        vo(i, j, k) = fsn*v(i, j, k)
                        we(i, j, k) = fsn*w(i, j, k)
                        wo(i, j, k) = fsn*w(i, j, k)
                    end do
                end do
            end do
        end if

        if (mlat /= 0) then
            do k=1, nt
                do j=1, nlon
                    ve(imid, j, k) = tsn*v(imid, j, k)
                    we(imid, j, k) = tsn*w(imid, j, k)
                end do
            end do
        end if

        do k=1, nt
            call sphere_aux%hfft%forward(idv, nlon, ve(1, 1, k), idv, wrfft, vb)
            call sphere_aux%hfft%forward(idv, nlon, we(1, 1, k), idv, wrfft, vb)
        end do

        !  Set polar coefficients to zero
        select case (ityp)
            case (0:1, 3:4, 6:7)
                do k=1, nt
                    do mp1=1, mmax
                        do np1=mp1, nlat
                            br(mp1, np1, k) = ZERO
                            bi(mp1, np1, k) = ZERO
                        end do
                    end do
                end do
        end select

        !  Set azimuthal coefficients to zero
        select case (ityp)
            case (0, 2:3, 5:6, 8)
                do k=1, nt
                    do mp1=1, mmax
                        do np1=mp1, nlat
                            cr(mp1, np1, k) = ZERO
                            ci(mp1, np1, k) = ZERO
                        end do
                    end do
                end do
        end select

        vector_symmetry_cases: select case (ityp)
            case (0)

                ! Case ityp=0 ,  no symmetries

                call sphere_aux%compute_polar_component(0, nlat, nlon, 0, vb, iv, wvbin)

                ! Case m=0
                do k=1, nt
                    do i=1, imid
                        tv = ve(i, 1, k)*wts(i)
                        tw = we(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do

                do k=1, nt
                    do i=1, imm1
                        tv = vo(i, 1, k)*wts(i)
                        tw = wo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do

                ! Case m = 1 through nlat-1
                if (mmax < 2) return

                do mp1=2, mmax
                    m = mp1-1
                    mp2 = mp1+1
                    call sphere_aux%compute_polar_component(0, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(0, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 <= ndo1) then
                        do k=1, nt
                            do i=1, imm1

                                ! Set temps to optimize quadrature
                                tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                                tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                                tve1 = ve(i, 2*mp1-1, k)*wts(i)
                                tve2 = ve(i, 2*mp1-2, k)*wts(i)
                                two1 = wo(i, 2*mp1-1, k)*wts(i)
                                two2 = wo(i, 2*mp1-2, k)*wts(i)
                                twe1 = we(i, 2*mp1-1, k)*wts(i)
                                twe2 = we(i, 2*mp1-2, k)*wts(i)

                                do np1=mp1, ndo1, 2
                                    br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tvo2 &
                                        +wb(i, np1, iw)*twe1
                                    bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tvo1 &
                                        -wb(i, np1, iw)*twe2
                                    cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*two2 &
                                        +wb(i, np1, iw)*tve1
                                    ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*two1 &
                                        -wb(i, np1, iw)*tve2
                                end do
                            end do
                        end do
                        if (mlat /= 0) then
                            i = imid
                            do k=1, nt
                                do np1=mp1, ndo1, 2
                                    br(mp1, np1, k)=br(mp1, np1, k)+wb(i, np1, iw)*we(i, 2*mp1-1, k)*wts(i)
                                    bi(mp1, np1, k)=bi(mp1, np1, k)-wb(i, np1, iw)*we(i, 2*mp1-2, k)*wts(i)
                                    cr(mp1, np1, k)=cr(mp1, np1, k)+wb(i, np1, iw)*ve(i, 2*mp1-1, k)*wts(i)
                                    ci(mp1, np1, k)=ci(mp1, np1, k)-wb(i, np1, iw)*ve(i, 2*mp1-2, k)*wts(i)
                                end do
                            end do
                        end if
                    end if

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                            tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                            tve1 = ve(i, 2*mp1-1, k)*wts(i)
                            tve2 = ve(i, 2*mp1-2, k)*wts(i)
                            two1 = wo(i, 2*mp1-1, k)*wts(i)
                            two2 = wo(i, 2*mp1-2, k)*wts(i)
                            twe1 = we(i, 2*mp1-1, k)*wts(i)
                            twe2 = we(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tve2 &
                                    +wb(i, np1, iw)*two1
                                bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tve1 &
                                    -wb(i, np1, iw)*two2
                                cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*twe2 &
                                    +wb(i, np1, iw)*tvo1
                                ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*twe1 &
                                    -wb(i, np1, iw)*tvo2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp2, ndo2, 2
                            br(mp1, np1, k)=br(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-2, k)*wts(i)
                            bi(mp1, np1, k)=bi(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-1, k)*wts(i)
                            cr(mp1, np1, k)=cr(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-2, k)*wts(i)
                            ci(mp1, np1, k)=ci(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do
            case(1)
                !
                ! case ityp=1 ,  no symmetries but cr and ci equal zero
                !
                call sphere_aux%compute_polar_component(0, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imid
                        tv = ve(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                        end do
                    end do
                end do

                do k=1, nt
                    do i=1, imm1
                        tv = vo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(0, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(0, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 <= ndo1) then
                        do k=1, nt
                            do i=1, imm1
                                tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                                tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                                twe1 = we(i, 2*mp1-1, k)*wts(i)
                                twe2 = we(i, 2*mp1-2, k)*wts(i)
                                do np1=mp1, ndo1, 2
                                    br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tvo2 &
                                        +wb(i, np1, iw)*twe1
                                    bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tvo1 &
                                        -wb(i, np1, iw)*twe2
                                end do
                            end do
                        end do
                        if (mlat /= 0) then
                            i = imid
                            do k=1, nt
                                do np1=mp1, ndo1, 2
                                    br(mp1, np1, k) = br(mp1, np1, k)+wb(i, np1, iw)*we(i, 2*mp1-1, k)*wts(i)
                                    bi(mp1, np1, k) = bi(mp1, np1, k)-wb(i, np1, iw)*we(i, 2*mp1-2, k)*wts(i)
                                end do
                            end do
                        end if
                    end if

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            tve1 = ve(i, 2*mp1-1, k)*wts(i)
                            tve2 = ve(i, 2*mp1-2, k)*wts(i)
                            two1 = wo(i, 2*mp1-1, k)*wts(i)
                            two2 = wo(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tve2 &
                                    +wb(i, np1, iw)*two1
                                bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tve1 &
                                    -wb(i, np1, iw)*two2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp2, ndo2, 2
                            br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-2, k)*wts(i)
                            bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do

            case(2)
                !
                ! case ityp=2 ,  no symmetries but br and bi equal zero
                !
                call sphere_aux%compute_polar_component(0, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imid
                        tw = we(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do

                do k=1, nt
                    do i=1, imm1
                        tw = wo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(0, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(0, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 <= ndo1) then
                        do k=1, nt
                            do i=1, imm1
                                tve1 = ve(i, 2*mp1-1, k)*wts(i)
                                tve2 = ve(i, 2*mp1-2, k)*wts(i)
                                two1 = wo(i, 2*mp1-1, k)*wts(i)
                                two2 = wo(i, 2*mp1-2, k)*wts(i)
                                do np1=mp1, ndo1, 2
                                    cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*two2 &
                                        +wb(i, np1, iw)*tve1
                                    ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*two1 &
                                        -wb(i, np1, iw)*tve2
                                end do
                            end do
                        end do
                        if (mlat /= 0) then
                            i = imid
                            do k=1, nt
                                do np1=mp1, ndo1, 2
                                    cr(mp1, np1, k) = cr(mp1, np1, k)+wb(i, np1, iw)*ve(i, 2*mp1-1, k)*wts(i)
                                    ci(mp1, np1, k) = ci(mp1, np1, k)-wb(i, np1, iw)*ve(i, 2*mp1-2, k)*wts(i)
                                end do
                            end do
                        end if
                    end if

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            twe1 = we(i, 2*mp1-1, k)*wts(i)
                            twe2 = we(i, 2*mp1-2, k)*wts(i)
                            tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                            tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*twe2 &
                                    +wb(i, np1, iw)*tvo1
                                ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*twe1 &
                                    -wb(i, np1, iw)*tvo2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp2, ndo2, 2
                            cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-2, k)*wts(i)
                            ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do

            case(3)
                !
                ! case ityp=3 ,  v even , w odd
                !
                call sphere_aux%compute_polar_component(0, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imid
                        tv = ve(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                        end do
                    end do
                end do

                do k=1, nt
                    do i=1, imm1
                        tw = wo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(0, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(0, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 <= ndo1) then
                        do k=1, nt
                            do i=1, imm1
                                two1 = wo(i, 2*mp1-1, k)*wts(i)
                                two2 = wo(i, 2*mp1-2, k)*wts(i)
                                tve1 = ve(i, 2*mp1-1, k)*wts(i)
                                tve2 = ve(i, 2*mp1-2, k)*wts(i)
                                do np1=mp1, ndo1, 2
                                    cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*two2 &
                                        +wb(i, np1, iw)*tve1
                                    ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*two1 &
                                        -wb(i, np1, iw)*tve2
                                end do
                            end do
                        end do
                        if (mlat /= 0) then
                            i = imid
                            do k=1, nt
                                do np1=mp1, ndo1, 2
                                    cr(mp1, np1, k) = cr(mp1, np1, k)+wb(i, np1, iw)*ve(i, 2*mp1-1, k)*wts(i)
                                    ci(mp1, np1, k) = ci(mp1, np1, k)-wb(i, np1, iw)*ve(i, 2*mp1-2, k)*wts(i)
                                end do
                            end do
                        end if
                    end if

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            two1 = wo(i, 2*mp1-1, k)*wts(i)
                            two2 = wo(i, 2*mp1-2, k)*wts(i)
                            tve1 = ve(i, 2*mp1-1, k)*wts(i)
                            tve2 = ve(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tve2 &
                                    +wb(i, np1, iw)*two1
                                bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tve1 &
                                    -wb(i, np1, iw)*two2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp2, ndo2, 2
                            br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-2, k)*wts(i)
                            bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do

            case(4)
                !
                ! case ityp=4 ,  v even, w odd, and cr and ci equal 0.
                !
                call sphere_aux%compute_polar_component(1, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imid
                        tv = ve(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(1, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(1, nlat, nlon, m, wb, iw, wwbin)

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            two1 = wo(i, 2*mp1-1, k)*wts(i)
                            two2 = wo(i, 2*mp1-2, k)*wts(i)
                            tve1 = ve(i, 2*mp1-1, k)*wts(i)
                            tve2 = ve(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tve2 &
                                    +wb(i, np1, iw)*two1
                                bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tve1 &
                                    -wb(i, np1, iw)*two2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp2, ndo2, 2
                            br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-2, k)*wts(i)
                            bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*ve(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do

            case(5)
                !
                ! case ityp=5   v even, w odd, and br and bi equal zero
                !
                call sphere_aux%compute_polar_component(2, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imm1
                        tw = wo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(2, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(2, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 > ndo1) return

                    do k=1, nt
                        do i=1, imm1
                            two1 = wo(i, 2*mp1-1, k)*wts(i)
                            two2 = wo(i, 2*mp1-2, k)*wts(i)
                            tve1 = ve(i, 2*mp1-1, k)*wts(i)
                            tve2 = ve(i, 2*mp1-2, k)*wts(i)
                            do np1=mp1, ndo1, 2
                                cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*two2 &
                                    +wb(i, np1, iw)*tve1
                                ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*two1 &
                                    -wb(i, np1, iw)*tve2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp1, ndo1, 2
                            cr(mp1, np1, k) = cr(mp1, np1, k)+wb(i, np1, iw)*ve(i, 2*mp1-1, k)*wts(i)
                            ci(mp1, np1, k) = ci(mp1, np1, k)-wb(i, np1, iw)*ve(i, 2*mp1-2, k)*wts(i)
                        end do
                    end do
                end do

            case(6)
                !
                ! case ityp=6 ,  v odd , w even
                !
                call sphere_aux%compute_polar_component(0, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imid
                        tw = we(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do

                do k=1, nt
                    do i=1, imm1
                        tv = vo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax
                    m = mp1-1
                    mp2 = mp1+1
                    call sphere_aux%compute_polar_component(0, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(0, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 <= ndo1) then
                        do k=1, nt
                            do i=1, imm1
                                twe1 = we(i, 2*mp1-1, k)*wts(i)
                                twe2 = we(i, 2*mp1-2, k)*wts(i)
                                tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                                tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                                do np1=mp1, ndo1, 2
                                    br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tvo2 &
                                        +wb(i, np1, iw)*twe1
                                    bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tvo1 &
                                        -wb(i, np1, iw)*twe2
                                end do
                            end do
                        end do
                        if (mlat /= 0) then
                            i = imid
                            do k=1, nt
                                do np1=mp1, ndo1, 2
                                    br(mp1, np1, k) = br(mp1, np1, k)+wb(i, np1, iw)*we(i, 2*mp1-1, k)*wts(i)
                                    bi(mp1, np1, k) = bi(mp1, np1, k)-wb(i, np1, iw)*we(i, 2*mp1-2, k)*wts(i)
                                end do
                            end do
                        end if
                    end if

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            twe1 = we(i, 2*mp1-1, k)*wts(i)
                            twe2 = we(i, 2*mp1-2, k)*wts(i)
                            tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                            tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*twe2 &
                                    +wb(i, np1, iw)*tvo1
                                ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*twe1 &
                                    -wb(i, np1, iw)*tvo2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp2, ndo2, 2
                            cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-2, k)*wts(i)
                            ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do

            case(7)
                !
                ! case ityp=7   v odd, w even, and cr and ci equal zero
                !
                call sphere_aux%compute_polar_component(2, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imm1
                        tv = vo(i, 1, k)*wts(i)
                        do np1=3, ndo1, 2
                            br(1, np1, k) = br(1, np1, k)+vb(i, np1, iv)*tv
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return

                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(2, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(2, nlat, nlon, m, wb, iw, wwbin)

                    if (mp1 > ndo1) return

                    do k=1, nt
                        do i=1, imm1
                            twe1 = we(i, 2*mp1-1, k)*wts(i)
                            twe2 = we(i, 2*mp1-2, k)*wts(i)
                            tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                            tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                            do np1=mp1, ndo1, 2
                                br(mp1, np1, k) = br(mp1, np1, k)+vb(i, np1, iv)*tvo2 &
                                    +wb(i, np1, iw)*twe1
                                bi(mp1, np1, k) = bi(mp1, np1, k)+vb(i, np1, iv)*tvo1 &
                                    -wb(i, np1, iw)*twe2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do np1=mp1, ndo1, 2
                            br(mp1, np1, k) = br(mp1, np1, k)+wb(i, np1, iw)*we(i, 2*mp1-1, k)*wts(i)
                            bi(mp1, np1, k) = bi(mp1, np1, k)-wb(i, np1, iw)*we(i, 2*mp1-2, k)*wts(i)
                        end do
                    end do
                end do

            case(8)
                !
                ! case ityp=8   v odd, w even, and both br and bi equal zero
                !
                call sphere_aux%compute_polar_component(1, nlat, nlon, 0, vb, iv, wvbin)
                !
                ! case m=0
                !
                do k=1, nt
                    do i=1, imid
                        tw = we(i, 1, k)*wts(i)
                        do np1=2, ndo2, 2
                            cr(1, np1, k) = cr(1, np1, k)-vb(i, np1, iv)*tw
                        end do
                    end do
                end do
                !
                ! case m = 1 through nlat-1
                !
                if (mmax < 2) return
                do mp1=2, mmax

                    m = mp1-1
                    mp2 = mp1+1

                    call sphere_aux%compute_polar_component(1, nlat, nlon, m, vb, iv, wvbin)
                    call sphere_aux%compute_azimuthal_component(1, nlat, nlon, m, wb, iw, wwbin)

                    if (mp2 > ndo2) return

                    do k=1, nt
                        do i=1, imm1
                            twe1 = we(i, 2*mp1-1, k)*wts(i)
                            twe2 = we(i, 2*mp1-2, k)*wts(i)
                            tvo1 = vo(i, 2*mp1-1, k)*wts(i)
                            tvo2 = vo(i, 2*mp1-2, k)*wts(i)
                            do np1=mp2, ndo2, 2
                                cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*twe2 &
                                    +wb(i, np1, iw)*tvo1
                                ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*twe1 &
                                    -wb(i, np1, iw)*tvo2
                            end do
                        end do
                    end do

                    if (mlat == 0) return

                    i = imid

                    do k=1, nt
                        do  np1=mp2, ndo2, 2
                            cr(mp1, np1, k) = cr(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-2, k)*wts(i)
                            ci(mp1, np1, k) = ci(mp1, np1, k)-vb(i, np1, iv)*we(i, 2*mp1-1, k)*wts(i)
                        end do
                    end do
                end do
        end select vector_symmetry_cases


    end subroutine vhagc_lower_routine

    ! Purpose:
    !
    ! Set first imid =(nlat+1)/2 of real weights in dwts
    ! as single precision in wts.
    !
    subroutine copy_gaussian_weights(imid, dwts, wts)

        ! Dummy arguments
        integer(ip), intent(in)  :: imid
        real(wp),    intent(in)  :: dwts(imid)
        real(wp),    intent(out) :: wts(imid)

        wts(1:imid) = dwts(1:imid)

    end subroutine copy_gaussian_weights

end submodule vector_analysis_gaussian_grid
