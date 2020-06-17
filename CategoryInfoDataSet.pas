unit CategoryInfoDataSet;

interface

uses
  FireDAC.Comp.DataSet, DSWrap, System.Classes, FireDAC.Comp.Client,
  ParserDataSet;

type
  TCategoryInfoW = class(TParserW)
  private
    FCaption: TFieldWrap;
    FHREF: TFieldWrap;
    FParentID: TFieldWrap;
    FDone: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure FilterByParentID(AParentID: Integer);
    procedure FilterByParentIDAndNotDone(AParentID: Integer);
    procedure FilterByRoot;
    property Caption: TFieldWrap read FCaption;
    property HREF: TFieldWrap read FHREF;
    property ParentID: TFieldWrap read FParentID;
    property Done: TFieldWrap read FDone;
  end;

  TCategoryInfoDS = class(TParserDS)
  private
    FW: TCategoryInfoW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TCategoryInfoW read FW;
  end;

implementation

uses
  Data.DB, System.SysUtils, NotifyEvents;

constructor TCategoryInfoW.Create(AOwner: TComponent);
begin
  inherited;
  FParentID := TFieldWrap.Create(Self, 'ParentID', 'Код родителя');
  FHREF := TFieldWrap.Create(Self, 'HREF', 'Ссылка');
  FCaption := TFieldWrap.Create(Self, 'Caption', 'Наименование');
  FDone := TFieldWrap.Create(Self, 'Done', 'Обработана');
  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert);
end;

procedure TCategoryInfoW.Do_AfterInsert(Sender: TObject);
begin
  Done.F.AsInteger := 0;
end;

procedure TCategoryInfoW.FilterByParentID(AParentID: Integer);
begin
  DataSet.Filter := Format('(%s = %d)', [ParentID.FieldName, AParentID]);
  DataSet.Filtered := True;
end;

procedure TCategoryInfoW.FilterByParentIDAndNotDone(AParentID: Integer);
begin
  DataSet.Filter := Format('(%s = %d) and (%s = 0)',
    [ParentID.FieldName, AParentID, Done.FieldName]);
  DataSet.Filtered := True;
end;

procedure TCategoryInfoW.FilterByRoot;
begin
  DataSet.Filter := Format('(%s is null)', [ParentID.FieldName]);
  DataSet.Filtered := True;
end;

constructor TCategoryInfoDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TCategoryInfoW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.Caption.FieldName, ftWideString, 200);
  FieldDefs.Add(W.FHREF.FieldName, ftWideString, 100);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);
  FieldDefs.Add(W.Done.FieldName, ftInteger);

  CreateDataSet;

end;

function TCategoryInfoDS.CreateWrap: TParserW;
begin
  Result := TCategoryInfoW.Create(Self);
end;

end.
