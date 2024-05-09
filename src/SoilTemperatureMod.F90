!--------------------------------------------------------------------------------------------------
module SoilTemperatureMod

!BOP
!
! discription: this module is using for calculating the snow and soil
! temperature including phase change proccess.
  use SoilTypeMod

  implicit none
  save

  !public  :: SoilTemperature
  public :: SoilThermalPropers
  public :: SoilTemperature

contains

  subroutine SoilThermalPropers(soil_disc, soil_text, soil_heat, soil_hydr)
    !USES:
    use ModelParameterMod, only : dtime
    use SoilConstantMod,   only : rho_fwater, rho_ice, LatH_fus, grav, Temp_frez_f, cpice, cpliq
    use SoilParameterMod,  only : nlevsoi

    !ARGUMENTS:
    implicit none
    save
    type(soildisctype)       ,intent(in)      :: soil_disc
    type(soiltexttype)       ,intent(in)      :: soil_text
    type(soilhydrtype)       ,intent(in)      :: soil_hydr
    type(soilheatype)        ,intent(inout)   :: soil_heat

    !LOCAL VARIABLES:
    integer   :: j
    real(kind=4)  :: bd(1:nlevsoi)            !bulk density [Kg/m^3]
    real(kind=4)  :: tkm(1:nlevsoi)           !thermal conductivity, soil minerals [W/m-K]
    real(kind=4)  :: tksat(1:nlevsoi)         !thermal conductivity, saturated soil [W/m-K]
    real(kind=4)  :: tkdry(1:nlevsoi)         !thermal conductivity, dry soil (W/m/Kelvin)
    real(kind=4)  :: satw(1:nlevsoi)          !soil degree of saturation/soil wetness
    real(kind=4)  :: dke(1:nlevsoi)           !kersten number
    real(kind=4)  :: csol(1:nlevsoi)          !heat capacity, soil solids(J/m**3/Kelvin) (nlevsoi)
    real(kind=4)  :: thk(1:nlevsoi)
    real(kind=4)  :: tk(1:nlevsoi)
    real(kind=4)  :: cv(1:nlevsoi)
    real(kind=4)  :: interm1
    real(kind=4)  :: tkdry_om = 0.05
    real(kind=4)  :: tks_om = 0.25
    real(kind=4)  :: csol_om = 2.5e6
    associate(z            =>   soil_disc%z_s, &
              dz           =>   soil_disc%dz_s, &
              zi           =>   soil_disc%zi_s, &
              clay         =>   soil_text%clay_s, &
              sand         =>   soil_text%sand_s, &
              organic      =>   soil_text%organic_s, &
              watsat       =>   soil_hydr%watsat_s, &
              h2osoi_liq   =>   soil_hydr%h2osoi_liq_s, &
              h2osoi_ice   =>   soil_hydr%h2osoi_ice_s, &
              tsoisno      =>   soil_heat%tsoisno_s)
              !thk          =>   soil_heat%thk_s, &!Inoutput;soil_thermal_conductivity_at_z
              !tk           =>   soil_heat%tk_s, &!Inoutput;soil_thermal_conductivity_at_zi
              !cv           =>   soil_heat%cv_s)!Input&Output;heat_capacity_of_soil

      ! first calculate the Thermal conductivity and Heat capacity of soil
      do j = 1, nlevsoi
        bd(j) = (1.-watsat(j))*2.7e3
        tkdry(j) = (0.135*bd(j) + 64.7) / (2.7e3 - 0.947*bd(j))
        tkdry(j) = (1.0-organic(j)) * tkdry(j) + organic(j)*tkdry_om
        tkm(j) = (8.80*sand(j)+2.92*clay(j))/(sand(j)+clay(j))**(1.-watsat(j))
        tkm(j) = (1.0-organic(j)) * tkm(j) + organic(j)*tks_om
        satw(j) = (h2osoi_liq(j)/rho_fwater + h2osoi_ice(j)/rho_ice)/(dz(j)*watsat(j))
        satw(j) = min(1.0, satw(j))
        if (satw(j) > .1e-6) then
          interm1 = h2osoi_liq(j)/(h2osoi_ice(j)+h2osoi_liq(j))
          if (tsoisno(j) >= Temp_frez_f) then
            dke(j) = max(0.0, log10(satw(j)) + 1.0)
            tksat(j) = tkm(j)**(1.-watsat(j))*0.57**watsat(j)
          else
            dke(j) = satw(j)
            tksat(j) = tkm(j)**(1.-watsat(j))*0.249**(interm1*watsat(j))*2.29**watsat(j)
          endif
          thk(j) = dke(j)*tksat(j) + (1.-dke(j))*tkdry(j)
        else
          thk(j) = tkdry(j)
        endif
      enddo

      ! Thermal conductivity at the layer interfaces
      do j = 1, nlevsoi
        if (j <= nlevsoi-1) then
          tk(j) = thk(j)*thk(j+1)*(z(j+1)-z(j))/(thk(j)*(z(j+1)-zi(j+1))+thk(j+1)*(zi(j+1)-z(j)))
        else
          tk(j) = 0.
        endif
      enddo

      ! Soil heat capacity, de Vires(1963)
      do j = 1, nlevsoi
        csol(j) = (2.128*sand(j)+2.385*clay(j))/(sand(j)+clay(j)) * 1.e6 !J/(m3 K)
        csol(j) = (1.0-organic(j))*csol(j) + organic(j)*csol_om
        cv(j) = csol(j)*(1.-watsat(j))*dz(j)+(h2osoi_ice(j)*cpice + h2osoi_liq(j)*cpliq)
      enddo

      do j =1, nlevsoi
        soil_heat%thk_s(j) = thk(j)
        soil_heat%tk_s(j)  = tk(j)
        soil_heat%cv_s(j)  = cv(j)
      enddo

    print *, "thk_s"
    print *, soil_heat%thk_s
    end associate

  end subroutine SoilThermalPropers

!--------------------------------------------------------------------------------------------------

  subroutine SoilTemperature(soil_disc, soil_heat)

    !USES:
    use ModelParameterMod, only : dtime !this is the error.log file
    use SoilConstantMod,   only : rho_fwater, capr, cnfac, rho_ice, LatH_fus, grav, Temp_frez_f, emg, sb
    use SoilParameterMod,  only : nlevsoi !the total layers number. the default values of this is 20.
    use TridiagonalMod,    only : Tridiagonal

    !ARGUMENTS:
    implicit none
    type(soildisctype)       ,intent(in)      :: soil_disc
    type(soilheatype)        ,intent(inout)   :: soil_heat

    !LOCAL VARIABLES:
    integer  :: j
    integer  :: jtop
    real(kind=4) :: amx(1:nlevsoi)                ! "a" left off diagonal of tridiagonal matrix
    real(kind=4) :: bmx(1:nlevsoi)                ! "b" diagonal column for tridiagonal matrix
    real(kind=4) :: cmx(1:nlevsoi)                ! "c" right off diagonal tridiagonal matrix
    real(kind=4) :: rmx(1:nlevsoi)                ! "r" forcing term of tridiagonal matrix
    real(kind=4) :: interm1                       ! intermediate variables
    real(kind=4) :: interm2                       ! intermediate variables
    real(kind=4) :: fact(1:nlevsoi)
    real(kind=4) :: fn(1:nlevsoi)
    real(kind=4) :: dhsdT                         ! d(hs)/dT
    real(kind=4) :: hs                            ! net energy flux into the surface (w/m2)
    real(kind=4) :: dzm
    real(kind=4) :: dzp
    real(kind=4) :: tsoisno_in(1:nlevsoi)

    associate(z            =>   soil_disc%z_s, &
              dz           =>   soil_disc%dz_s, &
              zi           =>   soil_disc%zi_s, &
              eflx_gnet    =>   soil_heat%eflx_gnet_s, &
              eflx_snsh    =>   soil_heat%eflx_snsh_s, &
              eflx_snsht   =>   soil_heat%eflx_snsht_s, &
              eflx_poth    =>   soil_heat%eflx_poth_s, &
              eflx_potht   =>   soil_heat%eflx_potht_s, &
              tsoisno      =>   soil_heat%tsoisno_s, &
              tsoisnot     =>   soil_heat%tsoisnot_s, &
              tk           =>   soil_heat%tk_s, &
              cv           =>   soil_heat%cv_s)

      ! First calculate the upper boundary
      hs = eflx_gnet        !the energy flux into the upper layer of soil-snow
      ! interm1 = 4.*emg * sb * tsoisno(1)**3
      ! interm2 = ((eflx_snsh-eflx_snsht)/(tsoisno(1)-tsoisnot(1)))+ &
      !         ((eflx_poth-eflx_poth)/(tsoisno(1)-tsoisnot(1)))
      ! dhsdT =  - interm1 - interm2            !cgrnd will be calculated in BareGroundFluxesMod

      ! second to determine if there have snow layers.
      do j = 1, nlevsoi
        if (nlevsoi >= 1) then
          if (j <= nlevsoi-1) then
            fact(j) = dtime/cv(j)
            fn(j) = tk(j)*(tsoisno(j+1)-tsoisno(j))/(z(j+1)-z(j))
            dzm     = (z(j)-z(j-1))
            dzp     = (z(j+1)-z(j))
            amx(j) =   - (1.-cnfac)*fact(j)* tk(j-1)/dzm
            bmx(j) = 1.+ (1.-cnfac)*fact(j)*(tk(j)/dzp + tk(j-1)/dzm)
            cmx(j) =   - (1.-cnfac)*fact(j)* tk(j)/dzp
            rmx(j) = tsoisno(j) + cnfac*fact(j)*( fn(j) - fn(j-1))
          else if (j == nlevsoi) then
            fact(j) = dtime/cv(j)
            fn(j) = 0.
            dzm   = (z(j)-z(j-1))
            amx(j) =   - (1.-cnfac)*fact(j)*tk(j-1)/dzm
            bmx(j) = 1.+ (1.-cnfac)*fact(j)*tk(j-1)/dzm
            cmx(j) = 0.
            rmx(j) = tsoisno(j) - cnfac*fact(j)*fn(j-1)
          end if
        else
          if (j == 1) then
            fact(j) = dtime/cv(j) * dz(j) / (0.5*(z(j)-zi(j-1)+capr*(z(j+1)-zi(j-1))))
            fn(j) = tk(j)*(tsoisno(j+1)-tsoisno(j))/(z(j+1)-z(j))
            dzp   = z(j+1)-z(j)
            amx(j) = 0.
            bmx(j) = 1+(1.-cnfac)*fact(j)*tk(j)/dzp
            cmx(j) =  -(1.-cnfac)*fact(j)*tk(j)/dzp
            rmx(j) = tsoisno(j) +  fact(j)*(cnfac*fn(j) - hs)
          endif
        endif
      end do

        ! Solve for tsoisno
      jtop = 1
      call Tridiagonal(1, nlevsoi, jtop, amx, bmx, cmx, rmx, tsoisno_in)

      soil_heat%tsoisno_s = tsoisno_in

    end associate
  end subroutine SoilTemperature

end module SoilTemperatureMod