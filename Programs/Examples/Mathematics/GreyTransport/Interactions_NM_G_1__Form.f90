module Interactions_NM_G_1__Form

  !-- Interactions_NeutrinoMoments_Grey_1__Form
  
  use Basics
  use Mathematics
  use Fluid_P_MHN__Form
  use NeutrinoMoments_Form
  use Interactions_Template

  implicit none
  private

      integer ( KDI ), private, parameter :: &
        N_FIELDS_NM = 2

  type, public, extends ( InteractionsTemplate ) :: Interactions_NM_G_1_Form
    integer ( KDI ) :: &
      N_FIELDS_NM                = N_FIELDS_NM, &
      EQUILIBRIUM_DENSITY_NUMBER = 0, &
      EFFECTIVE_OPACITY_NUMBER   = 0
    class ( Fluid_P_MHN_Form ), pointer :: &
      Fluid => null ( )
    class ( NeutrinoMomentsForm ), pointer :: &
      Neutrinos_E_Nu          => null ( ), &
      Neutrinos_E_NuBar       => null ( ), &
      Neutrinos_MuTau_NuNuBar => null ( )
  contains
    procedure, private, pass :: &
      InitializeAllocate_NM_G_1
    generic, public :: &
      Initialize => InitializeAllocate_NM_G_1
    procedure, private, pass :: &
      Set_NM_G_1
    generic, public :: &
      Set => Set_NM_G_1
    procedure, public, pass :: &
      Compute
    final :: &
      Finalize
    procedure, public, pass ( I ) :: &
      ComputeDegeneracyParameter_EQ
    procedure, private, pass :: &
      Compute_E_Nu_Kernel
    !procedure, private, pass :: &
    !  Compute_E_NuBar_Kernel
  end type Interactions_NM_G_1_Form

    private :: &
      InitializeBasics, &
      ComputeDegeneracyParameter_EQ_Kernel
      

contains


  subroutine InitializeAllocate_NM_G_1 &
               ( I, LengthUnit, EnergyDensityUnit, nValues, VariableOption, &
                 NameOption, ClearOption, UnitOption )

    class ( Interactions_NM_G_1_Form ), intent ( inout ) :: &
      I
    type ( MeasuredValueForm ), intent ( in ) :: &
      LengthUnit, &
      EnergyDensityUnit
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

    type ( MeasuredValueForm ), dimension ( : ), allocatable :: &
      VariableUnit
    character ( LDL ), dimension ( : ), allocatable :: &
      Variable
    logical ( KDL ) :: &
      Clear

    call InitializeBasics &
           ( I, Variable, VariableUnit, VariableOption, UnitOption )

    call I % InitializeTemplate &
           ( LengthUnit, EnergyDensityUnit, nValues, &
             VariableOption = Variable, NameOption = NameOption, &
             ClearOption = ClearOption, UnitOption = VariableUnit )

  end subroutine InitializeAllocate_NM_G_1


  subroutine Set_NM_G_1 &
               ( I, Neutrinos_E_Nu, Neutrinos_E_NuBar, &
                 Neutrinos_MuTau_NuNuBar, Fluid )

    class ( Interactions_NM_G_1_Form ), intent ( inout ) :: &
      I
    class ( NeutrinoMomentsForm ), intent ( in ), target :: &
      Neutrinos_E_Nu, &
      Neutrinos_E_NuBar, &
      Neutrinos_MuTau_NuNuBar
    class ( Fluid_P_MHN_Form ), intent ( in ), target :: &
      Fluid

    I % Fluid                    =>  Fluid
    I % Neutrinos_E_Nu           =>  Neutrinos_E_Nu
    I % Neutrinos_E_NuBar        =>  Neutrinos_E_NuBar
    I % Neutrinos_MuTau_NuNuBar  =>  Neutrinos_MuTau_NuNuBar 

  end subroutine Set_NM_G_1


  subroutine Compute ( I, Current )

    class ( Interactions_NM_G_1_Form ), intent ( inout ) :: &
      I
    class ( CurrentTemplate ), intent ( in ) :: &
      Current

    associate &
      ( Nu_E     => I % Neutrinos_E_Nu, &
        Nu_E_Bar => I % Neutrinos_E_NuBar, &
        Nu_M_T   => I % Neutrinos_MuTau_NuNuBar, &
        F        => I % Fluid )

    select case ( trim ( Current % Type ) )
    case ( 'NEUTRINOS_E_NU' )
       
      !-- Electron neutrino interactions
       
       call I % Compute_E_Nu_Kernel &
             ( Nu_E % Value ( :, Nu_E % TEMPERATURE_PARAMETER ), &
               Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER ), &
               Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER_EQ ), &
               F % Value ( :, F % BARYON_MASS ), &
               F % Value ( :, F % COMOVING_DENSITY ), &
               F % Value ( :, F % MASS_FRACTION_NEUTRON ), &
               F % Value ( :, F % MASS_FRACTION_PROTON ), &
               F % Value ( :, F % CHEMICAL_POTENTIAL_N_P ), &
               F % Value ( :, F % CHEMICAL_POTENTIAL_E ), &
               F % Value ( :, F % TEMPERATURE ), &
               I % Value ( :, I % EQUILIBRIUM_DENSITY ), &
               I % Value ( :, I % EFFECTIVE_OPACITY ), &
               I % Value ( :, I % TRANSPORT_OPACITY ) )

    case ( 'NEUTRINOS_E_NU_BAR' )

      !-- Electron antineutrino interactions

      ! call I % Compute_E_NuBar_Kernel &
      !       ( Nu_E % Value ( :, Nu_E % TEMPERATURE_PARAMETER ), &
      !         Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER ), &
      !         F % Value ( :, F % BARYON_MASS ), &
      !         F % Value ( :, F % COMOVING_DENSITY ), &
      !         F % Value ( :, F % CHEMICAL_POTENTIAL_N_P ), &
      !         F % Value ( :, F % CHEMICAL_POTENTIAL_E ), & ! Mu_e_+ = - Mu_e ?
      !         F % Value ( :, F % TEMPERATURE ), &
      !         I % Value ( :, I % EQUILIBRIUM_DENSITY ), &
      !         I % Value ( :, I % EFFECTIVE_OPACITY ), &
      !         I % Value ( :, I % TRANSPORT_OPACITY ) )

    case ( 'NEUTRINOS_MU_TAU_NU_NU_BAR' )

      !-- Mu and Tau neutrino and antineutrino interactions

    case default
      call Show ( 'Radiation Type not recognized', CONSOLE % ERROR )
      call Show ( 'Interactions_NM_G_1__Form', 'module', CONSOLE % ERROR )
      call Show ( 'Compute', 'subroutine', CONSOLE % ERROR )
    end select !-- Radiation % Type

    end associate !-- Nu_E, etc.
    
  end subroutine Compute


  impure elemental subroutine Finalize ( I )

    type ( Interactions_NM_G_1_Form ), intent ( inout ) :: &
      I

    nullify ( I % Neutrinos_MuTau_NuNuBar )
    nullify ( I % Neutrinos_E_NuBar )
    nullify ( I % Neutrinos_E_Nu )
    nullify ( I % Fluid )

    call I % FinalizeTemplate ( )

  end subroutine Finalize


  subroutine ComputeDegeneracyParameter_EQ ( Eta_EQ, I, C )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      Eta_EQ
    class ( Interactions_NM_G_1_Form ), intent ( in ) :: &
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
      call ComputeDegeneracyParameter_EQ_Kernel &
             ( Eta_EQ, Mu_E, Mu_NP, T, Sign = 1.0_KDR )
    case ( 'NEUTRINOS_E_NU_BAR' )
      call ComputeDegeneracyParameter_EQ_Kernel &
             ( Eta_EQ, Mu_E, Mu_NP, T, Sign = -1.0_KDR )
    end select !-- NM % Type

    end associate !-- Mu_E, etc.
    end associate !-- F

  end subroutine ComputeDegeneracyParameter_EQ


<<<<<<< HEAD
  subroutine Compute_E_Nu_Kernel &
               ( I, TP, Eta_Nu, Eta_Nu_Eq, M, N, X_n, X_p, Mu_N_P, Mu_E, T, EDV, EOV, TOV )

    class ( Interactions_NM_G_1_Form ), intent ( in ) :: &
      I
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      TP, &
      Eta_Nu, &
      Eta_Nu_Eq, &
      M, &
      N, &
      X_n, &
      X_p, &
      Mu_N_P, &
      Mu_E, &
      T
    real ( KDR ), dimension ( : ), intent ( out ) :: &
      EDV, &
      EOV, &
      TOV

    integer ( KDI ) :: &
      iV, &
      nValues
    real ( KDR ) :: &
      k_b, &
      E_Nu_Average, &
      J_Factor, &
      G_F, &
      Chi_Factor, &
      M_P, &
      M_N, &
      Q, &
      amu, &
      Beta_F, &
      Eta_N_P, &
      F_E, F_Nu_Eq, &
      Chi_0, &
      Fermi_2, Fermi_3, Fermi_4, Fermi_5, &
      Fermi_2_Eq, Fermi_3_Eq, Fermi_4_Eq, Fermi_5_Eq, &
      fdeta, fdeta2, &
      fdtheta, fdtheta2, &
      fdetadtheta, &
      S, S_Eq
      
    nValues  =  size ( EDV )
    
    k_b = CONSTANT % BOLTZMANN 
    
    associate &
      ( c      => CONSTANT % SPEED_OF_LIGHT, &
        hBar   => CONSTANT % PLANCK_REDUCED, &
        FourPi => 4.0_KDR * CONSTANT % PI, &
        TwoPi  => 2.0_KDR * CONSTANT % PI )

    J_Factor   =  FourPi  *  k_b ** 4  /  ( TwoPi * hBar * c ) ** 3
    G_F        =  1.1663787e-5_KDR * ( hBar * c ) ** 3 * ( 1.0e3_KDR * UNIT % MEV ) ** ( -2 )
    Chi_Factor = 2.0_KDR * G_F ** 2 / TwoPi * ( 3.0_KDR * 1.23_KDR ** 2 + 1.0_KDR ) / ( hbar * c ) ** 4 
    
    end associate !-- c, etc.
    
    M_P = 938.2720813_KDR * UNIT % MEV 
    M_N = 939.5654133_KDR * UNIT % MEV
    Q   = M_N - M_P
    amu = CONSTANT % ATOMIC_MASS_UNIT

    !$OMP parallel do private ( iV ) 
    do iV = 1, nValues
       
      call dfermi &
             ( 2.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_2, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 3.0_KDR, Eta_Nu_Eq ( iV ), 0.0_KDR, Fermi_3_eq, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 3.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_3, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 4.0_KDR, Eta_Nu_Eq ( iV ), 0.0_KDR, Fermi_4_eq, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 4.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_4, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 5.0_KDR, Eta_Nu_Eq ( iV ), 0.0_KDR, Fermi_5_eq, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 5.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_5, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)

      E_Nu_Average = k_B * TP ( iV ) * Fermi_3 / Fermi_2 
      Beta_F    = 1.0_KDR / ( k_B * T ( iV ) )
      Eta_N_P   = M ( iV ) * N ( iV ) * ( X_p ( iV ) - X_n ( iV ) ) / amu &
                  / ( exp ( Beta_F * ( Q - Mu_N_P ( iV ) ) ) - 1.0_KDR )
      F_E       = 1.0_KDR / ( exp ( Beta_F * ( E_Nu_Average + Q - Mu_E ( iV ) ) ) + 1.0_KDR )
      F_Nu_Eq   = 1.0_KDR / ( exp ( Beta_F * E_Nu_Average - Eta_Nu_Eq ( iV ) ) + 1.0_KDR )
      Chi_0     =  Chi_Factor * Eta_N_P * ( 1.0_KDR - F_e ) / ( 1.0_KDR - F_Nu_Eq )
      

      S = ( k_b * TP ( iV ) ) ** 2 * Fermi_5 / Fermi_3 
      S_eq = ( k_b * T ( iV ) ) ** 2 * Fermi_5_eq / Fermi_3_eq
      
      EDV ( iV )  =  J_Factor *  T ( iV ) ** 4 * Fermi_3_eq * S_eq / S
      EOV ( iV )  =  Chi_0 * S
      TOV ( iV )  =  EOV ( iV )
    end do !-- iV
    !$OMP end parallel do

  end subroutine Compute_E_Nu_Kernel
=======
  subroutine InitializeBasics &
               ( I, Variable, VariableUnit, VariableOption, &
                 VariableUnitOption )

    class ( Interactions_NM_G_1_Form ), intent ( inout ) :: &
      I
    character ( LDL ), dimension ( : ), allocatable, intent ( out ) :: &
      Variable
    type ( MeasuredValueForm ), dimension ( : ), allocatable, &
      intent ( out ) :: &
        VariableUnit
    character ( * ), dimension ( : ), intent ( in ), optional :: &
      VariableOption
    type ( MeasuredValueForm ), dimension ( : ), intent ( in ), optional :: &
      VariableUnitOption

    integer ( KDI ) :: &
      oF  !-- oField

    if ( I % Type == '' ) &
      I % Type = 'an Interactions_NM_G_1'

    !-- variable indices

    oF = I % N_FIELDS_TEMPLATE
    if ( I % N_FIELDS == 0 ) &
      I % N_FIELDS = oF + I % N_FIELDS_NM

    I % EQUILIBRIUM_DENSITY_NUMBER = oF + 1
    I % EFFECTIVE_OPACITY_NUMBER   = oF + 2

    !-- variable names 

    if ( present ( VariableOption ) ) then
      allocate ( Variable ( size ( VariableOption ) ) )
      Variable = VariableOption
    else
      allocate ( Variable ( I % N_FIELDS ) )
      Variable = ''
    end if

    Variable ( oF + 1 : oF + I % N_FIELDS_NM ) &
      = [ 'EquilibriumDensityNumber', &
          'EffectiveOpacityNumber  ' ]
          
    !-- units
    
    if ( present ( VariableUnitOption ) ) then
      allocate ( VariableUnit ( size ( VariableUnitOption ) ) )
      VariableUnit = VariableUnitOption
    else
      allocate ( VariableUnit ( I % N_FIELDS ) )
      VariableUnit = UNIT % IDENTITY
    end if
    
  end subroutine InitializeBasics
>>>>>>> 9fe1fd9b3a5a86753f118fb71db0d14f4043d651


  subroutine ComputeDegeneracyParameter_EQ_Kernel &
               ( Eta_EQ, Mu_E, Mu_NP, T, Sign )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
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
      Eta_EQ ( iV )  =  Sign  *  ( Mu_E ( iV )  -  Mu_NP ( iV ) )  &
                        /  max ( T ( iV ), tiny ( 0.0_KDR ) )
    end do !-- iV
    !$OMP end parallel do

  end subroutine ComputeDegeneracyParameter_EQ_Kernel


end module Interactions_NM_G_1__Form
