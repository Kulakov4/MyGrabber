unit DragHelper;

interface

uses
  System.Classes, cxGridDBBandedTableView;

type
  TRecOrder = class
    Key: Integer;
    Order: Integer;
  public
    constructor Create(AKey, AOrder: Integer);
  end;

  TStartDrag = class
  public
    Keys: array of Integer;
    MinOrderValue: Integer;
    MaxOrderValue: Integer;
  end;

  TDropDrag = class
  public
    Key: Integer;
    OrderValue: Integer;
  end;

  TDragAndDropInfo = class
  private
    FDropDrag: TDropDrag;
    FKeyColumn: TcxGridDBBandedColumn;
    FOrderColumn: TcxGridDBBandedColumn;
    FStartDrag: TStartDrag;
  public
    constructor Create(AKeyColumn, AOrderColumn: TcxGridDBBandedColumn);
    destructor Destroy; override;
    property DropDrag: TDropDrag read FDropDrag;
    property KeyColumn: TcxGridDBBandedColumn read FKeyColumn;
    property OrderColumn: TcxGridDBBandedColumn read FOrderColumn;
    property StartDrag: TStartDrag read FStartDrag;
  end;

  IOrderQuery = interface(IInterface)
    procedure MoveDSRecord(AStartDrag: TStartDrag;
      ADropDrag: TDropDrag); stdcall;
  end;

implementation

uses
  System.SysUtils;

constructor TRecOrder.Create(AKey, AOrder: Integer);
begin
  inherited Create;
  Assert(AKey > 0);
  Key := AKey;
  Order := AOrder;
end;

constructor TDragAndDropInfo.Create(AKeyColumn, AOrderColumn
  : TcxGridDBBandedColumn);
begin
  inherited Create;
  Assert(AKeyColumn <> nil);
  Assert(AOrderColumn <> nil);
  Assert(AKeyColumn.GridView <> nil);
  Assert(AKeyColumn.GridView = AOrderColumn.GridView);

  FKeyColumn := AKeyColumn;
  FOrderColumn := AOrderColumn;

  FStartDrag := TStartDrag.Create;
  FDropDrag := TDropDrag.Create;
end;

destructor TDragAndDropInfo.Destroy;
begin
  FreeAndNil(FStartDrag);
  FreeAndNil(FDropDrag);
  inherited;
end;

end.
