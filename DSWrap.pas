unit DSWrap;

interface

uses
  System.Classes, Data.DB, System.SysUtils, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, NotifyEvents, System.Contnrs,
  DBRecordHolder, Winapi.Messages, Winapi.Windows, FireDAC.Stan.Option,
  FireDAC.Stan.Intf;

const
  WM_DS_AFTER_SCROLL = WM_USER + 500;
  WM_DS_AFTER_POST = WM_USER + 501;
  WM_DS_BEFORE_SCROLL = WM_USER + 502;

type
  TFieldWrap = class;
  TParamWrap = class;

  TDSWrap = class(TComponent)
  private
    FAfterOpen: TNotifyEventsEx;
    FAfterClose: TNotifyEventsEx;
    FAfterInsert: TNotifyEventsEx;
    FBeforePost: TNotifyEventsEx;
    FAfterScroll: TNotifyEventsEx;
    FBeforeDelete: TNotifyEventsEx;
    FAfterPost: TNotifyEventsEx;
    FAfterCancel: TNotifyEventsEx;
    FAfterDelete: TNotifyEventsEx;
    FAfterEdit: TNotifyEventsEx;
    FAfterRefresh: TNotifyEventsEx;
    FAfterScrollM: TNotifyEventsEx;
    FAfterPostM: TNotifyEventsEx;
    FBeforeScrollM: TNotifyEventsEx;
    FBeforeOpen: TNotifyEventsEx;
    FBeforeClose: TNotifyEventsEx;
    FBeforeEdit: TNotifyEventsEx;
    FBeforeInsert: TNotifyEventsEx;
    FBeforeRefresh: TNotifyEventsEx;
    FBeforeScroll: TNotifyEventsEx;
    FCloneEvents: TObjectList;
    FClones: TObjectList<TFDMemTable>;
    FDataSet: TDataSet;
    FEventList: TObjectList;
    FFields: TObjectList<TParamWrap>;
    FHandle: HWND;
    FIsRecordModifedClone: TFDMemTable;
    FDeletedPKValue: Variant;
    FBeforePostState: TDataSetState;
    FDataSource: TDataSource;
    FNeedRefresh: Boolean;
    FObj: TObject;
    FPKFieldName: string;
    FRecHolder: TRecordHolder;
    procedure AfterDataSetScroll(DataSet: TDataSet);
    procedure AfterDataSetClose(DataSet: TDataSet);
    procedure AfterDataSetOpen(DataSet: TDataSet);
    procedure AfterDataSetInsert(DataSet: TDataSet);
    procedure AfterDataSetCancel(DataSet: TDataSet);
    procedure CloneAfterCloseOrBeforeRefresh(Sender: TObject);
    procedure CloneAfterOpenOrRefresh(Sender: TObject);
    procedure CloneCursor(AClone: TFDMemTable);
    procedure DoAfterOpen___(Sender: TObject);
    function GetActive: Boolean;
    function GetAfterOpen: TNotifyEventsEx;
    function GetAfterClose: TNotifyEventsEx;
    function GetAfterInsert: TNotifyEventsEx;
    function GetBeforePost: TNotifyEventsEx;
    function GetAfterScroll: TNotifyEventsEx;
    function GetBeforeDelete: TNotifyEventsEx;
    function GetAfterPost: TNotifyEventsEx;
    function GetAfterCancel: TNotifyEventsEx;
    function GetAfterDelete: TNotifyEventsEx;
    function GetAfterScrollM: TNotifyEventsEx;
    function GetBeforeOpen: TNotifyEventsEx;
    function GetBeforeClose: TNotifyEventsEx;
    function GetFDDataSet: TFDDataSet;
    function GetHandle: HWND;
    function GetPK: TField;
    function GetRecordCount: Integer;
    procedure ProcessAfterScrollMessage;
    procedure BeforeDataSetPost(DataSet: TDataSet);
    procedure BeforeDataSetDelete(DataSet: TDataSet);
    procedure AfterDataSetPost(DataSet: TDataSet);
    procedure AfterDataSetDelete(DataSet: TDataSet);
    procedure AfterDataSetEdit(DataSet: TDataSet);
    procedure AfterDataSetRefresh(DataSet: TDataSet);
    procedure BeforeDataSetRefresh(DataSet: TDataSet);
    procedure BeforeDataSetClose(DataSet: TDataSet);
    procedure BeforeDataSetOpen(DataSet: TDataSet);
    procedure BeforeDataSetEdit(DataSet: TDataSet);
    procedure BeforeDataSetInsert(DataSet: TDataSet);
    procedure BeforeDataSetScroll(DataSet: TDataSet);
    function GetAfterEdit: TNotifyEventsEx;
    function GetAfterRefresh: TNotifyEventsEx;
    function GetAfterPostM: TNotifyEventsEx;
    function GetBeforeScrollM: TNotifyEventsEx;
    function GetBeforeEdit: TNotifyEventsEx;
    function GetBeforeInsert: TNotifyEventsEx;
    function GetBeforeRefresh: TNotifyEventsEx;
    function GetBeforeScroll: TNotifyEventsEx;
    function GetDataSource: TDataSource;
    procedure ProcessAfterPostMessage;
    procedure ProcessBeforeScrollMessage;
  protected
    FNEList: TList<TNotifyEventsEx>;
    FPostedMessage: TList<Integer>;
    procedure FDQueryUpdateRecordOnClient(ASender: TDataSet;
      ARequest: TFDUpdateRequest; var AAction: TFDErrorAction;
      AOptions: TFDUpdateRowOptions);
    procedure UpdateFields; virtual;
    procedure WndProc(var Msg: TMessage); virtual;
    property FDDataSet: TFDDataSet read GetFDDataSet;
    property Handle: HWND read GetHandle;
    property RecHolder: TRecordHolder read FRecHolder;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddClone(const AFilter: String): TFDMemTable;
    procedure AfterConstruction; override;
    procedure AppendFrom(ADSWrap: TDSWrap);
    procedure AppendRows(AFieldName: string; AValues: TArray<String>);
      overload; virtual;
    procedure CancelUpdates; virtual;
    procedure CascadeDelete(const AIDMaster: Variant;
      const ADetailKeyFieldName: String;
      AFromClientOnly: Boolean = False); virtual;
    procedure ClearFields(AFieldList: TArray<String>; AIDList: TArray<Integer>);
    procedure ClearFilter;
    procedure CopyFromOtherDataSet(ACopyFrom: TDataSet;
      FieldNamesList: TStrings = nil);
    procedure CreateDefaultFields(AUpdate: Boolean);
    procedure DeleteAll;
    procedure DropClone(AClone: TFDMemTable);
    function Field(const AFieldName: string): TField;
    function GetFieldsWrapAsArr: TArray<TParamWrap>;
    function HaveAnyChanges: Boolean;
    function InsertRecord(ARecordHolder: TRecordHolder): Integer;
    function IsRecordModifed(APKValue: Variant): Boolean;
    function IsParamExist(const AParamName: String): Boolean;
    function Load(const AParamNames: TArray<String>;
      const AParamValues: TArray<Variant>; ATestResult: Integer = -1)
      : Integer; overload;
    function LocateByF(AFieldName: string; AValue: Variant;
      AOptions: TFDDataSetLocateOptions): Boolean;
    function LocateByPK(APKValue: Variant; TestResult: Boolean = False)
      : Boolean;
    procedure LocateByPKAndDelete(APKValue: Variant);
    procedure RefreshQuery; virtual;
    function RestoreBookmark: Boolean; virtual;
    function SaveBookmark: Boolean;
    procedure SetFieldsReadOnly(AReadOnly: Boolean);
    procedure SetFieldsRequired(ARequired: Boolean);
    procedure SetFieldsVisible(AVisible: Boolean);
    procedure SetParameters(const AParamNames: TArray<String>;
      const AParamValues: TArray<Variant>);
    procedure SmartRefresh; virtual;
    procedure TryAppend;
    procedure TryCancel;
    function TryEdit: Boolean;
    function TryLocate(AFields: TArray<String>;
      AValues: TArray<Variant>): Integer;
    procedure TryOpen;
    procedure TryPost;
    function UpdateRecord(ARecordHolder: TRecordHolder): Boolean;
    property Active: Boolean read GetActive;
    property AfterOpen: TNotifyEventsEx read GetAfterOpen;
    property AfterClose: TNotifyEventsEx read GetAfterClose;
    property AfterInsert: TNotifyEventsEx read GetAfterInsert;
    property BeforePost: TNotifyEventsEx read GetBeforePost;
    property AfterScroll: TNotifyEventsEx read GetAfterScroll;
    property BeforeDelete: TNotifyEventsEx read GetBeforeDelete;
    property AfterPost: TNotifyEventsEx read GetAfterPost;
    property AfterCancel: TNotifyEventsEx read GetAfterCancel;
    property AfterDelete: TNotifyEventsEx read GetAfterDelete;
    property AfterEdit: TNotifyEventsEx read GetAfterEdit;
    property AfterRefresh: TNotifyEventsEx read GetAfterRefresh;
    property AfterScrollM: TNotifyEventsEx read GetAfterScrollM;
    property AfterPostM: TNotifyEventsEx read GetAfterPostM;
    property BeforeScrollM: TNotifyEventsEx read GetBeforeScrollM;
    property BeforeOpen: TNotifyEventsEx read GetBeforeOpen;
    property BeforeClose: TNotifyEventsEx read GetBeforeClose;
    property BeforeEdit: TNotifyEventsEx read GetBeforeEdit;
    property BeforeInsert: TNotifyEventsEx read GetBeforeInsert;
    property BeforeRefresh: TNotifyEventsEx read GetBeforeRefresh;
    property BeforeScroll: TNotifyEventsEx read GetBeforeScroll;
    property DataSet: TDataSet read FDataSet;
    property EventList: TObjectList read FEventList;
    property DeletedPKValue: Variant read FDeletedPKValue;
    property BeforePostState: TDataSetState read FBeforePostState;
    property DataSource: TDataSource read GetDataSource;
    property Fields: TObjectList<TParamWrap> read FFields;
    property NeedRefresh: Boolean read FNeedRefresh write FNeedRefresh;
    property Obj: TObject read FObj write FObj;
    property PK: TField read GetPK;
    property PKFieldName: string read FPKFieldName write FPKFieldName;
    property RecordCount: Integer read GetRecordCount;
  end;

  TParamWrap = class(TObject)
  private
    FDataSetWrap: TDSWrap;
    FDefaultValue: Variant;
    FFieldName: string;
    FFullName: string;
    FTableName: string;
  public
    constructor Create(ADataSetWrap: TDSWrap; const AFullName: String);
    property DataSetWrap: TDSWrap read FDataSetWrap;
    property DefaultValue: Variant read FDefaultValue write FDefaultValue;
    property FullName: string read FFullName;
    property FieldName: string read FFieldName;
    property TableName: string read FTableName;
  end;

  TFieldWrap = class(TParamWrap)
  private
    FDisplayLabel: string;
    function GetF: TField;
  public
    constructor Create(ADataSetWrap: TDSWrap; const AFullName: String;
      const ADisplayLabel: string = ''; APrimaryKey: Boolean = False);
    function Locate(AValue: Variant; AOptions: TFDDataSetLocateOptions;
      TestResult: Boolean = False): Boolean;
    function AllValues(const ADelimiter: String = ',';
      AUnique: Boolean = False): String;
    function AsIntArray(AUnique: Boolean = False): TArray<Integer>;
    property DisplayLabel: string read FDisplayLabel;
    property F: TField read GetF;
  end;

implementation

uses
  FireDAC.Stan.Param, System.Variants, System.StrUtils;

constructor TDSWrap.Create(AOwner: TComponent);
begin
  inherited;

  if not(AOwner is TDataSet) then
    raise Exception.Create
      ('Ошибка при создании TDSWrap. Владелец должен быть TDataSet.');

  FDataSet := AOwner as TDataSet;
  FFields := TObjectList<TParamWrap>.Create;
  FEventList := TObjectList.Create;
  FNEList := TList<TNotifyEventsEx>.Create;
  FBeforePostState := FDataSet.State;
  FPostedMessage := TList<Integer>.Create;
end;

destructor TDSWrap.Destroy;
var
  I: Integer;
begin
  // Удалим все клоны
  if FClones <> nil then
  begin
    for I := FClones.Count - 1 downto 0 do
      DropClone(FClones[I]);
  end;
  Assert(FClones = nil);

  for I := FNEList.Count - 1 downto 0 do
  begin
    FNEList[I].Destroy;
    FNEList.Delete(I);
  end;
  Assert(FNEList.Count = 0);
  FreeAndNil(FNEList);

  FreeAndNil(FFields);
  FreeAndNil(FEventList);

  if FHandle <> 0 then
    DeallocateHWnd(FHandle);

  FreeAndNil(FPostedMessage);

  inherited;
end;

function TDSWrap.AddClone(const AFilter: String): TFDMemTable;
begin
  // Создаём список клонов
  if FClones = nil then
  begin
    FClones := TObjectList<TFDMemTable>.Create;

    // Список подписчиков
    FCloneEvents := TObjectList.Create;

    // Будем клонировать курсоры
    TNotifyEventWrap.Create(AfterOpen, CloneAfterOpenOrRefresh, FCloneEvents);
    TNotifyEventWrap.Create(AfterRefresh, CloneAfterOpenOrRefresh,
      FCloneEvents);
    // Будем закрывать курсоры
    TNotifyEventWrap.Create(AfterClose, CloneAfterCloseOrBeforeRefresh,
      FCloneEvents);
    TNotifyEventWrap.Create(BeforeRefresh, CloneAfterCloseOrBeforeRefresh,
      FCloneEvents);
  end;

  Result := TFDMemTable.Create(nil); // Владельцем будет список
  Result.Filter := AFilter;

  // Клонируем
  if FDataSet.Active then
    CloneCursor(Result);

  FClones.Add(Result); // Владельцем будет список
end;

procedure TDSWrap.AfterConstruction;
begin
  inherited;
  if FFields.Count = 0 then
    Exit;

  TNotifyEventWrap.Create(AfterOpen, DoAfterOpen___, EventList);
  if DataSet.Active then
    UpdateFields;
end;

procedure TDSWrap.AfterDataSetOpen(DataSet: TDataSet);
begin
  FAfterOpen.CallEventHandlers(Self);
end;

procedure TDSWrap.BeforeDataSetPost(DataSet: TDataSet);
begin
  FBeforePostState := DataSet.State;
  FBeforePost.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetScroll(DataSet: TDataSet);
begin
  // Если сообщение AfterScroll ещё не посылали и есть подписчики
  if (FAfterScrollM <> nil) and (FAfterScrollM.Count > 0) and
    (FPostedMessage.IndexOf(WM_DS_AFTER_SCROLL) < 0) then
  begin
    FPostedMessage.Add(WM_DS_AFTER_SCROLL);
    // Отправляем новое сообщение
    PostMessage(Handle, WM_DS_AFTER_SCROLL, 0, 0);
  end;

  // Извещаем тех, кто кочет получить сообщение немедленно
  if FAfterScroll <> nil then
    FAfterScroll.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetClose(DataSet: TDataSet);
begin
  FAfterClose.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetInsert(DataSet: TDataSet);
begin
  FAfterInsert.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetCancel(DataSet: TDataSet);
begin
  FAfterCancel.CallEventHandlers(Self);
end;

procedure TDSWrap.BeforeDataSetDelete(DataSet: TDataSet);
begin
  if not PKFieldName.IsEmpty then
    FDeletedPKValue := Field(FPKFieldName).Value;

  FBeforeDelete.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetPost(DataSet: TDataSet);
begin
  // Если сообщение AfterScroll ещё не посылали и есть подписчики
  if (FAfterPostM <> nil) and (FAfterPostM.Count > 0) and
    (FPostedMessage.IndexOf(WM_DS_AFTER_POST) < 0) then
  begin
    FPostedMessage.Add(WM_DS_AFTER_POST);
    // Отправляем новое сообщение
    PostMessage(Handle, WM_DS_AFTER_POST, 0, 0);
  end;

  // Извещаем тех, кто хочет получить сообщение немедленно
  if FAfterPost <> nil then
    FAfterPost.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetDelete(DataSet: TDataSet);
begin
  FAfterDelete.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetEdit(DataSet: TDataSet);
begin
  FAfterEdit.CallEventHandlers(Self);
end;

procedure TDSWrap.AfterDataSetRefresh(DataSet: TDataSet);
begin
  FAfterRefresh.CallEventHandlers(Self);
end;

procedure TDSWrap.AppendFrom(ADSWrap: TDSWrap);
var
  // AField: TParamWrap;
  FW: TFieldWrap;
  FW2: TFieldWrap;
  I: Integer;
begin
  Assert(ADSWrap <> nil);
  ADSWrap.DataSet.DisableControls;
  try
    ADSWrap.DataSet.First;
    while not ADSWrap.DataSet.Eof do
    begin
      DataSet.Append;
      try
        for I := 0 to Fields.Count - 1 do
        begin
          if not(Fields[I] is TFieldWrap) then
            continue;

          FW := Fields[I] as TFieldWrap;

          if not(ADSWrap.Fields[I] is TFieldWrap) then
            raise Exception.Create
              ('Ошибка при копировании наборов данных. Поля имеют разный тип');

          FW2 := ADSWrap.Fields[I] as TFieldWrap;
          if FW.FieldName <> FW2.FieldName then
            raise Exception.Create
              ('Ошибка при копировании наборов данных. Поля имеют разное имя');

          FW.F.Value := FW2.F.Value;
        end;
        DataSet.Post;
      except
        DataSet.Cancel;
        raise;
      end;

      ADSWrap.DataSet.Next;
    end;
  finally
    ADSWrap.DataSet.EnableControls;
  end;
end;

procedure TDSWrap.BeforeDataSetRefresh(DataSet: TDataSet);
begin
  FBeforeRefresh.CallEventHandlers(Self);
end;

procedure TDSWrap.AppendRows(AFieldName: string; AValues: TArray<String>);
var
  AValue: string;
begin
  Assert(not AFieldName.IsEmpty);

  // Добавляем в список родительские компоненты
  for AValue in AValues do
  begin
    TryAppend;
    Field(AFieldName).AsString := AValue;
    TryPost;
  end;
end;

procedure TDSWrap.BeforeDataSetOpen(DataSet: TDataSet);
begin
  FBeforeOpen.CallEventHandlers(Self);
end;

procedure TDSWrap.BeforeDataSetClose(DataSet: TDataSet);
begin
  FBeforeClose.CallEventHandlers(Self);
end;

procedure TDSWrap.BeforeDataSetEdit(DataSet: TDataSet);
begin
  FBeforeEdit.CallEventHandlers(Self);
end;

procedure TDSWrap.BeforeDataSetInsert(DataSet: TDataSet);
begin
  FBeforeInsert.CallEventHandlers(Self);
end;

procedure TDSWrap.BeforeDataSetScroll(DataSet: TDataSet);
begin
  // Если сообщение BeforeScroll ещё не посылали и есть подписчики
  if (FBeforeScrollM <> nil) and (FBeforeScrollM.Count > 0) and
    (FPostedMessage.IndexOf(WM_DS_BEFORE_SCROLL) < 0) then
  begin
    FPostedMessage.Add(WM_DS_BEFORE_SCROLL);
    // Отправляем новое сообщение
    PostMessage(Handle, WM_DS_BEFORE_SCROLL, 0, 0);
  end;

  // Извещаем тех, кто кочет получить сообщение немедленно
  if FBeforeScroll <> nil then
    FBeforeScroll.CallEventHandlers(Self);
end;

procedure TDSWrap.CancelUpdates;
begin
  // отменяем все сделанные изменения на стороне клиента
  TryCancel;
  if FDDataSet.CachedUpdates then
  begin
    FDDataSet.CancelUpdates;
  end
end;

procedure TDSWrap.CascadeDelete(const AIDMaster: Variant;
  const ADetailKeyFieldName: String; AFromClientOnly: Boolean = False);
var
  E: TFDUpdateRecordEvent;
begin
  Assert(AIDMaster > 0);

  E := FDDataSet.OnUpdateRecord;
  try
    // Если каскадное удаление уже реализовано на стороне сервера
    // Просто удалим эти записи с клиента ничего не сохраняя на стороне сервера
    if AFromClientOnly then
      FDDataSet.OnUpdateRecord := FDQueryUpdateRecordOnClient;

    // FDQuery.DisableControls;
    // try
    // Пока есть записи подчинённые мастеру
    while FDDataSet.LocateEx(ADetailKeyFieldName, AIDMaster, []) do
    begin
      FDDataSet.Delete;
    end;
    // finally
    // Тут cxGrid мастера синхронизирует с подчинённым и перескакивает на другую запись
    // FDQuery.EnableControls;
    // end;

  finally
    if AFromClientOnly then
      FDDataSet.OnUpdateRecord := E;
  end;
end;

procedure TDSWrap.ClearFields(AFieldList: TArray<String>;
  AIDList: TArray<Integer>);
var
  AFieldName: String;
  AID: Integer;
begin
  Assert(Length(AFieldList) > 0);
  Assert(Length(AIDList) > 0);

  DataSet.DisableControls;
  try
    SaveBookmark;
    for AID in AIDList do
    begin
      if not LocateByPK(AID) then
        continue;
      TryEdit;
      for AFieldName in AFieldList do
        Field(AFieldName).Value := NULL;
      TryPost;
    end;
    RestoreBookmark;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TDSWrap.ClearFilter;
begin
  FDataSet.Filtered := False;
end;

procedure TDSWrap.CloneAfterCloseOrBeforeRefresh(Sender: TObject);
var
  AClone: TFDMemTable;
begin
  // Закрываем клоны
  for AClone in FClones do
    AClone.Close;
end;

procedure TDSWrap.CloneAfterOpenOrRefresh(Sender: TObject);
var
  AClone: TFDMemTable;
begin
  // клонируем курсоры
  for AClone in FClones do
  begin
    CloneCursor(AClone);
  end;
end;

procedure TDSWrap.CloneCursor(AClone: TFDMemTable);
var
  AFilter: String;
begin
  // Assert(not AClone.Filter.IsEmpty);
  AFilter := AClone.Filter;
  AClone.CloneCursor(FDDataSet);

  // Если фильтр накладывать не надо
  if (AFilter.IsEmpty) then
    Exit;

  AClone.Filter := AFilter;
  AClone.Filtered := True;
end;

procedure TDSWrap.CopyFromOtherDataSet(ACopyFrom: TDataSet;
  FieldNamesList: TStrings = nil);

  procedure InternalCopyFromDataSet(ASource, ADestination: TDataSet);
  var
    I: Integer;
    F: TField;
  begin
    ADestination.DisableControls;
    ASource.DisableControls;
    try
      ASource.First;
      while not ASource.Eof do
      begin
        ADestination.Append;
        for I := 0 to ADestination.FieldCount - 1 do
        begin
          if (FieldNamesList = nil) or
            (FieldNamesList.IndexOf(ADestination.Fields[I].FieldName) >= 0) then
          begin
            F := ASource.FindField(ADestination.Fields[I].FieldName);
            if F <> nil then
            begin
              if F is TDataSetField then
                InternalCopyFromDataSet((F as TDataSetField).NestedDataSet,
                  (ADestination.Fields[I] as TDataSetField).NestedDataSet)
              else
                ADestination.Fields[I].Assign(F);
              // ASource.Fields[i].Value := F.Value;
            end;
          end;
        end;
        if ADestination.State in [dsEdit, dsInsert] then
          ADestination.Post;
        ASource.Next;
      end;
    finally
      ADestination.EnableControls;
      ASource.EnableControls;
    end;
  end;

begin
  Assert(ACopyFrom <> nil);
  if not FDataSet.Active then
    FDataSet.Open;

  InternalCopyFromDataSet(ACopyFrom, FDataSet);
end;

procedure TDSWrap.CreateDefaultFields(AUpdate: Boolean);
var
  I: Integer;
begin
  Assert(not DataSet.Active);
  with DataSet do
  begin
    if AUpdate then
      FieldDefs.Update;
    for I := 0 to FieldDefs.Count - 1 do
    begin
      FieldDefs[I].CreateField(DataSet);
    end;
  end;
end;

procedure TDSWrap.DeleteAll;
begin
  FDDataSet.DisableControls;
  try
    while not FDDataSet.Eof do
      FDDataSet.Delete;
  finally
    FDDataSet.EnableControls;
  end;
end;

procedure TDSWrap.DoAfterOpen___(Sender: TObject);
begin
  UpdateFields;
end;

procedure TDSWrap.DropClone(AClone: TFDMemTable);
begin
  Assert(AClone <> nil);
  Assert(FClones <> nil);

  FClones.Remove(AClone);

  if FClones.Count = 0 then
  begin
    // Отписываемся
    FreeAndNil(FCloneEvents);
    // Разрушаем список
    FreeAndNil(FClones);
  end;
end;

procedure TDSWrap.FDQueryUpdateRecordOnClient(ASender: TDataSet;
  ARequest: TFDUpdateRequest; var AAction: TFDErrorAction;
  AOptions: TFDUpdateRowOptions);
begin
  AAction := eaApplied;
end;

function TDSWrap.Field(const AFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(AFieldName);
end;

function TDSWrap.GetActive: Boolean;
begin
  Result := FDataSet.Active;
end;

function TDSWrap.GetAfterOpen: TNotifyEventsEx;
begin
  if FAfterOpen = nil then
  begin
    Assert(not Assigned(FDataSet.AfterOpen));
    FAfterOpen := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterOpen);
    FDataSet.AfterOpen := AfterDataSetOpen;
  end;

  Result := FAfterOpen;
end;

function TDSWrap.GetAfterClose: TNotifyEventsEx;
begin
  if FAfterClose = nil then
  begin
    Assert(not Assigned(FDataSet.AfterClose));
    FAfterClose := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterClose);
    FDataSet.AfterClose := AfterDataSetClose;
  end;

  Result := FAfterClose;
end;

function TDSWrap.GetAfterInsert: TNotifyEventsEx;
begin
  if FAfterInsert = nil then
  begin
    Assert(not Assigned(FDataSet.AfterInsert));
    FAfterInsert := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterInsert);
    FDataSet.AfterInsert := AfterDataSetInsert;
  end;

  Result := FAfterInsert;
end;

function TDSWrap.GetBeforePost: TNotifyEventsEx;
begin
  if FBeforePost = nil then
  begin
    Assert(not Assigned(FDataSet.BeforePost));
    FBeforePost := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforePost);
    FDataSet.BeforePost := BeforeDataSetPost;
  end;

  Result := FBeforePost;
end;

function TDSWrap.GetAfterScroll: TNotifyEventsEx;
begin
  if FAfterScroll = nil then
  begin
    Assert(not Assigned(FDataSet.AfterScroll));
    FAfterScroll := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterScroll);
    FDataSet.AfterScroll := AfterDataSetScroll;
  end;
  Result := FAfterScroll;
end;

function TDSWrap.GetBeforeDelete: TNotifyEventsEx;
begin
  if FBeforeDelete = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeDelete));
    FBeforeDelete := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeDelete);
    FDataSet.BeforeDelete := BeforeDataSetDelete;
  end;

  Result := FBeforeDelete;
end;

function TDSWrap.GetAfterPost: TNotifyEventsEx;
begin
  if FAfterPost = nil then
  begin
    Assert(not Assigned(FDataSet.AfterPost));
    FAfterPost := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterPost);
    FDataSet.AfterPost := AfterDataSetPost;
  end;

  Result := FAfterPost;
end;

function TDSWrap.GetAfterCancel: TNotifyEventsEx;
begin
  if FAfterCancel = nil then
  begin
    Assert(not Assigned(FDataSet.AfterCancel));
    FAfterCancel := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterCancel);
    FDataSet.AfterCancel := AfterDataSetCancel;
  end;

  Result := FAfterCancel;
end;

function TDSWrap.GetAfterDelete: TNotifyEventsEx;
begin
  if FAfterDelete = nil then
  begin
    Assert(not Assigned(FDataSet.AfterDelete));
    FAfterDelete := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterDelete);
    FDataSet.AfterDelete := AfterDataSetDelete;
  end;

  Result := FAfterDelete;
end;

function TDSWrap.GetAfterEdit: TNotifyEventsEx;
begin
  if FAfterEdit = nil then
  begin
    Assert(not Assigned(FDataSet.AfterEdit));
    FAfterEdit := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterEdit);
    FDataSet.AfterEdit := AfterDataSetEdit;
  end;

  Result := FAfterEdit;
end;

function TDSWrap.GetAfterRefresh: TNotifyEventsEx;
begin
  if FAfterRefresh = nil then
  begin
    Assert(not Assigned(FDataSet.AfterRefresh));
    FAfterRefresh := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterRefresh);
    FDataSet.AfterRefresh := AfterDataSetRefresh;
  end;

  Result := FAfterRefresh;
end;

function TDSWrap.GetAfterScrollM: TNotifyEventsEx;
begin
  if FAfterScrollM = nil then
  begin
    if FAfterScroll = nil then
      Assert(not Assigned(FDataSet.AfterScroll));
    // else
    // Assert(FDataSet.AfterScroll = AfterDataSetScroll);

    FAfterScrollM := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterScrollM);
    FDataSet.AfterScroll := AfterDataSetScroll;
  end;
  Result := FAfterScrollM;
end;

function TDSWrap.GetAfterPostM: TNotifyEventsEx;
begin
  if FAfterPostM = nil then
  begin
    if FAfterPost = nil then
      Assert(not Assigned(FDataSet.AfterPost));

    FAfterPostM := TNotifyEventsEx.Create(Self);
    FNEList.Add(FAfterPostM);
    FDataSet.AfterPost := AfterDataSetPost;
  end;
  Result := FAfterPostM;
end;

function TDSWrap.GetBeforeScrollM: TNotifyEventsEx;
begin
  if FBeforeScrollM = nil then
  begin
    if FBeforeScroll = nil then
      Assert(not Assigned(FDataSet.BeforeScroll));

    FBeforeScrollM := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeScrollM);
    FDataSet.BeforeScroll := BeforeDataSetScroll;
  end;
  Result := FBeforeScrollM;
end;

function TDSWrap.GetBeforeOpen: TNotifyEventsEx;
begin
  if FBeforeOpen = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeOpen));
    FBeforeOpen := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeOpen);
    FDataSet.BeforeOpen := BeforeDataSetOpen;
  end;

  Result := FBeforeOpen;
end;

function TDSWrap.GetBeforeClose: TNotifyEventsEx;
begin
  if FBeforeClose = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeClose));
    FBeforeClose := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeClose);
    FDataSet.BeforeClose := BeforeDataSetClose;
  end;

  Result := FBeforeClose;
end;

function TDSWrap.GetBeforeEdit: TNotifyEventsEx;
begin
  if FBeforeEdit = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeEdit));
    FBeforeEdit := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeEdit);
    FDataSet.BeforeEdit := BeforeDataSetEdit;
  end;

  Result := FBeforeEdit;
end;

function TDSWrap.GetBeforeInsert: TNotifyEventsEx;
begin
  if FBeforeInsert = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeInsert));
    FBeforeInsert := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeInsert);
    FDataSet.BeforeInsert := BeforeDataSetInsert;
  end;

  Result := FBeforeInsert;
end;

function TDSWrap.GetBeforeRefresh: TNotifyEventsEx;
begin
  if FBeforeRefresh = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeRefresh));
    FBeforeRefresh := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeRefresh);
    FDataSet.BeforeRefresh := BeforeDataSetRefresh;
  end;

  Result := FBeforeRefresh;
end;

function TDSWrap.GetBeforeScroll: TNotifyEventsEx;
begin
  if FBeforeScroll = nil then
  begin
    Assert(not Assigned(FDataSet.BeforeScroll));
    FBeforeScroll := TNotifyEventsEx.Create(Self);
    FNEList.Add(FBeforeScroll);
    FDataSet.BeforeScroll := BeforeDataSetScroll;
  end;

  Result := FBeforeScroll;
end;

function TDSWrap.GetDataSource: TDataSource;
begin
  if FDataSource = nil then
  begin
    FDataSource := TDataSource.Create(Self);
    FDataSource.DataSet := DataSet;
  end;
  Result := FDataSource;
end;

function TDSWrap.GetFDDataSet: TFDDataSet;
begin
  Result := FDataSet as TFDDataSet;
end;

function TDSWrap.GetFieldsWrapAsArr: TArray<TParamWrap>;
begin
  Result := FFields.ToArray;
end;

function TDSWrap.GetHandle: HWND;
begin
  if FHandle = 0 then
    FHandle := System.Classes.AllocateHWnd(WndProc);

  Result := FHandle;
end;

function TDSWrap.GetPK: TField;
begin
  if FPKFieldName.IsEmpty then
    raise Exception.Create('Имя первичного ключа не задано');

  Result := Field(FPKFieldName);
end;

procedure TDSWrap.WndProc(var Msg: TMessage);
begin
  with Msg do
    case Msg of
      WM_DS_BEFORE_SCROLL:
        ProcessBeforeScrollMessage;
      WM_DS_AFTER_SCROLL:
        ProcessAfterScrollMessage;
      WM_DS_AFTER_POST:
        ProcessAfterPostMessage;
    else
      DefWindowProc(FHandle, Msg, wParam, lParam);
    end;
end;

function TDSWrap.GetRecordCount: Integer;
begin
  Result := FDataSet.RecordCount;
end;

function TDSWrap.HaveAnyChanges: Boolean;
begin
  Result := FDataSet.State in [dsEdit, dsInsert];
end;

function TDSWrap.InsertRecord(ARecordHolder: TRecordHolder): Integer;
var
  AFieldHolder: TFieldHolder;
  F: TField;
begin
  Assert(ARecordHolder <> nil);

  TryAppend;
  try
    for F in DataSet.Fields do
    begin
      // Первичный ключ заполнять не будем
      if F.FieldName.ToUpper = PKFieldName.ToUpper then
        continue;

      // Ищем такое поле в коллекции вставляемых значений
      AFieldHolder := ARecordHolder.Find(F.FieldName);

      // Если нашли
      if (AFieldHolder <> nil) and not VarIsNull(AFieldHolder.Value) then
      begin
        F.Value := AFieldHolder.Value;
      end;

    end;

    TryPost;
    // Первичный ключ должен получить значение
    Assert(not PK.IsNull);

    Result := PK.AsInteger;
  except
    TryCancel;
    raise;
  end;

end;

function TDSWrap.IsRecordModifed(APKValue: Variant): Boolean;
var
  AFDDataSet: TFDDataSet;
  OK: Boolean;
begin
  // Если проверяем текущую запись
  if PK.Value = APKValue then
    AFDDataSet := FDDataSet
  else
  begin
    // Для проверки другой записи надо создать клон
    if FIsRecordModifedClone = nil then
    begin
      // Создаём клон
      FIsRecordModifedClone := AddClone('');
    end;
    OK := FIsRecordModifedClone.LocateEx(PKFieldName, APKValue);
    Assert(OK);
    AFDDataSet := FIsRecordModifedClone;
  end;

  Result := AFDDataSet.UpdateStatus in [usModified, usInserted]
end;

function TDSWrap.IsParamExist(const AParamName: String): Boolean;
var
  AFDParam: TFDParam;
begin
  Assert(not AParamName.IsEmpty);
  AFDParam := FDDataSet.FindParam(AParamName);
  Result := AFDParam <> nil;
end;

function TDSWrap.Load(const AParamNames: TArray<String>;
  const AParamValues: TArray<Variant>; ATestResult: Integer = -1): Integer;
begin
  FDataSet.DisableControls;
  try
    FDataSet.Close;
    SetParameters(AParamNames, AParamValues);
    FDataSet.Open;
  finally
    FDataSet.EnableControls;
  end;
  Result := FDataSet.RecordCount;

  if ATestResult >= 0 then
    Assert(Result = ATestResult);
end;

function TDSWrap.LocateByF(AFieldName: string; AValue: Variant;
  AOptions: TFDDataSetLocateOptions): Boolean;
begin
  Assert(not AFieldName.IsEmpty);
  Result := FDDataSet.LocateEx(AFieldName, AValue, AOptions);
end;

function TDSWrap.LocateByPK(APKValue: Variant;
  TestResult: Boolean = False): Boolean;
begin
  Assert(not FPKFieldName.IsEmpty);
  Result := FDDataSet.LocateEx(FPKFieldName, APKValue);
  if TestResult then
  begin
    Assert(Result);
  end;
end;

procedure TDSWrap.LocateByPKAndDelete(APKValue: Variant);
begin
  LocateByPK(APKValue, True);
  DataSet.Delete;
end;

procedure TDSWrap.ProcessAfterScrollMessage;
var
  I: Integer;
begin
  // Если наш объект уже разрушился
  if FPostedMessage = nil then
    Exit;
  I := FPostedMessage.IndexOf(WM_DS_AFTER_SCROLL);
  Assert(I >= 0);

  Assert(FAfterScrollM <> nil);
  FAfterScrollM.CallEventHandlers(Self);
  FPostedMessage.Delete(I);
end;

procedure TDSWrap.ProcessAfterPostMessage;
var
  I: Integer;
begin
  // Если наш объект уже разрушился
  if FPostedMessage = nil then
    Exit;

  I := FPostedMessage.IndexOf(WM_DS_AFTER_POST);
  Assert(I >= 0);

  Assert(FAfterPostM <> nil);
  FAfterPostM.CallEventHandlers(Self);
  FPostedMessage.Delete(I);
end;

procedure TDSWrap.ProcessBeforeScrollMessage;
var
  I: Integer;
begin
  // Если наш объект уже разрушился
  if FPostedMessage = nil then
    Exit;

  I := FPostedMessage.IndexOf(WM_DS_BEFORE_SCROLL);
  Assert(I >= 0);

  Assert(FBeforeScrollM <> nil);
  FBeforeScrollM.CallEventHandlers(Self);
  FPostedMessage.Delete(I);
end;

procedure TDSWrap.RefreshQuery;
begin
  FDataSet.DisableControls;
  try
    if (FDataSet.Active) then
    begin
      if FDDataSet.ChangeCount = 0 then
        FDataSet.Refresh
      else
      begin
        FDataSet.Close;
        FDataSet.Open;
      end;
    end
    else
      FDataSet.Open;

    FNeedRefresh := False;
  finally
    FDataSet.EnableControls;
  end;
end;

function TDSWrap.RestoreBookmark: Boolean;
begin
  Result := False;

  // Если есть сохранённая запись, к которой надо вернуться
  // И известен первичный ключ
  if (FRecHolder <> nil) and (not PKFieldName.IsEmpty) and
    (not VarIsNull(FRecHolder.Field[PKFieldName])) then
    Result := LocateByPK(FRecHolder.Field[PKFieldName]);
end;

function TDSWrap.SaveBookmark: Boolean;
begin
  Result := DataSet.Active and not DataSet.IsEmpty;
  if not Result then
  begin
    if FRecHolder <> nil then
      FreeAndNil(FRecHolder);

    Exit;
  end;

  if FRecHolder = nil then
    FRecHolder := TRecordHolder.Create(DataSet)
  else
    FRecHolder.Attach(DataSet);
end;

procedure TDSWrap.SetFieldsReadOnly(AReadOnly: Boolean);
var
  AField: TField;
begin
  inherited;
  for AField in FDataSet.Fields do
    AField.ReadOnly := AReadOnly;
end;

procedure TDSWrap.SetFieldsRequired(ARequired: Boolean);
var
  AField: TField;
begin
  inherited;
  for AField in FDataSet.Fields do
    AField.Required := ARequired;
end;

procedure TDSWrap.SetFieldsVisible(AVisible: Boolean);
var
  F: TField;
begin
  for F in FDataSet.Fields do
    F.Visible := AVisible;
end;

procedure TDSWrap.SetParameters(const AParamNames: TArray<String>;
  const AParamValues: TArray<Variant>);
var
  I: Integer;
begin
  Assert(Low(AParamNames) = Low(AParamValues));
  Assert(High(AParamNames) = High(AParamValues));

  for I := Low(AParamNames) to High(AParamNames) do
  begin
    FDDataSet.ParamByName(AParamNames[I]).Value := AParamValues[I];
  end;
end;

procedure TDSWrap.SmartRefresh;
var
  I: Integer;
  OK: Boolean;
begin
  // Обновление данных, при котором не возникает события AfterScroll
  FDDataSet.DisableControls;
  try
    SaveBookmark;

    I := FPostedMessage.IndexOf(WM_DS_AFTER_SCROLL);
    Assert(I < 0);
    // Как будто предыдущее сообщение AfterScroll уже послали
    FPostedMessage.Add(WM_DS_AFTER_SCROLL);

    // Заново выполняем запрос
    RefreshQuery;

    OK := RestoreBookmark;

    // Если старой записи не существует
    if not OK then
    begin
      // Как будто предыдущее сообщение AfterScroll ещё не посылали
      FPostedMessage.Remove(WM_DS_AFTER_SCROLL);

      // Искусственно вызываем событие AfterScroll
      AfterDataSetScroll(DataSet);
    end;

  finally
    // Тут визуальные компоненты DevExpress начнут загрузку данных и будут делать Scroll
    FDDataSet.EnableControls;
  end;

  if OK then
    // Как будто предыдущее сообщение AfterScroll ещё послали
    FPostedMessage.Remove(WM_DS_AFTER_SCROLL);
end;

procedure TDSWrap.TryAppend;
begin
  Assert(FDataSet.Active);

  if not(FDataSet.State in [dsEdit, dsInsert]) then
    FDataSet.Append;
end;

procedure TDSWrap.TryCancel;
begin
  Assert(FDataSet.Active);

  if FDataSet.State in [dsEdit, dsInsert] then
    FDataSet.Cancel;
end;

function TDSWrap.TryEdit: Boolean;
begin
  Assert(FDataSet.Active);

  Result := False;
  if FDataSet.State in [dsEdit, dsInsert] then
    Exit;

  Assert(FDataSet.RecordCount > 0);
  FDataSet.Edit;
  Result := True;
end;

function TDSWrap.TryLocate(AFields: TArray<String>;
  AValues: TArray<Variant>): Integer;
var
  AKeyFields: string;
  ALength: Integer;
  Arr: Variant;
  J: Integer;
  OK: Boolean;
begin
  Assert(Length(AFields) > 0);
  Assert(Length(AValues) > 0);
  Assert(Length(AFields) = Length(AValues));

  for ALength := Length(AValues) downto 1 do
  begin
    Result := ALength;
    AKeyFields := '';
    // Создаём вариантный массив
    Arr := VarArrayCreate([0, ALength - 1], varVariant);

    for J := 0 to ALength - 1 do
    begin
      AKeyFields := AKeyFields + IfThen(AKeyFields.IsEmpty, '', ';') +
        AFields[J];
      Arr[J] := AValues[J];
    end;

    OK := FDDataSet.LocateEx(AKeyFields, Arr, []);

    VarClear(Arr);

    if OK then
      Exit;
  end;
  Result := 0;
end;

procedure TDSWrap.TryOpen;
begin
  if not FDataSet.Active then
    FDataSet.Open;
end;

procedure TDSWrap.TryPost;
begin
  Assert(FDataSet.Active);

  if FDataSet.State in [dsEdit, dsInsert] then
    FDataSet.Post;
end;

procedure TDSWrap.UpdateFields;
var
  F: TField;
  FList: TList<TField>;
  PW: TParamWrap;
  FW: TFieldWrap;
begin
  DataSet.DisableControls;
  try
    FList := TList<TField>.Create;
    try

      // Показываем только те, у которых есть DisplayLabel
      for PW in FFields do
      begin
        if not(PW is TFieldWrap) then
          continue;

        FW := PW as TFieldWrap;

        F := FDataSet.FindField(FW.FieldName);
        if F = nil then
          continue;

        FList.Add(F);

        if not FW.DisplayLabel.IsEmpty then
        begin
          F.DisplayLabel := FW.DisplayLabel;
          F.Visible := True;
        end
        else
          F.Visible := False;
      end;

      // Остальные поля прячем
      for F in DataSet.Fields do
      begin
        if FList.IndexOf(F) < 0 then
          F.Visible := False;
      end;

    finally
      FreeAndNil(FList);
    end;
  finally
    DataSet.EnableControls;
  end;
end;

function TDSWrap.UpdateRecord(ARecordHolder: TRecordHolder): Boolean;
var
  AChangedFields: TDictionary<String, Variant>;
  AFieldHolder: TFieldHolder;
  AFieldName: string;
  F: TField;
begin
  Assert(ARecordHolder <> nil);

  // Создаём словарь тех полей что нужно будет обновить
  AChangedFields := TDictionary<String, Variant>.Create;
  try

    for F in DataSet.Fields do
    begin
      // Первичный ключ обновлять не будем
      if F.FieldName.ToUpper = PKFieldName.ToUpper then
        continue;

      // Ищем такое поле в коллекции обновляемых значений
      AFieldHolder := ARecordHolder.Find(F.FieldName);

      // Запоминаем в словаре какое поле нужно будет обновить
      if (AFieldHolder <> nil) and (F.Value <> AFieldHolder.Value) then
        AChangedFields.Add(F.FieldName, AFieldHolder.Value);
    end;

    Result := AChangedFields.Count > 0;

    // Если есть те поля, которые нужно обновлять
    if Result then
    begin
      TryEdit;
      try
        // Цикл по всем изменившимся полям
        for AFieldName in AChangedFields.Keys do
        begin
          Field(AFieldName).Value := AChangedFields[AFieldName];
        end;
        TryPost;
      except
        TryCancel;
        raise;
      end;
    end;

  finally
    FreeAndNil(AChangedFields);
  end;
end;

constructor TFieldWrap.Create(ADataSetWrap: TDSWrap; const AFullName: String;
  const ADisplayLabel: string = ''; APrimaryKey: Boolean = False);
begin
  inherited Create(ADataSetWrap, AFullName);

  FDisplayLabel := ADisplayLabel;

  if APrimaryKey then
  begin
    Assert(ADataSetWrap.PKFieldName = '');
    ADataSetWrap.PKFieldName := FFieldName;
  end;
end;

function TFieldWrap.GetF: TField;
begin
  Result := FDataSetWrap.Field(FFieldName);
end;

function TFieldWrap.Locate(AValue: Variant; AOptions: TFDDataSetLocateOptions;
  TestResult: Boolean = False): Boolean;
begin
  Result := FDataSetWrap.FDDataSet.LocateEx(FieldName, AValue, AOptions);
  if TestResult then
  begin
    Assert(Result);
  end;
end;

function TFieldWrap.AllValues(const ADelimiter: String = ',';
  AUnique: Boolean = False): String;
var
  AClone: TFDMemTable;
  AValue: string;
  L: TList<String>;
  OK: Boolean;
begin
  Assert(not ADelimiter.IsEmpty);

  Result := '';
  if AUnique then
    L := TList<String>.Create;

  // Создаём клона
  AClone := TFDMemTable.Create(DataSetWrap);
  try
    AClone.CloneCursor(DataSetWrap.FDDataSet);
    AClone.BeginBatch();
    try
      AClone.First;
      while not AClone.Eof do
      begin

        AValue := AClone.FieldByName(FieldName).AsString;

        OK := AValue <> '';

        if OK and AUnique then
        begin
          OK := L.IndexOf(AValue) < 0;
          if OK then
            L.Add(AValue);
        end;

        if OK then
          Result := IfThen(Result.IsEmpty, '', Result + ADelimiter) + AValue;
        AClone.Next;
      end;
    finally
      AClone.EndBatch;
    end;
  finally
    FreeAndNil(AClone);
    if AUnique then
      FreeAndNil(L);
  end;
end;

function TFieldWrap.AsIntArray(AUnique: Boolean = False): TArray<Integer>;
var
  A: TArray<String>;
  I: Integer;
begin
  A := AllValues(',', AUnique).Split([',']);
  SetLength(Result, Length(A));
  for I := Low(A) to High(A) do
    Result[I] := A[I].ToInteger();
end;

constructor TParamWrap.Create(ADataSetWrap: TDSWrap; const AFullName: String);
var
  p: Integer;
begin
  inherited Create;

  Assert(ADataSetWrap <> nil);
  Assert(not AFullName.IsEmpty);

  FDataSetWrap := ADataSetWrap;
  FDataSetWrap.Fields.Add(Self);

  FFullName := AFullName;

  p := AFullName.IndexOf('.');

  // Если имя поля содержит точку - всё что до точки - имя таблицы
  if p > 0 then
  begin
    FTableName := AFullName.Substring(0, p);
    FFieldName := AFullName.Substring(p + 1);
  end
  else
  begin
    FTableName := '';
    FFieldName := AFullName;
  end;

  // Значение для поля "по умолчанию"
  FDefaultValue := NULL;
end;

end.
