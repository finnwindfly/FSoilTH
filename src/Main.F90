program main

    use ModelParameterMod
    use SoilParameterMod
    use SoilConstantMod
    use TridiagonalMod
    use SoilTypeMod
    use SoilHydrologyMod

    implicit none

    type(soiltexttype) :: soil_text
    type(soilhydrtype) :: soil_hydr
    type(soildisctype) :: soil_disc
    type(soilheatype)  :: soil_heat
    type(waterfluxtype):: water_flx

    integer, parameter :: n = 5  ! 矩阵大小
    real(kind=4) :: a(n), b(n), c(n), r(n), u(n)  ! 矩阵和解向量
    integer :: i  ! 循环变量

    print *, author_name
    print *, nlevsoi
    print *, cpliq

    print *, "here start using Tridiagonal Matrix solution:"

    ! 初始化矩阵和外力项
    a = 1.0
    b = 2.0
    c = 1.0
    r = (/ (real(i), i=1,n) /)

    ! 调用Tridiagonal模块中的子程序解决矩阵
    call Tridiagonal(1, n, 1, a, b, c, r, u)

    ! 打印解向量
    print *, "Solution Vector u:"
    print *, u

    ! 输出type数据
    call InitializeSoilData(soil_disc, soil_text, soil_hydr, soil_heat, water_flx)
    print *, "print soil depth"
    ! print *, soil_disc%z_s
    print *, soil_disc%dz_s
    ! print *, soil_disc%zi_s
    print *, "Print soil initial h2osoi_liq_s"
    print *, soil_hydr%h2osoi_liq_s

    ! 计算土壤导水率与土壤基质势
    call HydraulicProperties(soil_disc, soil_text, soil_hydr)
    print *, "soil hydraulic conductivity"
    print *,  soil_hydr%hk_s
    print *, "soil matrix potential"
    print *,  soil_hydr%smp_s

    ! 计算土壤地表径流
    call SurfaceRunoff(soil_hydr, soil_disc, water_flx)
    print *, "water table depth"
    print *, soil_hydr%zwt_s
    print *, "Surface Runoff"
    print *, water_flx%qflx_surf_s
    print *, "Infiltration"
    print *, water_flx%qflx_infl_s
end program main