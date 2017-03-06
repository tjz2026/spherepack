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
! ... file shallow.f
!
!     program shallow solves the nonlinear shallow-water equations
!     on the sphere using spherepack software.
!
! ... required spherepack files
!
!     vtses.f, dives.f, vrtes.f, grades.f, sphcom.f, hrfft.f, 
!     vhaes.f, vhses.f, shaes.f, shses.f
!

program shallow
    use spherepack
    implicit none
    real(wp) :: a
    real(wp) :: aa
    real(wp) :: alpha
    real(wp) :: alphad
    real(wp) :: b
    real(wp) :: bi
    real(wp) :: br
    real(wp) :: ca
    real(wp) :: cfn
    real(wp) :: ci
    real(wp) :: cl
    real(wp) :: clh
    real(wp) :: cr
    real(wp) :: ct
    real(wp) :: cth
    real(wp) :: cthclh
    real(wp) :: cthslh
    real(wp) :: ctime
    real(wp) :: divg
    real(wp) :: dlam
    real(wp) :: dlath
    real(wp) :: dpdt
    real(wp) :: dpmax
    real(wp) :: dt
    real(wp) :: dtheta
    real(wp) :: dtr
    real(wp) :: dudt
    real(wp) :: dvdt
    real(wp) :: dvgm
    real(wp) :: dvmax
    real(wp) :: epmax
    real(wp) :: evmax
    real(wp) :: f
    real(wp) :: fzero
    real(wp) :: gpdl
    real(wp) :: gpdt
    real(wp) :: hpi
    real(wp) :: htime
    integer(ip) :: i
    integer(ip) :: idp
    integer(ip) :: ierror
    integer(ip) :: isym
    integer(ip) :: itmax
    integer(ip) :: j
    integer(ip) :: jdp
    integer(ip) :: ldwork
    integer(ip) :: lldwork
    integer(ip) :: lwork
    integer(ip) :: lwsha
    integer(ip) :: lwshs
    integer(ip) :: lwvha
    integer(ip) :: lwvhs
    integer(ip) :: lwvts
    integer(ip) :: mdab
    integer(ip) :: mmode
    integer(ip) :: mprint
    integer(ip) :: ncycle
    integer(ip) :: ndab
    integer(ip) :: nl
    integer(ip) :: nlat
    integer(ip) :: nlm1
    integer(ip) :: nlm2
    integer(ip) :: nlon
    integer(ip) :: nt
    real(wp) :: omega
    real(wp) :: p
    real(wp) :: p2max
    real(wp) :: phlt

    real(wp) :: pmax
    real(wp) :: pnew
    real(wp) :: pold
    real(wp) :: pxact
    real(wp) :: pzero
    real(wp) :: sa
    real(wp) :: sl
    real(wp) :: slh
    real(wp) :: st
    real(wp) :: sth
    real(wp) :: tdt
    real(wp) :: that
    real(wp) :: theta
    real(wp) :: time
    real(wp) :: u
    real(wp) :: uhat
    real(wp) :: unew
    real(wp) :: uold
    real(wp) :: ut
    real(wp) :: uxact
    real(wp) :: uzero
    real(wp) :: v
    real(wp) :: v2max
    real(wp) :: vmax
    real(wp) :: vnew
    real(wp) :: vold
    real(wp) :: vort
    real(wp) :: vt
    real(wp) :: vxact
    real(wp) :: work
    real(wp) :: wsha
    real(wp) :: wshs
    real(wp) :: wvha
    real(wp) :: wvhs
    real(wp) :: wvts
    !
    !     the nonlinear shallow-water equations on the sphere are
    !     solved using a spectral method based on the spherical
    !     vector harmonics. the method is described in the paper:
    !
    ! [1] p. n. swarztrauber, spectral transform methods for solving
    !     the shallow-water equations on the sphere, p.n. swarztrauber, 
    !     monthly weather review, vol. 124, no. 4, april 1996, pp. 730-744.
    !
    !     this program implements test case 3 (steady nonlinear rotated flow)
    !     in the paper:
    !
    ! [2] d.l. williamson, j.b. drake, j.j. hack, r. jakob, and
    !     p.n. swarztrauber, j. comp. phys., a standard test set
    !     for numerical approximations to the shallow-water
    !     equations in spherical geometry, j. comp. phys., 
    !     vol. 102, no. 1, sept. 1992, pp. 211-224.
    !
    ! definitions:
    !
    !
    !     nlat          number of latitudes including poles
    !     nlon          number of distinct longitudes
    !     mmode         max wave number
    !     omega         rotation rate of earth in radians per second
    !     aa            radius of earth in meters
    !     pzero         mean height of geopotential
    !     uzero         maximum velocity
    !     alpha         tilt angle of the rotated grid
    !     ncycle        cycle number
    !     time          model time in seconds
    !     dt            time step
    !     lambda        longitude
    !     theta         colatitude
    !
    !   the first dimension of the following two dimensional arrays
    !   corresponds to the latitude index with values i=1, ..., nlat
    !   where i=1 is the north pole and i=nlat is the south pole.
    !   the second dimension is longitude with values j=1, ..., nlon
    !   where j=1 corresponds to zero longitude and j=nlon corresponds
    !   to 2pi minus 2pi/nlon.
    !
    !     u(i, j)       east longitudinal velocity component at t=time
    !     v(i, j)       latitudinal velocity component at t=time
    !     p(i, j)       +pzero = geopotential at t=time
    !
    !     unew(i, j)    east longitudinal velocity component at t=time+dt
    !     vnew(i, j)    latitudinal velocity component at t=time+dt
    !     pnew(i, j)    +pzero = geopotential at t=time+dt
    !
    !     uold(i, j)    east longitudinal velocity component at t=time-dt
    !     vold(i, j)    latitudinal velocity component at t=time-dt
    !     pold(i, j)    +pzero = geopotential at t=time-dt
    !
    !     divg(i, j)    divergence (d/dtheta (cos(theta) v)
    !                                          + du/dlambda)/cos(theta)
    !     vort(i, j)    vorticity  (d/dtheta (cos(theta) u)
    !                                          - dv/dlambda)/cos(theta)
    !
    !     ut(i, j)      latitudinal derivative of longitudinal
    !                  velocity component
    !     vt(i, j)      latitudinal derivative of latitudinal
    !                  velocity component
    !
    !     dudt(i, j)    time derivative of longitudinal velocity component
    !     dvdt(i, j)    time derivative of latitudinal  velocity component
    !     dpdt(i, j)    time derivative of geopotential
    !
    !     gpdl(i, j)    first component of the gradient of p(i, j)
    !                  the longitudinal derivative of the geopotential
    !                  divided by the cosine of the latitude
    !
    !     gpdt(i, j)    second component of the gradient of p(i, j)
    !                  the latitudinal derivative of the geopotential
    !
    !     uxact(i, j)   the "exact" longitudinal veloctiy component
    !     vxact(i, j)   the "exact" latitudinal  veloctiy component
    !     uxact(i, j)   the "exact" geopotential
    !
    !     f(i, j)       the coriolis force on rotated grid
    !
    !   the following two dimensional arrays are nonzero in the triangle
    !   n=1, ..., nlat and m less than or equal to n.
    !
    !     a(m, n), b(m, n)    spectral coefficients of the geopotential
    !
    !     br(m, n), bi(m, n)  spectral coefficients of the velocity
    !     cr(m, n), ci(m, n)  vector [u(i, j), v(i, j)]
    !
    !
    !     phlt(i)      the coefficients in the cosine series
    !                  representation of the unrotated geopotential
    !
    parameter (idp=73, jdp=144, mdab=73, ndab=73)
    parameter(lldwork = 2*(idp+1))
    !
    dimension u(idp, jdp), v(idp, jdp), p(idp, jdp), f(idp, jdp), &
        unew(idp, jdp), vnew(idp, jdp), pnew(idp, jdp), &
        uold(idp, jdp), vold(idp, jdp), pold(idp, jdp), &
        uxact(idp, jdp), vxact(idp, jdp), pxact(idp, jdp), &
        divg(idp, jdp), vort(idp, jdp), ut(idp, jdp), &
        vt(idp, jdp), dudt(idp, jdp), dvdt(idp, jdp), &
        dpdt(idp, jdp), gpdt(idp, jdp), gpdl(idp, jdp), &
        a(mdab, ndab), b(mdab, ndab), br(mdab, ndab), &
        bi(mdab, ndab), cr(mdab, ndab), ci(mdab, ndab), &
        phlt(361)
    !
    !   the following work arrays are initialized and subsequently
    !   used repeatedly by spherepack routines.
    !
    dimension wsha(70928), wshs(70928), wvha(141647), wvhs(141647), &
        wvts(141647), work(40000)
    real dwork(lldwork)
    !
    real lambda, lhat

    lwsha = 70928
    lwshs = 70928
    lwvha = 141647
    lwvhs = 141647
    lwvts = 141647
    lwork = 40000
    ldwork = lldwork

    hpi = pi/2
    dtr = pi/180
    aa = 6.37122e6
    omega = 7.292e-5
    fzero = omega+omega
    uzero = 40.
    pzero = 2.94e4
    alphad = 60.
    alpha = dtr*alphad
    !
    itmax = 720
    mprint = 72
    mmode = 42
    nlat = 65
    nlon = 128
    dt = 600.
    tdt = dt+dt
    !
    !     initialize spherepack routines
    !
    call shaesi(nlat, nlon, wsha, ierror)
    if(ierror /= 0) write (*, 55) ierror
55  format(' error' i4 ' in shaesi')
    call shsesi(nlat, nlon, wshs, ierror)
    if(ierror /= 0) write (*, 56) ierror
56  format(' error' i4 ' in shsesi')
    call vhaesi(nlat, nlon, wvha, ierror)
    if(ierror /= 0) write (*, 57) ierror
57  format(' error' i4 ' in vhaesi')
    call vhsesi(nlat, nlon, wvhs, ierror)
    if(ierror /= 0) write (*, 58) ierror
58  format(' error' i4 ' in vhsesi')
    call vtsesi(nlat, nlon, wvts, lwvts, work, lwork, dwork, ldwork, ierror)
    if(ierror /= 0) write (*, 59) ierror
59  format(' error' i4 ' in vtsesi')
    !
    !
    !     compute the derivative of the unrotated geopotential
    !             p as a function of latitude
    !
    nl = 91
    nlm1 = nl-1
    nlm2 = nl-2
    cfn = 1./nlm1
    dlath = pi/nlm1
    do i=1, nlm2
        theta = i*dlath
        sth = sin(theta)
        cth = cos(theta)
        uhat = ui(uzero, hpi-theta)
        phlt(i) = cfn*cth*uhat*(uhat/sth+aa*fzero)
    end do
    !
    !     compute sine transform of the derivative of the geopotential
    !     for the purpose of computing the geopotential by integration
    !     see equation (3.9) in reference [1] above
    !
    call sine(nlm2, phlt, work)
    !
    !     compute the cosine coefficients of the unrotated geopotential
    !     by the formal integration of the sine series representation
    !
    do i=1, nlm2
        phlt(i) = -phlt(i)/i
    end do
    !
    !     phlt(i) contains the coefficients in the cosine series
    !     representation of the unrotated geopotential that are used
    !     below to compute the geopotential on the rotated grid.
    !
    !     compute the initial values of  east longitudinal
    !     and latitudinal velocities u and v as well as the
    !     geopotential p and coriolis f on the rotated grid.
    !
    ca = cos(alpha)
    sa = sin(alpha)
    dtheta = pi/(nlat-1)
    dlam = (pi+pi)/nlon
    do j=1, nlon
        lambda = (j-1)*dlam
        cl = cos(lambda)
        sl = sin(lambda)
        do i=1, nlat
            !
            !     lambda is longitude, theta is colatitude, and pi/2-theta is
            !     latitude on the rotated grid. lhat and that are longitude
            !     and colatitude on the unrotated grid. see text starting at
            !     equation (3.10)
            !
            theta = (i-1)*dtheta
            st = cos(theta)
            ct = sin(theta)
            sth = ca*st+sa*ct*cl
            cthclh = ca*ct*cl-sa*st
            cthslh = ct*sl
            lhat = atanxy(cthclh, cthslh)
            clh = cos(lhat)
            slh = sin(lhat)
            cth = clh*cthclh+slh*cthslh
            that = atanxy(sth, cth)
            uhat = ui(uzero, hpi-that)
            pxact(i, j) = cosine(that, nlm2, phlt)
            uxact(i, j) = uhat*(ca*sl*slh+cl*clh)
            vxact(i, j) = uhat*(ca*cl*slh*st-clh*sl*st+sa*slh*ct)
            f(i, j) = fzero*sth
        end do
    end do
    !
    vmax = 0.
    pmax = 0.
    v2max = 0.
    p2max = 0.
    do  j=1, nlon
        do i=1, nlat
            v2max = v2max+uxact(i, j)**2+vxact(i, j)**2
            p2max = p2max+pxact(i, j)**2
            vmax = amax1(abs(uxact(i, j)), abs(vxact(i, j)), vmax)
            pmax = amax1(abs(pxact(i, j)), pmax)
        end do
    end do
    !
    !     initialize first time step
    !
    do j=1, nlon
        do i=1, nlat
            u(i, j) = uxact(i, j)
            v(i, j) = vxact(i, j)
            p(i, j) = pxact(i, j)
        end do
    end do
    !
    isym = 0
    nt = 1
    time = 0.
    ctime = 0.
    ncycle = 0
    !
    !     start of the time loop
    !
    !   begin step 1, section 3
    !
    !     analyze the velocity components (u, v)
    !
90  call vhaesgo(nlat, nlon, isym, nt, u, v, idp, jdp, br, bi, cr, ci, &
        mdab, ndab, wvha, ierror)
    if(ierror /= 0) write (*, 91) ierror
91  format(' error' i4 ' in vhaes')
    !
    !     truncate spectrum to eliminate aliasing of the
    !     product terms in the shallow-water equations
    !
    call trunc(nlat, mmode, mdab, br, bi)
    call trunc(nlat, mmode, mdab, cr, ci)
    !
    !     resynthesize the velocity components
    !
    call vhsesgo(nlat, nlon, isym, nt, u, v, idp, jdp, br, bi, cr, ci, &
        mdab, ndab, wvhs, lwvhs, work, lwork, ierror)
    if(ierror /= 0) write (*, 92) ierror
92  format(' error' i4 ' in vhses')
    !
    !   begin step 2, section 3
    !
    !     analyze geopotential p
    !
    call shaes(nlat, nlon, isym, nt, p, idp, jdp, a, b, mdab, ndab, &
        wsha, ierror)
    if(ierror /= 0) write (*, 93) ierror
93  format(' error' i4 ' in shaes')
    !
    !     truncate spectrum to eliminate aliasing of the
    !     product terms in the shallow-water equations
    !
    call trunc(nlat, mmode, mdab, a, b)
    !
    !     resynthesize the geopotential p
    !
    call shses(nlat, nlon, isym, nt, p, idp, jdp, a, b, mdab, ndab, &
        wshs, ierror)
    if(ierror /= 0) write (*, 94) ierror
94  format(' error' i4 ' in shses')
    !
    !
    !   begin step 3, section 3
    !
    !     compute the vorticity of the velocity (u, v)
    !
    call vrtes(nlat, nlon, isym, nt, vort, idp, jdp, cr, ci, mdab, ndab, &
        wshs, lwshs, work, lwork, ierror)
    if(ierror /= 0) write (*, 95) ierror
95  format(' error' i4 ' in vrtes')
    !
    !     compute the divergence of the velocity (u, v)
    !
    call dives(nlat, nlon, isym, nt, divg, idp, jdp, br, bi, mdab, ndab, &
        wshs, lwshs, work, lwork, ierror)
    if(ierror /= 0) write (*, 96) ierror
96  format(' error' i4 ' in dives')
    !
    !   begin step 4, section 3
    !
    !     compute the derivative of the velocity (u, v) with
    !     respect to colatitude theta.
    !
    call vtsesgo(nlat, nlon, isym, nt, ut, vt, idp, jdp, br, bi, cr, ci, &
        mdab, ndab, wvts, lwvts, work, lwork, ierror)
    if(ierror /= 0) write (*, 97) ierror
97  format(' error' i4 ' in vtsesgo')
    !
    !   begin step 5, section 3
    !
    !     compute the gradient of the geopotential p
    !
    call gradesgo(nlat, nlon, isym, nt, gpdl, gpdt, idp, jdp, a, b, mdab, ndab, &
        wvhs, lwvhs, work, lwork, ierror)
    if(ierror /= 0) write (*, 98) ierror
98  format(' error' i4 ' in grades')
    !
    !     compute the time derivatives of the velocity (u, v)
    !     and the geopotential p using the shallow-water
    !     equations (2.8), (2.9), and (2.10), section 3.
    !
    do j=1, nlon
        do i=1, nlat
            dudt(i, j) = (u(i, j)*(vt(i, j)-divg(i, j))-v(i, j)*ut(i, j) &
                -gpdl(i, j))/aa+f(i, j)*v(i, j)
            dvdt(i, j) = -(u(i, j)*(vort(i, j)+ut(i, j))+v(i, j)*vt(i, j) &
                +gpdt(i, j))/aa-f(i, j)*u(i, j)
            dpdt(i, j) = -((p(i, j)+pzero)*divg(i, j)+v(i, j)*gpdt(i, j) &
                +u(i, j)*gpdl(i, j))/aa
        end do
    end do
    !
    if(mod(ncycle, mprint) /= 0) go to 370
    htime = time/3600.

    write (*, 390) ncycle, htime, dt, nlat, nlon, mmode, omega, pzero, &
        uzero, alphad
390 format(//' steady nonlinear rotated flow, test case 3'/ &
        ' cycle number              ' i10 &
        ' model time in  hours      ' f10.2/ &
        ' time step in seconds      ' f10.0 &
        ' number of latitudes       ' i10/ &
        ' number of longitudes      ' i10 &
        ' max wave number           ' i10/ &
        ' rotation rate        ' 1pe15.6 &
        ' mean height          ' 1pe15.6/ &
        ' maximum velocity     ' 1pe15.6 &
        ' tilt angle                ' f10.2)
    dvgm = 0.
    dvmax = 0.
    dpmax = 0.
    evmax = 0.0
    epmax = 0.0
    do j=1, nlon
        do i=1, nlat
            dvgm = amax1(dvgm, abs(divg(i, j)))
            dvmax = dvmax+(u(i, j)-uxact(i, j))**2+(v(i, j)-vxact(i, j))**2
            dpmax = dpmax+(p(i, j)-pxact(i, j))**2
            evmax = amax1(evmax, abs(v(i, j)-vxact(i, j)), abs(u(i, j)-uxact(i, j)))
            epmax = amax1(epmax, abs(p(i, j)-pxact(i, j)))
        end do
    end do

    dvmax = sqrt(dvmax/v2max)
    dpmax = sqrt(dpmax/p2max)
    evmax = evmax/vmax
    epmax = epmax/pmax

    write (*, 391) evmax, epmax, dvmax, dpmax, dvgm
391 format(' max error in velocity' 1pe15.6 &
        ' max error in geopot. ' 1pe15.6/ &
        ' l2 error in velocity ' 1pe15.6 &
        ' l2 error in geopot.  ' 1pe15.6/ &
        ' maximum divergence   ' 1pe15.6)
    !
    !     set values at time = -dt to values at time = 0.
    !
370 if(ncycle > 0) go to 206
    do j=1, nlon
        do i=1, nlat
            uold(i, j) = u(i, j)
            vold(i, j) = v(i, j)
            pold(i, j) = p(i, j)
        end do
    end do
    !
    !     compute values at next time level using leap frog
    !     time differencing
    !
    206 do j=1, nlon
        do  i=1, nlat
            unew(i, j) = uold(i, j)+tdt*dudt(i, j)
            vnew(i, j) = vold(i, j)+tdt*dvdt(i, j)
            pnew(i, j) = pold(i, j)+tdt*dpdt(i, j)
        end do
    end do
    !
    !     update values to next time level
    !
    do j=1, nlon
        do i=1, nlat
            uold(i, j) = u(i, j)
            vold(i, j) = v(i, j)
            pold(i, j) = p(i, j)
            u(i, j) = unew(i, j)
            v(i, j) = vnew(i, j)
            p(i, j) = pnew(i, j)
        end do
    end do

    ncycle = ncycle+1
    time = time+dt
    if(ncycle <= itmax) go to 90

contains

    subroutine vtsesgo(nlat, nlon, ityp, nt, ut, vt, idvw, jdvw, br, bi, cr, ci, &
        mdab, ndab, wvts, lwvts, work, lwork, ierror)
        implicit none
        real(wp) :: bi
        real(wp) :: br
        real(wp) :: ci
        real(wp) :: cr
        integer(ip) :: i
        integer(ip) :: idvw
        integer(ip) :: ierror
        integer(ip) :: ityp
        integer(ip) :: j
        integer(ip) :: jdvw
        integer(ip) :: k
        integer(ip) :: lwork
        integer(ip) :: lwvts
        integer(ip) :: mdab
        integer(ip) :: ndab
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: ut
        real(wp) :: vt
        real(wp) :: work
        real(wp) :: wvts
        !
        !     vtsesgo computes the latitudinal derivatives of the
        !     velocity components using subroutine vtses which
        !     assumes the velocity components are given in terms
        !     of mathematical coordinates
        !
        dimension ut(idvw, jdvw, 1), vt(idvw, jdvw, 1), br(mdab, ndab, 1), &
            bi(mdab, ndab, 1), cr(mdab, ndab, 1), ci(mdab, ndab, 1), &
            work(*), wvts(*)
        call vtses(nlat, nlon, ityp, nt, vt, ut, idvw, jdvw, br, bi, cr, ci, &
            mdab, ndab, wvts, lwvts, work, lwork, ierror)
        do k=1, nt
            do j=1, nlon
                do i=1, nlat
                    ut(i, j, k) = -ut(i, j, k)
                end do
            end do
        end do

    end subroutine vtsesgo

    real function ui(amp, thetad)
        implicit none
        real(wp) :: amp
        real(wp) :: pi
        real(wp) :: thetab
        real(wp) :: thetad
        real(wp) :: thetae
        real(wp) :: x
        real(wp) :: xe
        !
        !     computes the initial unrotated longitudinal velocity
        !     see section 3.3.
        !
        pi=4.*atan(1.)
        thetab=-pi/6.
        thetae= pi/2.
        xe=3.e-1
        x =xe*(thetad-thetab)/(thetae-thetab)
        ui = 0.
        if(x<=0. .or. x>=xe) return
        ui=amp*exp(-1./x-1./(xe-x)+4./xe)

    end function ui

    real function atanxy(x, y)
        implicit none
        real(wp) :: x
        real(wp) :: y
        atanxy = 0.
        if(x==0. .and. y==0.) return
        atanxy = atan2(y, x)

    end function atanxy

    subroutine sine(n, x, w)
        implicit none
        real(wp) :: arg
        integer(ip) :: i
        integer(ip) :: j
        integer(ip) :: n
        real(wp) :: w
        real(wp) :: x
        !
        !     computes the sine transform
        !
        dimension x(n), w(n)
        arg = 4.*atan(1.)/(n+1)
        do  j=1, n
            w(j) = 0.
            do  i=1, n
                w(j) = w(j)+x(i)*sin(i*j*arg)
            end do
        end do

        do i=1, n
            x(i) = 2.*w(i)
        end do

    end subroutine sine

    real function cosine(theta, n, cf)
        implicit none
        real(wp) :: cf
        integer(ip) :: i
        integer(ip) :: n
        real(wp) :: theta
        !
        !     computes the cosine transform
        !
        dimension cf(n)
        cosine = 0.
        do i=1, n
            cosine = cosine+cf(i)*cos(i*theta)
        end do

    end function cosine
    !
    subroutine trunc(nm, ms, id, a, b)
        implicit none
        real(wp) :: a
        real(wp) :: b
        integer(ip) :: id
        integer(ip) :: m
        integer(ip) :: mp
        integer(ip) :: ms
        integer(ip) :: n
        integer(ip) :: nm
        !
        !     truncates spectral coefficients so that aliasing
        !     does not occur when computing the spectral representations
        !     of the product terms.
        !
        dimension a(id, 1), b(id, 1)
        mp = ms+2
        do n=mp, nm
            do m=1, n
                a(m, n) = 0.
                b(m, n) = 0.
            end do
        end do

    end subroutine trunc

    subroutine vhaesgo(nlat, nlon, ityp, nt, u, v, iduv, jduv, &
        br, bi, cr, ci, mdab, ndab, wsav, ierror)

        real(wp) :: bi
        real(wp) :: br
        real(wp) :: ci
        real(wp) :: cr
        integer(ip) :: i
        integer(ip) :: iduv
        integer(ip) :: ierror
        integer(ip) :: ityp
        integer(ip) :: j
        integer(ip) :: jduv
        integer(ip) :: k
        
        
        integer(ip) :: mdab
        integer(ip) :: ndab
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: u
        real(wp) :: v
        real(wp) :: wsav(:)
        dimension u(iduv, jduv, *), v(iduv, jduv, *), br(mdab, ndab, *), &
            bi(mdab, ndab, *), cr(mdab, ndab, *), ci(mdab, ndab, *)

        !     vhaesgo computes the vector harmonic analysis of (u, v) using vhaes which
        !     assumes the velocity components are given in mathematical coordinates
        !
        do k=1, nt
            do j=1, nlon
                do i=1, nlat
                    v(i, j, k) = -v(i, j, k)
                end do
            end do
        end do

        call vhaes(nlat, nlon, ityp, nt, v, u, iduv, jduv, &
            br, bi, cr, ci, mdab, ndab, wsav, ierror)
        !
        !     restore v
        !
        do k=1, nt
            do j=1, nlon
                do i=1, nlat
                    v(i, j, k) = -v(i, j, k)
                end do
            end do
        end do

        if (ierror/=0) return

    end subroutine vhaesgo

    subroutine vhsesgo(nlat, nlon, ityp, nt, u, v, iduv, jduv, &
        br, bi, cr, ci, mdab, ndab, wsav, lwsav, work, lwork, ierror)
        implicit none
        real(wp) :: bi
        real(wp) :: br
        real(wp) :: ci
        real(wp) :: cr
        integer(ip) :: i
        integer(ip) :: iduv
        integer(ip) :: ierror
        integer(ip) :: ityp
        integer(ip) :: j
        integer(ip) :: jduv
        integer(ip) :: k
        integer(ip) :: lwork
        integer(ip) :: lwsav
        integer(ip) :: mdab
        integer(ip) :: ndab
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: u
        real(wp) :: v
        real(wp) :: work(..)
        real(wp) :: wsav(:)
        dimension u(iduv, jduv, *), v(iduv, jduv, *), br(mdab, ndab, *), &
            bi(mdab, ndab, *), cr(mdab, ndab, *), ci(mdab, ndab, *)
        !
        !     vhsesgo computes a vector harmonic synthesis in (u, v) using vhses which
        !     assumes the velocity components are given in mathematical coordinates
        !
        call vhses(nlat, nlon, ityp, nt, v, u, iduv, jduv, &
            br, bi, cr, ci, mdab, ndab, wsav, ierror)
        if (ierror /= 0) return

        do k=1, nt
            do j=1, nlon
                do i=1, nlat
                    v(i, j, k) = -v(i, j, k)
                end do
            end do
        end do

    end subroutine vhsesgo

    subroutine gradesgo(nlat, nlon, isym, nt, u, v, iduv, jduv, a, b, &
        mdab, ndab, wsav, lwsav, work, lwork, ierror)
        implicit none
        real(wp) :: a
        real(wp) :: b
        integer(ip) :: i
        integer(ip) :: iduv
        integer(ip) :: ierror
        integer(ip) :: isym
        integer(ip) :: j
        integer(ip) :: jduv
        integer(ip) :: k
        integer(ip) :: lwork
        integer(ip) :: lwsav
        integer(ip) :: mdab
        integer(ip) :: ndab
        integer(ip) :: nlat
        integer(ip) :: nlon
        integer(ip) :: nt
        real(wp) :: u
        real(wp) :: v
        real(wp) :: work
        real(wp) :: wsav
        dimension u(iduv, jduv, nt), v(iduv, jduv, nt)
        dimension a(mdab, ndab, nt), b(mdab, ndab, nt)
        dimension wsav(lwsav), work(lwork)
        !
        !     gradesgo computes the gradient in (u, v) using grades which assumes
        !     the velocity components are given in mathematical coordinates
        !
        call grades(nlat, nlon, isym, nt, v, u, iduv, jduv, a, b, &
            mdab, ndab, wsav, lwsav, work, lwork, ierror)

        if (ierror /=0) return
        do k=1, nt
            do j=1, nlon
                do i=1, nlat
                    v(i, j, k) = -v(i, j, k)
                end do
            end do
        end do

    end subroutine gradesgo

end program shallow
