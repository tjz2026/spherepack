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
! ... visgeo.f
!
!     contains documentation and code for subroutine visgeo
!
subroutine visgeo (m, idp, jdp, x, y, z, h, eyer, eyelat, eyelon, &
                          work, lwork, iwork, liwork, ierror)
implicit none
real :: eyelat
real :: eyelon
real :: eyer
real :: h
integer :: i
integer :: i1
integer :: i10
integer :: i11
integer :: i12
integer :: i13
integer :: i14
integer :: i2
integer :: i3
integer :: i4
integer :: i5
integer :: i6
integer :: i7
integer :: i8
integer :: i9
integer :: idp
integer :: ierror
integer :: j
integer :: jdp
integer :: k
integer :: lg
integer :: liwork
integer :: lt
integer :: lwork
integer :: m
integer :: mmsq
real :: work
real :: x
real :: y
real :: z
!
!     subroutine visgeo will display a function on the sphere
!     as a solid. ie. as a "lumpy" sphere. visgeo calls subroutine
!     vsurf to produce the visible surface rendering. X, Y, and Z
!     are the points on an icosahedral geodesic computed by
!     subroutine geopts available in spherepack.
!
!     requires routines visgeo1 ctos stoc vsurf vsurf1
!                       prjct box
!
!     visgeo uses the ncar graphics package.
!     compile with: ncargf77 (all programs above)
!
!     execute with:  a.out
!
!     on screen display with:  ctrans -d x11 gmeta
!                          
!     print with:  ctrans -d ps.color gmeta > gmeta.ps
!                  lpr -P(your printer) gmeta.ps 
!
!
!     input parameters
!
!     m        the number of points on one edge of the icosahedron
!
!     idp, jdp  the first and second dimensions of the three
!              dimensional arrays x, y, z, and h.
!
!     x, y, z    the coordinates of the geodesic points on 
!              the unit sphere computed by subroutine geopts.
!              the indices are defined on the unfolded 
!              icosahedron as follows for the case m=3
!
!                north pole
!
!                 (5, 1)          0      l
!        i     (4, 1) (5, 2)              a    (repeated for
!           (3, 1) (4, 2) (5, 3)  theta1   t    k=2, 3, 4, 5 in
!        (2, 1) (3, 2) (4, 3)              i        -->
!     (1, 1) (2, 2) (3, 3)        theta2   t    the longitudinal 
!        (1, 2) (2, 3)                    u    direction)
!           (1, 3)                pi     d
!      j                                e
!         south pole
!
!            total number of vertices is  10*(m-1)**2+2
!            total number of triangles is 20*(m-1)**2
!
!     h      a three dimensional array that contains the discrete
!            function to be displayed. h(i, j, k) is the distance from
!            the center of the sphere to the "lumpy" surface at the
!             point [x(i, j, k), y(i, j, k), z(i, j, k)] on the unit sphere.
!
!     eyer   the distance from the center of the sphere to the eye.
!
!     eyelat the colatitudinal coordinate of the eye (in degrees).
!
!     eyelon the longitudinal  coordinate of the eye (in degrees).
!
!     idp    the first dimension of the array h as it appears in
!            the program that calls visgeo
!
!     jdp    the second dimension of the array h as it appears in
!            the program that calls visgeo
!
!     work   a real work array 
!
!     lwork  the dimension of the array work as it appears in the
!            program that calls visgeo. lwork must be at least 
!                       480*(m-1)**2.
!
!     iwork  an integer work array
!
!     liwork the dimension of the array iwork as it appears in the
!            program that calls visgeo. liwork must be at least 
!                       140*(m-1)**2.
!
!     input parameter
!
!     ierror = 0    no error
!            = 1    h(i, j, k) is less than zero for some i, j, k.
!            = 2    eyer is less than h(i, j, k) for some i, k, k.
!            = 3    lwork  is less than 480*(m-1)**2
!            = 4    liwork is less than 140*(m-1)**2
!
dimension h(idp, jdp, 5), x(idp, jdp, 5), y(idp, jdp, 5), z(idp, jdp, 5), &
                                                        work(*)
integer iwork(*)
mmsq = (m-1)**2
ierror = 3
if (lwork < 480*mmsq) return
ierror = 4
if (liwork < 140*mmsq) return
do 10 k=1, 5
do 10 j=1, m
do 10 i=1, m+m-1
if (h(i, j, k) >= 0.) go to 15
ierror = 1
return
15 if (eyer > h(i, j, k)) go to 10
ierror = 2
return
10 continue
ierror = 0
lt = 20*(m-1)**2
lg = 5*m*(m+m-1)
i1 = 1
i2 = i1+lt
i3 = i2+lt
i4 = i3+lt
i5 = i4+lt
i6 = i5+lt
i7 = i6+lt
i8 = i7+lt
i9 = i8+lt
i10 = i9+lt
i11 = i10+lt
i12 = i11
i13 = i12+lg
i14 = i13+lg
call visgeo1 (m, idp, jdp, h, eyer, eyelat, eyelon, x, y, z, &
work(i1), work(i2), work(i3), work(i4), work(i5), work(i6), &
work(i7), work(i8), work(i9), IWORK(1), work(i11), &
work(i12), work(i13), work(i14), IWORK(lt+1))
return
end subroutine visgeo
subroutine visgeo1(m, idp, jdp, h, eyer, eyelat, eyelon, &
    xi, yi, zi, x1, y1, z1, x2, y2, z2, x3, y3, z3, itype, work, x, y, z, iwork)
implicit none
real :: dtr
real :: elambda
real :: eyelat
real :: eyelon
real :: eyer
real :: h
integer :: i
integer :: idp
integer :: itype
integer :: j
integer :: jdp
integer :: k
integer :: m
integer :: ntri
real :: pi
real :: rad
real :: theta
real :: work
real :: x
real :: x1
real :: x2
real :: x3
real :: xeye
real :: xi
real :: y
real :: y1
real :: y2
real :: y3
real :: yeye
real :: yi
real :: z
real :: z1
real :: z2
real :: z3
real :: zeye
real :: zi
dimension h(idp, jdp, 5), xi(idp, jdp, 5), yi(idp, jdp, 5), zi(idp, jdp, 5), &
x1(*), y1(*), z1(*), x2(*), y2(*), z2(*), x3(*), y3(*), z3(*), itype(*), &
work(*), x(m+m-1, m, 5), y(m+m-1, m, 5), z(m+m-1, m, 5)
integer iwork(*)
!
!     the * above refers to 20*(m-1)**2 locations which is the
!     number of triangles
!
do 10 k=1, 5
do 10 j=1, m
do 10 i=1, m+m-1
call cart2sph(xi(i, j, k), yi(i, j, k), zi(i, j, k), rad, theta, elambda)
call sph2cart(h(i, j, k), theta, elambda, x(i, j, k), y(i, j, k), z(i, j, k))
10 continue  
ntri = 0
do 20 k=1, 5
do 20 j=1, m-1
do 20 i=1, m+m-2
ntri = ntri+1
x1(ntri) = x(i, j, k)
y1(ntri) = y(i, j, k)
z1(ntri) = z(i, j, k)
x2(ntri) = x(i+1, j+1, k)
y2(ntri) = y(i+1, j+1, k)
z2(ntri) = z(i+1, j+1, k)
x3(ntri) = x(i+1, j, k)
y3(ntri) = y(i+1, j, k)
z3(ntri) = z(i+1, j, k)
itype(ntri) = 13
ntri = ntri+1
x1(ntri) = x(i, j, k)
y1(ntri) = y(i, j, k)
z1(ntri) = z(i, j, k)
x2(ntri) = x(i+1, j+1, k)
y2(ntri) = y(i+1, j+1, k)
z2(ntri) = z(i+1, j+1, k)
x3(ntri) = x(i, j+1, k)
y3(ntri) = y(i, j+1, k)
z3(ntri) = z(i, j+1, k)
itype(ntri) = 3
20 continue
!      write(6, 22) ntri
22 format(i10)
!      write(6, 23) (x1(l2), y1(l2), z1(l2), x2(l2), y2(l2), z2(l2), 
!     1             x3(l2), y3(l2), z3(l2), l2=1, ntri)
! 23   format(9f10.7)
!
pi = acos(-1.0)
dtr = pi/180
xeye=eyer*sin(dtr*eyelat)
yeye=xeye*sin(dtr*eyelon)
xeye=xeye*cos(dtr*eyelon)
zeye=eyer*cos(dtr*eyelat)
call vsurf(xeye, yeye, zeye, ntri, x1, y1, z1, x2, y2, z2, &
                 x3, y3, z3, itype, work, iwork)
return
end subroutine visgeo1
subroutine cart2sph(x, y, z, r, theta, phi)
implicit none
real :: phi
real :: r
real :: r1
real :: theta
real :: x
real :: y
real :: z
r1 = x*x+y*y
if (r1 /= 0.) go to 10
phi = 0.
theta = 0.
if (z < 0.) theta = acos(-1.0)
return
10 r = sqrt(r1+z*z)
r1 = sqrt(r1) 
phi = atan2(y, x)
theta = atan2(r1, z)
return
end subroutine cart2sph
subroutine sph2cart(r, theta, phi, x, y, z)
implicit none
real :: phi
real :: r
real :: st
real :: theta
real :: x
real :: y
real :: z
st = sin(theta)
x = r*st*cos(phi)
y = r*st*sin(phi)
z = r*cos(theta)
return
end subroutine sph2cart
subroutine vsurf(xeye, yeye, zeye, ntri, x1, y1, z1, x2, y2, z2, &
                 x3, y3, z3, itype, work, iwork)
implicit none
integer :: itype
integer :: ntri
real :: work
real :: x1
real :: x2
real :: x3
real :: xeye
real :: y1
real :: y2
real :: y3
real :: yeye
real :: z1
real :: z2
real :: z3
real :: zeye
!
!    subroutine vsurf is like subroutine hidel except the triangles
!    are categorized. vsurf is also like solid except triangles rather
!    than lines are covered.
!
!     written by paul n. swarztrauber, national center for atmospheric
!     research, p.o. box 3000, boulder, colorado, 80307  
!
!    this program plots visible lines for the surface defined
!    by the input 3-d triangles with corners at (x1, y1, z1), (x2, y2, z2)
!    and (x3, y3, z3). the sides of these these triangles may or
!    may not be plotted depending on itype. if itype is 1 then the
!    side between points (x1, y1, z1) and (x2, y2, z2) is plotted if it
!    is visible. if itype is 2 then the side between (x2, y2, z2)
!    and (x3, y3, z3) is plotted. if itype is 3 then the visible portion
!    of the side between (x3, y3, z3) and (x1, y1, z1) is plotted.
!    any combination is possible by specifying itype to be one
!    of the following values: 0, 1, 2, 3, 12, 13, 23, 123.
!
!    the length of real    array  work must be at least 14*ntri
!
!    the length of integer array iwork must be at least  6*ntri
!
!
!    the vertices of the triangles are renumbered by vsurf so that
!    their projections are orientated counterclockwise. the user need
!    only be aware that the vertices may be renumbered by vsurf.
!
dimension x1(ntri), y1(ntri), z1(ntri), x2(ntri), y2(ntri), z2(ntri), &
          x3(ntri), y3(ntri), z3(ntri), itype(ntri), work(14*ntri)
integer iwork(6*ntri)
!
call vsurf1(xeye, yeye, zeye, ntri, x1, y1, z1, x2, y2, z2, x3, y3, z3, &
 itype, work, work(ntri+1), work(2*ntri+1), work(3*ntri+1), &
 work(4*ntri+1), work(5*ntri+1), work(6*ntri+1), work(7*ntri+1), &
 work(8*ntri+1), work(9*ntri+1), work(10*ntri+1), work(11*ntri+1), &
 work(12*ntri+1), work(13*ntri+1), iwork, IWORK(ntri+1), &
 IWORK(2*ntri+1), IWORK(4*ntri+1))
return
end subroutine vsurf
subroutine vsurf1(xeye, yeye, zeye, ntri, x1, y1, z1, x2, y2, z2, x3, y3, z3, &
 itype, px1, py1, px2, py2, px3, py3, vx1, vy1, vx2, vy2, vx3, vy3, tl, tr, kh, &
 next, istart, ifinal)
implicit none
real :: a
real :: apl
real :: b
real :: bpl
real :: c
real :: c14
real :: c17
real :: c25
real :: c27
real :: c36
real :: c37
real :: cpl
real :: cprod
real :: d
real :: den
real :: dmx
real :: dmy
real :: dpl
real :: dum1
real :: dum2
real :: dxt
real :: fntri
real :: hdx
real :: hdy
real :: hgr
real :: hr
integer :: i
integer :: i1f
integer :: i1s
integer :: i2
integer :: i2m
integer :: icv
integer :: id
integer :: id1
integer :: id2
integer :: id3
integer :: if
integer :: ifinal
integer :: ifx
integer :: ijd
integer :: il
integer :: ip2
integer :: ir
integer :: ir1
integer :: ir2
integer :: ird
integer :: irdp
integer :: irmax
integer :: irmp1
integer :: irp1
integer :: isd
integer :: isize
integer :: ist
integer :: istart
integer :: isx
integer :: isxm
integer :: ith
integer :: ityp
integer :: itype
integer :: ixf
integer :: ixh
integer :: ixs
integer :: j1
integer :: j1f
integer :: j1s
integer :: j2
integer :: j2m
integer :: jd
integer :: jf
integer :: k
integer :: k1
integer :: k2
integer :: kb
integer :: kcv
integer :: kd
integer :: kdf
integer :: kds
integer :: kh
integer :: ks
integer :: l
integer :: last
integer :: ldo
integer :: lf
integer :: ls
integer :: ltp
integer :: maxs
integer :: nct
integer :: ncv
integer :: next
integer :: ns
integer :: nseg
integer :: nsegp
integer :: ntri
real :: pmax
real :: pmin
real :: px1
real :: px1h
real :: px2
real :: px3
real :: px4
real :: px5
real :: py1
real :: py1h
real :: py2
real :: py3
real :: py4
real :: py5
real :: thold
real :: til
real :: tim
real :: tir
real :: tl
real :: tl1
real :: tl2
real :: tlh
real :: tmax
real :: tmin
real :: tr
real :: trh
real :: vx1
real :: vx1t
real :: vx2
real :: vx2t
real :: vx3
real :: vx3t
real :: vy1
real :: vy1t
real :: vy2
real :: vy2t
real :: vy3
real :: vy3t
real :: vz1t
real :: vz2t
real :: vz3t
real :: x
real :: x1
real :: x1hold
real :: x2
real :: x3
real :: x4
real :: x5
real :: x54
real :: xa
real :: xb
real :: xeye
real :: xmax
real :: xmid
real :: xmin
real :: xpl
real :: xpr
real :: y
real :: y1
real :: y1hold
real :: y2
real :: y3
real :: y4
real :: y5
real :: y54
real :: ya
real :: yb
real :: yeye
real :: ymax
real :: ymid
real :: ymin
real :: ypl
real :: ypr
real :: z
real :: z1
real :: z1hold
real :: z2
real :: z3
real :: z4
real :: z5
real :: zeye
real :: zpl
real :: zpr
!
dimension x1(ntri), y1(ntri), z1(ntri), x2(ntri), y2(ntri), z2(ntri), &
          x3(ntri), y3(ntri), z3(ntri), itype(ntri), &
          px1(ntri), py1(ntri), px2(ntri), py2(ntri), &
          px3(ntri), py3(ntri), vx1(ntri), vy1(ntri), &
          vx2(ntri), vy2(ntri), vx3(ntri), vy3(ntri), &
          tl(ntri), tr(ntri), next(ntri), kh(ntri), &
          istart(2*ntri), ifinal(2*ntri), ltp(3), &
          ird(11), ip2(11), nct(11), ncv(11), last(11)
!
real l2e
real le2
!
!     compute projections of 3-d points
!
le2 = .6931471805599453094172321
l2e = 1.0/le2
fntri = ntri
irmax = .5*l2e*log(fntri)
irmax = min(irmax, 10)
irmp1 = irmax+1
do 4 icv=1, 11
ncv(icv) = 0
4 continue
nct(1) = 0
ip2(1) = 1
ird(1) = 0
isize = 4
do 7 irp1=2, irmp1
ir = irp1-1
nct(irp1) = 0
ip2(irp1) = 2**ir
ird(irp1) = ird(ir)+isize
isize = (ip2(irp1)+1)**2
7 continue 
isxm = ird(irmp1)+isize+1
do 8 isx=1, isxm
istart(isx) = 0
ifinal(isx) = 0
8 continue
do 6 i=1, ntri
next(i) = 0
6 continue 
call prjct(0, xeye, yeye, zeye, x, y, z, dum1, dum2)
!      write(6, 127) ntri
127 format(' ntri in hidel', i5)
do 86 k=1, ntri
call prjct(1, xeye, yeye, zeye, x1(k), y1(k), z1(k), px1(k), py1(k))
call prjct(1, xeye, yeye, zeye, x2(k), y2(k), z2(k), px2(k), py2(k))
call prjct(1, xeye, yeye, zeye, x3(k), y3(k), z3(k), px3(k), py3(k))
  if (k < 3) then
!          write(6, 333) xeye, yeye, zeye, x1(k), y1(k), z1(k), px1(k), py1(k)
333     format(' xeye, etc.', 8e8.1)
  endif
86 continue
!
!     orientate triangles counter clockwise
!
do 70 k=1, ntri
cprod = (px2(k)-px1(k))*(py3(k)-py1(k))-(py2(k)-py1(k)) &
       *(px3(k)-px1(k))
!      if (cprod.eq.0.) write(6, 79) k, px1(k), px2(k), px3(k), 
!     -                              py1(k), py2(k), py3(k)
79 format('  cprod=0 at k=', i5, 6e9.2)
if (cprod>=0.) go to 70
px1h = px1(k)
py1h = py1(k)
px1(k) = px2(k)
py1(k) = py2(k)
px2(k) = px1h
py2(k) = py1h
x1hold = x1(k)
y1hold = y1(k)
z1hold = z1(k)
x1(k) = x2(k)
y1(k) = y2(k)
z1(k) = z2(k)
x2(k) = x1hold
y2(k) = y1hold
z2(k) = z1hold
ityp = itype(k)
if (ityp==2) itype(k) = 3
if (ityp==3) itype(k) = 2
if (ityp==12) itype(k) = 13
if (ityp==13) itype(k) = 12
70 continue
!
!     set screen limits
!
pmax = px1(1)
pmin = px1(1)
do 87 k=1, ntri
pmin = amin1(pmin, px1(k), py1(k), px2(k), py2(k), px3(k), py3(k))
pmax = amax1(pmax, px1(k), py1(k), px2(k), py2(k), px3(k), py3(k))
87 continue
pmin = 1.1*pmin
pmax = 1.1*pmax
call set(0., 1., 0., 1., pmin, pmax, pmin, pmax, 1)
xmin = amin1(px1(1), px2(1), px3(1)) 
xmax = amax1(px1(1), px2(1), px3(1)) 
ymin = amin1(py1(1), py2(1), py3(1)) 
ymax = amax1(py1(1), py2(1), py3(1)) 
do 1 i=2, ntri
xmin = amin1(xmin, px1(i), px2(i), px3(i)) 
xmax = amax1(xmax, px1(i), px2(i), px3(i)) 
ymin = amin1(ymin, py1(i), py2(i), py3(i)) 
ymax = amax1(ymax, py1(i), py2(i), py3(i)) 
1 continue
dmx = xmax-xmin
dmy = ymax-ymin
if (dmx > dmy) go to 2 
c = ymin
d = ymax
xmid = .5*(xmin+xmax)
hdy = .5*dmy
a = xmid-hdy
b = xmid+hdy
go to 3
2 a = xmin
b = xmax
ymid = .5*(ymin+ymax)
hdx = .5*dmx
c = ymid-hdx
d = ymid+hdx
3 hgr = b-a
!
!     categorize triangles
!
do 100 i=1, ntri
xmin = amin1(px1(i), px2(i), px3(i))
xmax = amax1(px1(i), px2(i), px3(i))
ymin = amin1(py1(i), py2(i), py3(i))
ymax = amax1(py1(i), py2(i), py3(i))
dxt = amax1(xmax-xmin, ymax-ymin)
if (dxt > 0.) go to 10
ir = irmax
go to 20
10 ir = l2e*log(hgr/dxt)  
ir = min(ir, irmax)
20 irp1 = ir+1
nct(irp1) = nct(irp1)+1
hr = hgr/ip2(irp1)
xmid = .5*(xmin+xmax)
id = (xmid-a)/hr+1.5
ymid = .5*(ymin+ymax)
jd = (ymid-c)/hr+1.5
ijd = ip2(irp1)+1
isx = id+(jd-1)*ijd+ird(irp1)
ifx = ifinal(isx)
if (ifx > 0) go to 50
istart(isx) = i
go to 60
50 next(ifx) = i 
60 ifinal(isx) = i
100 continue
!      write(6, 106) tcat, (irp1, nct(irp1), irp1=1, irmp1)
106 format(' time to categorize   ', e15.6/(' ir+1', i3, ' ntri', i7))
!
!     sort triangles into boxes
!     
l = 0
do 30 irp1=1, irmp1
if (nct(irp1) == 0) go to 30
ist = ird(irp1)+1    
isd = ip2(irp1)+1
call box(isd, istart(ist), next, l, ifinal)
last(irp1) = l+1
30 continue
do 35 irp1=1, irmp1
il = ird(irp1)+(ip2(irp1)+1)**2+1
if (istart(il) == 0) istart(il) = last(irp1)
35 continue
!      write(6, 31) tsort, l, ntri
31 format(' time to sort  ', e15.6, '   l', i8, '   ntri', i8)
do 90 k=1, ntri
vx1(k) = px2(k)-px1(k)
vy1(k) = py2(k)-py1(k)
vx2(k) = px3(k)-px2(k)
vy2(k) = py3(k)-py2(k)
vx3(k) = px1(k)-px3(k)
vy3(k) = py1(k)-py3(k)
90 continue
tl1 = 0.
tl2 = 0.
maxs = 0
do 500 ir2=1, irmp1
if (nct(ir2) == 0) go to 500
ist = ird(ir2)    
isd = ip2(ir2)+1
do 490 j2=1, isd
do 480 i2=1, isd
ist = ist+1
ls = istart(ist)
lf = istart(ist+1)-1
if (lf < ls) go to 480
!
!     define coverings
!
kcv = 0
i2m = i2-1
j2m = j2-1
do 300 ir1=1, irmp1
if (nct(ir1) == 0) go to 300
if (ir1 >= ir2) go to 260
irdp = 2**(ir2-ir1)
i1s = (i2m-1)/irdp
i1f = (i2m+1)/irdp
if = i2m+1-i1f*irdp
if (if > 0) i1f = i1f+1
j1s = (j2m-1)/irdp
j1f = (j2m+1)/irdp
jf = j2m+1-j1f*irdp
if (jf > 0) j1f = j1f+1
go to 270
260 irdp = 2**(ir1-ir2)
i1s = irdp*(i2m-1)
i1f = irdp*(i2m+1)
j1s = irdp*(j2m-1)
j1f = irdp*(j2m+1)
270 ijd = ip2(ir1)+1
i1s = max(i1s+1, 1)
i1f = min(i1f+1, ijd)
j1s = max(j1s+1, 1)
j1f = min(j1f+1, ijd)
ixh = (j1s-2)*ijd+ird(ir1)
ixs = i1s+ixh
ixf = i1f+ixh
do 290 j1=j1s, j1f
ixs = ixs+ijd
kds = istart(ixs)
ixf = ixf+ijd
kdf = istart(ixf+1)-1
if (kdf < kds) go to 290
do 280 kd=kds, kdf
kcv = kcv+1
kh(kcv) = ifinal(kd) 
280 continue
290 continue
300 continue
do 310 icv=1, 10    
if (kcv <= ncv(icv)) go to 310
ncv(icv) = kcv 
go to 320
310 continue
!
!
320 do 470 ldo=ls, lf
l = ifinal(ldo)
ith = itype(l)
if (ith == 0) go to 470
ltp(1) = 0
ltp(2) = 0
ltp(3) = 0
id1 = ith/100 
ith = ith-100*id1
id2 = ith/10 
id3 = ith-10*id2
if (id1 /= 0) ltp(id1) = 1
if (id2 /= 0) ltp(id2) = 1
if (id3 /= 0) ltp(id3) = 1
!     if ((ith.eq.123) .or. (ith.eq.12) .or.(ith.eq.13)) ltp(1) = 1
!     if ((ith.eq.123) .or. (ith.eq.23) .or.(ith.eq.12)) ltp(2) = 1
!     if ((ith.eq.123) .or. (ith.eq.13) .or.(ith.eq.23)) ltp(3) = 1
do 460 ns=1, 3
go to (101, 102, 103), ns
101 if (ltp(ns) == 0) go to 460
px4 = px1(l)
py4 = py1(l)
px5 = px2(l)
py5 = py2(l)
x4 = x1(l)
y4 = y1(l)
z4 = z1(l)
x5 = x2(l)
y5 = y2(l)
z5 = z2(l)
go to 105
102 if (ltp(ns) == 0) go to 460
px4 = px2(l)
py4 = py2(l)
px5 = px3(l)
py5 = py3(l)
x4 = x2(l)
y4 = y2(l)
z4 = z2(l)
x5 = x3(l)
y5 = y3(l)
z5 = z3(l)
go to 105
103 if (ltp(ns) == 0) go to 460
px4 = px1(l)
py4 = py1(l)
px5 = px3(l)
py5 = py3(l)
x4 = x1(l)
y4 = y1(l)
z4 = z1(l)
x5 = x3(l)
y5 = y3(l)
z5 = z3(l)
105 x54 = px5-px4
y54 = py5-py4
nseg = 0
do 440 kd=1, kcv
k = kh(kd) 
c17 = vx1(k)*y54-vy1(k)*x54
c27 = vx2(k)*y54-vy2(k)*x54
c37 = vx3(k)*y54-vy3(k)*x54
c14 = vy1(k)*(px4-px1(k))-vx1(k)*(py4-py1(k))
c25 = vy2(k)*(px4-px2(k))-vx2(k)*(py4-py2(k))
c36 = vy3(k)*(px4-px3(k))-vx3(k)*(py4-py3(k))
tmin = 0.
tmax = 1.
if (c17< 0) then
    goto 151
else if (c17 == 0) then 
    goto 152
else 
    goto 153
end if
151 tmax = amin1(c14/c17, tmax)   
go to 154
152 if (c14< 0) then
    goto 154
else if (c14 == 0) then 
    goto 440
else 
    goto 440
end if
153 tmin = amax1(c14/c17, tmin)
154 if (c27< 0) then
        goto 155
    else if (c27 == 0) then 
        goto 156
    else 
        goto 157
    end if
155 tmax = amin1(c25/c27, tmax)   
go to 158
156 if (c25< 0) then
    goto 158
else if (c25 == 0) then 
    goto 440
else 
    goto 440
end if
157 tmin = amax1(c25/c27, tmin)
158 if (c37< 0) then
        goto 159
    else if (c37 == 0) then 
        goto 160
    else 
        goto 161
    end if
159 tmax = amin1(c36/c37, tmax)   
go to 162
160 if (c36< 0) then
    goto 162
else if (c36 == 0) then 
    goto 440
else 
    goto 440
end if
161 tmin = amax1(c36/c37, tmin)
162 if (tmax-tmin < .00001) go to 440
xpl = x4+tmin*(x5-x4)
ypl = y4+tmin*(y5-y4)
zpl = z4+tmin*(z5-z4)
xpr = x4+tmax*(x5-x4)
ypr = y4+tmax*(y5-y4)
zpr = z4+tmax*(z5-z4)
!
!     the projections of line and plane intersect
!     now determine if plane covers line
!
vx1t = x2(k)-x1(k)
vy1t = y2(k)-y1(k)
vz1t = z2(k)-z1(k)
vx2t = x3(k)-x1(k)
vy2t = y3(k)-y1(k)
vz2t = z3(k)-z1(k)
apl = vy1t*vz2t-vy2t*vz1t
bpl = vx2t*vz1t-vx1t*vz2t
cpl = vx1t*vy2t-vx2t*vy1t
dpl = apl*x1(k)+bpl*y1(k)+cpl*z1(k)
vx3t = xpl-xeye
vy3t = ypl-yeye
vz3t = zpl-zeye
den = apl*vx3t+bpl*vy3t+cpl*vz3t
til = 0.
if (den == 0.) go to 410
til = (dpl-apl*xeye-bpl*yeye-cpl*zeye)/den
410 vx3t = xpr-xeye
vy3t = ypr-yeye
vz3t = zpr-zeye
den = apl*vx3t+bpl*vy3t+cpl*vz3t
tir = 0.
if (den == 0.) go to 412
tir = (dpl-apl*xeye-bpl*yeye-cpl*zeye)/den
412 if (til>=.99999.and.tir>=.99999) go to 440
if (til<1..and.tir<1.) go to 164
vx3t = xpr-xpl
vy3t = ypr-ypl
vz3t = zpr-zpl
den = apl*vx3t+bpl*vy3t+cpl*vz3t
tim = 0.
if (den == 0.) go to 414
tim = (dpl-apl*xpl-bpl*ypl-cpl*zpl)/den
414 thold = tmin+tim*(tmax-tmin)
if (til>=1.) go to 163
tmax = thold
go to 164
163 tmin = thold
164 nseg = nseg+1
tl(nseg) = tmin
tr(nseg) = tmax
440 continue
maxs = max(maxs, nseg)
if (nseg-1< 0) then
    goto 171
else if (nseg-1 == 0) then 
    goto 180
else 
    goto 172
end if
171 call line(px4, py4, px5, py5)
go to 460
!
!     order the segments according to left end point tl(k)
!
172 do 173 k=2, nseg
do 173 i=k, nseg
if (tl(k-1)<=tl(i)) go to 173
tlh = tl(k-1)
trh = tr(k-1)
tl(k-1) = tl(i)
tr(k-1) = tr(i)
tl(i) = tlh
tr(i) = trh
173 continue
!
!     eliminate segment overlap
!
k1 = 1
k2 = 1
174 k2 = k2+1
if (k2>nseg) go to 176
if (tr(k1)<tl(k2)) go to 175
tr(k1) = amax1(tr(k1), tr(k2))
go to 174
175 k1 = k1+1
tl(k1) = tl(k2)
tr(k1) = tr(k2)
go to 174
176 nseg = k1
!
!     plot all segments of the line
!
180 do 181 ks =1, nseg
kb = nseg-ks+1
tl(kb+1) = tr(kb)
tr(kb) = tl(kb)
181 continue
tl(1) = 0.
tr(nseg+1) = 1.
nsegp = nseg+1
do 450 k=1, nsegp
if (abs(tr(k)-tl(k))<.000001) go to 450
xa = px4+tl(k)*(px5-px4)
ya = py4+tl(k)*(py5-py4)
xb = px4+tr(k)*(px5-px4)
yb = py4+tr(k)*(py5-py4)
call line(xa, ya, xb, yb)
450 continue
460 continue
470 continue
480 continue
490 continue
500 continue
!      write(6, 903) tl1, tl2
903 format(' time to cover', e15.6/ &
       ' time to test ', e15.6)
!      write(6, 904) maxs
904 format(' maximum number of segments', i5)
!      write(6, 250) (ncv(icv), icv=1, 10)
250 format('  the ten largest coverings'/(10i5))
call frame
end subroutine vsurf1
subroutine prjct(init, xeye, yeye, zeye, x, y, z, px, py)
implicit none
real :: cx1
real :: cx2
real :: cx3
real :: cy1
real :: cy2
real :: cy3
real :: cz2
real :: cz3
real :: d1
real :: d2
integer :: init
real :: px
real :: py
real :: rads1
real :: rads2
real :: ratio
real :: x
real :: x1
real :: xeye
real :: y
real :: y1
real :: yeye
real :: z
real :: z1
real :: zeye
!
!     subroutine prjct projects the point x, y, z onto a plane through
!     the origin that is perpendicular to a line between the origin
!     and the eye. the projection is along the line between the eye
!     and the point x, y, z. px and py are the coordinates of the
!     projection in the plane.
!     (version 2 , 12-10-82)
!
save
if (init/=0) go to 1
rads1 = xeye**2+yeye**2
rads2 = rads1+zeye**2
d1 = sqrt(rads1)
d2 = sqrt(rads2)
if (d1/=0.) go to 2
cx1 = 1.
cy1 = 0.
cx2 = 0.
cy2 = 1.
cz2 = 0.
cx3 = 0.
cy3 = 0.
cz3 = 1.
return
2 cx1 = -yeye/d1
cy1 = xeye/d1
cx2 = -xeye*zeye/(d1*d2)
cy2 = -yeye*zeye/(d1*d2)
cz2 = d1/d2
cx3 = xeye/d2
cy3 = yeye/d2
cz3 = zeye/d2
return
1 x1 = cx1*x+cy1*y
y1 = cx2*x+cy2*y+cz2*z
z1 = cx3*x+cy3*y+cz3*z
ratio = d2/(d2-z1)
px = ratio*x1
py = ratio*y1
return
end subroutine prjct
subroutine box(isd, istart, next, l, list)
implicit none
integer :: id
integer :: idx
integer :: isd
integer :: istart
integer :: jd
integer :: l
integer :: list
integer :: next
dimension istart(isd, isd), next(1), list(1)
do 30 jd=1, isd
do 10 id=1, isd
idx = istart(id, jd)
istart(id, jd) = l+1
if (idx == 0) go to 10
20 l = l+1
list(l) = idx
if (next(idx) == 0) go to 10
idx = next(idx)
go to 20
10 continue
30 continue
return
end subroutine box
