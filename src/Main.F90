program main

    use ModelParameterMod
    use SoilParameterMod
    use SoilConstantMod
    use TridiagonalMod
    use SoilTypeMod

    implicit none

    type(soiltexttype) :: soil_text
    type(soilhydrtype) :: soil_hydr
    type(soildisctype) :: soil_disc
    type(soilheatype)  :: soil_heat
    type(waterfluxtype):: water_flx

    integer, parameter :: n = 5  ! 矩阵大小
    real(kind=16) :: a(n), b(n), c(n), r(n), u(n)  ! 矩阵和解向量
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
    print *, "print clay data"
    print *, soil_text%clay_s

end program main