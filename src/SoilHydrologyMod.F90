!--------------------------------------------------------------------------------------------------
module SoilHydrologyMod

!DESCRIPTION:
!
! Calculate soil hydrology including calculate Hydrualic_Properties fo soil,
! SurfaceRunoff, Infiltration, Soil_water_movement,  and Drainage
! which SurfaceRunoff; Infiltration; Drainage's subroutines were adapted from
! CLM3.5 or CLM5.0.
!
! Hydrualic_Properties' method is also adapted from CLM3.5, but modified some
! crucial parameters
!
! And for SoilWater subroutine, the method of freezing and thawing; SWC or SFC
! curve's paramterizations, are adapted from GEOtop and STEMMUS-FT model
! Dall'Amico 2010; Zeng et al., 2011
!
!
  use SoilTypeMod

  implicit none
  save

  public :: HydraulicProperties
  public :: SurfaceRunoff        ! Calculate surface runoff, which is adapted from CLM3.5
  public :: Infiltration         ! Calculate infiltration into surface soil layer, which was adapted from CLM3.5
  public :: SoilWater            ! Calculate soil hydrology, which was adapted from CLM3.5

contains

  subroutine HydraulicProperties(soil_disc, soil_text, soil_hydr)
    ! Inputs
    use SoilConstantMod,   only : rho_fwater, rho_ice, LatH_fus, grav,Temp_frez_f
    use SoilParameterMod,  only : nlevsoi !the total layers number. the default values of this is 20.

    implicit none
    save
    type(soildisctype), intent(in) :: soil_disc
    type(soiltexttype), intent(in) :: soil_text
    type(soilhydrtype), intent(inout) :: soil_hydr

    ! Local variables
    integer :: j
    real(kind=4) :: vol_w_sat_org = 0.9      !porosity of organic matter = 0.9 (Farouki 1981; Letts et al.2009)
    real(kind=4) :: vol_w_sat_min(1:nlevsoi)!the porosity of mineral [mm^3/mm^3]
    real(kind=4) :: slopb_org = 2.7         !the slop of b for organic matter.(Letts et al. 2000)
    real(kind=4) :: slopb_min(1:nlevsoi)    !the slop of b for mineral [no unit]
    real(kind=4) :: hk_sat(1:nlevsoi)       !saturated_soil_hydraulic_conductivity[mm/s]
    real(kind=4) :: interm1                 !intermediate variables 1 for calculating soil hydraulic conductivity
    real(kind=4) :: interm2                 !intermediate variables 2 for calculating soil hydraulic conductivity
    real(kind=4) :: smp_sat(1:nlevsoi)      !soil_matric_potential_at_saturated [mm]
    real(kind=4) :: smp_org = -10.3         !soil_matric_potential_of_organic_matter [mm] (Letts et la. 2000)
    real(kind=4) :: smp_min(1:nlevsoi)      !soil_matric_potential_of_mineral [mm]
    real(kind=4) :: interm3                 !intermediate variable 3 for calculating soil matric potential.
    real(kind=4) :: vol_ice(1:nlevsoi)
    real(kind=4) :: vol_liq(1:nlevsoi)
    !real(kind=4) :: smp_s(1:nlevsoi)
    !real(kind=4) :: dsmpdw(1:nlevsoi)
    !print *, soil_text%sand_s(1)
    ! Associate pointers
    associate(dz           => soil_disc%dz_s, &
              clay         => soil_text%clay_s, &
              sand         => soil_text%sand_s, &
              organic      => soil_text%organic_s, &
              h2osoi_liq   => soil_hydr%h2osoi_liq_s, &
              h2osoi_ice   => soil_hydr%h2osoi_ice_s, &
              eff_porosity => soil_hydr%eff_porosity_s)

      !initialize the hydraulic_properties values.
      vol_w_sat_min     = 0.0
      slopb_min         = 0.0
      hk_sat            = 0.0
      smp_sat           = 0.0
      smp_min           = 0.0
      vol_ice           = 0.0
      vol_liq           = 0.0

      do j = 1, nlevsoi

         ! Fist for porosity
         vol_w_sat_min(j) = 0.489-(0.00126*sand(j)) !calculate the porosity of mineral

         soil_hydr%watsat_s(j) = (1.0-organic(j))*vol_w_sat_min(j) + organic(j)*vol_w_sat_org !calculate the porosity of each soil layer.

         ! second for component "B"
         slopb_min(j) = 2.91+(0.159*clay(j)) !calculate the slopb of mineral in soil
         soil_hydr%slopb_s(j) = (1.0-organic(j))*slopb_min(j) + organic(j)*slopb_org !component "B" of each soil layer

         ! calculate soil water and soil ice per nuit volume, and effective porosity
         vol_ice(j) = min(soil_hydr%watsat_s(j), h2osoi_ice(j)/(dz(j)*rho_ice))
         eff_porosity(j) = soil_hydr%watsat_s(j)-vol_ice(j)
         vol_liq(j) = min(eff_porosity(j),h2osoi_liq(j)/(dz(j)*rho_fwater))

         ! for hydraulic_conductivity, First not include the organic matter.
         hk_sat(j) = 0.0070556 * 10**(-0.884+0.0153*sand(j)) !same as CLM3.0,

         if ((eff_porosity(j) < 0.05) .or. (vol_liq(j) <= 1.0e-4)) then
             soil_hydr%hk_s(j) = 0.0
             soil_hydr%dhkdw_s(j) = 0.0
         else
             interm1 = 0.5*(vol_liq(j)+vol_liq(min(nlevsoi,j+1))) / &
                      (0.5*(soil_hydr%watsat_s(j)+soil_hydr%watsat_s(min(nlevsoi,j+1))))
             interm2 = hk_sat(j)*interm1**(2.*soil_hydr%slopb_s(j)+2.)
             soil_hydr%hk_s(j)    = interm1*interm2
             soil_hydr%dhkdw_s(j) = (2.*soil_hydr%slopb_s(j)+3.)*interm2*0.5/soil_hydr%watsat_s(j)
             if (j == nlevsoi) soil_hydr%dhkdw_s(j) = soil_hydr%dhkdw_s(j) * 2.
         end if

        ! for soil matric potential of each soil layers:
         smp_min(j) = -10.0*10**(1.88-0.0131*(sand(j)))
         smp_sat(j) = (1.-organic(j))*smp_min(j) + organic(j)*smp_org
         interm3 = max(vol_liq(j)/soil_hydr%watsat_s(j), 0.01)
         interm3 = min(1.0, interm3)
         soil_hydr%smp_s(j)    = smp_sat(j)*interm3**(-soil_hydr%slopb_s(j))
         soil_hydr%smp_s(j)    = max(-1.e10,soil_hydr%smp_s(j))
         soil_hydr%dsmpdw_s(j) = -soil_hydr%slopb_s(j)*soil_hydr%smp_s(j)/(interm3*soil_hydr%watsat_s(j))

      end do

    end associate
  end subroutine HydraulicProperties

!--------------------------------------------------------------------------------------------------
  subroutine SurfaceRunoff (soil_hydr, soil_disc, water_flx)

    use SoilConstantMod,   only : rho_fwater, rho_ice ! density_of_freewater; density_of_ice.
    use SoilParameterMod,  only : nlevsoi !the total soil layers, the default value is 20.

    ! !ARGUMENTS:
    implicit none
    type(soildisctype)     ,intent(in)     :: soil_disc
    type(soilhydrtype)     ,intent(inout)  :: soil_hydr
    type(waterfluxtype)    ,intent(inout)  :: water_flx

    !LOCAL VARIABLES
    integer  :: j
    real(kind=4) :: vol_liq(1:nlevsoi)
    real(kind=4) :: vol_ice(1:nlevsoi)
    real(kind=4) :: wetness(1:nlevsoi)
    real(kind=4) :: zmean                         !The surface soil layers contributing to runoff
    real(kind=4) :: wmean                         !The averaged soil wetness in surface soil layers
    real(kind=4), parameter:: wtfact = 0.3        !Fraction of model area with high water table
    real(kind=4), parameter:: fz = 1.0            !coefficient for water table depth
    real(kind=4), parameter:: wimp = 0.05         !water impermeable volumetric water content

    associate(dz            =>   soil_disc%dz_s, &
              zi            =>   soil_disc%zi_s, &
              h2osoi_liq    =>   soil_hydr%h2osoi_liq_s, &
              h2osoi_ice    =>   soil_hydr%h2osoi_ice_s, &
              eff_porosity  =>   soil_hydr%eff_porosity_s, &
              !zwt           =>   soil_hydr%zwt_s, &
              !fcov          =>   soil_hydr%fcov_s, &
              !wetness       =>   soil_hydr%wetness_s, &
              watsat        =>   soil_hydr%watsat_s, &
              qflx_top_soil =>   water_flx%qflx_top_s)
              !qflx_surf     =>   water_flx%qflx_surf_s)

      ! initalize the zmean and wmean
      zmean = 0.0
      wmean = 0.0

      ! First calculate the  partial volume of ice and liquid
      ! water-vol_ice & vol_liq ; and eff_porosity
      do j=1,nlevsoi

        ! Porosity of soil, partial volume of ice and liquid

        vol_ice(j) = min(watsat(j), h2osoi_ice(j)/(dz(j)*rho_ice))
        eff_porosity(j) = watsat(j)-vol_ice(j)
        vol_liq(j) = min(eff_porosity(j),h2osoi_liq(j)/(dz(j)*rho_fwater))

        ! Wetness of soil

        wetness(j) = min(1.0,(vol_ice(j)+vol_liq(j))/watsat(j))

        ! Averaged soil wetness in surface soil layers

        wmean = wmean + wetness(j)*dz(j)
      end do

      ! Then calculate the water table dept-zwt, and saturated fraction-soil_hydr%fcov_s
      do j=1,nlevsoi

        ! Determine water table depth

        soil_hydr%zwt_s = fz * (zi(nlevsoi-1) - wmean)

        ! Determine saturation fraction

        soil_hydr%fcov_s = wtfact * min(1.0,exp(-soil_hydr%zwt_s))

        ! Re-initialize wmean to zero for use below

        wmean = 0.0
      end do

      ! the soil layer thickness weighted wetness in the top three layers
      do j=1,3
        zmean = zmean + dz(j)
        wmean = wmean + wetness(j) * dz(j)
      end do

      ! If top soil layer is impermeable then all qflx_top_soil goes to surface
      ! runoff

      do j=1, nlevsoi
        if (eff_porosity(1) < wimp) then
           water_flx%qflx_surf_s =  max(0.0, soil_hydr%fcov_s * qflx_top_soil) + &
                        max(0.0, (1.-soil_hydr%fcov_s) * qflx_top_soil)
        else
           water_flx%qflx_surf_s =  max(0.0, soil_hydr%fcov_s * qflx_top_soil) + &
                        max(0.0, (1.-soil_hydr%fcov_s) * min(1.0,wmean**4)*qflx_top_soil)
        end if
      end do

    end associate

  end subroutine SurfaceRunoff

!--------------------------------------------------------------------------------------------------
  subroutine Infiltration(water_flx)

    !ARGUMENTS:
    implicit none
    type(waterfluxtype)    ,intent(inout)  :: water_flx

    associate(qflx_top_soil    =>   water_flx%qflx_top_s, &
              qflx_surf        =>   water_flx%qflx_surf_s)
              !qflx_infl        =>   water_flx%qflx_infl_s)

      water_flx%qflx_infl_s = qflx_top_soil - qflx_surf

      print *, 'qflx_infl_s equal:'
      print *, water_flx%qflx_infl_s
    end associate
  end subroutine Infiltration

!--------------------------------------------------------------------------------------------------
  subroutine SoilWater(soil_hydr, soil_disc, water_flx)

    use ModelParameterMod, only : dtime
    use SoilConstantMod,   only : rho_fwater, rho_ice, LatH_fus, grav, Temp_frez_f
    use SoilParameterMod,  only : nlevsoi
    use TridiagonalMod,    only : Tridiagonal


    implicit none
    type(soildisctype)     ,intent(in)     :: soil_disc
    type(soilhydrtype)     ,intent(inout)  :: soil_hydr
    type(waterfluxtype)    ,intent(inout)  :: water_flx

    !LOCAL VARIABLES
    integer  :: j
    integer  :: jtop
    real(kind=4) :: zmm(1:nlevsoi)                !layer depth [mm]
    real(kind=4) :: dzmm(1:nlevsoi)               !layer thickness [mm]
    real(kind=4) :: vol_liq(1:nlevsoi)
    real(kind=4) :: vol_ice(1:nlevsoi)
    real(kind=4) :: amx(1:nlevsoi)
    real(kind=4) :: bmx(1:nlevsoi)
    real(kind=4) :: cmx(1:nlevsoi)
    real(kind=4) :: rmx(1:nlevsoi)
    real(kind=4) :: den                           ! used in calculating qin, qout
    real(kind=4) :: dqidw0                        ! d(qin)/d(vol_liq(i-1))
    real(kind=4) :: dqidw1                        ! d(qin)/d(vol_liq(i))
    real(kind=4) :: dqodw1                        ! d(qout)/d(vol_liq(i))
    real(kind=4) :: dqodw2                        ! d(qout)/d(vol_liq(i+1))
    real(kind=4) :: num                           ! used in calculating qin, qout
    real(kind=4) :: qin                           ! flux of water into soil layer [mm h2o/s]
    real(kind=4) :: qout                          ! flux of water out of soil layer [mm h2o/s]
    real(kind=4) :: sdamp                         ! extrapolates soiwat dependence of evaporation
    real(kind=4) :: dwat(1:nlevsoi)

    associate(z              =>   soil_disc%z_s, &
              dz             =>   soil_disc%dz_s, &
              h2osoi_liq     =>   soil_hydr%h2osoi_liq_s, &
              h2osoi_ice     =>   soil_hydr%h2osoi_ice_s, &
              eff_porosity   =>   soil_hydr%eff_porosity_s, &
              watsat         =>   soil_hydr%watsat_s, &
              slopb          =>   soil_hydr%slopb_s, &
              hk             =>   soil_hydr%hk_s, &
              dhkdw          =>   soil_hydr%dhkdw_s, &
              smp            =>   soil_hydr%smp_s, &
              dsmpdw         =>   soil_hydr%dsmpdw_s, &
              qflx_infl      =>   water_flx%qflx_infl_s)
              !dwat           =>   water_flx%dwat_s)

      ! First , because soil hydraulic conducitivity and soil matrix potential's
      ! unit are all mm, so transfer the soil depth and soil thickness to mm.
      do j = 1, nlevsoi
          zmm(j) = z(j)*1.e3
          dzmm(j) = dz(j)*1.e3
      end do

      do j=1,nlevsoi
        ! Porosity of soil, partial volume of ice and liquid
        vol_ice(j) = min(watsat(j), h2osoi_ice(j)/(dz(j)*rho_ice))
        eff_porosity(j) = watsat(j)-vol_ice(j)
        vol_liq(j) = min(eff_porosity(j),h2osoi_liq(j)/(dz(j)*rho_fwater))
      end do

      !then set up the a, b, c, and r vectors for tridiagonal equations

      ! Node j=1
      !set initial values:
      sdamp = 0.0

      j = 1

      qin    = qflx_infl
      den    = (zmm(j+1)-zmm(j))
      num    = (smp(j+1)-smp(j)) - den
      qout   = -hk(j)*num/den
      dqodw1 = -(-hk(j)*dsmpdw(j) + num*dhkdw(j))/den
      dqodw2 = -( hk(j)*dsmpdw(j+1) + num*dhkdw(j))/den
      rmx(j) =  qin - qout     !qflx_tran_veg_col(c) * rootr_col(c,j) e is ignored in this small model.
      amx(j) =  0.0
      bmx(j) =  dzmm(j)*(sdamp+1.0/dtime) + dqodw1
      cmx(j) =  dqodw2

      ! Nodes j=2 to j=nlevsoi-1

      do j = 2, nlevsoi - 1
        den    = (zmm(j) - zmm(j-1))
        num    = (smp(j)-smp(j-1)) - den
        qin    = -hk(j-1)*num/den
        dqidw0 = -(-hk(j-1)*dsmpdw(j-1) + num*dhkdw(j-1))/den
        dqidw1 = -( hk(j-1)*dsmpdw(j) + num*dhkdw(j-1))/den
        den    = (zmm(j+1)-zmm(j))
        num    = (smp(j+1)-smp(j)) - den
        qout   = -hk(j)*num/den
        dqodw1 = -(-hk(j)*dsmpdw(j) + num*dhkdw(j))/den
        dqodw2 = -( hk(j)*dsmpdw(j+1) + num*dhkdw(j))/den
        rmx(j) =  qin - qout  !- qflx_tran_veg_col(c)*rootr_col(c,j)
        amx(j) = -dqidw0
        bmx(j) =  dzmm(j)/dtime - dqidw1 + dqodw1
        cmx(j) =  dqodw2
      end do

      ! Node j=nlevsoi

      j = nlevsoi

      den    = (zmm(j) - zmm(j-1))
      num    = (smp(j)-smp(j-1)) - den
      qin    = -hk(j-1)*num/den
      dqidw0 = -(-hk(j-1)*dsmpdw(j-1) + num*dhkdw(j-1))/den
      dqidw1 = -( hk(j-1)*dsmpdw(j)   + num*dhkdw(j-1))/den
      qout   =  hk(j)
      dqodw1 =  dhkdw(j)
      rmx(j) =  qin - qout !- qflx_tran_veg_col(c)*rootr_col(c,j)
      amx(j) = -dqidw0
      bmx(j) =  dzmm(j)/dtime - dqidw1 + dqodw1
      cmx(j) =  0.0

      ! Solve for dwat

      jtop = 1
      call Tridiagonal(1, nlevsoi, jtop, amx, bmx, cmx, rmx, dwat)
      water_flx%dwat_s = dwat

      ! Renew the mass of liquid water

      do j= 1,nlevsoi
          h2osoi_liq(j) = h2osoi_liq(j) + water_flx%dwat_s(j)*dzmm(j)
          soil_hydr%h2osoi_liq_s(j) = h2osoi_liq(j)  !update type data of h2osoi_liq
      end do

      print *, 'updated h2osoi_liq_s:'
      print *, soil_hydr%h2osoi_liq_s
    end associate
  end subroutine SoilWater

!--------------------------------------------------------------------------------------------------
  subroutine Drainage(soil_hydr, soil_disc, water_flx)

    use ModelParameterMod, only : dtime
    use SoilConstantMod,   only : rho_fwater, rho_ice, LatH_fus, grav, Temp_frez_f, pondmx
    use SoilParameterMod,  only : nlevsoi

    implicit none
    type(soildisctype)     ,intent(in)     :: soil_disc
    type(soilhydrtype)     ,intent(inout)  :: soil_hydr
    type(waterfluxtype)    ,intent(inout)  :: water_flx

    !OTHER LOCAL VARIABLES:
    integer  :: j                        !indices
    real(kind=4) :: xs                       !excess soil water above saturation
    real(kind=4) :: zmm(1:nlevsoi)
    real(kind=4) :: dzmm(1:nlevsoi)
    real(kind=4) :: vol_liq(1:nlevsoi)
    real(kind=4) :: vol_ice(1:nlevsoi)
    real(kind=4) :: wetness(1:nlevsoi)
    real(kind=4) :: watmin                   !minimum soil moisture
    real(kind=4) :: hksum                    !summation of hydraulic cond for layers 11->20
    real(kind=4) :: zsat                     !hydraulic conductivity weighted soil thickness
    real(kind=4) :: wsat                     !hydraulic conductivity weighted soil wetness
    real(kind=4) :: qflx_drain_wet           !subsurface runoff from "wet" part (mm h2o/s)
    real(kind=4) :: qflx_drain_dry           !subsurface runoff from "dry" part (mm h2o/s)
    real(kind=4) :: qflx_drain
    real(kind=4) :: dzksum                   !hydraulic conductivity weighted soilthickness
    real(kind=4) :: zwice = 0.0

    associate(z             =>   soil_disc%z_s, &
              dz            =>   soil_disc%dz_s, &
              h2osoi_liq    =>   soil_hydr%h2osoi_liq_s, &
              h2osoi_ice    =>   soil_hydr%h2osoi_ice_s, &
              zwt           =>   soil_hydr%zwt_s, &
              fcov          =>   soil_hydr%fcov_s, &
              eff_porosity  =>   soil_hydr%eff_porosity_s, &
              watsat        =>   soil_hydr%watsat_s, &
              slopb         =>   soil_hydr%slopb_s, &
              hk            =>   soil_hydr%hk_s, &
              dhkdw         =>   soil_hydr%dhkdw_s, &
              smp           =>   soil_hydr%smp_s, &
              dsmpdw        =>   soil_hydr%dsmpdw_s, &
              dwat          =>   water_flx%dwat_s)
              !qflx_drain    =>   water_flx%qflx_drain_s)

      do j = 1, nlevsoi
          zmm(j) = z(j)*1.e3
          dzmm(j) = dz(j)*1.e3
      end do

      do j=1,nlevsoi
        ! Porosity of soil, partial volume of ice and liquid
        vol_ice(j) = min(watsat(j), h2osoi_ice(j)/(dz(j)*rho_ice))
        eff_porosity(j) = watsat(j)-vol_ice(j)
        vol_liq(j) = min(eff_porosity(j),h2osoi_liq(j)/(dz(j)*rho_fwater))
        wetness(j) = min(1.0,(vol_ice(j)+vol_liq(j))/watsat(j))
      end do

      ! initialize
      qflx_drain     = 0.0      ! subsurface runoff
      qflx_drain_wet = 0.0      ! subsurface runoff
      qflx_drain_dry = 0.0      ! subsurface runoff
      hksum          = 0.0

      do j = 11,nlevsoi-1
        hksum = hksum + hk(j)
      end do

      if (zwice <= 0. .AND. hksum > 0.) then
        zsat = 0.0
        wsat = 0.0
        dzksum = 0.0
      end if

      do j = 11,nlevsoi-1
        if (zwice <= 0. .AND. hksum > 0.) then
          zsat = zsat + dz(j)*hk(j)
          !wsat = wsat + s(j)*dz(j)*hk(j)
          wsat = wsat + wetness(j)*dz(j)*hk(j)
          dzksum = dzksum + hk(j)*dz(j)
        end if
      end do

      ! calculate the drainage from saturated and unsaturated fraction.
      if (zwice <= 0. .AND. hksum > 0.) then
        wsat = wsat / zsat
        qflx_drain_dry = (1.-fcov)*4.e-2* wsat ** (2.*slopb(1)+3.)  !mm/s
        qflx_drain_wet = fcov * 1.e-5 * exp(-zwt)                 !mm/s
        qflx_drain = qflx_drain_dry + qflx_drain_wet
      end if

      ! upadate the soil liquid water content in layers 11-20
      do j = 11, nlevsoi-1
        if (zwice <= 0. .AND. hksum > 0.) then
          h2osoi_liq(j) = h2osoi_liq(j) - dtime*qflx_drain*dz(j)*hk(j)/dzksum
        end if
      end do

      ! Limit h2osoi_liq to be greater than or equal to watmin.
      ! Get water needed to bring h2osoi_liq equal watmin from lower layer.
      watmin = 0.0
      do j = 1, nlevsoi-1
        if (h2osoi_liq(j) < 0.) then
            xs = watmin - h2osoi_liq(j)
        else
            xs = 0.0
        end if
        h2osoi_liq(j  ) = h2osoi_liq(j  ) + xs
        h2osoi_liq(j+1) = h2osoi_liq(j+1) - xs
      end do

      j = nlevsoi
        if (h2osoi_liq(j) < watmin) then
          xs = watmin-h2osoi_liq(j)
        else
          xs = 0.0
        end if
        h2osoi_liq(j) = h2osoi_liq(j) + xs
        qflx_drain = qflx_drain - xs/dtime

      ! Determine water in excess of saturation
      xs = max(0.0, h2osoi_liq(1)-(pondmx + eff_porosity(1)*dzmm(1)))
      if (xs > 0.) h2osoi_liq(1) = pondmx + eff_porosity(1)*dzmm(1)

      do j = 2,nlevsoi
        xs = xs + max(h2osoi_liq(j) - eff_porosity(j)*dzmm(j), 0.0)  ! [mm]
        h2osoi_liq(j) = min(eff_porosity(j)*dzmm(j), h2osoi_liq(j))
      end do

      ! Sub-surface runoff and drainage

      qflx_drain = qflx_drain + xs/dtime + hk(nlevsoi) + dhkdw(nlevsoi)*dwat(nlevsoi) ! [mm/s]
      water_flx%qflx_drain_s = qflx_drain

      ! Implicit evaporation term is now zero

      !eflx_impsoil = 0._r8
      ! Renew the ice and liquid mass due to condensation

      !if (snl+1 >= 1) then
      !  h2osoi_liq(1) = h2osoi_liq(1) + qflx_dew_grnd * dtime
      !  h2osoi_ice(1) = h2osoi_ice(1) + (qflx_dew_snow * dtime)
      !  if (qflx_sub_snow*dtime > h2osoi_ice(1)) then
      !    qflx_sub_snow = h2osoi_ice(1)/dtime
      !    h2osoi_ice(1) = 0._r8
      !  else
      !    h2osoi_ice(1) = h2osoi_ice(1) - (qflx_sub_snow * dtime)
      !  end if
      !end if

      print *, 'qflx_drain :'
      print *, water_flx%qflx_drain_s
    end associate
  end subroutine Drainage

end module SoilHydrologyMod
