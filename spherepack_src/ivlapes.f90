!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 1998 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                      SPHEREPACK version 3.2                   *
!     *                                                               *
!     *       A Package of Fortran77 Subroutines and Programs         *
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
!
! ... file ivlapes.f
!
!     this file includes documentation and code for
!     subroutine ivlapes
!
! ... files which must be loaded with ivlapes.f
!
!     sphcom.f, hrfft.f, vhaes.f, vhses.f
!
!
!
!     subroutine ivlapes(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, 
!    +mdbc, ndbc, wvhses, lvhses, work, lwork, ierror)
!
!
!     subroutine ivlapes computes a the vector field (v, w) whose vector
!     laplacian is (vlap, wlap).  w and wlap are east longitudinal
!     components of the vectors.  v and vlap are colatitudinal components
!     of the vectors.  br, bi, cr, and ci are the vector harmonic coefficients
!     of (vlap, wlap).  these must be precomputed by vhaes and are input
!     parameters to ivlapes.  (v, w) have the same symmetry or lack of
!     symmetry about the about the equator as (vlap, wlap).  the input
!     parameters ityp, nt, mdbc, ndbc must have the same values used by
!     vhaes to compute br, bi, cr, and ci for (vlap, wlap).
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
!            vhaes to compute the coefficients br, bi, cr, and ci for the
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
!            that calls ivlapes, the arrays v, w, br, bi, cr and ci can be
!            three dimensional corresponding to an indexed multiple vector
!            field.  in this case multiple vector synthesis will be performed
!            to compute the (v, w) for each field (vlap, wlap).  the third
!            index is the synthesis index which assumes the values k=1, ..., nt.
!            for a single synthesis set nt=1.  the description of the
!            remaining parameters is simplified by assuming that nt=1 or
!            that all arrays are two dimensional.
!
!   idvw     the first dimension of the arrays w and v as it appears in
!            the program that calls ivlapes.  if ityp=0, 1, or 2  then idvw
!            must be at least nlat.  if ityp > 2 and nlat is even then idvw
!            must be at least nlat/2. if ityp > 2 and nlat is odd then idvw
!            must be at least (nlat+1)/2.
!
!   jdvw     the second dimension of the arrays w and v as it appears in
!            the program that calls ivlapes. jdvw must be at least nlon.
!
!
!   br, bi    two or three dimensional arrays (see input parameter nt)
!   cr, ci    that contain vector spherical harmonic coefficients of the
!            vector field (vlap, wlap) as computed by subroutine vhaes.
!            br, bi, cr and ci must be computed by vhaes prior to calling
!            ivlapes.  if ityp=1, 4, or 7 then cr, ci are not used and can
!            be dummy arguments.  if ityp=2, 5, or 8 then br, bi are not
!            used and can be dummy arguments.
!
!    mdbc    the first dimension of the arrays br, bi, cr and ci as it
!            appears in the program that calls ivlapes.  mdbc must be
!            at least min(nlat, nlon/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!    ndbc    the second dimension of the arrays br, bi, cr and ci as it
!            appears in the program that calls ivlapes. ndbc must be at
!            least nlat.
!
!    wvhses  an array which must be initialized by subroutine vhsesi.
!            once initialized, wvhses
!            can be used repeatedly by ivlapes as long as nlat and nlon
!            remain unchanged.  wvhses must not be altered between calls
!            of ivlapes.
!
!    lvhses  the dimension of the array wvhses as it appears in the
!            program that calls ivlapes.  let
!
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd.
!
!            let
!
!               lsavmin = (l1*l2*(nlat+nlat-l1+1))/2+nlon+15
!
!            then lvhses must be greater than or equal to lsavmin
!            (see ierror=9 below).
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls ivlapes. define
!
!               l2 = nlat/2                    if nlat is even or
!               l2 = (nlat+1)/2                if nlat is odd
!               l1 = min(nlat, nlon/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            if ityp .le. 2 then
!
!               (2*nt+1)*nlat*nlon + nlat*(4*nt*l1+1)
!
!            or if ityp .gt. 2 then
!
!               (2*nt+1)*l2*nlon + nlat*(4*nt*l1+1)
!
!            will suffice as a length for lwork.
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
!            let d( )/dlambda  and d( )/dtheta be the first order partial
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
!            = 9  error in the specification of lvhses
!
!            = 10 error in the specification of lwork
!
!
! **********************************************************************
!                                                                              
!     end of documentation for ivlapes
!
! **********************************************************************
!
subroutine ivlapes(nlat, nlon, ityp, nt, v, w, idvw, jdvw, br, bi, cr, ci, &
    mdbc, ndbc, wvhses, lvhses, work, lwork, ierror)
    dimension v(idvw, jdvw, nt), w(idvw, jdvw, nt)
    dimension br(mdbc, ndbc, nt), bi(mdbc, ndbc, nt)
    dimension cr(mdbc, ndbc, nt), ci(mdbc, ndbc, nt)
    dimension wvhses(lvhses), work(lwork)
    ierror = 1
    if(nlat < 3) return
    ierror = 2
    if(nlon < 1) return
    ierror = 3
    if(ityp<0 .or. ityp>8) return
    ierror = 4
    if(nt < 0) return
    ierror = 5
    imid = (nlat+1)/2
    if((ityp<=2 .and. idvw<nlat) .or. &
        (ityp>2 .and. idvw<imid)) return
    ierror = 6
    if(jdvw < nlon) return
    ierror = 7
    mmax = min(nlat, (nlon+1)/2)
    if(mdbc < mmax) return
    ierror = 8
    if(ndbc < nlat) return
    ierror = 9
    !
    !     set minimum and verify saved workspace length
    !
    idz = (mmax*(nlat+nlat-mmax+1))/2
    lzimn = idz*imid
    lsavmin = lzimn+lzimn+nlon+15
    if (lvhses < lsavmin) return
    !
    !     set minimum and verify unsaved work space length
    !
    mn = mmax*nlat*nt
    l2 = (nlat+1)/2
    l1 = min(nlat, (nlon+1)/2)
    if (ityp <= 2) then
        lwkmin = (2*nt+1)*nlat*nlon + nlat*(4*nt*l1+1)
    else
        lwkmin = (2*nt+1)*l2*nlon + nlat*(4*nt*l1+1)
    end if
    if (lwork < lwkmin) return
    ierror = 0
    !
    !     set work space pointers for vector laplacian coefficients
    !
    select case (ityp)
        case (0)
            ibr = 1
            ibi = ibr+mn
            icr = ibi+mn
            ici = icr+mn
        case (3)
            ibr = 1
            ibi = ibr+mn
            icr = ibi+mn
            ici = icr+mn
        case (6)
            ibr = 1
            ibi = ibr+mn
            icr = ibi+mn
            ici = icr+mn
        case (1)
            ibr = 1
            ibi = ibr+mn
            icr = ibi+mn
            ici = icr
        case (4)
            ibr = 1
            ibi = ibr+mn
            icr = ibi+mn
            ici = icr
        case (7)
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

    call ivlapes1(nlat, nlon, ityp, nt, v, w, idvw, jdvw, work(ibr), &
        work(ibi), work(icr), work(ici), mmax, work(ifn), mdbc, ndbc, br, bi, &
        cr, ci, wvhses, lvhses, work(iwk), liwk, ierror)

end subroutine ivlapes



subroutine ivlapes1(nlat, nlon, ityp, nt, v, w, idvw, jdvw, brvw, &
    bivw, crvw, civw, mmax, fnn, mdbc, ndbc, br, bi, cr, ci, wsave, lsave, &
    wk, lwk, ierror)
    dimension v(idvw, jdvw, nt), w(idvw, jdvw, nt)
    dimension fnn(nlat), brvw(mmax, nlat, nt), bivw(mmax, nlat, nt)
    dimension crvw(mmax, nlat, nt), civw(mmax, nlat, nt)
    dimension br(mdbc, ndbc, nt), bi(mdbc, ndbc, nt)
    dimension cr(mdbc, ndbc, nt), ci(mdbc, ndbc, nt)
    dimension wsave(lsave), wk(lwk)
    !
    !     preset coefficient multiplyers
    !
    do n=2, nlat
        fn = real(n-1)
        fnn(n) = -1.0/(fn*(fn + 1.0))
    end do
    !
    !     set (u, v) coefficients from br, bi, cr, ci
    !
    select case (ityp)
        case (0)
            !
            !     all coefficients needed
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        brvw(m, n, k) = 0.0
                        bivw(m, n, k) = 0.0
                        crvw(m, n, k) = 0.0
                        civw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    brvw(1, n, k) = fnn(n)*br(1, n, k)
                    bivw(1, n, k) = fnn(n)*bi(1, n, k)
                    crvw(1, n, k) = fnn(n)*cr(1, n, k)
                    civw(1, n, k) = fnn(n)*ci(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        brvw(m, n, k) = fnn(n)*br(m, n, k)
                        bivw(m, n, k) = fnn(n)*bi(m, n, k)
                        crvw(m, n, k) = fnn(n)*cr(m, n, k)
                        civw(m, n, k) = fnn(n)*ci(m, n, k)
                    end do
                end do
            end do
        case (3)
            !
            !     all coefficients needed
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        brvw(m, n, k) = 0.0
                        bivw(m, n, k) = 0.0
                        crvw(m, n, k) = 0.0
                        civw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    brvw(1, n, k) = fnn(n)*br(1, n, k)
                    bivw(1, n, k) = fnn(n)*bi(1, n, k)
                    crvw(1, n, k) = fnn(n)*cr(1, n, k)
                    civw(1, n, k) = fnn(n)*ci(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        brvw(m, n, k) = fnn(n)*br(m, n, k)
                        bivw(m, n, k) = fnn(n)*bi(m, n, k)
                        crvw(m, n, k) = fnn(n)*cr(m, n, k)
                        civw(m, n, k) = fnn(n)*ci(m, n, k)
                    end do
                end do
            end do
        case (6)
            !
            !     all coefficients needed
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        brvw(m, n, k) = 0.0
                        bivw(m, n, k) = 0.0
                        crvw(m, n, k) = 0.0
                        civw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    brvw(1, n, k) = fnn(n)*br(1, n, k)
                    bivw(1, n, k) = fnn(n)*bi(1, n, k)
                    crvw(1, n, k) = fnn(n)*cr(1, n, k)
                    civw(1, n, k) = fnn(n)*ci(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        brvw(m, n, k) = fnn(n)*br(m, n, k)
                        bivw(m, n, k) = fnn(n)*bi(m, n, k)
                        crvw(m, n, k) = fnn(n)*cr(m, n, k)
                        civw(m, n, k) = fnn(n)*ci(m, n, k)
                    end do
                end do
            end do
        case (1)
            !
            !     vorticity is zero so cr, ci=0 not used
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        brvw(m, n, k) = 0.0
                        bivw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    brvw(1, n, k) = fnn(n)*br(1, n, k)
                    bivw(1, n, k) = fnn(n)*bi(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        brvw(m, n, k) = fnn(n)*br(m, n, k)
                        bivw(m, n, k) = fnn(n)*bi(m, n, k)
                    end do
                end do
            end do
        case (4)
            !
            !     vorticity is zero so cr, ci=0 not used
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        brvw(m, n, k) = 0.0
                        bivw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    brvw(1, n, k) = fnn(n)*br(1, n, k)
                    bivw(1, n, k) = fnn(n)*bi(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        brvw(m, n, k) = fnn(n)*br(m, n, k)
                        bivw(m, n, k) = fnn(n)*bi(m, n, k)
                    end do
                end do
            end do
        case (7)
            !
            !     vorticity is zero so cr, ci=0 not used
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        brvw(m, n, k) = 0.0
                        bivw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    brvw(1, n, k) = fnn(n)*br(1, n, k)
                    bivw(1, n, k) = fnn(n)*bi(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        brvw(m, n, k) = fnn(n)*br(m, n, k)
                        bivw(m, n, k) = fnn(n)*bi(m, n, k)
                    end do
                end do
            end do
        case default
            !
            !     divergence is zero so br, bi=0 not used
            !
            do k=1, nt
                do n=1, nlat
                    do m=1, mmax
                        crvw(m, n, k) = 0.0
                        civw(m, n, k) = 0.0
                    end do
                end do
                do n=2, nlat
                    crvw(1, n, k) = fnn(n)*cr(1, n, k)
                    civw(1, n, k) = fnn(n)*ci(1, n, k)
                end do
                do m=2, mmax
                    do n=m, nlat
                        crvw(m, n, k) = fnn(n)*cr(m, n, k)
                        civw(m, n, k) = fnn(n)*ci(m, n, k)
                    end do
                end do
            end do
    end select
    !
    !     sythesize coefs into vector field (v, w)
    !
    call vhses(nlat, nlon, ityp, nt, v, w, idvw, jdvw, brvw, bivw, &
        crvw, civw, mmax, nlat, wsave, lsave, wk, lwk, ierror)

end subroutine ivlapes1
