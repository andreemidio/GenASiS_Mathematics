module CollectiveOperation_BI__Form

  use MPI
  use VariableManagement
  use Display
  use MessagePassingBasics
  use PointToPoint
  use CollectiveOperation_Template

  implicit none
  private

  type, public, extends ( CollectiveOperationTemplate ) :: &
    CollectiveOperation_BI_Form
      type ( MessageIncoming_BI_Form ), allocatable :: &
        Incoming
      type ( MessageOutgoing_BI_Form ), allocatable :: &
        Outgoing
  contains
    procedure, public, pass :: &
      InitializeAllocate
    procedure, public, pass :: &
      InitializeAssociate
    generic :: &
      Initialize => InitializeAllocate, InitializeAssociate
    procedure, public, pass :: &
      Broadcast
    procedure, public, pass :: &
      Gather
    procedure, public, pass :: &
      AllToAll
    final :: &
      Finalize
  end type CollectiveOperation_BI_Form
  
contains


  subroutine InitializeAllocate &
               ( CO, C, nOutgoing, nIncoming, RootOption )

    class ( CollectiveOperation_BI_Form ), intent ( inout ) :: &
      CO
    type ( CommunicatorForm ), intent ( in ), target :: &
      C
    integer ( KDI ), intent ( in ), dimension ( : ) :: &
      nOutgoing, &
      nIncoming
    integer ( KDI ), intent ( in ), optional :: &
      RootOption

    call CO % InitializeTemplate ( C, nOutgoing, nIncoming, RootOption )

    allocate ( CO % Incoming )
    call CO % Incoming % Initialize ( C, 0, C % Rank, sum ( nIncoming ) )

    allocate ( CO % Outgoing )
    call CO % Outgoing % Initialize ( C, 0, C % Rank, sum ( nOutgoing ) )
      
  end subroutine InitializeAllocate
  
  
  subroutine InitializeAssociate &
               ( CO, C, OutgoingValue, IncomingValue, RootOption )

    class ( CollectiveOperation_BI_Form ), intent ( inout ) :: &
      CO
    type ( CommunicatorForm ), intent ( in ), target :: &
      C
    integer ( KBI ), dimension ( : ), intent ( in ), target :: &
      OutgoingValue, &
      IncomingValue
    integer ( KDI ), intent ( in ), optional :: &
      RootOption

    call CO % InitializeTemplate &
           ( C, shape ( OutgoingValue ), shape ( IncomingValue ), RootOption )

    allocate ( CO % Incoming )
    call CO % Incoming % Initialize ( C, IncomingValue, 0, C % Rank )
    
    allocate ( CO % Outgoing )
    call CO % Outgoing % Initialize ( C, OutgoingValue, 0, C % Rank )

  end subroutine InitializeAssociate
  
  
  subroutine Broadcast ( CO )

    class ( CollectiveOperation_BI_Form ), intent ( inout ) :: &
      CO

    integer :: &
      PlainInteger
    integer ( KDI ) :: &
      PlainValueSize, &
      ThisValueSize, &
      SizeRatio, &
      SendCount

    associate &
      ( OV => CO % Outgoing % Value ( : ), &
        IV => CO % Incoming % Value ( : ) )

    inquire ( iolength = ThisValueSize ) OV ( 1 )
    inquire ( iolength = PlainValueSize ) PlainInteger
    SizeRatio = max ( 1, ThisValueSize / PlainValueSize )
    SendCount = size ( OV ) * SizeRatio
      
    call MPI_BCAST &
           ( OV, SendCount, MPI_INTEGER, &
             CO % Root, CO % Communicator % Handle, CO % Error)
    call Copy ( OV, IV )
      
    end associate
  
  end subroutine Broadcast


  subroutine Gather ( CO )
  
    class ( CollectiveOperation_BI_Form ), intent ( inout ) :: &
      CO
      
    integer :: &
      PlainInteger
    integer ( KDI ) :: &
      PlainValueSize, &
      ThisValueSize, &
      SizeRatio, &
      SendCount
    
    associate &
      ( OV => CO % Outgoing % Value ( : ), &
        IV => CO % Incoming % Value ( : ) )

    inquire ( iolength = ThisValueSize ) OV ( 1 )
    inquire ( iolength = PlainValueSize ) PlainInteger
    SizeRatio = max ( 1, ThisValueSize / PlainValueSize )
    SendCount = size ( OV ) * SizeRatio
      
    if ( CO % Root /= UNSET ) then
      call MPI_GATHER &
             ( OV, SendCount, MPI_INTEGER, &
               IV, SendCount, MPI_INTEGER, &
               CO % Root, CO % Communicator % Handle, CO % Error)
    else
      call MPI_ALLGATHER &
             ( OV, SendCount, MPI_INTEGER, &
               IV, SendCount, MPI_INTEGER, &
               CO % Communicator % Handle, CO % Error)
    end if
      
    end associate
  
  end subroutine Gather


  subroutine AllToAll ( CO )
  
    class ( CollectiveOperation_BI_Form ), intent ( inout ) :: &
      CO

    integer :: &
      PlainInteger
    integer ( KDI ) :: &
      PlainValueSize, &
      ThisValueSize, &
      SizeRatio, &
      SendCount

    associate &
      ( OV => CO % Outgoing % Value ( : ), &
        IV => CO % Incoming % Value ( : ) )

    inquire ( iolength = ThisValueSize ) OV ( 1 )
    inquire ( iolength = PlainValueSize ) PlainInteger
    SizeRatio = max ( 1, ThisValueSize / PlainValueSize )
    SendCount = ( size ( OV ) / CO % Communicator % Size ) * SizeRatio
      
    call MPI_ALLTOALL &
           ( OV, SendCount, MPI_INTEGER, &
             IV, SendCount, MPI_INTEGER, &
             CO % Communicator % Handle, CO % Error)  
      
    end associate
    
  end subroutine AllToAll


  elemental subroutine Finalize ( CO )

    type ( CollectiveOperation_BI_Form ), intent ( inout ) :: &
      CO

    if ( allocated ( CO % Outgoing ) ) deallocate ( CO % Outgoing )
    if ( allocated ( CO % Incoming ) ) deallocate ( CO % Incoming )
    
    if ( allocated ( CO % nOutgoing ) ) deallocate ( CO % nOutgoing )
    if ( allocated ( CO % nIncoming ) ) deallocate ( CO % nIncoming )
    
    nullify ( CO % Communicator )

  end subroutine Finalize

  
end module CollectiveOperation_BI__Form
