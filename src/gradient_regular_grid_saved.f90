!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 1998 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                         Spherepack                            *
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
submodule(gradient_routines) gradient_regular_grid_saved

contains

    !     subroutine grades(nlat, nlon, isym, nt, v, w, idvw, jdvw, a, b, mdab, ndab, &
    !                       wvhses, ierror)
    !
    !     given the scalar spherical harmonic coefficients a and b, precomputed
    !     by subroutine shaes for a scalar field sf, subroutine grades computes
    !     an irrotational vector field (v, w) such that
    !
    !           gradient(sf) = (v, w).
    !
    !     v is the colatitudinal and w is the east longitudinal component
    !     of the gradient.  i.e.,
    !
    !            v(i, j) = d(sf(i, j))/dtheta
    !
    !     and
    !
    !            w(i, j) = 1/sint*d(sf(i, j))/dlambda
    !
    !     at colatitude
    !
    !            theta(i) = (i-1)*pi/(nlat-1)
    !
    !     and longitude
    !
    !            lambda(j) = (j-1)*2*pi/nlon.
    !
    !     where sint = sin(theta(i)).  required associated legendre polynomials
    !     are stored rather than recomputed as they are in subroutine gradec
    !
    !
    !     input parameters
    !
    !
    !     nlat   the number of colatitudes on the full sphere including the
    !            poles. for example, nlat = 37 for a five degree grid.
    !            nlat determines the grid increment in colatitude as
    !            pi/(nlat-1).  if nlat is odd the equator is located at
    !            grid point i=(nlat + 1)/2. if nlat is even the equator is
    !            located half way between points i=nlat/2 and i=nlat/2+1.
    !            nlat must be at least 3. note: on the half sphere, the
    !            number of grid points in the colatitudinal direction is
    !            nlat/2 if nlat is even or (nlat + 1)/2 if nlat is odd.
    !
    !     nlon   the number of distinct londitude points.  nlon determines
    !            the grid increment in longitude as 2*pi/nlon. for example
    !            nlon = 72 for a five degree grid. nlon must be greater than
    !            3.  the efficiency of the computation is improved when nlon
    !            is a product of small prime numbers.
    !
    !
    !     isym   this has the same value as the isym that was input to
    !            subroutine shaes to compute the arrays a and b from the
    !            scalar field sf.  isym determines whether (v, w) are
    !            computed on the full or half sphere as follows:
    !
    !      = 0
    !
    !           sf is not symmetric about the equator. in this case
    !           the vector field (v, w) is computed on the entire sphere.
    !           i.e., in the arrays  v(i, j), w(i, j) for i=1, ..., nlat and
    !           j=1, ..., nlon.
    !
    !      = 1
    !
    !           sf is antisymmetric about the equator. in this case w is
    !           antisymmetric and v is symmetric about the equator. w
    !           and v are computed on the northern hemisphere only.  i.e.,
    !           if nlat is odd they are computed for i=1, ..., (nlat + 1)/2
    !           and j=1, ..., nlon.  if nlat is even they are computed for
    !           i=1, ..., nlat/2 and j=1, ..., nlon.
    !
    !      = 2
    !
    !           sf is symmetric about the equator. in this case w is
    !           symmetric and v is antisymmetric about the equator. w
    !           and v are computed on the northern hemisphere only.  i.e.,
    !           if nlat is odd they are computed for i=1, ..., (nlat + 1)/2
    !           and j=1, ..., nlon.  if nlat is even they are computed for
    !           i=1, ..., nlat/2 and j=1, ..., nlon.
    !
    !
    !     nt     nt is the number of scalar and vector fields.  some
    !            computational efficiency is obtained for multiple fields.
    !            the arrays a, b, v, and w can be three dimensional corresponding
    !            to an indexed multiple array sf.  in this case, multiple
    !            vector synthesis will be performed to compute each vector
    !            field.  the third index for a, b, v, and w is the synthesis
    !            index which assumes the values k = 1, ..., nt.  for a single
    !            synthesis set nt = 1.  the description of the remaining
    !            parameters is simplified by assuming that nt=1 or that a, b, v,
    !            and w are two dimensional arrays.
    !
    !     idvw   the first dimension of the arrays v, w as it appears in
    !            the program that calls grades. if isym = 0 then idvw
    !            must be at least nlat.  if isym = 1 or 2 and nlat is
    !            even then idvw must be at least nlat/2. if isym = 1 or 2
    !            and nlat is odd then idvw must be at least (nlat + 1)/2.
    !
    !     jdvw   the second dimension of the arrays v, w as it appears in
    !            the program that calls grades. jdvw must be at least nlon.
    !
    !     a, b    two or three dimensional arrays (see input parameter nt)
    !            that contain scalar spherical harmonic coefficients
    !            of the scalar field array sf as computed by subroutine shaes.
    !     ***    a, b must be computed by shaes prior to calling grades.
    !
    !     mdab   the first dimension of the arrays a and b as it appears in
    !            the program that calls grades (and shaes). mdab must be at
    !            least min(nlat, (nlon+2)/2) if nlon is even or at least
    !            min(nlat, (nlon + 1)/2) if nlon is odd.
    !
    !     ndab   the second dimension of the arrays a and b as it appears in
    !            the program that calls grades (and shaes). ndab must be at
    !            least nlat.
    !
    !
    !   wvhses   an array which must be initialized by subroutine gradesi
    !            (or equivalently by subroutine vhsesi).  once initialized,
    !            wsav can be used repeatedly by grades as long as nlon
    !            and nlat remain unchanged.  wvhses must not be altered
    !            between calls of grades.
    !
    !
    !  lvhses    the dimension of the array wvhses as it appears in the
    !            program that calls grades. define
    !
    !               l1 = min(nlat, nlon/2) if nlon is even or
    !               l1 = min(nlat, (nlon + 1)/2) if nlon is odd
    !
    !            and
    !
    !               l2 = nlat/2        if nlat is even or
    !               l2 = (nlat + 1)/2    if nlat is odd.
    !
    !            then lvhses must be greater than or equal to
    !
    !               (l1*l2*(2*nlat-l1+1))/2+nlon+15
    !
    !     output parameters
    !
    !
    !     v, w   two or three dimensional arrays (see input parameter nt) that
    !           contain an irrotational vector field such that the gradient of
    !           the scalar field sf is (v, w).  w(i, j) is the east longitude
    !           component and v(i, j) is the colatitudinal component of velocity
    !           at colatitude theta(i) = (i-1)*pi/(nlat-1) and longitude
    !           lambda(j) = (j-1)*2*pi/nlon. the indices for v and w are defined
    !           at the input parameter isym.  the vorticity of (v, w) is zero.
    !           note that any nonzero vector field on the sphere will be
    !           multiple valued at the poles [reference swarztrauber].
    !
    !
    !  ierror   = 0  no errors
    !           = 1  error in the specification of nlat
    !           = 2  error in the specification of nlon
    !           = 3  error in the specification of isym
    !           = 4  error in the specification of nt
    !           = 5  error in the specification of idvw
    !           = 6  error in the specification of jdvw
    !           = 7  error in the specification of mdab
    !           = 8  error in the specification of ndab
    !           = 9  error in the specification of lvhses
    !
    module subroutine grades(nlat, nlon, isym, nt, v, w, idvw, jdvw, a, b, mdab, ndab, &
        wvhses, ierror)

        ! Dummy arguments
        integer(ip), intent(in)  :: nlat
        integer(ip), intent(in)  :: nlon
        integer(ip), intent(in)  :: isym
        integer(ip), intent(in)  :: nt
        real(wp),    intent(out) :: v(idvw, jdvw, nt)
        real(wp),    intent(out) :: w(idvw, jdvw, nt)
        integer(ip), intent(in)  :: idvw
        integer(ip), intent(in)  :: jdvw
        real(wp),    intent(in)  :: a(mdab, ndab, nt)
        real(wp),    intent(in)  :: b(mdab, ndab, nt)
        integer(ip), intent(in)  :: mdab
        integer(ip), intent(in)  :: ndab
        real(wp),    intent(in)  :: wvhses(:)
        integer(ip), intent(out) :: ierror

        ! Local variables
        integer(ip) :: idz, imid
        integer(ip) :: required_wavetable_size
        integer(ip) :: lzimn, mmax

        ! Check calling arguments
        ierror = 1
        if (nlat < 3) return
        ierror = 2
        if (nlon < 4) return
        ierror = 3
        if (isym < 0 .or. isym > 2) return
        ierror = 4
        if (nt < 0) return
        ierror = 5
        imid = (nlat + 1)/2
        if ((isym == 0 .and. idvw<nlat) .or. &
            (isym /= 0 .and. idvw<imid)) return
        ierror = 6
        if (jdvw < nlon) return
        ierror = 7
        mmax = min(nlat, (nlon + 1)/2)
        if (mdab < min(nlat, (nlon+2)/2)) return
        ierror = 8
        if (ndab < nlat) return
        ierror = 9
        !
        !     verify minimum saved workspace length
        !
        idz = (mmax*(2*nlat-mmax+1))/2
        lzimn = idz*imid
        required_wavetable_size = 2*lzimn+nlon+15
        if (size(wvhses) < required_wavetable_size) return
        ierror = 0

        call gradient_lower_utility_routine(nlat, nlon, isym, nt, v, w, idvw, jdvw, a, b, &
            wvhses, vhses, ierror)

    end subroutine grades

end submodule gradient_regular_grid_saved
