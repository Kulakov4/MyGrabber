unit ErrorDataSet;

interface

uses
  FireDAC.Comp.Client, DSWrap, System.Classes, Data.DB, ParserDataSet,
  NotifyEvents;

type
  TErrorW = class(TParserW)
  private
    FErrorText: TFieldWrap;
    FFileName: TFieldWrap;
    FErrorTime: TFieldWrap;
    FURL: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    function HaveManyErrors: Boolean;
    property ErrorText: TFieldWrap read FErrorText;
    property FileName: TFieldWrap read FFileName;
    property ErrorTime: TFieldWrap read FErrorTime;
    property URL: TFieldWrap read FURL;
  end;

  TErrorDS = class(TParserDS)
  private
    FW: TErrorW;
  class var
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TErrorW read FW;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

constructor TErrorDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TErrorW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.ErrorTime.FieldName, ftDateTime);
  FieldDefs.Add(W.URL.FieldName, ftString, 300);
  FieldDefs.Add(W.FileName.FieldName, ftString, 300);
  FieldDefs.Add(W.ErrorText.FieldName, ftString, 300);

  CreateDataSet;

  FFileName := 'Errors.dat';
end;

function TErrorDS.CreateWrap: TParserW;
begin
  Result := TErrorW.Create(Self);
end;

constructor TErrorW.Create(AOwner: TComponent);
begin
  inherited;
  FErrorTime := TFieldWrap.Create(Self, 'ErrorTime', 'Время');
  FURL := TFieldWrap.Create(Self, 'URL', 'URL');
  FFileName := TFieldWrap.Create(Self, 'FileName', 'Имя файла');
  FErrorText := TFieldWrap.Create(Self, 'ErrorText', 'Ошибка');

  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert, EventList);
end;

procedure TErrorW.Do_AfterInsert(Sender: TObject);
begin
  ErrorTime.F.AsDateTime := Now;
end;

function TErrorW.HaveManyErrors: Boolean;
var
  AErrorCount: Integer;
  AMaxErrorCount: Integer;
  T: TDateTime;
  W: TErrorW;
begin
  T := IncMinute(Time, -1);
  W := TErrorW.Create( AddClone('') );
  try
    AErrorCount := 0;
    AMaxErrorCount := 10;
    W.DataSet.Last;

    while (AErrorCount < AMaxErrorCount) and (W.ErrorTime.F.AsDateTime >= T) and
      not W.DataSet.Bof do
    begin
      Inc(AErrorCount);
      W.DataSet.Prior;
    end;

    Result := AErrorCount = AMaxErrorCount;
  finally
    DropClone(W.DataSet as TFDMemTable);
  end;
end;

end.
