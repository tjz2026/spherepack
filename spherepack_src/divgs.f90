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
! ... file divgs.f
!
!     this file includes documentation and code for
!     subroutine divgs          i
!
! ... files which must be loaded with divgs.f
!
!     sphcom.f, hrfft.f, vhags.f, shsgs.f, gaqd.f
!
!
!     subroutine divgs(nlat, nlon, isym, nt, divg, idiv, jdiv, br, bi, mdb, ndb, 
!    +                 wshsgs, lshsgs, work, lwork, ierror)
!
!     given the vector spherical harmonic coefficients br and bi, precomputed
!     by subroutine vhags for a vector field (v, w), subroutine divgs
!     computes the divergence of the vector field in the scalar array divg.
!     divg(i, j) is the divergence at the gaussian colatitude point theta(i)
!     (see nlat as input parameter) and east longitude
!
!            lambda(j) = (j-1)*2*pi/nlon
!
!     on the sphere.  i.e.
!
!            dv(i, j) = 1/sint*[ d(sint*v(i, j))/dtheta + d(w(i, j))/dlambda ]
!
!     where sint = sin(theta(i)).  w is the east longitudinal and v
!     is the colatitudinal component of the vector field from which
!     br, bi were precomputed
!
!
!     input parameters
!
!     nlat   the number of points in the gaussian colatitude grid on the
!            full sphere. these lie in the interval (0, pi) and are computed
!            in radians in theta(1) <...< theta(nlat) by subroutine gaqd.
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
!
!     isym   a parameter which determines whether the divergence is
!            computed on the full or half sphere as follows:
!
!      = 0
!
!            the symmetries/antsymmetries described in isym=1, 2 below
!            do not exist in (v, w) about the equator.  in this case the
!            divergence is neither symmetric nor antisymmetric about
!            the equator.  the divergence is computed on the entire
!            sphere.  i.e., in the array divg(i, j) for i=1, ..., nlat and
!            j=1, ..., nlon.
!
!      = 1
!
!            w is antisymmetric and v is symmetric about the equator.
!            in this case the divergence is antisymmetyric about
!            the equator and is computed for the northern hemisphere
!            only.  i.e., if nlat is odd the divergence is computed
!            in the array divg(i, j) for i=1, ..., (nlat+1)/2 and for
!            j=1, ..., nlon.  if nlat is even the divergence is computed
!            in the array divg(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!      = 2
!            w is symmetric and v is antisymmetric about the equator
!            in this case the divergence is symmetyric about the
!            equator and is computed for the northern hemisphere
!            only.  i.e., if nlat is odd the divergence is computed
!            in the array divg(i, j) for i=1, ..., (nlat+1)/2 and for
!            j=1, ..., nlon.  if nlat is even the divergence is computed
!            in the array divg(i, j) for i=1, ..., nlat/2 and j=1, ..., nlon.
!
!
!     nt     nt is the number of scalar and vector fields.  some
!            computational efficiency is obtained for multiple fields.
!            in the program that calls divgs, the arrays br, bi, and divg
!            can be three dimensional corresponding to an indexed multiple
!            vector field.  in this case multiple scalar synthesis will
!            be performed to compute the divergence for each field.  the
!            third index is the synthesis index which assumes the values
!            k=1, ..., nt.  for a single synthesis set nt = 1.  the
!            description of the remaining parameters is simplified by
!            assuming that nt=1 or that all the arrays are two dimensional.
!
!     idiv   the first dimension of the array divg as it appears in
!            the program that calls divgs. if isym = 0 then idiv
!            must be at least nlat.  if isym = 1 or 2 and nlat is
!            even then idiv must be at least nlat/2. if isym = 1 or 2
!            and nlat is odd then idiv must be at least (nlat+1)/2.
!
!     jdiv   the second dimension of the array divg as it appears in
!            the program that calls divgs. jdiv must be at least nlon.
!
!     br, bi  two or three dimensional arrays (see input parameter nt)
!            that contain vector spherical harmonic coefficients
!            of the vector field (v, w) as computed by subroutine vhags.
!     ***    br and bi must be computed by vhags prior to calling
!            divgs.
!
!     mdb    the first dimension of the arrays br and bi as it
!            appears in the program that calls divgs. mdb must be at
!            least min(nlat, nlon/2) if nlon is even or at least
!            min(nlat, (nlon+1)/2) if nlon is odd.
!
!     ndb    the second dimension of the arrays br and bi as it
!            appears in the program that calls divgs. ndb must be at
!            least nlat.
!
!
!     wshsgs an array which must be intialized by subroutine shsgsi.
!            once initialized, 
!            wshsgs can be used repeatedly by divgs as long as nlon
!            and nlat remain unchanged.  wshsgs must not be altered
!            between calls of divgs.
!
!
!     lshsgs the dimension of the array wshsgs as it appears in the
!            program that calls divgs. define
!
!               l1 = min(nlat, (nlon+2)/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2        if nlat is even or
!               l2 = (nlat+1)/2    if nlat is odd
!
!            then lshsgs must be at least
!
!               nlat*(3*(l1+l2)-2)+(l1-1)*(l2*(2*nlat-l1)-3*l1)/2+nlon+15
!
!
!     work   a work array that does not have to be saved.
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls divgs. define
!
!               l1 = min(nlat, (nlon+2)/2) if nlon is even or
!               l1 = min(nlat, (nlon+1)/2) if nlon is odd
!
!            and
!
!               l2 = nlat/2                    if nlat is even or
!               l2 = (nlat+1)/2                if nlat is odd
!
!            if isym = 0 then lwork must be at least
!
!               nlat*((nt+1)*nlon+2*nt*l1+1)
!
!            if isym > 0 then lwork must be at least
!
!               (nt+1)*l2*nlon+nlat*(2*nt*l1+1)
!
!     **************************************************************
!
!     output parameters
!
!
!    divg   a two or three dimensional array (see input parameter nt)
!           that contains the divergence of the vector field (v, w)
!           whose coefficients br, bi where computed by subroutine
!           vhags.  divg(i, j) is the divergence at the gaussian colatitude
!           point theta(i) and longitude point lambda(j) = (j-1)*2*pi/nlon.
!           the index ranges are defined above at the input parameter
!           isym.
!
!
!    ierror = 0  no errors
!           = 1  error in the specification of nlat
!           = 2  error in the specification of nlon
!           = 3  error in the specification of isym
!           = 4  error in the specification of nt
!           = 5  error in the specification of idiv
!           = 6  error in the specification of jdiv
!           = 7  error in the specification of mdb
!           = 8  error in the specification of ndb
!           = 9  error in the specification of lshsgs
!           = 10 error in the specification of lwork
! **********************************************************************
!                                                                              
!   
subroutine divgs(nlat, nlon, isym, nt, divg, idiv, jdiv, br, bi, mdb, ndb, &
    wshsgs, lshsgs, work, lwork, ierror)

    dimension divg(idiv, jdiv, nt), br(mdb, ndb, nt), bi(mdb, ndb, nt)
    dimension wshsgs(lshsgs), work(lwork)
    !
    !     check input parameters
    !
    ierror = 1
    if (nlat < 3) return
    ierror = 2
    if (nlon < 4) return
    ierror = 3
    if (isym < 0 .or. isym > 2) return
    ierror = 4
    if (nt < 0) return
    ierror = 5
    imid = (nlat+1)/2
    if ((isym == 0 .and. idiv<nlat) .or. &
        (isym>0 .and. idiv<imid)) return
    ierror = 6
    if (jdiv < nlon) return
    ierror = 7
    if (mdb < min(nlat, (nlon+1)/2)) return
    mmax = min(nlat, (nlon+2)/2)
    ierror = 8
    if (ndb < nlat) return
    ierror = 9
    imid = (nlat+1)/2
    lpimn = (imid*mmax*(nlat+nlat-mmax+1))/2
    !     check permanent work space length
    l2 = (nlat+1)/2
    l1 = min((nlon+2)/2, nlat)
    lp=nlat*(3*(l1+l2)-2)+(l1-1)*(l2*(2*nlat-l1)-3*l1)/2+nlon+15
    if (lshsgs < lp) return
    ierror = 10
    !
    !     verify unsaved work space (add to what shses requires, file f3)
    !
    ls = nlat
    if (isym > 0) ls = imid
    nln = nt*ls*nlon
    !
    !     set first dimension for a, b (as requried by shses)
    !
    mab = min(nlat, nlon/2+1)
    mn = mab*nlat*nt
    if (lwork < nln+ls*nlon+2*mn+nlat) return
    ierror = 0
    !
    !     set work space pointers
    !
    ia = 1
    ib = ia+mn
    is = ib+mn
    iwk = is+nlat
    lwk = lwork-2*mn-nlat

    call divgs1(nlat, nlon, isym, nt, divg, idiv, jdiv, br, bi, mdb, ndb, &
        work(ia), work(ib), mab, work(is), wshsgs, lshsgs, work(iwk), lwk, &
        ierror)

end subroutine divgs



subroutine divgs1(nlat, nlon, isym, nt, divg, idiv, jdiv, br, bi, mdb, ndb, &
    a, b, mab, sqnn, wshsgs, lshsgs, wk, lwk, ierror)
    dimension divg(idiv, jdiv, nt), br(mdb, ndb, nt), bi(mdb, ndb, nt)
    dimension a(mab, nlat, nt), b(mab, nlat, nt), sqnn(nlat)
    dimension wshsgs(lshsgs), wk(lwk)
    !
    !     set coefficient multiplyers
    !
    do  n=2, nlat
        fn = real(n - 1)
        sqnn(n) = sqrt(fn * (fn + 1.0))
    end do
    !
    !     compute divergence scalar coefficients for each vector field
    !
    do  k=1, nt
        do  n=1, nlat
            do  m=1, mab
                a(m, n, k) = 0.0
                b(m, n, k) = 0.0
            end do
        end do
        !
        !     compute m=0 coefficients
        !
        do  n=2, nlat
            a(1, n, k) = -sqnn(n)*br(1, n, k)
            b(1, n, k) = -sqnn(n)*bi(1, n, k)
        end do
        !
        !     compute m>0 coefficients using vector spherepack value for mmax
        !
        mmax = min(nlat, (nlon+1)/2)
        do  m=2, mmax
            do  n=m, nlat
                a(m, n, k) = -sqnn(n)*br(m, n, k)
                b(m, n, k) = -sqnn(n)*bi(m, n, k)
            end do
        end do
    end do
    !
    !     synthesize a, b into divg
    !
    call shsgs(nlat, nlon, isym, nt, divg, idiv, jdiv, a, b, &
        mab, nlat, wshsgs, lshsgs, wk, lwk, ierror)

end subroutine divgs1
