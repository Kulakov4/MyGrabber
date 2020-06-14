unit DBRecordHolder;

interface

uses Classes, SysUtils, Data.DB, System.Generics.Collections{, MapFieldsUnit};

type
  TRecordHolder = class;

  TFieldHolder = class(TCollectionItem)
  private
    FValue: Variant;
    FFieldName: String;
    procedure SetFieldName(const Value: String);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(Collection: TRecordHolder; AField: TField);
      reintroduce; overload;
    constructor Create(Collection: TRecordHolder; AFieldName: string;
      AValue: Variant); reintroduce; overload;
    constructor Create(Collection: TRecordHolder; AField: TField;
      const ANewFieldName: string); reintroduce; overload;
    property FieldName: String read FFieldName write SetFieldName;
    property Value: Variant read FValue write FValue;
  end;

  TRecordHolder = class(TCollection)
  private
    function GetField(const FieldName: String): Variant;
    function GetItems(Index: Integer): TFieldHolder;
    procedure SetField(const FieldName: String; const Value: Variant);
    procedure SetItems(Index: Integer; const Value: TFieldHolder);
  public
    constructor Create(DataSet: TDataSet; const AExceptFieldNames: String = '');
        reintroduce; overload;
    constructor Create; overload;
    procedure Attach(DataSet: TDataSet; const AExceptFieldNames: String = '');
    procedure Detach;
    function FieldEx(const FieldName: String; NullSubstitute: Variant): Variant;
    function Find(const FieldName: string): TFieldHolder;
    procedure Put(DataSet: TDataSet);
    property Field[const FieldName: String]: Variant read GetField
      write SetField;
    property Items[Index: Integer]: TFieldHolder read GetItems
      write SetItems; default;
  end;

  TDBRecord = class(TObject)
  protected
  public
    class function GetFieldsDic(ADataSet: TDataSet)
      : TDictionary<String, String>; static;
    class function Fill(ADataSet, AFetchDataSet: TDataSet;
      const APKFieldName: String; AFieldsDic: TDictionary<String, String> = nil)
      : TRecordHolder; static;
  end;

implementation

uses Variants;

{ TFieldHolder }

constructor TFieldHolder.Create(Collection: TRecordHolder; AField: TField);
begin
  inherited Create(Collection);
  FValue := AField.Value;
  FFieldName := AnsiUpperCase(AField.FieldName);
end;

{ TFieldHolder }

constructor TFieldHolder.Create(Collection: TRecordHolder; AFieldName: string;
  AValue: Variant);
begin
  Assert(not AFieldName.IsEmpty);
  inherited Create(Collection);
  FFieldName := AnsiUpperCase(AFieldName);
  FValue := AValue;
end;

{ TFieldHolder }

constructor TFieldHolder.Create(Collection: TRecordHolder; AField: TField;
  const ANewFieldName: string);
begin
  Assert(not ANewFieldName.IsEmpty);
  Assert(AField <> nil);
  inherited Create(Collection);
  FFieldName := AnsiUpperCase(ANewFieldName);
  FValue := AField.Value;
end;

procedure TFieldHolder.AssignTo(Dest: TPersistent);
var
  ADest: TFieldHolder;
begin
  if not(Dest is TFieldHolder) then
    inherited; // Вызываем сообщение об ошибке

  ADest := Dest as TFieldHolder;
  ADest.FValue := FValue;
end;

procedure TFieldHolder.SetFieldName(const Value: String);
begin
  FFieldName := Value.ToUpper;
end;

{ TRecordHolder }

constructor TRecordHolder.Create(DataSet: TDataSet; const AExceptFieldNames:
    String = '');
begin
  inherited Create(TFieldHolder);
  Attach(DataSet, AExceptFieldNames);
end;

constructor TRecordHolder.Create;
begin
  inherited Create(TFieldHolder);
end;

procedure TRecordHolder.Attach(DataSet: TDataSet;
  const AExceptFieldNames: String = '');
Var
  AField: TField;
  S: string;
begin
  Assert(DataSet <> nil);
  if (not DataSet.Active) then
    raise Exception.Create
      ('Ошибка при сохранении записи из набора данных. Набор данных не открыт или пуст');

  S := ';' + AExceptFieldNames.ToUpper + ';';

  Clear;

  for AField in DataSet.Fields do
  begin
    // Если это поле не в списке полей для исключения
    if S.IndexOf(';' + AField.FieldName.ToUpper + ';') < 0 then
      TFieldHolder.Create(Self, AField);
  end;
end;

procedure TRecordHolder.Detach;
begin
  Clear;
end;

function TRecordHolder.FieldEx(const FieldName: String;
  NullSubstitute: Variant): Variant;
begin
  Result := Field[FieldName];

  // Заменяем значение поля NULL на иное значение
  if VarIsNull(Result) then
    Result := NullSubstitute;
end;

function TRecordHolder.Find(const FieldName: string): TFieldHolder;
var
  AFieldName: string;
  i: Integer;
begin
  AFieldName := AnsiUpperCase(FieldName);
  for i := 0 to Count - 1 do // Iterate
  begin
    Result := (Items[i] as TFieldHolder);
    if Result.FFieldName = AFieldName then
      Exit;

  end; // for
  Result := nil;
end;

function TRecordHolder.GetField(const FieldName: String): Variant;
var
  FieldHolder: TFieldHolder;
  i: Integer;
  AFieldName: String;
begin
  Result := NULL;
  AFieldName := AnsiUpperCase(FieldName);
  for i := 0 to Count - 1 do // Iterate
  begin
    FieldHolder := (Items[i] as TFieldHolder);
    if FieldHolder.FFieldName = AFieldName then
    begin
      Result := FieldHolder.Value;
      Exit;
    end;
  end; // for
  if VarIsNull(Result) then
    raise Exception.CreateFmt('Поле %s не найдено в буфере полей', [FieldName]);
end;

function TRecordHolder.GetItems(Index: Integer): TFieldHolder;
begin
  Result := inherited GetItem(Index) as TFieldHolder;
end;

procedure TRecordHolder.Put(DataSet: TDataSet);
var
  i: Integer;
  FieldHolder: TFieldHolder;
begin
  Assert(DataSet <> nil);
  Assert(DataSet.State in [dsEdit, dsInsert]);

  for i := 0 to Count - 1 do
  begin
    FieldHolder := (Items[i] as TFieldHolder);
    DataSet.FieldByName(FieldHolder.FFieldName).Value := FieldHolder.Value;
  end;
end;

procedure TRecordHolder.SetField(const FieldName: String; const Value: Variant);
var
  FieldHolder: TFieldHolder;
  i: Integer;
  AFieldName: String;
begin
  AFieldName := AnsiUpperCase(FieldName);
  for i := 0 to Count - 1 do // Iterate
  begin
    FieldHolder := (Items[i] as TFieldHolder);
    if FieldHolder.FFieldName = AFieldName then
    begin
      FieldHolder.FValue := Value;
      Exit;
    end;
  end; // for
  raise Exception.CreateFmt('TRecordHolder: поля %s не найдено', [FieldName]);
end;

procedure TRecordHolder.SetItems(Index: Integer; const Value: TFieldHolder);
begin
  inherited SetItem(Index, Value);
end;

class function TDBRecord.GetFieldsDic(ADataSet: TDataSet)
  : TDictionary<String, String>;
var
  AField: TField;
begin
  Assert(ADataSet <> nil);
  Result := TDictionary<String, String>.Create;

  for AField in ADataSet.Fields do
  begin
    Result.Add(AField.FieldName.ToUpper, AField.FieldName.ToUpper);
  end;

end;

class function TDBRecord.Fill(ADataSet, AFetchDataSet: TDataSet;
  const APKFieldName: String; AFieldsDic: TDictionary<String, String> = nil)
  : TRecordHolder;
var
  AFetchField: TField;
  AField: TField;
begin
  Assert(not APKFieldName.IsEmpty);
  Assert(ADataSet <> nil);
  Assert(AFetchDataSet <> nil);
  Assert(AFetchDataSet.RecordCount = 1);
  Assert(ADataSet.State in [dsEdit, dsInsert]);

  Result := TRecordHolder.Create;

  if AFieldsDic = nil then
  begin
    AFieldsDic := TDBRecord.GetFieldsDic(AFetchDataSet);
    // Первичный ключь обновлять не будем
    AFieldsDic.Remove(APKFieldName.ToUpper);
  end;
  try

    // Заполняем пустые поля выбранными значениями
    for AFetchField in AFetchDataSet.Fields do
    begin
      AField := nil;

      if AFieldsDic.ContainsKey(AFetchField.FieldName.ToUpper) then
        AField := ADataSet.FindField(AFieldsDic[AFetchField.FieldName.ToUpper]);

      // Если такое поле найдено
      if (AField <> nil) then
      begin
        // Если это поле пустое, будем его заполнять значением с сервера
        if AField.IsNull then
        begin
          AField.Value := AFetchField.Value;
        end
        else
        begin
          // Если в поле не пустое и его значение отличается от значения на сервере
          if AFetchField.IsNull or (AField.Value <> AFetchField.Value) then
          begin
            // Это поле надо будет обновить на сервере
            TFieldHolder.Create(Result, AField);
          end;
        end;
      end;
    end;

    // если есть поля, которые надо обновлять
    if Result.Count > 0 then
    begin
      // Добавим тогда и первичный ключ
      TFieldHolder.Create(Result, AFetchDataSet.FieldByName(APKFieldName));
    end;
  finally
    FreeAndNil(AFieldsDic);
  end;

end;

end.
