!-- CONSTANT_Singleton defines physical and astrophysical constants

module CONSTANT_Singleton

  !-- "Natural units" with Lorentz-Heaviside electron charge, base unit = MeV
  !     ( hBar = c = k = \mu = MeV = 1 )
  !   https://en.wikipedia.org/wiki
  !     /Natural_units#.22Natural_units.22_.28particle_physics_and_cosmology.29

  use KIND_DEFAULT_Singleton
  
  implicit none
  private
  
    real ( KDR ), private, parameter :: &
      !-- Mathematical
      PI  =  acos ( -1.0_KDR ), &
      !-- Physical SI
      !   http://pdg.lbl.gov/2016/reviews/rpp2016-rev-phys-constants.pdf
      SPEED_OF_LIGHT_SI    =  2.99792458e+8_KDR, &
      PLANCK_REDUCED_SI    =  1.054571800e-34_KDR, &
      ELECTRON_CHARGE_SI   =  1.6021766208e-19_KDR, &
      ATOMIC_MASS_UNIT_SI  =  1.660539040e-27_KDR, &
      PERMEABILITY_SI      =  4.0e-7_KDR * PI, & 
      GRAVITATIONAL_SI     =  6.67408e-11_KDR, &
      AVOGADRO_SI          =  6.022140857e23_KDR, &
      BOLTZMANN_SI         =  1.38064852e-23_KDR, &
      !-- Astrophysical SI
      !   http://pdg.lbl.gov/2016/reviews
      !          /rpp2016-rev-astrophysical-constants.pdf
      ASTRONOMICAL_UNIT_SI = 1.49597870700e+11_KDR, &
      PARSEC_SI            = 3.08567758149e+16_KDR, &
      SOLAR_MASS_SI        = 1.98848e+30_KDR, &
      !-- GenASiS Fundamental
      SPEED_OF_LIGHT  =  1.0_KDR, &
      PLANCK_REDUCED  =  1.0_KDR, &    
      PERMEABILITY    =  1.0_KDR, &
      BOLTZMANN       =  1.0_KDR, &
      !-- GenASiS Metric
      MEGA_ELECTRON_VOLT  =  1.0_KDR, &
      JOULE               =  1.0e-6_KDR * MEGA_ELECTRON_VOLT &
                             / ELECTRON_CHARGE_SI, & 
      SECOND              =  PLANCK_REDUCED / PLANCK_REDUCED_SI &
                             / JOULE, &
      METER               =  SPEED_OF_LIGHT / SPEED_OF_LIGHT_SI &
                             * SECOND, &
      KILOGRAM            =  JOULE  *  SECOND ** 2  /  METER ** 2, &
      AMPERE              =  sqrt ( ( PERMEABILITY_SI / PERMEABILITY ) &
                                    *  KILOGRAM  *  METER  /  SECOND ** 2 ), &
      KELVIN              =  BOLTZMANN_SI / BOLTZMANN &
                             *  JOULE, &
      MOLE                =  AVOGADRO_SI, &
      !-- GenASiS Derived
      ELECTRON_CHARGE   =  ELECTRON_CHARGE_SI &
                           *  AMPERE * SECOND, &
      ATOMIC_MASS_UNIT  =  ATOMIC_MASS_UNIT_SI &
                           *  KILOGRAM, &
      GRAVITATIONAL     =  GRAVITATIONAL_SI &
                           *  METER ** 3  /  KILOGRAM  /  SECOND ** 2, &
      STEFAN_BOLTZMANN  =  PI ** 2  /  60.0_KDR &
                           *  BOLTZMANN ** 4 &
                           /  ( PLANCK_REDUCED * SPEED_OF_LIGHT ) ** 3, &
      ASTRONOMICAL_UNIT =  ASTRONOMICAL_UNIT_SI &
                           *  METER, &
      PARSEC            =  PARSEC_SI &
                           *  METER, &
      SOLAR_MASS        =  SOLAR_MASS_SI * KILOGRAM

  type, public :: ConstantSingleton
    real ( KDR ) :: &
      !-- Mathematical
      PI                  =  PI, &
      !-- Metric, SI Base 
      !   https://en.wikipedia.org/wiki/SI_base_unit
      METER     =  METER, &
      KILOGRAM  =  KILOGRAM, &
      SECOND    =  SECOND, &
      AMPERE    =  AMPERE, &
      KELVIN    =  KELVIN, &
      MOLE      =  MOLE, &
      !-- Physical
      SPEED_OF_LIGHT    =  SPEED_OF_LIGHT, &
      PLANCK_REDUCED    =  PLANCK_REDUCED, &
      ELECTRON_CHARGE   =  ELECTRON_CHARGE, &
      ATOMIC_MASS_UNIT  =  ATOMIC_MASS_UNIT, &
      PERMEABILITY      =  PERMEABILITY, &
      GRAVITATIONAL     =  GRAVITATIONAL, &
      BOLTZMANN         =  BOLTZMANN, &
      STEFAN_BOLTZMANN  =  STEFAN_BOLTZMANN, &
      !-- Astrophysical
      ASTRONOMICAL_UNIT  =  ASTRONOMICAL_UNIT, &
      PARSEC             =  PARSEC, &
      SOLAR_MASS         =  SOLAR_MASS
  end type ConstantSingleton
  
  type ( ConstantSingleton ), public, parameter :: &
    CONSTANT = ConstantSingleton ( )

end module CONSTANT_Singleton
