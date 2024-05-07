module NetcdfReadMod
  use netcdf
  implicit none

  public  :: read_netcdf
  private :: check

contains

  SUBROUTINE check(istatus, line_number)
    use netcdf
    implicit none
    integer, intent(in) :: istatus
    integer, optional, intent(in) :: line_number

    CHARACTER(LEN=256) :: error_message

    IF (istatus /= nf90_noerr) THEN
      error_message = TRIM(ADJUSTL(nf90_strerror(istatus)))
      IF (PRESENT(line_number)) THEN
        PRINT *, "Error occurred in line", line_number, ":", error_message
      ELSE
        PRINT *, "Error occurred:", error_message
      END IF
    END IF
    END SUBROUTINE check

  SUBROUTINE read_netcdf(infile, varname, dimname, idata)
    use netcdf
    IMPLICIT NONE
    REAL(KIND=8), DIMENSION(:), ALLOCATABLE, INTENT(OUT) :: idata
    CHARACTER(LEN=*), INTENT(IN) :: infile
    CHARACTER(LEN=*), INTENT(IN) :: varname
    CHARACTER(LEN=*), INTENT(IN) :: dimname
    INTEGER :: ncid, varid, status, xlen, dimid

    ! open nc file
    CALL check(nf90_open(infile, nf90_nowrite, ncid), __LINE__)

    ! get the dimid of dimname
    CALL check(nf90_inq_dimid(ncid, dimname, dimid), __LINE__)

    ! get the length of dimid
    CALL check(nf90_inquire_dimension(ncid, dimid, len = xlen), __LINE__)

    print *, xlen

    ! allocate idata
    ALLOCATE(idata(xlen))


    ! get the varid of varname
    CALL check(NF90_INQ_VARID(ncid, varname, varid), __LINE__)

    ! get the data values of varid
    CALL check(NF90_GET_VAR(ncid, varid, idata), __LINE__)

    ! close the nc file
    CALL check(nf90_close(ncid), __LINE__)
  END SUBROUTINE read_netcdf

end module NetcdfReadMod