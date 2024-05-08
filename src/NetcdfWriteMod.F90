module NetcdfWriteMod

  use netcdf
  implicit none

  public :: write_netcdf
  private :: check

contains

  subroutine check(istatus, line_number)
    integer, intent(in) :: istatus
    integer, optional, intent(in) :: line_number
    character(len=256) :: error_message

    if (istatus /= nf90_noerr) then
      error_message = trim(adjustl(nf90_strerror(istatus)))
      if (present(line_number)) then
        print *, "Error in line", line_number, ":", error_message
      else
        print *, "Error:", error_message
      endif
      stop 'Stopped'
    endif
  end subroutine check

  subroutine write_netcdf(filename, varname, dimname, data, attr_name, attr_value)
    character(len=*), intent(in) :: filename, varname, dimname
    real(kind=8), dimension(:), intent(in) :: data
    character(len=*), intent(in) :: attr_name, attr_value
    integer :: ncid, varid, dimid
    integer :: dimlen

    dimlen = size(data)

    ! Create a new nc file or replace an existing one
    call check(nf90_open(filename, nf90_write, ncid), __LINE__)

    ! Put the file back into define mode if it was in data mode
    call check(nf90_redef(ncid), __LINE__)

    ! Define the dimension
    call check(nf90_def_dim(ncid, dimname, dimlen, dimid), __LINE__)

    ! Define the variable
    call check(nf90_def_var(ncid, varname, nf90_double, dimid, varid), __LINE__)

    ! Define the attribute
    call check(nf90_put_att(ncid, varid, attr_name, attr_value), __LINE__)

    ! End define mode and into data mode
    call check(nf90_enddef(ncid), __LINE__)

    ! Write the variable
    call check(nf90_put_var(ncid, varid, data), __LINE__)

    ! Close the nc file
    call check(nf90_close(ncid), __LINE__)

  end subroutine write_netcdf

end module NetcdfWriteMod