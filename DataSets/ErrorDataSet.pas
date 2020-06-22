unit ErrorDataSet;

interface

uses
  FireDAC.Comp.Client, DSWrap, System.Classes, Data.DB, ParserDataSet,
  NotifyEvents;

type
  TErrorW = class(TParserW)
  private
    FErrorText: TFieldWrap;
    FErrorTime: TFieldWrap;
    FURL: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    property ErrorText: TFieldWrap read FErrorText;
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
  System.SysUtils;

constructor TErrorDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TErrorW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.ErrorTime.FieldName, ftDateTime);
  FieldDefs.Add(W.URL.FieldName, ftString, 300);
  FieldDefs.Add(W.ErrorText.FieldName, ftString, 300);

  CreateDataSet;
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
  FErrorText := TFieldWrap.Create(Self, 'ErrorText', 'Ошибка');

  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert, EventList);
end;

procedure TErrorW.Do_AfterInsert(Sender: TObject);
begin
  ErrorTime.F.AsDateTime := Now;
end;

end.
