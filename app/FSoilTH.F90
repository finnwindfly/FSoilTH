program FSoilTH

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

    integer :: i  ! 循环变量
    real(kind=4) :: vol_liq(1:nlevsoi)

    ! local forcing data
    real(kind=4), allocatable :: eflx_gnet_loc(:)
    real(kind=4), allocatable :: qflx_top_loc(:)   ! this 20 means 20 times
    real(kind=4), allocatable :: tsoisno_out(:,:)
    real(kind=4), allocatable :: h2osoi_liq_out(:,:)
    real(kind=4), allocatable :: vol_liq_out(:,:)
    real(kind=4), allocatable :: h2osoi_ice_out(:,:)

    allocate(h2osoi_ice_out(1:steptime,1:nlevsoi))

    h2osoi_ice_out = -999.9
    ! 释放内存
    deallocate(h2osoi_ice_out)

    print *, "FSoilTH prototype driver"

    ! 输出type数据
    call InitializeSoilData(soil_disc, soil_text, soil_hydr, soil_heat, water_flx)
    print *, "z_s:"
    print *, soil_disc%z_s
    print *, "zi_s:"
    print *, soil_disc%zi_s
    ! print *, "Print soil initial h2osoi_liq_s"
    ! print *, soil_hydr%h2osoi_liq_s
    ! print *, "Soil initilization temperature"
    ! print *, soil_heat%tsoisno_s

    ! 计算土壤导水率与土壤基质势
    call HydraulicProperties(soil_disc, soil_text, soil_hydr)
    ! print *, "soil hydraulic conductivity"
    ! print *,  soil_hydr%hk_s
    ! print *, "soil matrix potential"
    ! print *,  soil_hydr%smp_s

    ! 计算土壤地表径流
    call SurfaceRunoff(soil_hydr, soil_disc, water_flx)
    ! print *, "water table depth"
    ! print *, soil_hydr%zwt_s
    ! print *, "Surface Runoff"
    ! print *, water_flx%qflx_surf_s
    ! print *, "Infiltration"
    ! print *, water_flx%qflx_infl_s

    ! 计算土壤的水分upadate
    call SoilWater(soil_hydr, soil_disc, water_flx)
    ! print *, "update soil water"
    ! do i=1,nlevsoi
    !     ! Porosity of soil, partial volume of ice and liquid
    !     ! vol_ice(i) = min(soil_hydr%watsat_s(i), zero))
    !     vol_liq(i) = min(soil_hydr%eff_porosity_s(i),soil_hydr%h2osoi_liq_s(i)/(soil_disc%dz_s(i)*rho_fwater))
    ! end do
    ! print *, vol_liq

    ! 计算drainage
    call Drainage(soil_hydr, soil_disc, water_flx)
    ! print *, "Drainage:"
    ! print *, water_flx%qflx_drain_s

    ! 计算土壤导热率
    call SoilThermalPropers(soil_disc, soil_text, soil_heat, soil_hydr)
    print *, "soil thermal conductivity"
    print *, soil_heat%tk_s

    ! 计算土壤温度
    call SoilTemperature(soil_disc, soil_heat)
    print *, "SoilTemperature"
    print *, soil_heat%tsoisno_s

end program FSoilTH
