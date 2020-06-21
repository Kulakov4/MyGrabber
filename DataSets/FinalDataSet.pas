unit FinalDataSet;

interface

uses
  FireDAC.Comp.Client, DSWrap, System.Classes;

type
  TFinalW = class(TDSWrap)
  private
    FCategory2: TFieldWrap;
    FCategory1: TFieldWrap;
    FCategory3: TFieldWrap;
    FCategory4: TFieldWrap;
    FDescription: TFieldWrap;
    FDrawing: TFieldWrap;
    FID: TFieldWrap;
    FImage: TFieldWrap;
    FItemNumber: TFieldWrap;
    FProducer: TFieldWrap;
    FSpecification: TFieldWrap;
    FTemperatureRange: TFieldWrap;
  public
    constructor Create(AOwner: TComponent); override;
    property Category2: TFieldWrap read FCategory2;
    property Category1: TFieldWrap read FCategory1;
    property Category3: TFieldWrap read FCategory3;
    property Category4: TFieldWrap read FCategory4;
    property Description: TFieldWrap read FDescription;
    property Drawing: TFieldWrap read FDrawing;
    property ID: TFieldWrap read FID;
    property Image: TFieldWrap read FImage;
    property ItemNumber: TFieldWrap read FItemNumber;
    property Producer: TFieldWrap read FProducer;
    property Specification: TFieldWrap read FSpecification;
    property TemperatureRange: TFieldWrap read FTemperatureRange;
  end;

  TFinalDataSet = class(TFDMemTable)
  private
  class var
    FID: Integer;
  var
    FW: TFinalW;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    property W: TFinalW read FW;
  end;

implementation

uses
  Data.DB, NotifyEvents;

constructor TFinalW.Create(AOwner: TComponent);
begin
  inherited;
  FID := TFieldWrap.Create(Self, 'ID', '', True);
  FCategory1 := TFieldWrap.Create(Self, 'Category1', 'Тип');
  FCategory2 := TFieldWrap.Create(Self, 'Category2', 'Категория');
  FCategory3 := TFieldWrap.Create(Self, 'Category3', 'Группа');
  FCategory4 := TFieldWrap.Create(Self, 'Category4', 'Подгруппа');
  FItemNumber := TFieldWrap.Create(Self, 'ItemNumber', 'Наименование');
  FDescription := TFieldWrap.Create(Self, 'Description', 'Описание');
  FImage := TFieldWrap.Create(Self, 'Image', 'Изображение');
  FSpecification := TFieldWrap.Create(Self, 'Specification', 'Спецификация');
  FDrawing := TFieldWrap.Create(Self, 'Drawing', 'Чертёж');
  FProducer := TFieldWrap.Create(Self, 'Producer', 'Производитель');
  FTemperatureRange := TFieldWrap.Create(Self, 'TemperatureRange', 'Температурный диапазон');
end;

constructor TFinalDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FW := TFinalW.Create(Self);

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.Category1.FieldName, ftWideString, 250);
  FieldDefs.Add(W.Category2.FieldName, ftWideString, 250);
  FieldDefs.Add(W.Category3.FieldName, ftWideString, 250);
  FieldDefs.Add(W.Category4.FieldName, ftWideString, 250);
  FieldDefs.Add(W.ItemNumber.FieldName, ftWideString, 50);
  FieldDefs.Add(W.Description.FieldName, ftWideString, 500);
  FieldDefs.Add(W.Image.FieldName, ftWideString, 50);
  FieldDefs.Add(W.FSpecification.FieldName, ftWideString, 50);
  FieldDefs.Add(W.Drawing.FieldName, ftWideString, 50);
  FieldDefs.Add(W.Producer.FieldName, ftWideString, 50);
  FieldDefs.Add(W.TemperatureRange.FieldName, ftWideString, 50);

  CreateDataSet;

  TNotifyEventWrap.Create(FW.AfterInsert, Do_AfterInsert,
    FW.EventList);
end;

procedure TFinalDataSet.Do_AfterInsert(Sender: TObject);
begin
  // Заполняем поле ID
  Inc(FID);
  W.ID.F.AsInteger := FID;
  W.Producer.F.AsString := 'HARTING';
end;

end.
