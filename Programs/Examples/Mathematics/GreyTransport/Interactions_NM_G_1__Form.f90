module Interactions_NM_G_1__Form

  !-- Interactions_NeutrinoMoments_Grey_1__Form
  
  use Basics
  use Mathematics
  use Fluid_P_MHN__Form
  use NeutrinoMoments_Form
  use Interactions_Template

  implicit none
  private

!    integer ( KDI ), private, parameter :: &
!      N_FIELDS_NM = 0

  type, public, extends ( InteractionsTemplate ) :: Interactions_NM_G_1_Form
!    integer ( KDI ) :: &
!      N_FIELDS_NM              = N_FIELDS_NM
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
    procedure, public, pass :: &
      Compute_E_Nu_N_Kernel
    procedure, public, pass :: &
      Compute_E_Nu_Nuclei_Kernel
    procedure, public, pass :: &
      Compute_E_NuBar_Kernel
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

    call Show ( 'Computing Interactions', I % IGNORABILITY )

    associate &
      ( Nu_E     => I % Neutrinos_E_Nu, &
        NuBar_E => I % Neutrinos_E_NuBar, &
        Nu_M_T   => I % Neutrinos_MuTau_NuNuBar, &
        F        => I % Fluid )

    select case ( trim ( Current % Type ) )
    case ( 'NEUTRINOS_E_NU' )
       
      call Show ( Nu_E % Name, 'Species', I % IGNORABILITY )

! call Show ( '>>> Free nucleons' )       
!       call I % Compute_E_Nu_N_Kernel &
!              ( Nu_E % Value ( :, Nu_E % TEMPERATURE_PARAMETER ), &
!                Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER ), &
!                Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER_EQ ), &
!                F % Value ( :, F % BARYON_MASS ), &
!                F % Value ( :, F % COMOVING_DENSITY ), &
!                F % Value ( :, F % MASS_FRACTION_NEUTRON ), &
!                F % Value ( :, F % MASS_FRACTION_PROTON ), &
!                F % Value ( :, F % CHEMICAL_POTENTIAL_N_P ), &
!                F % Value ( :, F % CHEMICAL_POTENTIAL_E ), &
!                F % Value ( :, F % TEMPERATURE ), &
!                I % Value ( :, I % EQUILIBRIUM_DENSITY ), &
!                I % Value ( :, I % EFFECTIVE_OPACITY ), &
!                I % Value ( :, I % TRANSPORT_OPACITY ), &
!                I % Value ( :, I % EQUILIBRIUM_DENSITY_NUMBER ), &
!                I % Value ( :, I % EFFECTIVE_OPACITY_NUMBER ) )
       
!call Show ( '>>> Nuclei' )       
      call I % Compute_E_Nu_Nuclei_Kernel &
             ( Nu_E % Value ( :, Nu_E % TEMPERATURE_PARAMETER ), &
               Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER ), &
               Nu_E % Value ( :, Nu_E % DEGENERACY_PARAMETER_EQ ), &
               Nu_E % Value ( :, Nu_E % ENERGY_AVERAGE ), &
               F % Value ( :, F % BARYON_MASS ), &
               F % Value ( :, F % COMOVING_DENSITY ), &
               F % Value ( :, F % MASS_FRACTION_HEAVY ), &
               F % Value ( :, F % HEAVY_ATOMIC_NUMBER ), &
               F % Value ( :, F % HEAVY_MASS_NUMBER ), &
               F % Value ( :, F % CHEMICAL_POTENTIAL_N_P ), &
               F % Value ( :, F % CHEMICAL_POTENTIAL_E ), &
               F % Value ( :, F % TEMPERATURE ), &
               I % Value ( :, I % EMISSIVITY ), &
               I % Value ( :, I % EFFECTIVE_OPACITY ), &
               I % Value ( :, I % TRANSPORT_OPACITY ), &
               I % Value ( :, I % EMISSIVITY_NUMBER ), &
               I % Value ( :, I % EFFECTIVE_OPACITY_NUMBER ) )

    case ( 'NEUTRINOS_E_NU_BAR' )

      call Show ( NuBar_E % Name, 'Species', I % IGNORABILITY )

call Clear ( I % Value ( :, I % EMISSIVITY ) )
call Clear ( I % Value ( :, I % EFFECTIVE_OPACITY ) )
call Clear ( I % Value ( :, I % TRANSPORT_OPACITY ) )
call Clear ( I % Value ( :, I % EMISSIVITY_NUMBER ) )
call Clear ( I % Value ( :, I % EFFECTIVE_OPACITY_NUMBER ) )

      ! call I % Compute_E_NuBar_Kernel &
      !        ( NuBar_E % Value ( :, NuBar_E % TEMPERATURE_PARAMETER ), &
      !          NuBar_E % Value ( :, NuBar_E % DEGENERACY_PARAMETER ), &
      !          NuBar_E % Value ( :, NuBar_E % DEGENERACY_PARAMETER_EQ ), &
      !          F % Value ( :, F % BARYON_MASS ), &
      !          F % Value ( :, F % COMOVING_DENSITY ), &
      !          F % Value ( :, F % MASS_FRACTION_NEUTRON ), &
      !          F % Value ( :, F % MASS_FRACTION_PROTON ),&
      !          F % Value ( :, F % CHEMICAL_POTENTIAL_N_P ), &
      !          F % Value ( :, F % CHEMICAL_POTENTIAL_E ), & ! Mu_e_+ = - Mu_e 
      !          F % Value ( :, F % TEMPERATURE ), &
      !          I % Value ( :, I % EMISSIVITY ), &
      !          I % Value ( :, I % EFFECTIVE_OPACITY ), &
      !          I % Value ( :, I % TRANSPORT_OPACITY ), &
      !          I % Value ( :, I % EMISSIVITY_NUMBER ), &
      !          I % Value ( :, I % EFFECTIVE_OPACITY_NUMBER ) )

    case ( 'NEUTRINOS_MU_TAU_NU_NU_BAR' )

      call Show ( Nu_M_T % Name, 'Species', I % IGNORABILITY )

      !-- Mu and Tau neutrino and antineutrino interactions

call Clear ( I % Value ( :, I % EMISSIVITY ) )
call Clear ( I % Value ( :, I % EFFECTIVE_OPACITY ) )
call Clear ( I % Value ( :, I % TRANSPORT_OPACITY ) )
call Clear ( I % Value ( :, I % EMISSIVITY_NUMBER ) )
call Clear ( I % Value ( :, I % EFFECTIVE_OPACITY_NUMBER ) )

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


  subroutine ComputeDegeneracyParameter_EQ ( T_EQ, Eta_EQ, I, C )

    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      T_EQ, &
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
             ( T_EQ, Eta_EQ, Mu_E, Mu_NP, T, Sign = 1.0_KDR )
    case ( 'NEUTRINOS_E_NU_BAR' )
      call ComputeDegeneracyParameter_EQ_Kernel &
             ( T_EQ, Eta_EQ, Mu_E, Mu_NP, T, Sign = -1.0_KDR )
    end select !-- NM % Type

    end associate !-- Mu_E, etc.
    end associate !-- F

  end subroutine ComputeDegeneracyParameter_EQ


  subroutine Compute_E_Nu_N_Kernel &
               ( I, TP, Eta_Nu, Eta_Nu_EQ, M, N, X_n, X_p, Mu_N_P, Mu_E, T, &
                 EDV, EOV, TOV, EDNV, EONV )

    class ( Interactions_NM_G_1_Form ), intent ( in ) :: &
      I
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      TP, &
      Eta_Nu, &
      Eta_Nu_EQ, &
      M, &
      N, &
      X_n, &
      X_p, &
      Mu_N_P, &
      Mu_E, &
      T
    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      EDV, &
      EOV, &
      TOV, &
      EDNV, &
      EONV

    integer ( KDI ) :: &
      iV, &
      nValues
    real ( KDR ) :: &
      Tiny_10, &
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
      One_Minus_F_E, One_Minus_F_Nu_EQ, &
      Chi_0, &
      Fermi_2, Fermi_3, Fermi_4, Fermi_5, &
      Fermi_3_EQ, Fermi_4_EQ, Fermi_5_EQ, &
      fdeta, fdeta2, &
      fdtheta, fdtheta2, &
      fdetadtheta, &
      S, S_EQ, &
      S_N, S_N_EQ
      
    nValues  =  size ( EDV )
    
    Tiny_10 = 1.0e10_KDR * tiny ( 0.0_KDR )

    k_b = CONSTANT % BOLTZMANN 
    
    associate &
      ( c      => CONSTANT % SPEED_OF_LIGHT, &
        hBar   => CONSTANT % PLANCK_REDUCED, &
        FourPi => 4.0_KDR * CONSTANT % PI, &
        TwoPi  => 2.0_KDR * CONSTANT % PI, &
        Pi     => CONSTANT % PI )

    J_Factor   = FourPi * k_b ** 4  /  ( TwoPi * hBar * c ) ** 3
    G_F        =  1.1663787e-5_KDR * ( hBar * c ) ** 3 &
                  * ( 1.0e3_KDR * UNIT % MEGA_ELECTRON_VOLT ) ** ( -2 )
    Chi_Factor =  G_F ** 2 / Pi * ( 3.0_KDR * 1.23_KDR ** 2 + 1.0_KDR ) &
                  / ( hbar * c ) ** 4 
    
    end associate !-- c, etc.
    
    M_P = 938.2720813_KDR * UNIT % MEGA_ELECTRON_VOLT
    M_N = 939.5654133_KDR * UNIT % MEGA_ELECTRON_VOLT
    Q   = M_N - M_P
    amu = CONSTANT % ATOMIC_MASS_UNIT

    !$OMP parallel do private ( iV ) 
    do iV = 1, nValues
       
      if ( T ( iV ) == 0.0_KDR ) &
        cycle

call Show ( iV, '>>> iV' )
      call dfermi &
             ( 2.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_2, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 3.0_KDR, Eta_Nu_EQ ( iV ), 0.0_KDR, Fermi_3_EQ, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 3.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_3, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 4.0_KDR, Eta_Nu_EQ ( iV ), 0.0_KDR, Fermi_4_EQ, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 4.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_4, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 5.0_KDR, Eta_Nu_EQ ( iV ), 0.0_KDR, Fermi_5_EQ, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 5.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_5, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )

!call Show ( '>>> 1' )
      E_Nu_Average = k_B * TP ( iV ) * Fermi_3 / Fermi_2 
      Beta_F    = 1.0_KDR / ( k_B * T ( iV ) )
!      Eta_N_P   = M ( iV ) * N ( iV ) * ( X_p ( iV ) - X_n ( iV ) ) / amu &
!                  / ( exp ( Beta_F * ( Q - Mu_N_P ( iV ) ) ) - 1.0_KDR )
      Eta_N_P   = M ( iV ) * N ( iV ) * X_n ( iV ) / amu
      !-- Use Fermi-Dirac identity 1 - f(x) = f(-x) to avoid precision loss 
!      One_Minus_F_E &
!        = 1.0_KDR / ( exp ( - Beta_F * ( E_Nu_Average + Q - Mu_E ( iV ) ) ) &
!                      + 1.0_KDR )
      One_Minus_F_E &
        = 1.0_KDR / ( exp ( - Beta_F * ( E_Nu_Average - Mu_E ( iV ) ) ) &
                      + 1.0_KDR )
      One_Minus_F_Nu_EQ &
        = 1.0_KDR / ( exp ( - Beta_F * E_Nu_Average + Eta_Nu_EQ ( iV ) ) &
                      + 1.0_KDR )
!      Chi_0 = Chi_Factor * Eta_N_P * One_Minus_F_E / One_Minus_F_Nu_EQ
      Chi_0 = Chi_Factor * Eta_N_P * One_Minus_F_E
call Show ( Chi_Factor, '>>> Chi_Factor' )
call Show ( Eta_N_P, '>>> Eta_N_P' )
call Show ( One_Minus_F_E, '>>> One_Minus_F_E' )      
call Show ( One_Minus_F_Nu_EQ, '>>> One_Minus_F_Nu_EQ' )
call Show ( exp ( - Eta_Nu_EQ ( iV ) ), '>>> exp ( -eta_nu_eq )' )

      S      = max ( ( k_b * TP ( iV ) ) ** 2 * Fermi_5 / Fermi_3, Tiny_10 ) 
      S_EQ   = ( k_b * T ( iV ) ) ** 2 * Fermi_5_EQ / Fermi_3_EQ
      S_N    = max ( ( k_b * TP ( iV ) ) * Fermi_4 / Fermi_3, Tiny_10 ) 
      S_N_EQ = ( k_b * T ( iV ) ) * Fermi_4_EQ / Fermi_3_EQ

      EDV ( iV )  = J_Factor *  T ( iV ) ** 4 * Fermi_3_EQ * S_EQ / S
      EOV ( iV )  = Chi_0 * S
      TOV ( iV )  = EOV ( iV )
      EDNV ( iV ) = J_Factor *  T ( iV ) ** 4 * Fermi_3_EQ * S_N_EQ / S_N
      EONV ( iV ) = Chi_0 * S_N
    
    end do !-- iV
    !$OMP end parallel do

  end subroutine Compute_E_Nu_N_Kernel


  subroutine Compute_E_Nu_Nuclei_Kernel &
               ( I, TP, Eta_Nu, Eta_Nu_EQ, E_Nu_Ave, M, N, X_heavy, Z, A, &
                 Mu_N_P, Mu_E, T, EV, EOV, TOV, ENV, EONV )

    class ( Interactions_NM_G_1_Form ), intent ( in ) :: &
      I
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      TP, &
      Eta_Nu, &
      Eta_Nu_EQ, &
      E_Nu_Ave, &
      M, &
      N, &
      X_heavy, &
      Z, &
      A, &
      Mu_N_P, &
      Mu_E, &
      T
    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      EV, &
      EOV, &
      TOV, &
      ENV, &
      EONV

    integer ( KDI ) :: &
      iV, &
      nValues
    real ( KDR ) :: &
      Tiny_10, &
      TwoPi, EightPi, &
      k_b, hBar_c, &
      G_F, &
      Chi_Factor, &
      Q, &
      E_Min, &
      amu, &
      N_p, &
      N_h, &
      Beta_F, &
      N_A, &
      One_Minus_F_E, One_Minus_F_Nu, &
      Chi_0, &
      Fermi_2_Nu, Fermi_3_Nu, Fermi_4_Nu, Fermi_5_Nu, &
      Fermi_2_E, Fermi_4_E, Fermi_5_E, &
      fdeta, fdeta2, &
      fdtheta, fdtheta2, &
      fdetadtheta, &
      S, S_EQ, &
      S_N, S_N_EQ
      
    nValues  =  size ( EV )
    
    Tiny_10  =  1.0e10_KDR * tiny ( 0.0_KDR )
    TwoPi    =  2.0_KDR  *  CONSTANT % PI
    EightPi  =  8.0_KDR  *  CONSTANT % PI

    k_b     =  CONSTANT % BOLTZMANN 
    hBar_c  =  CONSTANT % PLANCK_REDUCED  *  CONSTANT % SPEED_OF_LIGHT

    associate &
      ( FourPi => 4.0_KDR * CONSTANT % PI, &
        Pi     => CONSTANT % PI )

    G_F        =  1.1663787e-5_KDR * ( hBar_c ) ** 3 &
                  * ( 1.0e3_KDR * UNIT % MEGA_ELECTRON_VOLT ) ** ( -2 )
    Chi_Factor =  G_F ** 2 / Pi * 1.23_KDR ** 2 * 2.0_KDR / 7.0_KDR &
                  / ( hbar_c ) ** 4 
    
    end associate !-- c, etc.
    
    amu = CONSTANT % ATOMIC_MASS_UNIT

    !$OMP parallel do private ( iV ) 
    do iV = 1, nValues
!call Show ( iV, '>>> iV' )
        
      if ( T ( iV ) == 0.0_KDR .or. A ( iV ) == 0.0_KDR ) &
        cycle

      Q  =  Mu_N_P ( iV )  +  3.0_KDR * UNIT % MEGA_ELECTRON_VOLT
!call Show ( Q, UNIT % MEV, '>>> Q' )
!call Show ( Mu_N_P ( iV ), UNIT % MEV, '>>> Mu_N_P' )

      E_Min = 0.0_KDR
      if ( Q < 0.0_KDR ) &
        E_Min = abs ( Q )

      call dfermi &
             ( 2.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_2_Nu, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 3.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_3_Nu, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 4.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_4_Nu, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 5.0_KDR, Eta_Nu ( iV ), 0.0_KDR, Fermi_5_Nu, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta )
      call dfermi &
             ( 4.0_KDR, ( Mu_E ( iV ) - ( Q + E_Min ) ) / ( k_b * T ( iV ) ), &
               0.0_KDR, Fermi_4_E, fdeta, fdtheta, fdeta2, fdtheta2, &
               fdetadtheta )
      call dfermi &
             ( 5.0_KDR, ( Mu_E ( iV ) - ( Q + E_Min ) ) / ( k_b * T ( iV ) ), &
               0.0_KDR, Fermi_5_E, fdeta, fdtheta, fdeta2, fdtheta2, &
               fdetadtheta )

! call Show ( E_Nu_Ave ( iV ), UNIT % MEV, '>>> E_Nu' )
!call Show ( Mu_E ( iV ), UNIT % MEV, '>>> Mu_E' )
!call Show ( Mu_E ( iV ) - Q, '>>> Mu_E - Q' )

      if ( Z ( iV ) < 20 ) then
        N_p = 0.0_KDR
      else if ( Z ( iV ) < 28 ) then
        N_p = Z ( iV ) - 20.0_KDR
      else if ( Z ( iV ) >= 28 ) then
        N_p = 8.0_KDR
      end if
      
      if ( A ( iV ) - Z ( iV ) < 34 ) then
        N_h = 6.0_KDR
      else if ( A ( iV ) - Z ( iV ) < 40 ) then
        N_h = 40.0_KDR - ( A ( iV ) - Z ( iV ) )
      else if ( A ( iV ) - Z ( iV ) >= 40 ) then
        N_h = 0.0_KDR
      end if

!call Show ( Chi_Factor, '>>> Chi_Factor' )
!call Show ( N_p, '>>> N_p' )
!call Show ( N_h, '>>> N_h' )
      Beta_F    = 1.0_KDR / ( k_B * T ( iV ) )
!call Show ( Beta_F, '>>> Beta_F' )
!call Show ( A ( iV ), '>>> A' )
      N_A       = M ( iV ) * N ( iV ) *  X_heavy ( iV ) / ( A ( iV ) * amu ) 
!call Show ( N_A, '>>> N_A' )
!call Show ( E_Nu_Ave ( iV ), '>>> E_Nu_Ave' )
      !-- Use Fermi-Dirac identity 1 - f(x) = f(-x) to avoid precision loss 
      One_Minus_F_E = 0.0_KDR
!      One_Minus_F_E &
!        = 1.0_KDR &
!          / ( exp ( - Beta_F * ( E_Nu_Ave ( iV ) + Q - Mu_E ( iV ) ) ) &
!              + 1.0_KDR )
!call Show ( One_Minus_F_E, '>>> One_Minus_F_E' )    
!      if ( TP ( iV ) > 0.0_KDR ) then
!        One_Minus_F_Nu &
!          = 1.0_KDR / ( exp ( - E_Nu_Ave ( iV ) / ( k_b * TP ( iV ) ) &
!                              + Eta_Nu ( iV ) ) &
!                        + 1.0_KDR )
!      else 
        One_Minus_F_Nu = 1.0_KDR
!      end if
!call Show ( One_Minus_F_Nu_EQ, '>>> One_Minus_F_Nu_EQ' )   
!call Show ( exp ( Beta_f * ( Mu_N_P ( iV ) - Q ) ), '>>> exp' )   
      Chi_0     = Chi_Factor * N_A * N_p * N_h &
                  * One_Minus_F_E * exp ( Beta_f * ( Mu_N_P ( iV ) - Q ) )

      S = max ( ( k_b * TP ( iV ) ) ** 2 * Fermi_5_Nu / Fermi_3_Nu, Tiny_10) 
      S_N = max ( ( k_b * TP ( iV ) ) ** 2 * Fermi_4_Nu / Fermi_2_Nu, Tiny_10 )

!call Show ( ( k_b * T ( iV ) / ( TwoPi * hBar_c ) ) ** 3, &
!            '>>> ( kT/hBar_c ) **3 ' )
!call Show ( ( k_b * T ( iV ) ) ** 3, '>>> ( kT ) **3 ' )
!call Show ( Fermi_5_E, '>>> Fermi_5_E' )
      EV ( iV )   = Chi_Factor * N_A * N_p * N_h * EightPi &
                    * ( k_b * T ( iV ) / ( TwoPi * hBar_c ) ) ** 3 &
                    * ( k_b * T ( iV ) ) ** 3 * Fermi_5_E !&
!                    * One_Minus_F_Nu
!call Show ( EV ( iV ), '>>> EV' )    
      EOV ( iV )  = Chi_0 * S
!call Show ( EOV ( iV ), '>>> EOV' )    
      TOV ( iV )  = EOV ( iV )
!call Show ( Fermi_4_E, '>>> Fermi_4_E' )
      ENV ( iV )  = Chi_Factor * N_A * N_p * N_h * EightPi &
                    * ( k_b * T ( iV ) / ( TwoPi * hBar_c ) ) ** 3 &
                    * ( k_b * T ( iV ) ) ** 2 * Fermi_4_E !&
!                    * One_Minus_F_Nu
!call Show ( amu * ENV ( iV ), '>>> amu * ENV' )    
      EONV ( iV ) = Chi_0 * S_N

    end do !-- iV
    !$OMP end parallel do

  end subroutine Compute_E_Nu_Nuclei_Kernel


  subroutine Compute_E_NuBar_Kernel &
               ( I, TP, Eta_NuBar, Eta_NuBar_EQ, M, N, X_n, X_p, &
                 Mu_N_P, Mu_E, T, EDV, EOV, TOV, EDNV, EONV )

    class ( Interactions_NM_G_1_Form ), intent ( in ) :: &
      I
    real ( KDR ), dimension ( : ), intent ( in ) :: &
      TP, &
      Eta_NuBar, &
      Eta_NuBar_EQ, &
      M, &
      N, &
      X_n, &
      X_p, &
      Mu_N_P, &
      Mu_E, &
      T
    real ( KDR ), dimension ( : ), intent ( inout ) :: &
      EDV, &
      EOV, &
      TOV, &
      EDNV, &
      EONV

    integer ( KDI ) :: &
      iV, &
      nValues
    real ( KDR ) :: &
      Tiny_10, &
      k_b, &
      E_NuBar_Average, &
      J_Factor, &
      G_F, &
      Chi_Factor, &
      M_P, &
      M_N, &
      Q, &
      amu, &
      Beta_F, &
      Eta_P_N, &
      One_Minus_F_E_Bar, One_Minus_F_NuBar_EQ, &
      Chi_0, &
      Fermi_2, Fermi_3, Fermi_4, Fermi_5, &
      Fermi_3_EQ, Fermi_4_EQ, Fermi_5_EQ, &
      fdeta, fdeta2, &
      fdtheta, fdtheta2, &
      fdetadtheta, &
      S, S_EQ, &
      S_N, S_N_EQ
      
    nValues  =  size ( EDV )
    
    Tiny_10 = 1.0e10_KDR * tiny ( 0.0_KDR )

    k_b = CONSTANT % BOLTZMANN 
    
    associate &
      ( c      => CONSTANT % SPEED_OF_LIGHT, &
        hBar   => CONSTANT % PLANCK_REDUCED, &
        FourPi => 4.0_KDR * CONSTANT % PI, &
        TwoPi  => 2.0_KDR * CONSTANT % PI, &
        Pi     => CONSTANT % PI )

    J_Factor   = FourPi * k_b ** 4  /  ( TwoPi * hBar * c ) ** 3
    G_F        =  1.1663787e-5_KDR * ( hBar * c ) ** 3 &
                  * ( 1.0e3_KDR * UNIT % MEGA_ELECTRON_VOLT ) ** ( -2 )
    Chi_Factor =  G_F ** 2 / Pi * ( 3.0_KDR * 1.23_KDR ** 2 + 1.0_KDR ) &
                  / ( hbar * c ) ** 4 
    
    end associate !-- c, etc.
    
    M_P = 938.2720813_KDR * UNIT % MEGA_ELECTRON_VOLT 
    M_N = 939.5654133_KDR * UNIT % MEGA_ELECTRON_VOLT
    Q   = M_N - M_P
    amu = CONSTANT % ATOMIC_MASS_UNIT

    !$OMP parallel do private ( iV ) 
    do iV = 1, nValues
       
      if ( T ( iV ) == 0.0_KDR ) &
        cycle

      call dfermi &
             ( 2.0_KDR, Eta_NuBar ( iV ), 0.0_KDR, Fermi_2, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 3.0_KDR, Eta_NuBar_EQ ( iV ), 0.0_KDR, Fermi_3_EQ, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 3.0_KDR, Eta_NuBar ( iV ), 0.0_KDR, Fermi_3, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 4.0_KDR, Eta_NuBar_EQ ( iV ), 0.0_KDR, Fermi_4_EQ, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 4.0_KDR, Eta_NuBar ( iV ), 0.0_KDR, Fermi_4, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 5.0_KDR, Eta_NuBar_EQ ( iV ), 0.0_KDR, Fermi_5_EQ, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)
      call dfermi &
             ( 5.0_KDR, Eta_NuBar ( iV ), 0.0_KDR, Fermi_5, &
               fdeta, fdtheta, fdeta2, fdtheta2, fdetadtheta)

      E_NuBar_Average = k_B * TP ( iV ) * Fermi_3 / Fermi_2 
      Beta_F    = 1.0_KDR / ( k_B * T ( iV ) )
!      Eta_P_N   = M ( iV ) * N ( iV ) * ( X_n ( iV ) - X_p ( iV ) ) / amu &
!                  / ( exp ( Beta_F * ( Mu_N_P ( iV ) - Q ) ) - 1.0_KDR )
      Eta_P_N   = M ( iV ) * N ( iV ) * X_p ( iV ) / amu
      !-- Use Fermi-Dirac identity 1 - f(x) = f(-x) to avoid precision loss 
      One_Minus_F_E_Bar &
        = 1.0_KDR &
          / ( exp ( - Beta_F * ( E_NuBar_Average - Q + Mu_E ( iV ) ) ) &
              + 1.0_KDR )
      One_Minus_F_NuBar_EQ &
        = 1.0_KDR &
          / ( exp ( - Beta_F * E_NuBar_Average + Eta_NuBar_EQ ( iV ) ) &
              + 1.0_KDR )
!      Chi_0 = Chi_Factor * Eta_P_N * One_Minus_F_E_Bar / One_Minus_F_NuBar_EQ
      Chi_0 = Chi_Factor * Eta_P_N * One_Minus_F_E_Bar

      S      = max ( ( k_b * TP ( iV ) ) ** 2 * Fermi_5 / Fermi_3, Tiny_10 ) 
      S_EQ   = ( k_b * T ( iV ) ) ** 2 * Fermi_5_EQ / Fermi_3_EQ
      S_N    = max ( ( k_b * TP ( iV ) ) * Fermi_4 / Fermi_3, Tiny_10 ) 
      S_N_EQ = ( k_b * T ( iV ) ) * Fermi_4_EQ / Fermi_3_EQ

      EDV ( iV )  = J_Factor *  T ( iV ) ** 4 * Fermi_3_EQ * S_EQ / S
      EOV ( iV )  = Chi_0 * S
      TOV ( iV )  = EOV ( iV )
      EDNV ( iV ) = J_Factor *  T ( iV ) ** 4 * Fermi_3_EQ * S_N_EQ / S_N
      EONV ( iV ) = Chi_0 * S_N

    end do !-- iV
    !$OMP end parallel do

  end subroutine Compute_E_NuBar_Kernel


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

    ! !-- variable indices

    ! oF = I % N_FIELDS_TEMPLATE
    ! if ( I % N_FIELDS == 0 ) &
    !   I % N_FIELDS = oF + I % N_FIELDS_NM

    ! I % EMISSIVITY_NUMBER        = oF + 1
    ! I % EFFECTIVE_OPACITY_NUMBER = oF + 2

    ! !-- variable names 

    ! if ( present ( VariableOption ) ) then
    !   allocate ( Variable ( size ( VariableOption ) ) )
    !   Variable = VariableOption
    ! else
    !   allocate ( Variable ( I % N_FIELDS ) )
    !   Variable = ''
    ! end if

    ! Variable ( oF + 1 : oF + I % N_FIELDS_NM ) &
    !   = [ 'EmissivityNumber      ', &
    !       'EffectiveOpacityNumber' ]
          
    ! !-- units
    
    ! if ( present ( VariableUnitOption ) ) then
    !   allocate ( VariableUnit ( size ( VariableUnitOption ) ) )
    !   VariableUnit = VariableUnitOption
    ! else
    !   allocate ( VariableUnit ( I % N_FIELDS ) )
    !   VariableUnit = UNIT % IDENTITY
    ! end if
    
  end subroutine InitializeBasics


  subroutine ComputeDegeneracyParameter_EQ_Kernel &
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

      Eta_EQ ( iV )  =  Sign  *  ( Mu_E ( iV )  -  Mu_NP ( iV ) )  &
                        /  max ( T ( iV ), tiny ( 0.0_KDR ) )

    end do !-- iV
    !$OMP end parallel do

  end subroutine ComputeDegeneracyParameter_EQ_Kernel


end module Interactions_NM_G_1__Form