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
! ... file helmsph.f
!
!     this file contains a program for solving the Helmholtz
!     equation with constant 1.0 on a ten degree grid on the full sphere
!
! ... required spherepack files
!
!     islapec.f, shaec.f, shsec.f, sphcom.f, hrfft.f
!
! ... description
!
!     let theta be latitude and phi be east longitude in radians.
!     and let
!
!
!       x = cos(theta)*sin(phi)
!       y = cos(theta)*cos(phi)
!       z = sint(theta)
!
!     be the cartesian coordinates corresponding to theta and phi.
!     on the unit sphere.  The exact solution
!
!        ue(theta,phi) = (1.+x*y)*exp(z)
!
!     is used to set the right hand side and compute error.
!
!
! **********************************************************************
!
! OUTPUT FROM EXECUTING THE PROGRAM BELOW
! WITH 32 AND 64 BIT FLOATING POINT ARITHMETIC
!
! Helmholtz approximation on a ten degree grid
! nlat = 19   nlon = 36
! xlmbda =  1.00   pertrb =  0.000E+00
! maximum error =  0.715E-06 *** (32 BIT)
! maximum error =  0.114E-12 *** (64 BIT)
!
program helmsph

    use, intrinsic :: iso_fortran_env, only: &
        ip => INT32, &
        wp => REAL64, &
        stdout => OUTPUT_UNIT

    use type_RegularSphere, only: &
        Regularsphere

    use type_GaussianSphere, only: &
        GaussianSphere

    ! Explicit typing only
    implicit none

    !----------------------------------------------------------------------
    ! Dictionary
    !----------------------------------------------------------------------
    type (GaussianSphere)   :: sphere
    integer (ip), parameter :: NLONS = 36
    integer (ip), parameter :: NLATS = NLONS/2 + 1
    integer (ip)            :: i, j !! Counters
    real (wp)               :: approximate_solution(NLATS, NLONS)
    real (wp)               :: source_term(NLATS, NLONS)
    real (wp)               :: helmholtz_constant, discretization_error
    real (wp)               :: pertrb
    integer (ip)            :: ierror
    !----------------------------------------------------------------------

    ! Set up workspace arrays
    call sphere%create(nlat=NLATS, nlon=NLONS, isym=0, isynt=1)

    ! Set helmholtz constant
    helmholtz_constant = 1.0_wp

    ! Set right hand side as helmholtz operator
    ! applied to ue = (1.+x*y)*exp(z)
    associate( &
        rhs => source_term, &
        radial => sphere%unit_vectors%radial &
        )
        do j=1,NLONS
            do i=1,NLATS
                associate( &
                    x => radial(i,j)%x, &
                    y => radial(i,j)%y, &
                    z => radial(i,j)%z &
                    )
                    rhs(i,j) = -(x*y*(z*z+6.0_wp*(z+1.0_wp))+z*(z+2.0_wp))*exp(z)
                end associate
            end do
        end do
    end associate

    !
    ! Solve Helmholtz equation on the sphere in u
    !
!    associate( &
!        xlmbda => helmholtz_constant, &
!        rhs => source_term, &
!        u => approximate_solution &
!        )
!        call sphere%invert_helmholtz( xlmbda, rhs, u)
!    end associate

    associate( workspace => sphere%workspace)
        associate( &
            xlmbda => helmholtz_constant, &
            nlat => sphere%NUMBER_OF_LATITUDES, &
            nlon => sphere%NUMBER_OF_LONGITUDES, &
            isym => sphere%SCALAR_SYMMETRIES, &
            nt => sphere%NUMBER_OF_SYNTHESES, &
            u => approximate_solution, &
            a => workspace%real_harmonic_coefficients, &
            b => workspace%imaginary_harmonic_coefficients, &
            wshsec => workspace%backward_scalar, &
            lshsec => size(workspace%backward_scalar), &
            work => workspace%legendre_workspace, &
            lwork => size(workspace%legendre_workspace) &
            )
            call islapec(nlat,nlon,isym,nt,xlmbda,u,nlat,nlon,a,b,nlat,nlat, &
                wshsec,lshsec,work,lwork,pertrb,ierror)
        end associate
    end associate
    !
    ! Compute and print maximum error
    !
    discretization_error = 0.0
    associate( &
        err_max => discretization_error, &
        u => approximate_solution, &
        radial => sphere%unit_vectors%radial &
        )
        do j=1,NLONS
            do i=1,NLATS
                associate( &
                    x => radial(i,j)%x, &
                    y => radial(i,j)%y, &
                    z => radial(i,j)%z &
                    )
                    associate( ue => (1.0_wp + x * y) * exp(z) )
                        err_max = max(err_max,abs(u(i,j)-ue))
                    end associate
                end associate
            end do
        end do
    end associate

    ! Print earlier output from platform with 64-bit floating point
    ! arithmetic followed by the output from this computer
    write( stdout, '(A)') ''
    write( stdout, '(A)') '     helmsph *** TEST RUN *** '
    write( stdout, '(A)') ''
    write( stdout, '(A)') '     Helmholtz approximation on a ten degree grid'
    write( stdout, '(2(A,I2))') '     nlat = ', NLATS,' nlon = ', NLONS
    write( stdout, '(A)') '     Previous 64 bit floating point arithmetic result '
    write( stdout, '(A)') '     discretization error = 0.114E-12'
    write( stdout, '(A)') '     The output from your computer is: '
    write( stdout, '(A,1pe15.6)') '     discretization error = ', &
        discretization_error
    write( stdout, '(A)' ) ''

    ! Release memory
    call sphere%destroy()

end program helmsph

