unit GridSort;

interface

uses
  cxGridDBBandedTableView, System.Generics.Collections, System.SysUtils,
  System.StrUtils, cxGridTableView, cxDBTL, dxCore;

type
  TSortVariant = class(TObject)
  private
    FKeyFieldName: string;
    FSortedFieldNames: TList<String>;
    procedure Init(AKeyFieldName: string);
  public
    constructor Create(AColumn: TcxGridDBBandedColumn;
      ASortedColumns: TArray<TcxGridDBBandedColumn>); overload;
    constructor Create(AColumn: TcxDBTreeListColumn; ASortedColumns:
        TArray<TcxDBTreeListColumn>); overload;
    destructor Destroy; override;
    property KeyFieldName: string read FKeyFieldName;
    property SortedFieldNames: TList<String> read FSortedFieldNames;
  end;

  TGridSort = class(TObject)
  private
    FSortDictionary: TDictionary<String, TSortVariant>;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(ASortVariant: TSortVariant);
    procedure Clear;
    function ContainsColumn(const AFieldName: string): Boolean;
    function GetSortVariant(AColumn: TcxGridColumn): TSortVariant; overload;
    function GetSortVariant(AColumn: TcxDBTreeListColumn)
      : TSortVariant; overload;
    property Count: Integer read GetCount;
  end;

implementation

constructor TSortVariant.Create(AColumn: TcxGridDBBandedColumn;
  ASortedColumns: TArray<TcxGridDBBandedColumn>);
var
  i: Integer;
begin
  Assert(AColumn <> nil);
  Init(AColumn.DataBinding.FieldName);

  Assert(Length(ASortedColumns) > 0);
  for i := Low(ASortedColumns) to High(ASortedColumns) do
    FSortedFieldNames.Add(ASortedColumns[i].DataBinding.FieldName);
end;

constructor TSortVariant.Create(AColumn: TcxDBTreeListColumn; ASortedColumns:
    TArray<TcxDBTreeListColumn>);
var
  i: Integer;
begin
  Assert(AColumn <> nil);
  Init(AColumn.DataBinding.FieldName);

  Assert(Length(ASortedColumns) > 0);

  for i := Low(ASortedColumns) to High(ASortedColumns) do
    FSortedFieldNames.Add(ASortedColumns[i].DataBinding.FieldName);
end;

destructor TSortVariant.Destroy;
begin
  FreeAndNil(FSortedFieldNames);
  inherited;
end;

procedure TSortVariant.Init(AKeyFieldName: string);
begin
  Assert(not AKeyFieldName.IsEmpty);

  FKeyFieldName := AKeyFieldName;
  FSortedFieldNames := TList < String>.Create;
end;

constructor TGridSort.Create;
begin
  FSortDictionary := TDictionary<String, TSortVariant>.Create;
end;

destructor TGridSort.Destroy;
var
  AKeyFieldName: string;
begin
  // Освобождаем все варианты сортировок
  For AKeyFieldName in FSortDictionary.Keys do
  begin
    FSortDictionary[AKeyFieldName].Free;
    FSortDictionary[AKeyFieldName] := nil;
  end;

  FreeAndNil(FSortDictionary);
  inherited;
end;

procedure TGridSort.Add(ASortVariant: TSortVariant);
begin
  Assert(FSortDictionary <> nil);
  Assert(ASortVariant <> nil);

  FSortDictionary.Add(ASortVariant.KeyFieldName, ASortVariant);
end;

procedure TGridSort.Clear;
begin
  FSortDictionary.Clear;
end;

function TGridSort.ContainsColumn(const AFieldName: string): Boolean;
begin
  Assert(not AFieldName.IsEmpty);
  Result := FSortDictionary.ContainsKey(AFieldName);
end;

function TGridSort.GetCount: Integer;
begin
  Result := FSortDictionary.Count;
end;

function TGridSort.GetSortVariant(AColumn: TcxGridColumn): TSortVariant;
var
  AFieldName: String;
begin
  Result := nil;
  AFieldName := (AColumn as TcxGridDBBandedColumn).DataBinding.FieldName;
  if ContainsColumn(AFieldName) then
    Result := FSortDictionary[AFieldName];
end;

function TGridSort.GetSortVariant(AColumn: TcxDBTreeListColumn): TSortVariant;
var
  AFieldName: String;
begin
  Result := nil;
  AFieldName := AColumn.DataBinding.FieldName;
  if ContainsColumn(AFieldName) then
    Result := FSortDictionary[AFieldName];
end;

end.
