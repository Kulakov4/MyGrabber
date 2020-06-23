unit ProductsDataSet;

interface

uses
  ParserDataSet, DSWrap, System.Classes;

type
  TProductW = class(TParserW)
  private
    FDescription: TFieldWrap;
    FTemperatureRange: TFieldWrap;
    FImageURL: TFieldWrap;
    FSpecificationURL: TFieldWrap;
    FDrawingURL: TFieldWrap;
    FDrawingFileName: TFieldWrap;
    FImageFileName: TFieldWrap;
    FItemNumber: TFieldWrap;
    FStatus: TFieldWrap;
    FParentID: TFieldWrap;
    FSpecificationFileName: TFieldWrap;
    procedure Do_AfterInsert(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure FilterByNotDone;
    procedure SetStatus(AStatus: Integer);
    property Description: TFieldWrap read FDescription;
    property TemperatureRange: TFieldWrap read FTemperatureRange;
    property ImageURL: TFieldWrap read FImageURL;
    property SpecificationURL: TFieldWrap read FSpecificationURL;
    property DrawingURL: TFieldWrap read FDrawingURL;
    property DrawingFileName: TFieldWrap read FDrawingFileName;
    property ImageFileName: TFieldWrap read FImageFileName;
    property ItemNumber: TFieldWrap read FItemNumber;
    property Status: TFieldWrap read FStatus;
    property ParentID: TFieldWrap read FParentID;
    property SpecificationFileName: TFieldWrap read FSpecificationFileName;
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
  FItemNumber := TFieldWrap.Create(Self, 'ItemNumber', 'Артикул');
  FDescription := TFieldWrap.Create(Self, 'Description', 'Описание');
  FTemperatureRange := TFieldWrap.Create(Self, 'TemperatureRange', 'Температурный диапазон');
  FImageURL := TFieldWrap.Create(Self, 'ImageURL', 'URL Изображения');
  FImageFileName := TFieldWrap.Create(Self, 'ImageFileName', 'Файл изображения');
  FSpecificationURL := TFieldWrap.Create(Self, 'SpecificationURL', 'URL спецификации');
  FSpecificationFileName := TFieldWrap.Create(Self, 'SpecificationFileName', 'Файл спецификации');
  FDrawingURL := TFieldWrap.Create(Self, 'DrawingURL', 'URL чертёж');
  FDrawingFileName := TFieldWrap.Create(Self, 'DrawingFileName', 'Файл чертёжа');
  FParentID := TFieldWrap.Create(Self, 'ParentID', 'Код родителя');
  FStatus := TFieldWrap.Create(Self, 'Status', 'Состояние');
  TNotifyEventWrap.Create(AfterInsert, Do_AfterInsert);
end;

procedure TProductW.Do_AfterInsert(Sender: TObject);
begin
  Status.F.AsInteger := 0;
end;

procedure TProductW.FilterByNotDone;
begin
  DataSet.Filter := Format('%s = %d', [Status.FieldName, 0]);
  DataSet.Filtered := True;
end;

procedure TProductW.SetStatus(AStatus: Integer);
begin
  TryEdit;
  Status.F.AsInteger := AStatus;
  TryPost;
end;

constructor TProductsDS.Create(AOwner: TComponent);
begin
  inherited;
  FW := ParserW as TProductW;

  FieldDefs.Add(W.ID.FieldName, ftInteger);
  FieldDefs.Add(W.ItemNumber.FieldName, ftWideString, 50);
  FieldDefs.Add(W.Description.FieldName, ftWideString, 500);
  FieldDefs.Add(W.ImageURL.FieldName, ftWideString, 500);
  FieldDefs.Add(W.ImageFileName.FieldName, ftWideString, 50);
  FieldDefs.Add(W.FSpecificationURL.FieldName, ftWideString, 500);
  FieldDefs.Add(W.FSpecificationFileName.FieldName, ftWideString, 50);
  FieldDefs.Add(W.DrawingURL.FieldName, ftWideString, 500);
  FieldDefs.Add(W.DrawingFileName.FieldName, ftWideString, 50);
  FieldDefs.Add(W.TemperatureRange.FieldName, ftWideString, 50);
  FieldDefs.Add(W.ParentID.FieldName, ftInteger);
  FieldDefs.Add(W.Status.FieldName, ftInteger);

  CreateDataSet;

  FFileName := 'Products.dat';
end;

function TProductsDS.CreateWrap: TParserW;
begin
  Result := TProductW.Create(Self);
end;

end.
