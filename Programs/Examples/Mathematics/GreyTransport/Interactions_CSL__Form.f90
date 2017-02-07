module Interactions_CSL__Form

  use Basics
  use Mathematics
  use Interactions_Template
  use Interactions_F__Form
  use Interactions_BE_G__Form

  implicit none
  private

  type, public, extends ( Field_CSL_Template ) :: Interactions_CSL_Form
    type ( MeasuredValueForm ) :: &
      LengthUnit, &
      EnergyDensityUnit
    character ( LDL ) :: &
      InteractionsType = ''
  contains
    procedure, public, pass :: &
      Initialize
    procedure, public, pass :: &
      Interactions_F
    procedure, public, pass :: &
      Interactions_BE_G
    final :: &
      Finalize
    procedure, private, pass :: &
      SetField
  end type Interactions_CSL_Form

contains


  subroutine Initialize &
               ( IC, C, InteractionsType, LengthUnit, EnergyDensityUnit, &
                 nValues, NameOutputOption )

    class ( Interactions_CSL_Form ), intent ( inout ) :: &
      IC
    class ( ChartHeader_SL_Form ), intent ( in ), target :: &
      C
    character ( * ), intent ( in ) :: &
      InteractionsType
    type ( MeasuredValueForm ), intent ( in ) :: &
      LengthUnit, &
      EnergyDensityUnit
    integer ( KDI ), intent ( in ) :: &
      nValues
    character ( * ), intent ( in ), optional :: &
      NameOutputOption

    if ( IC % Type == '' ) &
      IC % Type = 'an Interactions_CSL'
    IC % InteractionsType = InteractionsType    

    IC % LengthUnit        = LengthUnit
    IC % EnergyDensityUnit = EnergyDensityUnit

    call IC % InitializeTemplate_CSL &
           ( C, nValues, NameOutputOption = NameOutputOption )

  end subroutine Initialize


  function Interactions_F ( IC ) result ( I )

    class ( Interactions_CSL_Form ), intent ( in ), target :: &
      IC
    class ( Interactions_F_Form ), pointer :: &
      I
      
    class ( VariableGroupForm ), pointer :: &
      Field

    I => null ( )

    Field => IC % Field
    select type ( Field )
    class is ( Interactions_F_Form )
    I => Field
    end select !-- Field

  end function Interactions_F


  function Interactions_BE_G ( IC ) result ( I )

    class ( Interactions_CSL_Form ), intent ( in ), target :: &
      IC
    class ( Interactions_BE_G_Form ), pointer :: &
      I
      
    class ( VariableGroupForm ), pointer :: &
      Field

    I => null ( )

    Field => IC % Field
    select type ( Field )
    class is ( Interactions_BE_G_Form )
    I => Field
    end select !-- Field

  end function Interactions_BE_G


  impure elemental subroutine Finalize ( IC )

    type ( Interactions_CSL_Form ), intent ( inout ) :: &
      IC

    call IC % FinalizeTemplate ( )

  end subroutine Finalize


  subroutine SetField ( FC, NameOption )

    class ( Interactions_CSL_Form ), intent ( inout ) :: &
      FC
    character ( * ), intent ( in ), optional :: &
      NameOption

    allocate ( FC % FieldOutput )

    select case ( trim ( FC % InteractionsType ) )
    case ( 'FIXED' )
      allocate ( Interactions_F_Form :: FC % Field )
      select type ( I => FC % Field )
      type is ( Interactions_F_Form )
        call I % Initialize &
               ( FC % LengthUnit, FC % EnergyDensityUnit, FC % nValues, &
                 NameOption = NameOption )
        call I % SetOutput ( FC % FieldOutput )
      end select !-- RM
    case ( 'BOSE_EINSTEIN_GREY' )
      allocate ( Interactions_BE_G_Form :: FC % Field )
      select type ( I => FC % Field )
      type is ( Interactions_BE_G_Form )
        call I % Initialize &
               ( FC % LengthUnit, FC % EnergyDensityUnit, FC % nValues, &
                 NameOption = NameOption )
        call I % SetOutput ( FC % FieldOutput )
      end select !-- RM
    case default
      call Show ( 'InteractionsType not recognized', CONSOLE % ERROR )
      call Show ( FC % InteractionsType, 'InteractionsType', &
                  CONSOLE % ERROR )
      call Show ( 'Interactions_CSL__Form', 'module', CONSOLE % ERROR )
      call Show ( 'SetField', 'subroutine', CONSOLE % ERROR )
      call PROGRAM_HEADER % Abort ( )
    end select !-- InteractionsType

  end subroutine SetField


end module Interactions_CSL__Form
