!-- Storage_ASC is generic storage for a set of fields on a single-chart Atlas.

module Storage_ASC__Form

  !-- Storage_AtlasSingleChart_Form

  use Basics
  use Charts
  use Field_ASC__Template
  use Atlas_SC__Form

  implicit none
  private

  type, public, extends ( Field_ASC_Template ) :: Storage_ASC_Form
    integer ( KDI ) :: &
      nFields
    class ( Atlas_SC_Form ), pointer :: &
      Atlas_SC => null ( )
  contains
    procedure, public, pass :: &
      Initialize
    final :: &
      Finalize
    procedure, private, pass :: &
      SetField
  end type Storage_ASC_Form

contains


  subroutine Initialize ( SA, A, NameShort, nFields, IgnorabilityOption )

    class ( Storage_ASC_Form ), intent ( inout ) :: &
      SA
    class ( Atlas_SC_Form ), intent ( in ), target :: &
      A
    character ( * ), intent ( in ) :: &
      NameShort
    integer ( KDI ), intent ( in ) :: &
      nFields
    integer ( KDL ), intent ( in ), optional :: &
      IgnorabilityOption

    if ( SA % Type == '' ) &
      SA % Type = 'a Storage_ASC' 

    SA % nFields  =  nFields
    SA % Atlas_SC => A

    call SA % InitializeTemplate_ASC ( A, NameShort, IgnorabilityOption )

  end subroutine Initialize


  impure elemental subroutine Finalize ( SA )

    type ( Storage_ASC_Form ), intent ( inout ) :: &
      SA

    nullify ( SA % Atlas_SC )

    call SA % FinalizeTemplate_ASC ( )

  end subroutine Finalize


  subroutine SetField ( FA )

    class ( Storage_ASC_Form ), intent ( inout ) :: &
      FA

    select type ( C => FA % Atlas_SC % Chart )
    class is ( Chart_SL_Template )

      allocate ( Storage_CSL_Form :: FA % Chart )

      select type ( SC => FA % Chart )
      class is ( Storage_CSL_Form )
        associate ( nValues => C % nProperCells + C % nGhostCells )
        call SC % Initialize &
                    ( C, FA % NameShort, FA % nFields, nValues, &
                      IgnorabilityOption = FA % IGNORABILITY + 1 )
        end associate !-- nValues
      end select !-- GC

    end select !-- C

  end subroutine SetField


end module Storage_ASC__Form
