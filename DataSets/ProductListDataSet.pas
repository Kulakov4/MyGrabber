unit ProductListDataSet;

interface

uses
  ParserDataSet, DSWrap, System.Classes;

type
  TProductListW = class(TParserW)
  private
    FHREF: TFieldWrap;
    FItemNumber: TFieldWrap;
    FCaption: TFieldWrap;
    FParentID: TFieldWrap;
    FStatus: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure FilterByNotDone;
    procedure SetStatus(AStatus: Integer);
    property HREF: TFieldWrap read FHREF;
    property ItemNumber: TFieldWrap read FItemNumber;
    property Caption: TFieldWrap read FCaption;
    property ParentID: TFieldWrap read FParentID;
    property Status: TFieldWrap read FStatus;
  end;

  TProductListDS = class(TParserDS)
  private
    FW: TProductListW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TProductListW read FW;
  end;
implementation

uses
  Data.DB, NotifyEvents, System.SysUtils;

constructor TProductListW.Create(AOwner: TComponent);
begin
  inherited;
  FParentID := TFieldWrap.Create(Self, 'ParentID', 'Код родителя');
  FHREF := TFieldWrap.Create(Self, 'HREF', 'Ссылка');
  FItemNumber := TFieldWrap.Create(Self, 'ItemNumber', 'Артикул');
  FCaption := TFieldWrap.Create(Self, 'Caption', 'Наименование');
  FStatus := TFieldWrap.Create(Self, 'Status', 'Статус');
  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert);
end;

procedure TProductListW.Do_AfterInsert(Sender: TObject);
begin
  Status.F.AsInteger := 0;
end;

procedure TProductListW.FilterByNotDone;
begin
  DataSet.Filter := Format('%s = %d', [Status.FieldName, 0]);
  DataSet.Filtered := True;
end;

procedure TProductListW.SetStatus(AStatus: Integer);
begin
  TryEdit;
  Status.F.AsInteger := AStatus;
  TryPost;
end;

constructor TProductListDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TProductListW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.FHREF.FieldName, ftWideString, 300);
  FieldDefs.Add(W.ItemNumber.FieldName, ftWideString, 30);
  FieldDefs.Add(W.Caption.FieldName, ftWideString, 200);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);
  FieldDefs.Add(W.Status.FieldName, ftInteger);

  CreateDataSet;

  FFileName := 'ProductList.dat';
end;

function TProductListDS.CreateWrap: TParserW;
begin
  Result := TProductListW.Create(Self);
end;

end.
