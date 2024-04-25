!--------------------------------------------------------------------------------------------------
module SoilTypeMod

  use ModelParameterMod,  only : surfdataname
  use SoilParameterMod,   only : nlevsoi


  implicit none
  save

  ! Define types
  type, public :: soildisctype
    real, allocatable :: dz_s(:)
    real, allocatable :: z_s(:)
    real, allocatable :: zi_s(:)
  end type soildisctype

  type, public :: soiltexttype
    real, allocatable :: clay_s(:)
    real, allocatable :: sand_s(:)
    real, allocatable :: organic_s(:)
  end type soiltexttype

  type, public :: soilhydrtype
    real, allocatable :: h2osoi_liq_s(:)         ! liquid water in soil
    real, allocatable :: h2osoi_ice_s(:)         ! ice water
    real, allocatable :: watsat_s(:)          ! volumetric soil water at saturation(porosity)
    real, allocatable :: eff_porosity_s(:)    ! effective porosity = porosity - vol_ice
    real, allocatable :: slopb_s(:)           ! the exponent B
    real, allocatable :: hk_s(:)              ! the hydraulic conductivity of soil
    real, allocatable :: dhkdw_s(:)           ! d(hk)/d(vol_liq)
    real, allocatable :: smp_s(:)             ! soil matrix potential
    real, allocatable :: dsmpdw_s(:)          ! d(smp)/d(vol_liq)
    real, allocatable :: wetness_s(:)         ! soil wetness in soil
    real              :: zwt_s                ! water table depth
    real              :: fcov_s               ! fractional area with water table at surface
  end type soilhydrtype

  type, public :: soilheatype
    real, allocatable :: tsoisno_s(:)         ! soil temperature at n time step
    real, allocatable :: tsoisnot_s(:)        ! soil tmeperature at n-1 time step
    real, allocatable :: thk_s(:)             ! soil thermal conductivity at z
    real, allocatable :: tk_s(:)              ! soil thermal conductivity at zi
    real, allocatable :: cv_s(:)              ! soil heat capacity
    real              :: eflx_gnet_s          ! one-dimensional energy flux into upper soil layer
    real              :: eflx_snsh_s          ! one-dimensional sensible heat into upper soil layer
    real              :: eflx_snsht_s         ! one-dimensional sensible heat at n-1 time into upper soil layer
    real              :: eflx_poth_s          ! one-dimensional potential heat into upper soil layer
    real              :: eflx_potht_s         ! one-dimensional potential heat at n-1 into upper soil layer
  end type soilheatype

  type, public :: waterfluxtype
    real, allocatable :: dwat_s(:)            ! change in soil water
    real              :: qflx_top_s           ! net water input into soil from top (mm/s)
    real              :: qflx_surf_s          ! surface runoff (mm/s)
    real              :: qflx_infl_s          ! infiltration (mm/s)
    real              :: qflx_drain_s         ! sub-surface runoff
  end type waterfluxtype

contains

  subroutine InitializeSoilData(soil_disc, soil_text, soil_hydr, soil_heat, water_flx)
    ! Inputs
    class (soildisctype) :: soil_disc
    class (soiltexttype) :: soil_text
    class (soilhydrtype) :: soil_hydr
    class (soilheatype)  :: soil_heat
    class (waterfluxtype):: water_flx
    ! Local variables
    integer :: j

    ! Allocate and initialize soil_disc data (example values)
    allocate(soil_disc%dz_s(1:nlevsoi), soil_disc%z_s(1:nlevsoi), soil_disc%zi_s(1:nlevsoi+1))
    ! calculate the dz, z, and zi
    soil_disc%z_s(1) = 0.05
    soil_disc%z_s(2) = 0.1
    soil_disc%z_s(3) = 0.2
    soil_disc%z_s(4) = 0.3
    soil_disc%z_s(5) = 0.4
    soil_disc%z_s(6) = 0.5
    soil_disc%z_s(7) = 0.6
    soil_disc%z_s(8) = 0.8
    soil_disc%z_s(9) = 1.0
    soil_disc%z_s(10) = 1.2
    soil_disc%z_s(11) = 1.4
    soil_disc%z_s(12) = 1.6
    soil_disc%z_s(13) = 2.0
    soil_disc%z_s(14) = 2.5
    soil_disc%z_s(15) = 3.0
    soil_disc%z_s(16) = 3.5
    soil_disc%z_s(17) = 5.0
    soil_disc%z_s(18) = 6.5
    soil_disc%z_s(19) = 8.0
    soil_disc%z_s(20) = 10.0

    soil_disc%dz_s(1) = 0.5*(soil_disc%z_s(1)+soil_disc%z_s(2))
    do j = 2, nlevsoi-1
      soil_disc%dz_s(j) = 0.5*(soil_disc%z_s(j+1)-soil_disc%z_s(j-1))
    enddo
    soil_disc%dz_s(nlevsoi) = soil_disc%z_s(nlevsoi) - soil_disc%z_s(nlevsoi-1)

    soil_disc%zi_s(1) = 0.
    do j = 2, nlevsoi
      soil_disc%zi_s(j) = 0.5*(soil_disc%z_s(j)+soil_disc%z_s(j+1))
    enddo
    soil_disc%zi_s(nlevsoi+1) = soil_disc%z_s(nlevsoi) + 0.5*soil_disc%dz_s(nlevsoi)


    ! Allocate and initialize soil_text data (example values)
    allocate(soil_text%clay_s(1:nlevsoi))
    allocate(soil_text%sand_s(1:nlevsoi))
    allocate(soil_text%organic_s(1:nlevsoi))

    ! call read_netcdf(trim(surfdataname), trim('sand'), trim('nlevsoi'), soil_text%sand_s)
    !call read_netcdf(trim(surfdataname), trim('clay'), trim('nlevsoi'), soil_text%clay_s)
    !call read_netcdf(trim(surfdataname), trim('organic'), trim('nlevsoi'), soil_text%organic_s)
    soil_text%clay_s = (/8.56,11.02,8.84,10.57,7.99,9.33,7.34,5.43,3.89,1.54,4.29,9.71,9.71,&
    9.71,9.71,9.71,9.71,9.71,9.71,9.71/)
    soil_text%sand_s = (/35.87,29.94,34.09,41.63,49.08,48.94,52.89,68.78,78.13,91.6,&
    77.5,50.91,50.91,50.91,50.91,50.91,50.91,50.91,50.91,50.91/)
    soil_text%organic_s =(/129.06,81.41,56.69,21.85,19.50,13.18,12.72,7.36,3.53,&
    2.44,2.26,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57/)/130.0


    ! Allocate soil_hydr data
    allocate(soil_hydr%hk_s(1:nlevsoi))             ; soil_hydr%hk_s(:)          = 0.0
    allocate(soil_hydr%h2osoi_liq_s(1:nlevsoi))
    soil_hydr%h2osoi_liq_s  = (/0.321, 0.322, 0.293, 0.293, 0.262, 0.262, 0.262, 0.134, 0.134, 0.134, &
    0.134, 0.109, 0.109, 0.109, 0.109, 0.109, 0.109, 0.109, 0.109, 0.109/)
    allocate(soil_hydr%h2osoi_ice_s(1:nlevsoi))
    soil_hydr%h2osoi_ice_s  = (/0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0/)
    allocate(soil_hydr%watsat_s(1:nlevsoi))         ; soil_hydr%watsat_s(:)      = 0.0
    allocate(soil_hydr%eff_porosity_s(1:nlevsoi))   ; soil_hydr%eff_porosity_s(:)= 0.0
    allocate(soil_hydr%slopb_s(1:nlevsoi))          ; soil_hydr%slopb_s(:)       = 0.0
    allocate(soil_hydr%dhkdw_s(1:nlevsoi))          ; soil_hydr%dhkdw_s(:)       = 0.0
    allocate(soil_hydr%wetness_s(1:nlevsoi))        ; soil_hydr%wetness_s(:)     = 0.0
    allocate(soil_hydr%smp_s(1:nlevsoi))            ; soil_hydr%smp_s(:)         = 0.0
    allocate(soil_hydr%dsmpdw_s(1:nlevsoi))         ; soil_hydr%dsmpdw_s(:)      = 0.0
    soil_hydr%zwt_s     = 0.0
    soil_hydr%fcov_s    = 0.0

    ! Allocate soil_heat data
    allocate(soil_heat%tsoisno_s(1:nlevsoi))
    soil_heat%tsoisno_s   = (/7.208, 6.975, 7.308, 7.308, 8.85, 8.85, 8.85, 7.22, 7.22, 7.22,&
    5.488, 5.488, 5.488, 5.488, 5.488, 5.488, 5.488, 5.488, 5.488, 5.488/) + 273.15
    allocate(soil_heat%tsoisnot_s(1:nlevsoi))
    soil_heat%tsoisnot_s  = (/6.774, 6.795, 7.324, 7.324, 8.86, 8.86, 8.86, 7.22, 7.22, 7.22,&
    5.486, 5.486, 5.486, 5.486, 5.486, 5.486, 5.486, 5.486, 5.486, 5.486/) + 273.15
    allocate(soil_heat%thk_s(1:nlevsoi))            ; soil_heat%thk_s(:)         = 0.0
    allocate(soil_heat%tk_s(1:nlevsoi))             ; soil_heat%tk_s(:)          = 0.0
    allocate(soil_heat%cv_s(1:nlevsoi))             ; soil_heat%cv_s(:)          = 0.0
    soil_heat%eflx_gnet_s     = 0.0
    soil_heat%eflx_snsh_s     = 0.0
    soil_heat%eflx_snsht_s    = 0.0
    soil_heat%eflx_poth_s     = 0.0
    soil_heat%eflx_potht_s    = 0.0

    ! Allocate water flux data
    allocate(water_flx%dwat_s(1:nlevsoi))           ; water_flx%dwat_s(:)        = 0.0
    water_flx%qflx_top_s      = 0.0
    water_flx%qflx_surf_s     = 0.0
    water_flx%qflx_infl_s     = 0.0
    water_flx%qflx_drain_s    = 0.0


  end subroutine InitializeSoilData

end module SoilTypeMod
