module Interactions_NM_1_G__Form

  !-- Interactions_NeutrinoMoments_1_Grey__Form
  
  use Basics
  use Mathematics
  use Fluid_P_MHN__Form
  use NeutrinoMoments_G__Form
  use Interactions_Template

  implicit none
  private

  type, public, extends ( InteractionsTemplate ) :: Interactions_NM_1_G_Form
    real ( KDR ) :: &
      RegulationParameter = 0.01_KDR
    class ( Fluid_P_MHN_Form ), pointer :: &
      Fluid => null ( )
    class ( NeutrinoMoments_G_Form ), pointer :: &
      Neutrinos_E_Nu          => null ( ), &
      Neutrinos_E_NuBar       => null ( ), &
      Neutrinos_MuTau_NuNuBar => null ( )
  contains
    procedure, private, pass :: &
      InitializeAllocate_NM_1_G
    generic, public :: &
      Initialize => InitializeAllocate_NM_1_G
    procedure, private, pass :: &
      Set_NM_1_G
    generic, public :: &
      Set => Set_NM_1_G
    procedure, public, pass :: &
      Compute
    procedure, public, pass :: &
      Regulate
    final :: &
      Finalize
    procedure, private, pass ( I ) :: &
      ComputeEquilibrium_T_Eta
    procedure, public, nopass :: &
      Compute_NuE_N
    ! procedure, public, pass :: &
    !   Compute_E_Nu_Nuclei_Kernel
    ! procedure, public, pass :: &
    !   Compute_E_NuBar_Kernel
  end type Interactions_NM_1_G_Form

    private :: &
      ComputeEquilibrium_T_Eta_Kernel, &
      RegulateKernel

    real ( KDR ), private :: &
      Pi, &
      TwoPi, &
      FourPi, &
      AMU, &
      m_n, m_p, &
      G_F, &
      g_A

contains


  subroutine InitializeAllocate_NM_1_G &
               ( I, LengthUnit, EnergyDensityUnit, TemperatureUnit, nValues, &
                 VariableOption, NameOption, ClearOption, UnitOption )

    class ( Interactions_NM_1_G_Form ), intent ( inout ) :: &
      I
    type ( MeasuredValueForm ), intent ( in ) :: &
      LengthUnit, &
      EnergyDensityUnit, &
      TemperatureUnit
    integer ( KDI ), intent ( in ) :: &
      nValues
    character ( * ), dimension ( : ), intent ( in ), optional :: &
      VariableOption
    character ( * ), intent ( in ), optional :: &
      NameOption
    logical ( KDL ), intent ( in ), optional :: &
      ClearOption
    type ( MeasuredValueForm ), dimension ( : ), intent ( in ), optional :: &
      UnitOption

    if ( I % Type == '' ) &
      I % Type = 'an Interactions_NM_1_G'

    call I % InitializeTemplate &
           ( LengthUnit, EnergyDensityUnit, TemperatureUnit, nValues, &
             VariableOption, NameOption, ClearOption, UnitOption )

    Pi      =  CONSTANT % PI
    TwoPi   =  2.0_KDR * CONSTANT % PI
    FourPi  =  4.0_KDR * CONSTANT % PI
    AMU     =  CONSTANT % ATOMIC_MASS_UNIT
    m_n     =  CONSTANT % NEUTRON_MASS
    m_p     =  CONSTANT % PROTON_MASS
    G_F     =  CONSTANT % FERMI_COUPLING
    g_A     =  CONSTANT % NEUTRON_AXIAL_COUPLING

  end subroutine InitializeAllocate_NM_1_G


  subroutine Set_NM_1_G &
               ( I, Neutrinos_E_Nu, Neutrinos_E_NuBar, &
                 Neutrinos_MuTau_NuNuBar, Fluid )

    class ( Interactions_NM_1_G_Form ), intent ( inout ) :: &
      I
    class ( NeutrinoMoments_G_Form ), intent ( in ), target :: &
      Neutrinos_E_Nu, &
      Neutrinos_E_NuBar, &
      Neutrinos_MuTau_NuNuBar
    class ( Fluid_P_MHN_Form ), intent ( in ), target :: &
      Fluid

    I % Fluid                    =>  Fluid
    I % Neutrinos_E_Nu           =>  Neutrinos_E_Nu
    I % Neutrinos_E_NuBar        =>  Neutrinos_E_NuBar
    I % Neutrinos_MuTau_NuNuBar  =>  Neutrinos_MuTau_NuNuBar 

  end subroutine Set_NM_1_G


  subroutine Compute ( I, Current )

    class ( Interactions_NM_1_G_Form ), intent ( inout ) :: &
      I
    class ( CurrentTemplate ), intent ( in ) :: &
      Current

    call Show ( 'Computing Interactions', I % IGNORABILITY )

    call Clear ( I % Value ( :, I % EMISSIVITY_J ) )
    call Clear ( I % Value ( :, I % EMISSIVITY_H ) )
    call Clear ( I % Value ( :, I % EMISSIVITY_N ) )
    call Clear ( I % Value ( :, I % OPACITY_J ) )
    call Clear ( I % Value ( :, I % OPACITY_H ) )
    call Clear ( I % Value ( :, I % OPACITY_N ) )

    associate &
      ( Nu_E    => I % Neutrinos_E_Nu, &
        NuBar_E => I % Neutrinos_E_NuBar, &
        Nu_X    => I % Neutrinos_MuTau_NuNuBar, &
        F       => I % Fluid )

    select case ( trim ( Current % Type ) )
    case ( 'NEUTRINOS_E_NU' )
       
      call Show ( Nu_E % Name, 'Species', I % IGNORABILITY )

      call I % Compute_NuE_N &
             ( I % Value ( :, I % EMISSIVITY_J ), &
               I % Value ( :, I % EMISSIVITY_N ), &
               F % Value ( :, F % BARYON_MASS ), &
               F % Value ( :, F % COMOVING_DENSITY ), &
               F % Value ( :, F % TEMPERATURE ), &
               F % Value ( :, F % MASS_FRACTION_PROTON ), &
               F % Value ( :, F % MASS_FRACTION_NEUTRON ), &
               F % Value ( :, F % CHEMICAL_POTENTIAL_E ) )

!    case default
!      call Show ( 'Radiation Type not recognized', CONSOLE % ERROR )
!      call Show ( 'Interactions_NM_G_1__Form', 'module', CONSOLE % ERROR )
!      call Show ( 'Compute', 'subroutine', CONSOLE % ERROR )
    end select !-- Radiation % Type

    end associate !-- Nu_E, etc.
    
  end subroutine Compute


  subroutine Regulate ( I, Current, dT )

    class ( Interactions_NM_1_G_Form ), intent ( inout ) :: &
      I
    class ( CurrentTemplate ), intent ( in ) :: &
      Current
    real ( KDR ), intent ( in ) :: &
      dT

    call Show ( 'Regulating Interactions', I % IGNORABILITY )

    select type ( NM => Current )
    class is ( NeutrinoMoments_G_Form )

    associate ( F => I % Fluid )

    call RegulateKernel &
           ( I % Value ( :, I % EMISSIVITY_J ), &
             I % Value ( :, I % EMISSIVITY_H ), &
             I % Value ( :, I % EMISSIVITY_N ), &
             I % Value ( :, I % OPACITY_J ), &
             I % Value ( :, I % OPACITY_H ), &
             I % Value ( :, I % OPACITY_N ), &
             NM % Value ( :, NM % COMOVING_ENERGY ), &
             F % Value ( :, F % INTERNAL_ENERGY ), &
             I % RegulationParameter, dT )

    end associate !-- F
    end select !-- NM

  end subroutine Regulate


  impure elemental subroutine Finalize ( I )

    type ( Interactions_NM_1_G_Form ), intent ( inout ) :: &
      I

    nullify ( I % Neutrinos_MuTau_NuNuBar )
    nullify ( I % Neutrinos_E_NuBar )
    nullify ( I % Neutrinos_E_Nu )
    nullify ( I % Fluid )

    call I % FinalizeTemplate ( )

  end subroutine Finalize


  subroutine ComputeEquilibrium_T_Eta ( T_EQ, Eta_EQ, I, C )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      T_EQ, &
      Eta_EQ
    class ( Interactions_NM_1_G_Form ), intent ( in ) :: &
      I
    class ( CurrentTemplate ), intent ( in ) :: &
      C

    associate ( F => I % Fluid )
    associate &
      (  Mu_E =>  F % Value ( :, F % CHEMICAL_POTENTIAL_E ), &
        Mu_NP =>  F % Value ( :, F % CHEMICAL_POTENTIAL_N_P ), &
            T =>  F % Value ( :, F % TEMPERATURE ) )

    select case ( trim ( C % Type ) )
    case ( 'NEUTRINOS_E_NU' )
      call ComputeEquilibrium_T_Eta_Kernel &
             ( T_EQ, Eta_EQ, Mu_E, Mu_NP, T, Sign = 1.0_KDR )
    case ( 'NEUTRINOS_E_NU_BAR' )
      call ComputeEquilibrium_T_Eta_Kernel &
             ( T_EQ, Eta_EQ, Mu_E, Mu_NP, T, Sign = -1.0_KDR )
    end select !-- NM % Type

    end associate !-- Mu_E, etc.
    end associate !-- F

  end subroutine ComputeEquilibrium_T_Eta


  subroutine Compute_NuE_N ( Xi_J, Xi_N, M, N, T, X_P, X_N, Mu_E )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      Xi_J, Xi_N
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      M, &
      N, &
      T, &
      X_p, &
      X_n, &
      Mu_E

    integer ( KDI ) :: &
      iV, &
      nValues
    real ( KDR ) :: &
      Factor, &
      Q, &
      N_p, N_n, &
      Eta_E_Q, &
      Fermi_2_E, Fermi_3_E, Fermi_4_E, Fermi_5_E, &
      fdeta, fdeta2, &
      fdtheta, fdtheta2, &
      fdetadtheta

    nValues  =  size ( Xi_J )
    
    Factor  =  4 / TwoPi ** 3  *  G_F ** 2  *  ( 1  +  3 * g_A ** 2 )
    Q       =  m_n - m_p

    !$OMP parallel do &
    !$OMP   private ( iV, N_P, N_N, Eta_E_Q, &
    !$OMP             Fermi_2_E, Fermi_3_E, Fermi_4_E, Fermi_5_E, &
    !$OMP             fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta ) 
    do iV = 1, nValues

!call Show ( iV, '>>> iV' )

      if ( T ( iV ) == 0.0_KDR ) &
        cycle

      N_p  =  M ( iV )  *  N ( iV )  *  X_p ( iV )  /  AMU
      N_n  =  M ( iV )  *  N ( iV )  *  X_n ( iV )  /  AMU

      Eta_E_Q  =  ( Mu_E ( iV )  -  Q )  /  T ( iV )

      call DFERMI ( 2.0_KDR, Eta_E_Q, 0.0_KDR, Fermi_2_E, &
                    fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call DFERMI ( 3.0_KDR, Eta_E_Q, 0.0_KDR, Fermi_3_E, &
                    fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call DFERMI ( 4.0_KDR, Eta_E_Q, 0.0_KDR, Fermi_4_E, &
                    fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call DFERMI ( 5.0_KDR, Eta_E_Q, 0.0_KDR, Fermi_5_E, &
                    fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )

      Xi_J ( iV )  &
        =  Xi_J ( iV )  &
           +  Factor  *  N_p  *  T ( iV ) ** 4 &
              *  (    T ( iV ) ** 2     *  Fermi_5_E  &
                   +  2 * Q * T ( iV )  *  Fermi_4_E  &
                   +  Q ** 2            *  Fermi_3_E )

      Xi_N ( iV )  &
        =  Xi_N ( iV )  &
           +  Factor  *  N_p  *  T ( iV ) ** 3 &
              *  (    T ( iV ) ** 2     *  Fermi_4_E  &
                   +  2 * Q * T ( iV )  *  Fermi_3_E  &
                   +  Q ** 2            *  Fermi_2_E )

    end do !-- iV
    !$OMP end parallel do

  end subroutine Compute_NuE_N


  subroutine ComputeEquilibrium_T_Eta_Kernel &
               ( T_EQ, Eta_EQ, Mu_E, Mu_NP, T, Sign )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      T_EQ, &
      Eta_EQ
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      Mu_E, &
      Mu_NP, &
      T
    real ( KDR ), intent ( in ) :: &
      Sign

    integer ( KDI ) :: &
      iV, &
      nValues

    nValues = size ( Eta_EQ )

    !$OMP parallel do private ( iV ) 
    do iV = 1, nValues

      T_EQ ( iV )  =  T ( iV )

      if ( T ( iV ) > 0.0_KDR ) then
        Eta_EQ ( iV )  =  Sign  *  ( Mu_E ( iV )  -  Mu_NP ( iV ) )  &
                          /  T ( iV )
      else
        Eta_EQ ( iV )  =  0.0_KDR
      end if

    end do !-- iV
    !$OMP end parallel do

  end subroutine ComputeEquilibrium_T_Eta_Kernel


  subroutine RegulateKernel &
               ( Xi_J, Xi_H, Xi_N, Chi_J, Chi_H, Chi_N, J, E, R, dT )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      Xi_J, Xi_H, Xi_N, &
      Chi_J, Chi_H, Chi_N
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      J, &
      E
    real ( KDR ), intent ( in ) :: &
      R, &
      dT

    integer ( KDI ) :: &
      iV, &
      nValues
    real ( KDR ) :: &
      Ratio  

    nValues  =  size ( Xi_J )
    
    !$OMP parallel do private ( iV, Ratio )
    do iV = 1, nValues

      Ratio  =  ( Xi_J ( iV )  -  Chi_J ( iV ) * J ( iV ) ) * dT  /  E ( iV )

      if ( Ratio > R ) then
         Xi_J ( iV )  =  R / Ratio  *   Xi_J ( iV )
         Xi_H ( iV )  =  R / Ratio  *   Xi_H ( iV )
         Xi_N ( iV )  =  R / Ratio  *   Xi_N ( iV )
        Chi_J ( iV )  =  R / Ratio  *  Chi_J ( iV )
        Chi_H ( iV )  =  R / Ratio  *  Chi_H ( iV )
        Chi_N ( iV )  =  R / Ratio  *  Chi_N ( iV )
call Show ( '>>> Regulating Interactions', CONSOLE % ERROR )
call Show ( PROGRAM_HEADER % Communicator % Rank, '>>> Rank', CONSOLE % ERROR )
call Show ( iV, '>>> iV', CONSOLE % ERROR )
call Show ( R / Ratio, '>>> RegulationFactor', CONSOLE % ERROR )
      end if
    end do !-- iV
    !$OMP end parallel do

  end subroutine RegulateKernel


end module Interactions_NM_1_G__Form
