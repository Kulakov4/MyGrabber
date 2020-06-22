unit DownloadManagerEx;

interface

uses
  System.Classes, System.Generics.Collections, NotifyEvents, System.Threading,
  System.SyncObjs;

type
  TDownloadError = class
  private
    FErrorMessage: String;
    FFileName: String;
    FURL: String;
  public
    constructor Create(const AURL, AFileName, AErrorMessage: string);
    property ErrorMessage: String read FErrorMessage;
    property FileName: String read FFileName;
    property URL: String read FURL;
  end;

  TDMRec = record
    URL: String;
    FileName: String;
  public
    constructor Create(const AURL, AFileName: String);
  end;

  TDownloadManagerEx = class(TComponent)
  private
    FTaskList: TList<ITask>;
    FOnDownloadComplete: TNotifyEventsEx;
    FCompletedTaskList: TList<ITask>;
    FErrorList: TThreadList<TDownloadError>;
    FID: Integer;
    FOnError: TNotifyEventsEx;
    function CreateTask(const AURL, AFileName: String;
      ATaskIndex: Integer): ITask;
    procedure DoOnDownloadComplete(ATaskIndex: Integer);
    procedure DoOnError(ATaskIndex, AErrorIndex: Integer);
    procedure FreeErrors;
    function GetOnDownloadComplete: TNotifyEventsEx;
    function GetDownloading: Boolean;
    function GetOnError: TNotifyEventsEx;
    procedure Main(const AURL, AFileName: String; ATaskIndex: Integer);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure StartDownload(AID: Integer; ADMRecs: TArray<TDMRec>);
    property ID: Integer read FID;
    property Downloading: Boolean read GetDownloading;
    property OnDownloadComplete: TNotifyEventsEx read GetOnDownloadComplete;
    property OnError: TNotifyEventsEx read GetOnError;
  end;

implementation

uses
  System.SysUtils, WebLoader2;

constructor TDownloadManagerEx.Create(AOwner: TComponent);
begin
  inherited;
  FTaskList := TList<ITask>.Create;
  FCompletedTaskList := TList<ITask>.Create;
  FErrorList := TThreadList<TDownloadError>.Create;
end;

destructor TDownloadManagerEx.Destroy;
begin
  FreeAndNil(FTaskList);
  FreeAndNil(FCompletedTaskList);

  FreeErrors;

  FreeAndNil(FErrorList);
  inherited;
end;

function TDownloadManagerEx.CreateTask(const AURL, AFileName: String;
  ATaskIndex: Integer): ITask;
begin
  Result := TTask.Create(
    procedure
    begin
      Main(AURL, AFileName, ATaskIndex);
    end);
end;

procedure TDownloadManagerEx.DoOnDownloadComplete(ATaskIndex: Integer);
begin
  Assert(ATaskIndex >= 0);
  Assert(ATaskIndex < FTaskList.Count);

  FCompletedTaskList.Add(FTaskList[ATaskIndex]);

  // Извещаем, что загрузка всех файлов закончена
  if (FCompletedTaskList.Count = FTaskList.Count) then
  begin
    TTask.WaitForAll(FCompletedTaskList.ToArray);
    FTaskList.Clear;
    FCompletedTaskList.Clear;

    if (FOnDownloadComplete <> nil) then
      FOnDownloadComplete.CallEventHandlers(Self);
  end;
end;

procedure TDownloadManagerEx.DoOnError(ATaskIndex, AErrorIndex: Integer);
var
  ADownloadError: TDownloadError;
  AErrors: TList<TDownloadError>;
begin
  Assert(AErrorIndex >= 0);

  // Извещаем о том, что произошла ошибка
  if (FOnError <> nil) then
  begin
    AErrors := FErrorList.LockList;
    try
      Assert(AErrorIndex < AErrors.Count);
      ADownloadError := AErrors[AErrorIndex];
      FOnError.CallEventHandlers(ADownloadError);
    finally
      FErrorList.UnlockList;
    end;
  end;

  DoOnDownloadComplete(ATaskIndex);
end;

procedure TDownloadManagerEx.FreeErrors;
var
  ADownloadError: TDownloadError;
  AList: TList<TDownloadError>;
  I: Integer;
begin
  AList := FErrorList.LockList;
  try
    for I := AList.Count - 1 downto 0 do
    begin
      ADownloadError := AList[I];
      FErrorList.Remove(ADownloadError);
      FreeAndNil(ADownloadError);
    end;
  finally
    FErrorList.UnlockList;
  end;
end;

function TDownloadManagerEx.GetOnDownloadComplete: TNotifyEventsEx;
begin
  if FOnDownloadComplete = nil then
    FOnDownloadComplete := TNotifyEventsEx.Create(Self);

  Result := FOnDownloadComplete;
end;

function TDownloadManagerEx.GetDownloading: Boolean;
begin
  Result := FTaskList.Count > 0;
end;

function TDownloadManagerEx.GetOnError: TNotifyEventsEx;
begin
  if FOnError = nil then
    FOnError := TNotifyEventsEx.Create(Self);

  Result := FOnError;
end;

procedure TDownloadManagerEx.Main(const AURL, AFileName: String;
ATaskIndex: Integer);
var
  ADownloadError: TDownloadError;
  AErrorIndex: Integer;
  ALoader: TWebLoader2;
  AMemoryStream: TMemoryStream;
begin
  try
    ALoader := TWebLoader2.Create(nil);
    try
      AMemoryStream := TMemoryStream.Create;
      try
        // Загружаем файл в память
        ALoader.Load(AURL, AMemoryStream);
        // Сохраняем данные в файл
        AMemoryStream.SaveToFile(AFileName);
      finally
        FreeAndNil(AMemoryStream);
      end;
    finally
      FreeAndNil(ALoader);

      TThread.Queue(nil,
        procedure
        begin
          DoOnDownloadComplete(ATaskIndex)
        end);
    end;
  except
    on E: Exception do
    begin
      // Запоминаем ошибку
      ADownloadError := TDownloadError.Create(AURL, AFileName, E.Message);
      // Добавляем её в список ошибок
      FErrorList.Add(ADownloadError);
      AErrorIndex := FErrorList.LockList.Count - 1;
      FErrorList.UnlockList;

      TThread.Synchronize(nil,
        procedure
        begin
          DoOnError(ATaskIndex, AErrorIndex);
        end);

    end;
  end;
end;

procedure TDownloadManagerEx.StartDownload(AID: Integer;
ADMRecs: TArray<TDMRec>);
var
  ATask: ITask;
  I: Integer;
begin
  Assert(Length(ADMRecs) > 0);

  // Важно чтобы никакая друга загрузка не производилась
  Assert(FTaskList.Count = 0);

  FreeErrors;

  FID := AID; // Идентификатор загрузки

  for I := 0 to Length(ADMRecs) - 1 do
  begin
    ATask := CreateTask(ADMRecs[I].URL, ADMRecs[I].FileName, I);
    FTaskList.Add(ATask);
    ATask.Start;
  end;
end;

constructor TDMRec.Create(const AURL, AFileName: String);
begin
  Assert(not AURL.IsEmpty);
  Assert(not AFileName.IsEmpty);

  URL := AURL;
  FileName := AFileName;
end;

constructor TDownloadError.Create(const AURL, AFileName, AErrorMessage: string);
begin
  FURL := AURL;
  FFileName := AFileName;
  FErrorMessage := AErrorMessage;
end;

end.
