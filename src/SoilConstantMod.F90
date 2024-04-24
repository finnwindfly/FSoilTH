!--------------------------------------------------------------------------------------------------
module SoilConstantMod

    implicit none
    ! define all constant variables related to soil physics.

    real(kind=16),parameter :: grav = 9.80616              ! acceleration ofgravity ~ m/s^2
    real(kind=16),parameter :: rho_fwater = 1.000e3        ! density of fresh water ~ kg/m^3
    real(kind=16),parameter :: rho_ice = 0.917e3           ! density of ice   ~ kg/m^3
    real(kind=8),parameter  :: Temp_frez_f = 273.16        ! freezing T of fresh water ~ K
    real(kind=16),parameter :: LatH_fus = 3.337e5          ! latent heat of fusion ~ J/kg
    real(kind=16),parameter :: cpliq = 4.188e3             ! specific heat of fresh h2o ~ J/kg/K
    real(kind=16),parameter :: cpice = 2.11727e3           ! specific heat of fresh ice ~ J/kg/K
    real(kind=16),parameter :: cpair = 1.00464e3           !specific heat of dry air ~ J/kg/K
    real(kind=16),parameter :: sb=5.67e-8                  ! stefan-boltzmann constant  [W/m2/K4]
    real(kind=8),parameter  :: emg=0.96                    ! ground emissivity, no surface water or surface snow
    real(kind=16),parameter :: pondmx = 10.0               ! Ponding depth (mm)
    real(kind=16),parameter :: tkair  = 0.023              ! thermal conductivity of air   [W/m/k]
    real(kind=16),parameter :: tkice  = 2.290              ! thermal conductivity of ice   [W/m/k]
    real(kind=16),parameter :: tkwat  = 0.6                ! thermal conductivity of water [W/m/k]
    real(kind=16),parameter :: cnfac  = 0.5                !Crank Nicholson factor between 0 and 1
    real(kind=16),parameter :: capr   = 0.34               !Tuning factor to turn first layer T into surface T

end module SoilConstantMod