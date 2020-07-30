unit ReportDataSet;

interface

uses
  FireDAC.Comp.Client, DSWrap, System.Classes, Data.DB;

type
  TReportW = class(TDSWrap)
  private
    FCategory: TFieldWrap;
    FDrawing: TFieldWrap;
    FImage: TFieldWrap;
    FItemNumber: TFieldWrap;
    FSpecification: TFieldWrap;
  public
    constructor Create(AOwner: TComponent); override;
    property Category: TFieldWrap read FCategory;
    property Drawing: TFieldWrap read FDrawing;
    property Image: TFieldWrap read FImage;
    property ItemNumber: TFieldWrap read FItemNumber;
    property Specification: TFieldWrap read FSpecification;
  end;

  TReportDS = class(TFDMemTable)
  private
    FW: TReportW;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TReportW read FW;
  end;

implementation

constructor TReportW.Create(AOwner: TComponent);
begin
  inherited;
  FCategory := TFieldWrap.Create(Self, 'Category', 'Тип');
  FItemNumber := TFieldWrap.Create(Self, 'ItemNumber', 'Наименование');
  FImage := TFieldWrap.Create(Self, 'Image', 'Изображение');
  FSpecification := TFieldWrap.Create(Self, 'Specification', 'Спецификация');
  FDrawing := TFieldWrap.Create(Self, 'Drawing', 'Чертёж');
end;

constructor TReportDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := TReportW.Create(Self);

  FieldDefs.Add(W.Category.FieldName, ftWideString, 250);
  FieldDefs.Add(W.ItemNumber.FieldName, ftWideString, 50);
  FieldDefs.Add(W.Image.FieldName, ftWideString, 50);
  FieldDefs.Add(W.FSpecification.FieldName, ftWideString, 50);
  FieldDefs.Add(W.Drawing.FieldName, ftWideString, 50);

  CreateDataSet;
end;

end.
