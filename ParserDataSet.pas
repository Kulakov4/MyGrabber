unit ParserDataSet;

interface

uses
  FireDAC.Comp.Client, DSWrap, System.Classes;

type
  TParserW = class(TDSWrap)
  private
    FID: TFieldWrap;
  public
    constructor Create(AOwner: TComponent); override;
    property ID: TFieldWrap read FID;
  end;

  TParserDS = class(TFDMemTable)
  private
    FParserW: TParserW;
  class var
    FID: Integer;
    procedure DoAfterInsert(Sender: TObject);
  protected
    function CreateWrap: TParserW; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property ParserW: TParserW read FParserW;
  end;

implementation

uses
  NotifyEvents;

constructor TParserW.Create(AOwner: TComponent);
begin
  inherited;
  FID := TFieldWrap.Create(Self, 'ID', 'Код', True);
end;

constructor TParserDS.Create(AOwner: TComponent);
begin
  inherited;
  FParserW := CreateWrap;
  TNotifyEventWrap.Create(FParserW.AfterInsert, DoAfterInsert,
    FParserW.EventList);
end;

function TParserDS.CreateWrap: TParserW;
begin
  Result := TParserW.Create(Self);
end;

procedure TParserDS.DoAfterInsert(Sender: TObject);
begin
  // Заполняем поле ID
  Inc(FID);
  ParserW.ID.F.AsInteger := FID;
end;

end.
