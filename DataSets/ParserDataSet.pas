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
    procedure Do_AfterInsert(Sender: TObject);
  protected
    FFileName: string;
    function CreateWrap: TParserW; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Save;
    procedure Load;
    class property ID: Integer read FID write FID;
    property ParserW: TParserW read FParserW;
  end;

implementation

uses
  NotifyEvents, System.IOUtils, MyDir, System.SysUtils,
  FireDAC.Comp.DataSet, FireDAC.Stan.Intf;

constructor TParserW.Create(AOwner: TComponent);
begin
  inherited;
  FID := TFieldWrap.Create(Self, 'ID', 'Код', True);
end;

constructor TParserDS.Create(AOwner: TComponent);
begin
  inherited;
  FParserW := CreateWrap;
  TNotifyEventWrap.Create(FParserW.AfterInsert, Do_AfterInsert,
    FParserW.EventList);
end;

function TParserDS.CreateWrap: TParserW;
begin
  Result := TParserW.Create(Self);
end;

procedure TParserDS.Do_AfterInsert(Sender: TObject);
begin
  // Заполняем поле ID
  Inc(FID);
  ParserW.ID.F.AsInteger := FID;
end;

procedure TParserDS.Save;
begin
  Assert(not FFileName.IsEmpty);
  SaveToFile(TPath.Combine(TMyDir.AppDataDir, FFileName), sfBinary);
end;

procedure TParserDS.Load;
begin
  Assert(not FFileName.IsEmpty);
  LoadFromFile(TPath.Combine(TMyDir.AppDataDir, FFileName), sfBinary);
end;

end.
