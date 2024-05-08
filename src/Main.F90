program main

    use ModelParameterMod
    use SoilParameterMod
    use SoilConstantMod
    use TridiagonalMod
    use SoilTypeMod
    use SoilHydrologyMod
    use SoilTemperatureMod

    implicit none

    type(soiltexttype) :: soil_text
    type(soilhydrtype) :: soil_hydr
    type(soildisctype) :: soil_disc
    type(soilheatype)  :: soil_heat
    type(waterfluxtype):: water_flx

    ! local forcing data
    real(kind=4), allocatable :: eflx_gnet_loc(:)
    real(kind=4), allocatable :: qflx_top_loc(:)   ! this 20 means 20 times
    real(kind=4), allocatable :: tsoisno_out(:,:)
    real(kind=4), allocatable :: h2osoi_liq_out(:,:)
    real(kind=4), allocatable :: vol_liq_out(:,:)
    real(kind=4), allocatable :: h2osoi_ice_out(:,:)

    allocate(h2osoi_ice_out(1:steptime,1:nlevsoi))

    h2osoi_ice_out = -999.9

    print *, "put h2osoi_ice_out"

    print *, h2osoi_ice_out
    ! 释放内存
    deallocate(h2osoi_ice_out)




end program main