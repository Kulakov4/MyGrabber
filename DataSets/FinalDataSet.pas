unit FinalDataSet;

interface

uses
  FireDAC.Comp.Client, DSWrap, System.Classes, ParserDataSet;

type
  TFinalW = class(TParserW)
  private
    FCategory2: TFieldWrap;
    FCategory1: TFieldWrap;
    FCategory3: TFieldWrap;
    FCategory4: TFieldWrap;
    FDescription: TFieldWrap;
    FDrawing: TFieldWrap;
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
    property Image: TFieldWrap read FImage;
    property ItemNumber: TFieldWrap read FItemNumber;
    property Producer: TFieldWrap read FProducer;
    property Specification: TFieldWrap read FSpecification;
    property TemperatureRange: TFieldWrap read FTemperatureRange;
  end;

  TFinalDataSet = class(TParserDS)
  private
  class var
  var
    FW: TFinalW;
  protected
    function CreateWrap: TParserW; override;
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
  ID.DisplayLabel := '';
  FCategory1 := TFieldWrap.Create(Self, 'Category1', '���');
  FCategory2 := TFieldWrap.Create(Self, 'Category2', '���������');
  FCategory3 := TFieldWrap.Create(Self, 'Category3', '������');
  FCategory4 := TFieldWrap.Create(Self, 'Category4', '���������');
  FItemNumber := TFieldWrap.Create(Self, 'ItemNumber', '������������');
  FDescription := TFieldWrap.Create(Self, 'Description', '��������');
  FImage := TFieldWrap.Create(Self, 'Image', '�����������');
  FSpecification := TFieldWrap.Create(Self, 'Specification', '������������');
  FDrawing := TFieldWrap.Create(Self, 'Drawing', '�����');
  FProducer := TFieldWrap.Create(Self, 'Producer', '�������������');
  FTemperatureRange := TFieldWrap.Create(Self, 'TemperatureRange', '������������� ��������');
end;

constructor TFinalDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TFinalW;

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

  FileName := 'Final.dat';
end;

function TFinalDataSet.CreateWrap: TParserW;
begin
  Result := TFinalW.Create(Self);
end;

end.
