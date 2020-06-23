unit LogDataSet;

interface

uses
  ParserDataSet, DSWrap, System.Classes;

type
  TLogW = class(TParserW)

  private
    FPath: TFieldWrap;
    FState: TFieldWrap;
  public
    constructor Create(AOwner: TComponent); override;
    function Add(const APath, AState: string): Integer;
    procedure SetState(ALogID: Integer; const AState: string);
    property Path: TFieldWrap read FPath;
    property State: TFieldWrap read FState;
  end;

  TLogDS = class(TParserDS)

  private
    FW: TLogW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TLogW read FW;
  end;

implementation

uses
  Data.DB;

constructor TLogW.Create(AOwner: TComponent);
begin
  inherited;
  ID.DisplayLabel := '';
  FPath := TFieldWrap.Create(Self, 'Path', 'Категории');
  FState := TFieldWrap.Create(Self, 'State', 'Состояние');
end;

function TLogW.Add(const APath, AState: string): Integer;
begin
  TryAppend;
  Path.F.AsString := APath;
  State.F.AsString := AState;
  TryPost;
  Result := ID.F.AsInteger;
end;

procedure TLogW.SetState(ALogID: Integer; const AState: string);
begin
  if not LocateByPK(ALogID) then
    Exit;

  TryEdit;
  State.F.AsString := AState;
  TryPost;
end;

constructor TLogDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TLogW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.Path.FieldName, ftString, 300);
  FieldDefs.Add(W.State.FieldName, ftString, 100);

  CreateDataSet;

  FileName := 'Log.dat';
end;

function TLogDS.CreateWrap: TParserW;
begin
  Result := TLogW.Create(Self);
end;

end.
