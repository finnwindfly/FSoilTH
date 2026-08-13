module EmptyNetcdfMod

  use netcdf
  implicit none

contains

  subroutine check(status, line_number)
    integer, intent(in) :: status
    integer, optional, intent(in) :: line_number
    character(len=256) :: error_message

    if (status /= nf90_noerr) then
      error_message = trim(adjustl(nf90_strerror(status)))
      if (present(line_number)) then
        print *, "Error at line", line_number, ":", error_message
      else
        print *, "Error:", error_message
      end if
      stop 'Stopped'
    end if
  end subroutine check

  subroutine create_empty_netcdf(filename)
    character(len=*), intent(in) :: filename
    integer :: ncid

    ! create new empty netcdf file
    call check(nf90_create(filename, nf90_clobber, ncid), __LINE__)

    ! close this file
    call check(nf90_close(ncid), __LINE__)

  end subroutine create_empty_netcdf

end module EmptyNetcdfMod