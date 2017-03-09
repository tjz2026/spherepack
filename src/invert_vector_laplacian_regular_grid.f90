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
! ... file ivlapec.f
!
!     this file includes documentation and code for
!     subroutine ivlapec
!
! ... files which must be loaded with ivlapec.f
!
!     type_SpherepackUtility.f, type_RealPeriodicFastFourierTransform.f, vhaec.f, vhsec.f
!
!
!
!     subroutine ivlapec(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, 
!    +mdbc, ndbc, wvhsec, lvhsec, work, lwork, ierror)
!
!
!     subroutine ivlapec computes a the vector field (v, w) whose vector
!     laplacian is (vlap, wlap).  w and wlap are east longitudinal
!     components of the vectors.  v and vlap are colatitudinal components
!     of the vectors.  br, bi, cr, and ci are the vector harmonic coefficients
!     of (vlap, wlap).  these must be precomputed by vhaec and are input
!     parameters to ivlapec.  (v, w) have the same symmetry or lack of
!     symmetry about the about the equator as (vlap, wlap).  the input
!     parameters ityp, nt, mdbc, ndbc must have the same values used by
!     vhaec to compute br, bi, cr, and ci for (vlap, wlap).
!
!
!     input parameters
!
!     nlat   the number of colatitudes on the full sphere including the
!            poles. for example, nlat = 37 for a five degree grid.
!            nlat determines the grid increment in colatitude as
!            pi/(nlat-1).  if nlat is odd the equator is located at
!            grid point i=(nlat+1)/2. if nlat is even the equator is
!            located half way between points i=nlat/2 and i=nlat/2+1.
!            nlat must be at least 3. note: on the half sphere, the
!            number of grid points in the colatitudinal direction is
!            nlat/2 if nlat is even or (nlat+1)/2 if nlat is odd.
!
!     nlon   the number of distinct longitude points.  nlon determines
!            the grid increment in longitude as 2*pi/nlon. for example
!            nlon = 72 for a five degree grid. nlon must be greater
!            than zero. the axisymmetric case corresponds to nlon=1.
!            the efficiency of the computation is improved when nlon
!            is a product of small prime numbers.
!
!     ityp   this parameter should have the same value input to subroutine
!            vhaec to compute the coefficients br, bi, cr, and ci for the
!            vector field (vlap, wlap).  ityp is set as follows:
!
!            = 0  no symmetries exist in (vlap, wlap) about the equator. (v, w)
!                 is computed and stored on the entire sphere in the arrays
!                 arrays v(i, j) and w(i, j) for i=1, ..., nlat and j=1, ..., nlon.
!
!            = 1  no symmetries exist in (vlap, wlap) about the equator. (v, w)
!                 is computed and stored on the entire sphere in the arrays
!                 v(i, j) and w(i, j) for i=1, ..., nlat and j=1, ..., nlon.  the
!                 vorticity of (vlap, wlap) is zero so the coefficients cr and
!                 ci are zero and are not used.  the vorticity of (v, w) is
!                 also zero.
!
!
!            = 2  no symmetries exist in (vlap, wlap) about the equator. (v, w)
!                 is computed and stored on the entire sphere in the arrays
!                 w(i, j) and v(i, j) for i=1, ..., nlat and j=1, ..., nlon.  the
!                 divergence of (vlap, wlap) is zero so the coefficients br and
!                 bi are zero and are not used.  the divergence of (v, w) is
!                 also zero.
!
!            = 3  wlap is antisymmetric and vlap is symmetric about the
!                 equator. consequently w is antisymmetric and v is symmetric.
!                 (v, w) is computed and stored on the northern hemisphere
!                 only.  if nlat is odd, storage is in the arrays v(i, j), 
!                 w(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if nlat
!                 is even, storage is in the arrays v(i, j), w(i, j) for
!                 i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 4  wlap is antisymmetric and vlap is symmetric about the
!                 equator. consequently w is antisymmetric and v is symmetric.
!                 (v, w) is computed and stored on the northern hemisphere
!                 only.  if nlat is odd, storage is in the arrays v(i, j), 
!                 w(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if nlat
!                 is even, storage is in the arrays v(i, j), w(i, j) for
!                 i=1, ..., nlat/2 and j=1, ..., nlon.  the vorticity of (vlap, 
!                 wlap) is zero so the coefficients cr, ci are zero and
!                 are not used. the vorticity of (v, w) is also zero.
!
!            = 5  wlap is antisymmetric and vlap is symmetric about the
!                 equator. consequently w is antisymmetric and v is symmetric.
!                 (v, w) is computed and stored on the northern hemisphere
!                 only.  if nlat is odd, storage is in the arrays w(i, j), 
!                 v(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if nlat
!                 is even, storage is in the arrays w(i, j), v(i, j) for
!                 i=1, ..., nlat/2 and j=1, ..., nlon.  the divergence of (vlap, 
!                 wlap) is zero so the coefficients br, bi are zero and
!                 are not used. the divergence of (v, w) is also zero.
!
!
!            = 6  wlap is symmetric and vlap is antisymmetric about the
!                 equator. consequently w is symmetric and v is antisymmetric.
!                 (v, w) is computed and stored on the northern hemisphere
!                 only.  if nlat is odd, storage is in the arrays w(i, j), 
!                 v(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if nlat
!                 is even, storage is in the arrays w(i, j), v(i, j) for
!                 i=1, ..., nlat/2 and j=1, ..., nlon.
!
!            = 7  wlap is symmetric and vlap is antisymmetric about the
!                 equator. consequently w is symmetric and v is antisymmetric.
!                 (v, w) is computed and stored on the northern hemisphere
!                 only.  if nlat is odd, storage is in the arrays w(i, j), 
!                 v(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if nlat
!                 is even, storage is in the arrays w(i, j), v(i, j) for
!                 i=1, ..., nlat/2 and j=1, ..., nlon.  the vorticity of (vlap, 
!                 wlap) is zero so the coefficients cr, ci are zero and
!                 are not used. the vorticity of (v, w) is also zero.
!
!            = 8  wlap is symmetric and vlap is antisymmetric about the
!                 equator. consequently w is symmetric and v is antisymmetric.
!                 (v, w) is computed and stored on the northern hemisphere
!                 only.  if nlat is odd, storage is in the arrays w(i, j), 
!                 v(i, j) for i=1, ..., (nlat+1)/2 and j=1, ..., nlon.  if nlat
!                 is even, storage is in the arrays w(i, j), v(i, j) for
!                 i=1, ..., nlat/2 and j=1, ..., nlon.  the divergence of (vlap, 
!                 wlap) is zero so the coefficients br, bi are zero and
!                 are not used. the divergence of (v, w) is also zero.
!
!
!     nt     nt is the number of vector fields (vlap, wlap). some computational
!            efficiency is obtained for multiple fields.  in the program
!            that calls ivlapec, the arrays v, w, br, bi, cr and ci can be
!            three dimensional corresponding to an indexed multiple vector
!            field.  in this case multiple vector synthesis will be performed
!            to compute the (v, w) for each field (vlap, wlap).  the third
!            index is the synthesis index which assumes the values k=1, ..., nt.
!            for a single synthesis set nt=1.  the description of the
!            remaining parameters is simplified by assuming that nt=1 or
!            that all arrays are two dimensional.
!
!   idvw     the first dimension of the arrays w and v as it appears in
!            the program that calls ivlapec.  if ityp=0, 1, or 2  then idvw
!            must be at least nlat.  if ityp > 2 and nlat is even then idvw
!            must be at least nlat/2. if ityp > 2 and nlat is odd then idvw
!            must be at least (nlat+1)/2.
!
!   jdvw     the second dimension of the arrays w and v as it appears in
!            the program that calls ivlapec. jdvw must be at least nlon.
!
!
!   br, bi    two or three dimensional arrays (see input parameter nt)
!   cr, ci    that contain vector spherical harmonic coefficients of the
!            vector field (vlap, wlap) as computed by subroutine vhaec.
!            br, bi, cr and ci must be computed by vhaec prior to calling
!            ivlapec.  if ityp=1, 4, or 7 then cr, ci are not used and can
!            be dummy arguments.  if ityp=2, 5, or 8 then br, bi are not
!            used and can be dummy arguments.
!
!    mdbc    the first dimension of the arrays br, bi, cr and ci as it
!            appears in the program that calls ivlapec.  mdbc must be
!            at least min(nlat, nlon/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!    ndbc    the second dimension of the arrays br, bi, cr and ci as it
!            appears in the program that calls ivlapec. ndbc must be at
!            least nlat.
!
!    wvhsec  an array which must be initialized by subroutine vhseci.
!            once initialized, wvhsec
!            can be used repeatedly by ivlapec as long as nlat and nlon
!            remain unchanged.  wvhsec must not be altered between calls
!            of ivlapec.
!
!    lvhsec  the dimension of the array wvhsec as it appears in the
!            program that calls ivlapec.  let
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd.
!
!            then lvhsec must be at least
!
!            4*nlat*l2+3*max(l1-2, 0)*(2*nlat-l1-1)+nlon+15
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls ivlapec. define
!
!               l2 = nlat/2                    if nlat is even or
!               l2 = (nlat+1)/2                if nlat is odd
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            if ityp <= 2 then
!
!               nlat*(2*nt*nlon+max(6*l2, nlon)) + nlat*(4*nt*l1+1)
!
!            or if ityp > 2 let
!
!               l2*(2*nt*nlon+max(6*nlat, nlon)) + nlat*(4*nt*l1+1)
!
!            will suffice as a minimum length for lwork
!            (see ierror=10 below)
!
!     **************************************************************
!
!     output parameters
!
!
!    v, w     two or three dimensional arrays (see input parameter nt) that
!            contain a vector field whose vector laplacian is (vlap, wlap).
!            w(i, j) is the east longitude and v(i, j) is the colatitudinal
!            component of the vector. v(i, j) and w(i, j) are given on the
!            sphere at the colatitude
!
!                 theta(i) = (i-1)*pi/(nlat-1)
!
!            for i=1, ..., nlat and east longitude
!
!                 lambda(j) = (j-1)*2*pi/nlon
!
!            for j=1, ..., nlon.
!
!            let cost and sint be the cosine and sine at colatitude theta.
!            let d()/dlambda  and d()/dtheta be the first order partial
!            derivatives in longitude and colatitude.  let sf be either v
!            or w.  define:
!
!                 del2s(sf) = [d(sint*d(sf)/dtheta)/dtheta +
!                               2            2
!                              d (sf)/dlambda /sint]/sint
!
!            then the vector laplacian of (v, w) in (vlap, wlap) satisfies
!
!                 vlap = del2s(v) + (2*cost*dw/dlambda - v)/sint**2
!
!            and
!
!                 wlap = del2s(w) - (2*cost*dv/dlambda + w)/sint**2
!
!
!  ierror    a parameter which flags errors in input parameters as follows:
!
!            = 0  no errors detected
!
!            = 1  error in the specification of nlat
!
!            = 2  error in the specification of nlon
!
!            = 3  error in the specification of ityp
!
!            = 4  error in the specification of nt
!
!            = 5  error in the specification of idvw
!
!            = 6  error in the specification of jdvw
!
!            = 7  error in the specification of mdbc
!
!            = 8  error in the specification of ndbc
!
!            = 9  error in the specification of lvhsec
!
!            = 10 error in the specification of lwork
!
!
! **********************************************************************
!                                                                              
!     end of documentation for ivlapec
!
! **********************************************************************
!
submodule(vector_laplacian_routines) invert_vector_laplacian_regular_grid

contains

    module subroutine ivlapec(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, &
        mdbc, ndbc, wvhsec, lvhsec, work, lwork, ierror)

        ! Dummy arguments
        integer(ip), intent(in)  :: nlat
        integer(ip), intent(in)  :: nlon
        integer(ip), intent(in)  :: ityp
        integer(ip), intent(in)  :: nt
        real(wp),    intent(out) :: v(idvw, jdvw, nt)
        real(wp),    intent(out) :: w(idvw, jdvw, nt)
        integer(ip), intent(in)  :: idvw
        integer(ip), intent(in)  :: jdvw
        real(wp),    intent(in)  :: br(mdbc, ndbc, nt)
        real(wp),    intent(in)  :: bi(mdbc, ndbc, nt)
        real(wp),    intent(in)  :: cr(mdbc, ndbc, nt)
        real(wp),    intent(in)  :: ci(mdbc, ndbc, nt)
        integer(ip), intent(in)  :: mdbc
        integer(ip), intent(in)  :: ndbc
        real(wp),    intent(in)  :: wvhsec(lvhsec)
        integer(ip), intent(in)  :: lvhsec
        real(wp),    intent(out) :: work(lwork)
        integer(ip), intent(in)  :: lwork
        integer(ip), intent(out) :: ierror

        ! Local variables
        integer(ip) :: ibi
        integer(ip) :: ibr
        integer(ip) :: ici
        integer(ip) :: icr
        integer(ip) :: idz
        integer(ip) :: ifn
        integer(ip) :: imid
        integer(ip) :: iwk
        integer(ip) :: labc
        integer(ip) :: liwk
        integer(ip) :: lwkmin
        integer(ip) :: lzimn
        integer(ip) :: lzz1
        integer(ip) :: mmax
        integer(ip) :: mn

        ! Check calling arguments
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
        if (mdbc < mmax) return
        ierror = 8
        if (ndbc < nlat) return
        ierror = 9
        !
        !     set minimum and verify saved workspace length
        !
        idz = (mmax*(2*nlat-mmax+1))/2
        lzimn = idz*imid
        !     lsavmin = 2*lzimn+nlon+15
        !     if (lvhsec .lt. lsavmin) return
        lzz1 = 2*nlat*imid
        labc = 3*(max(mmax-2, 0)*(2*nlat-mmax-1))/2
        if (lvhsec < 2*(lzz1+labc)+nlon+15) return
        !
        !     set minimum and verify unsaved workspace length
        !
        ierror = 10
        mn = mmax*nlat*nt

        select case (ityp)
            case(0)
                !     no symmetry
                !       br, bi, cr, ci nonzero
                lwkmin = nlat*(2*nt*nlon+max(6*imid, nlon)+1)+4*mn
            case(1:2)
                !       br, bi or cr, ci zero
                lwkmin = nlat*(2*nt*nlon+max(6*imid, nlon)+1)+2*mn
            case(3, 6)
                !     symmetry
                !       br, bi, cr, ci nonzero
                lwkmin = imid*(2*nt*nlon+max(6*nlat, nlon))+4*mn+nlat
            case default
                !       br, bi or cr, ci zero
                lwkmin = imid*(2*nt*nlon+max(6*nlat, nlon))+2*mn+nlat
        end select

        if (lwork < lwkmin) return

        ierror = 0
        !
        ! Set workspace index pointers for vector laplacian coefficients
        !
        select case (ityp)
            case(0, 3, 6)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr+mn
            case(1, 4, 7)
                ibr = 1
                ibi = ibr+mn
                icr = ibi+mn
                ici = icr
            case default
                ibr = 1
                ibi = 1
                icr = ibi+mn
                ici = icr+mn
        end select

        ifn = ici + mn
        iwk = ifn + nlat

        select case (ityp)
            case (0, 3, 6)
                liwk = lwork-4*mn-nlat
            case default
                liwk = lwork-2*mn-nlat
        end select

        call ivlapec_lower_utility_routine(nlat, nlon, ityp, nt, v, w, idvw, jdvw, work(ibr), &
            work(ibi), work(icr), work(ici), mmax, work(ifn), mdbc, ndbc, br, bi, &
            cr, ci, wvhsec, lvhsec, work(iwk), liwk, ierror)

    end subroutine ivlapec

    subroutine ivlapec_lower_utility_routine(nlat, nlon, ityp, nt, v, w, idvw, jdvw, brvw, &
        bivw, crvw, civw, mmax, fnn, mdbc, ndbc, br, bi, cr, ci, wsave, lwsav, &
        wk, lwk, ierror)

        real(wp) :: bi
        real(wp) :: bivw
        real(wp) :: br
        real(wp) :: brvw
        real(wp) :: ci
        real(wp) :: civw
        real(wp) :: cr
        real(wp) :: crvw
        
        real(wp) :: fnn
        integer(ip) :: idvw
        integer(ip) :: ierror
        integer(ip) :: ityp
        integer(ip) :: jdvw
        
        integer(ip) :: lwk
        integer(ip) :: lwsav
        
        integer(ip) :: mdbc
        integer(ip) :: mmax
        
        integer(ip) :: ndbc
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: v
        real(wp) :: w
        real(wp) :: wk
        real(wp) :: wsave
        dimension v(idvw, jdvw, nt), w(idvw, jdvw, nt)
        dimension fnn(nlat), brvw(mmax, nlat, nt), bivw(mmax, nlat, nt)
        dimension crvw(mmax, nlat, nt), civw(mmax, nlat, nt)
        dimension br(mdbc, ndbc, nt), bi(mdbc, ndbc, nt)
        dimension cr(mdbc, ndbc, nt), ci(mdbc, ndbc, nt)
        dimension wsave(lwsav), wk(lwk)

        call perform_setup_for_inversion( &
            ityp,  br, bi, cr, ci, brvw, bivw, crvw, civw, fnn)

        ! Synthesize coefs into vector field (v, w)
        call vhsec(nlat, nlon, ityp, nt, v, w, idvw, jdvw, brvw, bivw, &
            crvw, civw, mmax, nlat, wsave, ierror)

    end subroutine ivlapec_lower_utility_routine

end submodule invert_vector_laplacian_regular_grid
