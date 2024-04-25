!--------------------------------------------------------------------------------------------------
module TridiagonalMod

! !PUBLIC TYPES:
  implicit none
  save

! !PUBLIC MEMBER FUNCTIONS:
  public :: Tridiagonal

contains

!
! SUBROUTINE: Tridiagonal
!
! Tridiagonal matrix solution
! using for solve soil one-dimension heat transfer equation &
! soil one-dimension water transfer equation

  subroutine Tridiagonal(lbj, ubj, jtop, a, b, c, r, u)

! !ARGUMENTS:
    implicit none
    integer , intent(in)         :: lbj, ubj               ! lbinning and ubing level indices
    integer , intent(in)         :: jtop                   ! top level for each column
    real(kind=4), intent(in)    :: a(lbj:ubj)             ! "a" left off diagonal oftridiagonal matrix
    real(kind=4), intent(in)    :: b(lbj:ubj)             ! "b" diagonal column for tridiagonal matrix
    real(kind=4), intent(in)    :: c(lbj:ubj)             ! "c" right off diagonal tridiagonal matrix
    real(kind=4), intent(in)    :: r(lbj:ubj)             ! "r" forcing term of tridiagonal matrix
    real(kind=4), intent(inout) :: u(lbj:ubj)             ! solution
!
! !REVISION HISTORY:
! Finn Windfly, Initial code, 2023.12.12

! !LOCAL VARIABLES:
    integer       :: j                 !indices
    real(kind=4) :: gam(lbj:ubj)      !temporary
    real(kind=4) :: bet               !temporary

    ! solve the matrix
    bet = b(jtop)

    do j = lbj, ubj
      if (j >= jtop) then
        if (j == jtop) then
          u(j) = r(j) / bet
        else
          gam(j) = c(j-1) / bet
          bet = b(j) - a(j) * gam(j)
          u(j) = (r(j) - a(j)*u(j-1)) / bet
        end if
      end if
    end do

    do j = ubj-1,lbj,-1
      if (j >= jtop) then
        u(j) = u(j) - gam(j+1) * u(j+1)
      end if
    end do

  end subroutine Tridiagonal

end module TridiagonalMod