unit CategoryDataSet;

interface

uses
  FireDAC.Comp.DataSet, DSWrap, System.Classes, FireDAC.Comp.Client,
  ParserDataSet;

type
  TCategoryW = class(TParserW)
  private
    FCaption: TFieldWrap;
    FHREF: TFieldWrap;
    FParentID: TFieldWrap;
    FStatus: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure FilterByParentID(AParentID: Integer);
    procedure FilterByParentIDAndNotDone(AParentID: Integer);
    procedure FilterByRoot;
    procedure SetStatus(AStatus: Integer);
    property Caption: TFieldWrap read FCaption;
    property HREF: TFieldWrap read FHREF;
    property ParentID: TFieldWrap read FParentID;
    property Status: TFieldWrap read FStatus;
  end;

  TCategoryDS = class(TParserDS)
  private
    FW: TCategoryW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TCategoryW read FW;
  end;

implementation

uses
  Data.DB, System.SysUtils, NotifyEvents;

constructor TCategoryW.Create(AOwner: TComponent);
begin
  inherited;
  FParentID := TFieldWrap.Create(Self, 'ParentID', 'Код родителя');
  FHREF := TFieldWrap.Create(Self, 'HREF', 'Ссылка');
  FCaption := TFieldWrap.Create(Self, 'Caption', 'Наименование');
  FStatus := TFieldWrap.Create(Self, 'Status', 'Статус');
  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert);
end;

procedure TCategoryW.Do_AfterInsert(Sender: TObject);
begin
  Status.F.AsInteger := 0;
end;

procedure TCategoryW.FilterByParentID(AParentID: Integer);
begin
  DataSet.Filter := Format('(%s = %d)', [ParentID.FieldName, AParentID]);
  DataSet.Filtered := True;
end;

procedure TCategoryW.FilterByParentIDAndNotDone(AParentID: Integer);
begin
  DataSet.Filter := Format('(%s = %d) and (%s = 0)',
    [ParentID.FieldName, AParentID, Status.FieldName]);
  DataSet.Filtered := True;
end;

procedure TCategoryW.FilterByRoot;
begin
  DataSet.Filter := Format('(%s is null)', [ParentID.FieldName]);
  DataSet.Filtered := True;
end;

procedure TCategoryW.SetStatus(AStatus: Integer);
begin
  TryEdit;
  Status.F.AsInteger := AStatus;
  TryPost;
end;

constructor TCategoryDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TCategoryW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.Caption.FieldName, ftWideString, 200);
  FieldDefs.Add(W.FHREF.FieldName, ftWideString, 300);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);
  FieldDefs.Add(W.Status.FieldName, ftInteger);

  CreateDataSet;

end;

function TCategoryDS.CreateWrap: TParserW;
begin
  Result := TCategoryW.Create(Self);
end;

end.
