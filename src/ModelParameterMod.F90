module ModelParameterMod

    implicit none

    ! define all necessary paramters for this model.

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! first define the parameters control the model's running

    integer, public             :: dtime = 10800                        ! time for every step time
    integer, public             :: steptime = 20                        ! all time for run
    character(len=*), parameter :: surfdataname = "surfcedata.nc"
    character(len=*), parameter :: forcedataname = "forcedata.nc"
    character(len=*), parameter :: author_name = "Finn Windfly"

end module ModelParameterMod