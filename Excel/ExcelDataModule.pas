unit ExcelDataModule;

interface

uses
  System.SysUtils, System.Classes, Vcl.OleServer, Excel2010,
  System.Generics.Collections, FireDAC.Comp.Client, NotifyEvents, Data.DB,
  Graphics;

{$WARN SYMBOL_PLATFORM OFF}

type
  TExcelDMClass = class of TExcelDM;

  TStringTreeNode = class(TObject)
  private
    FChilds: TList<TStringTreeNode>;
    FID: Integer;
    FParent: TStringTreeNode;
    FValue: string;
  protected
    class var FMaxID: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddChild(const AValue: String): TStringTreeNode;
    class procedure ClearMaxID;
    function FindByID(AID: Integer): TStringTreeNode;
    function IndexOf(AValue: string): Integer;
    property Childs: TList<TStringTreeNode> read FChilds write FChilds;
    property ID: Integer read FID;
    property Parent: TStringTreeNode read FParent write FParent;
    property Value: string read FValue write FValue;
  end;

  THeaderInfoTable = class(TFDMemTable)
  private
    function GetColumnName: TField;
  protected
    procedure CreateFieldDefs; virtual;
    property ColumnName: TField read GetColumnName;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TExcelDM = class(TDataModule)
    EA: TExcelApplication;
    EWS: TExcelWorksheet;
    EWB: TExcelWorkbook;
  private
    procedure FreezePanesInternal(ASplitRow, ASplitColumn: Integer);
    function GetCellsColor(ACell: OleVariant): TColor;
    procedure InternalLoadExcelFile(const AFileName: string);
    function LoadExcelFileHeaderEx(const AFileName: string): TStringTreeNode;
    function LoadExcelFileHeaderFromActiveSheetEx: TStringTreeNode;
    function LoadExcelFileHeaderInternal: TStringTreeNode;
    // TODO: LoadExcelFile
    // procedure LoadExcelFile(const AFileName: string; ANotifyEventRef:
    // TNotifyEventRef = nil);
    { Private declarations }
  protected
    FLastColIndex: Integer;
    function GetExcelRange(AStartLine, AStartCol, AEndLine, AEndCol: Integer)
      : ExcelRange;
    function GetIndent: Integer; virtual;
    function HaveHeader(const ARow: Integer): Boolean; virtual;
    function IsCellEmpty(ACell: OleVariant): Boolean;
    function IsEmptyRow(ARowIndex: Integer): Boolean;
    property Indent: Integer read GetIndent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ConnectToSheet(ASheetIndex: Integer = -1);
    class procedure FreezePanes(const AFileName: string;
      ASplitRow, ASplitColumn: Integer); static;
    procedure FreezePanesEx(const AFileName: string;
      ASplitRow, ASplitColumn: Integer);
    class function LoadExcelFileHeader(const AFileName: string)
      : TStringTreeNode; static;
    class function LoadExcelFileHeaderFromActiveSheet: TStringTreeNode; static;
    { Public declarations }
  end;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

uses System.Variants, System.Math, ActiveX, DBRecordHolder;

constructor TExcelDM.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TExcelDM.Destroy;
begin
  inherited;
end;

procedure TExcelDM.ConnectToSheet(ASheetIndex: Integer = -1);
var
  AEWS: ExcelWorksheet;
begin
  if ASheetIndex = -1 then
    AEWS := EWB.ActiveSheet as ExcelWorksheet
  else
    AEWS := EWB.Sheets.Item[ASheetIndex] as ExcelWorksheet;

  EWS.ConnectTo(AEWS);
end;

procedure TExcelDM.FreezePanesInternal(ASplitRow, ASplitColumn: Integer);
begin
  if ASplitRow > 0 then
    EA.ActiveWindow.SplitRow := ASplitRow;

  if ASplitColumn > 0 then
    EA.ActiveWindow.SplitColumn := ASplitColumn;

  EA.ActiveWindow.FreezePanes := True;
  // Для того, чтобы не было предупреждения о том,
  // что сохранение в старом формате ведёт к потере точности
  EWB.Application.DisplayAlerts[0] := False;
  EWB.Save;
end;

class procedure TExcelDM.FreezePanes(const AFileName: string;
  ASplitRow, ASplitColumn: Integer);
var
  AExcelDM: TExcelDM;
begin
  AExcelDM := TExcelDM.Create(nil);
  try
    AExcelDM.FreezePanesEx(AFileName, ASplitRow, ASplitColumn);
  finally
    FreeAndNil(AExcelDM);
  end;
end;

procedure TExcelDM.FreezePanesEx(const AFileName: string;
  ASplitRow, ASplitColumn: Integer);
begin
  InternalLoadExcelFile(AFileName);
  try
    ConnectToSheet(1);
    EA.Visible[0] := True;
    FreezePanesInternal(ASplitRow, ASplitColumn);
  finally
    // EA.Quit;
    EA.Disconnect;
  end;
end;

function TExcelDM.GetCellsColor(ACell: OleVariant): TColor;
var
  R: ExcelRange;
begin
  R := EWS.Range[ACell, ACell];
  Result := R.Interior.Color;
end;

// Проверяет, находится ли в строке ARow заголовок
function TExcelDM.HaveHeader(const ARow: Integer): Boolean;
var
  ACell: OleVariant;
  AColor: TColor;
  AFirstCell: OleVariant;
  // ALastCell: OleVariant;
  ma: ExcelRange;
  R: Integer;
  rc: Integer;
begin
  ACell := EWS.Cells.Item[ARow, Indent + 1];
  AColor := GetCellsColor(ACell);
  Result := AColor <> clWhite;

  if not Result then
  begin
    // Получаем цвет левой верхней ячейки
    AFirstCell := EWS.Cells.Item[1, Indent + 1];
    AColor := GetCellsColor(AFirstCell);
    Result := AColor <> clWhite;

    if Result and (ARow > 1) then
    begin
      // Получаем диапазон объединения в первом столбце
      ma := EWS.Range[AFirstCell, AFirstCell].MergeArea;
      R := ma.Row;
      rc := ma.Rows.Count;
      Result := (R + rc - 1) >= ARow;
    end;
  end;
end;

function TExcelDM.GetExcelRange(AStartLine, AStartCol, AEndLine,
  AEndCol: Integer): ExcelRange;
begin
  if (AStartLine <= AEndLine) and (AStartCol <= AEndCol) then
  begin
    // Получаем новый "Рабочий" диапазон
    Result := EWS.Range[EWS.Cells.Item[AStartLine, AStartCol],
      EWS.Cells.Item[AEndLine, AEndCol]];
  end
  else
    Result := nil;

end;

function TExcelDM.GetIndent: Integer;
begin
  // отступ слева
  Result := 0;
end;

function TExcelDM.IsCellEmpty(ACell: OleVariant): Boolean;
begin
  Result := VarIsNull(ACell.Value) or VarIsEmpty(ACell.Value);
end;

function TExcelDM.IsEmptyRow(ARowIndex: Integer): Boolean;
Var
  ACell: OleVariant;
  I: Integer;
begin
  Result := True;

  for I := Indent + 1 to Indent + FLastColIndex do
  begin
    ACell := EWS.Cells.Item[ARowIndex, I];
    if not IsCellEmpty(ACell) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure TExcelDM.InternalLoadExcelFile(const AFileName: string);
var
  AWorkbook: ExcelWorkbook;
begin
  EA.Connect;
  AWorkbook := EA.Workbooks.Open(AFileName, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);

  if AWorkbook = nil then
    raise Exception.CreateFmt('Не удаётся открыть файл %s', [AFileName]);

  if AWorkbook.Sheets.Count = 0 then
    raise Exception.Create('Документ Excel не содержит ни одного листа');

  EWB.ConnectTo(AWorkbook);

  // AEWS := AWorkbook.ActiveSheet as ExcelWorksheet;
  // EWS.ConnectTo(AEWS);
end;

class function TExcelDM.LoadExcelFileHeader(const AFileName: string)
  : TStringTreeNode;
var
  AExcelDM: TExcelDM;
begin
  AExcelDM := TExcelDM.Create(nil);
  try
    Result := AExcelDM.LoadExcelFileHeaderEx(AFileName);
  finally
    FreeAndNil(AExcelDM);
  end;
end;

function TExcelDM.LoadExcelFileHeaderEx(const AFileName: string)
  : TStringTreeNode;
begin
  InternalLoadExcelFile(AFileName);
  ConnectToSheet(1);

  Result := LoadExcelFileHeaderInternal;

  EA.Quit;
  EA.Disconnect;
end;

class function TExcelDM.LoadExcelFileHeaderFromActiveSheet: TStringTreeNode;
var
  AExcelDM: TExcelDM;
begin
  AExcelDM := TExcelDM.Create(nil);
  try
    Result := AExcelDM.LoadExcelFileHeaderFromActiveSheetEx;
  finally
    FreeAndNil(AExcelDM);
  end;
end;

function TExcelDM.LoadExcelFileHeaderFromActiveSheetEx: TStringTreeNode;
begin
  EA.ConnectKind := ckRunningInstance;
  try
    EA.Connect;
  except
    raise Exception.Create('Не найден активный лист документа Excel');
  end;

  if EA.ActiveWorkbook = nil then
    raise Exception.Create('Не найден активный лист документа Excel');

  EWB.ConnectTo(EA.ActiveWorkbook);
  EWS.ConnectTo(EWB.ActiveSheet as _WorkSheet);

  Result := LoadExcelFileHeaderInternal;

  EWS.Disconnect;
  EWB.Disconnect;
  EA.Disconnect;
end;

function TExcelDM.LoadExcelFileHeaderInternal: TStringTreeNode;
var
  ACell: OleVariant;
  ACell2: OleVariant;
  ACellValue: string;
  ACol: Integer;
  AColor: TColor;
  AColor2: TColor;
  ARow: Integer;
  AStringNode: TStringTreeNode;
begin
  // Очистили
  TStringTreeNode.ClearMaxID;
  // Создали дерево
  Result := TStringTreeNode.Create;
  AStringNode := nil;

  ARow := 1;
  ACol := 1;
  while True do
  begin
    ACell := EWS.Cells.Item[ARow, ACol];
    {
      if ACell.MergeCells then
      begin
      r := ACell.MergeArea.Row;
      c := ACell.MergeArea.Column;
      rc := ACell.MergeArea.Rows.Count;
      cc := ACell.MergeArea.Columns.Count;
      end;
    }
    AColor := GetCellsColor(ACell);
    if (AColor = clWhite) and (not ACell.MergeCells) then
      break
    else
    begin
      ACellValue := ACell.Value;
      // Если это новая ячейка, то создаём новый узел
      if ACellValue <> '' then
        AStringNode := Result.AddChild(ACellValue);

      // Получаем ячейку под нашей
      ACell2 := EWS.Cells.Item[ARow + 1, ACol];
      // Получаем её цвет
      AColor2 := GetCellsColor(ACell2);

      ACellValue := ACell2.Value;
      // если в заголовке указан подпараметр
      if (AColor2 <> clWhite) and (ACellValue <> '') then
      begin
        // Родительская ячейка должна быть заполнена
        Assert(AStringNode <> nil);
        AStringNode.AddChild(ACellValue);
      end;
    end;
    Inc(ACol);
  end;

end;

constructor THeaderInfoTable.Create(AOwner: TComponent);
begin
  inherited;
  CreateFieldDefs;
  CreateDataSet;
  Open;
end;

procedure THeaderInfoTable.CreateFieldDefs;
begin
  FieldDefs.Add('ColumnName', ftWideString, 200);
end;

function THeaderInfoTable.GetColumnName: TField;
begin
  Result := FieldByName('ColumnName');
end;

constructor TStringTreeNode.Create;
begin
  inherited;
  FChilds := TObjectList<TStringTreeNode>.Create;
  FID := FMaxID;
end;

destructor TStringTreeNode.Destroy;
begin
  FreeAndNil(FChilds);
  inherited;
end;

function TStringTreeNode.AddChild(const AValue: String): TStringTreeNode;
begin
  // Увеличиваем максимальный идентификатор
  Inc(FMaxID);
  Result := TStringTreeNode.Create;
  Result.Value := AValue;
  Result.Parent := Self;
  Assert(Childs <> nil);
  Childs.Add(Result);
end;

class procedure TStringTreeNode.ClearMaxID;
begin
  FMaxID := 0;
end;

function TStringTreeNode.FindByID(AID: Integer): TStringTreeNode;
var
  AStringTreeNode: TStringTreeNode;
begin
  Assert(AID > 0);

  Result := Self;

  if FID = AID then
    Exit;

  for AStringTreeNode in Childs do
  begin
    // Просим свой дочерний узел поискать у себя
    Result := AStringTreeNode.FindByID(AID);
    if Result <> nil then
      Exit;
  end;

  Result := nil;
end;

function TStringTreeNode.IndexOf(AValue: string): Integer;
var
  I: Integer;
begin
  Assert(not AValue.IsEmpty);

  for I := 0 to Childs.Count - 1 do
  begin
    Result := I;
    if String.CompareText(Childs[I].Value, AValue) = 0 then
      Exit;
  end;
  Result := -1;
end;

end.
