unit ProductsDataSet;

interface

uses
  ParserDataSet, DSWrap, System.Classes;

type
  TProductW = class(TParserW)
  private
    FDescription: TFieldWrap;
    FTemperatureRange: TFieldWrap;
    FImage: TFieldWrap;
    FSpecification: TFieldWrap;
    FDrawing: TFieldWrap;
    FStatus: TFieldWrap;
    FParentID: TFieldWrap;
    FProducer: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure FilterByNotDone;
    property Description: TFieldWrap read FDescription;
    property TemperatureRange: TFieldWrap read FTemperatureRange;
    property Image: TFieldWrap read FImage;
    property Specification: TFieldWrap read FSpecification;
    property Drawing: TFieldWrap read FDrawing;
    property Status: TFieldWrap read FStatus;
    property ParentID: TFieldWrap read FParentID;
    property Producer: TFieldWrap read FProducer;
  end;

  TProductsDS = class(TParserDS)
  private
    FW: TProductW;
  protected
    function CreateWrap: TParserW; override;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TProductW read FW;
  end;

implementation

uses
  NotifyEvents, Data.DB, System.SysUtils;

constructor TProductW.Create(AOwner: TComponent);
begin
  inherited;
  FDescription := TFieldWrap.Create(Self, 'Description', 'Описание');
  FTemperatureRange := TFieldWrap.Create(Self, 'TemperatureRange', 'Температурный диапазон');
  FImage := TFieldWrap.Create(Self, 'Image', 'Изображение');
  FSpecification := TFieldWrap.Create(Self, 'Specification', 'Спецификация');
  FDrawing := TFieldWrap.Create(Self, 'Drawing', 'Чертёж');
  FProducer := TFieldWrap.Create(Self, 'Producer', 'Производитель');
  FParentID := TFieldWrap.Create(Self, 'ParentID', 'Код родителя');
  FStatus := TFieldWrap.Create(Self, 'Status', 'Состояние');
  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert);
end;

procedure TProductW.Do_AfterInsert(Sender: TObject);
begin
  Status.F.AsInteger := 0;
  Producer.F.AsString := 'HARTING';
end;

procedure TProductW.FilterByNotDone;
begin
  DataSet.Filter := Format('%s = %d', [Status.FieldName, 0]);
  DataSet.Filtered := True;
end;

constructor TProductsDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TProductW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.Description.FieldName, ftWideString, 200);
  FieldDefs.Add(W.Image.FieldName, ftWideString, 100);
  FieldDefs.Add(W.FSpecification.FieldName, ftWideString, 100);
  FieldDefs.Add(W.Drawing.FieldName, ftWideString, 100);
  FieldDefs.Add(W.Producer.FieldName, ftWideString, 50);
  FieldDefs.Add(W.TemperatureRange.FieldName, ftWideString, 50);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);

  CreateDataSet;
end;

function TProductsDS.CreateWrap: TParserW;
begin
  Result := TProductW.Create(Self);
end;

end.
