unit DownloadManagerEx;

interface

uses
  System.Classes, System.Generics.Collections, NotifyEvents, System.Threading,
  System.SyncObjs, Vcl.ExtCtrls, Winapi.Messages, Winapi.Windows;

const
  WM_DOWNLOAD_COMPLETE = WM_USER + 2;

type
  TDownloadError = class
  private
    FErrorMessage: String;
    FFileName: String;
    FID: Integer;
    FURL: String;
  public
    constructor Create(const AURL, AFileName, AErrorMessage: string;
      AID: Integer);
    property ErrorMessage: String read FErrorMessage;
    property FileName: String read FFileName;
    property ID: Integer read FID;
    property URL: String read FURL;
  end;

  TMyTask = class
  private
    FTaskID: Integer;
    FTask: ITask;
  public
    constructor Create(ATask: ITask; ATaskID: Integer);
    property TaskID: Integer read FTaskID;
    property Task: ITask read FTask;
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
    FDMRecArr: TArray<TDMRec>;
    FErrorList: TThreadList<TDownloadError>;
    FHandle: HWND;
    FID: Integer;
    FLock: TCriticalSection;
    FOnError: TNotifyEventsEx;
    FTaskIDList: TList<Integer>;
    FTimer: TTimer;
    class var FTaskID: Integer;
    function CreateTask(const AURL, AFileName: String;
      ATaskIndex, ATaskID: Integer): ITask;
    procedure DoOnDownloadComplete(ATaskIndex, ATaskID: Integer);
    procedure DoOnDownloadError(const AURL, AFileName, AErrorMessage: String;
      ATaskID: Integer);
    procedure FreeErrors;
    function GetOnDownloadComplete: TNotifyEventsEx;
    function GetDownloading: Boolean;
    function GetHandle: HWND;
    function GetOnError: TNotifyEventsEx;
    procedure Main(const AURL, AFileName: String; ATaskIndex, ATaskID: Integer);
    procedure NotifyDownloadComplete;
    procedure OnTimer(Sender: TObject);
  protected
    procedure WndProc(var Msg: TMessage); virtual;
    property Handle: HWND read GetHandle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnAllDownloadComplete;
    procedure StartDownload(AID: Integer; ADMRecs: TArray<TDMRec>);
    property ID: Integer read FID;
    property Downloading: Boolean read GetDownloading;
    property ErrorList: TThreadList<TDownloadError> read FErrorList;
    class property TaskID: Integer read FTaskID write FTaskID;
    property OnDownloadComplete: TNotifyEventsEx read GetOnDownloadComplete;
    property OnError: TNotifyEventsEx read GetOnError;
  end;

implementation

uses
  System.SysUtils, WebLoader2;

constructor TDownloadManagerEx.Create(AOwner: TComponent);
begin
  inherited;
  FLock := TCriticalSection.Create;

  FTaskList := TList<ITask>.Create;
  FCompletedTaskList := TList<ITask>.Create;
  FTaskIDList := TList<Integer>.Create;

  FErrorList := TThreadList<TDownloadError>.Create;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;
  FTimer.Interval := 10000;
end;

destructor TDownloadManagerEx.Destroy;
begin
  FreeAndNil(FTaskList);
  FreeAndNil(FCompletedTaskList);
  FreeAndNil(FTaskIDList);

  FreeErrors;

  FreeAndNil(FErrorList);

  if FHandle <> 0 then
    DeallocateHWnd(FHandle);

  FreeAndNil(FLock);

  inherited;
end;

function TDownloadManagerEx.CreateTask(const AURL, AFileName: String;
  ATaskIndex, ATaskID: Integer): ITask;
begin
  Result := TTask.Create(
    procedure
    begin
      Main(AURL, AFileName, ATaskIndex, ATaskID);
    end);
end;

procedure TDownloadManagerEx.DoOnDownloadComplete(ATaskIndex, ATaskID: Integer);
begin
  // Объект уже разрушен. А задача только завершается
  if FLock = nil then
    Exit;

  FLock.Acquire;
  try
    // Возможно мы уже запустили новые задачи, а завершилась просроченная старая
    if FTaskIDList.IndexOf(ATaskID) < 0 then
      Exit;

    Assert(ATaskIndex >= 0);
    Assert(ATaskIndex < FTaskList.Count);

    FCompletedTaskList.Add(FTaskList[ATaskIndex]);

    // Понятно, что загрузка всех файлов закончена
    if (FCompletedTaskList.Count = FTaskList.Count) then
    begin
      TTask.WaitForAll(FCompletedTaskList.ToArray);

      OnAllDownloadComplete;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TDownloadManagerEx.DoOnDownloadError(const AURL, AFileName,
  AErrorMessage: String; ATaskID: Integer);
var
  ADownloadError: TDownloadError;
begin
  // Объект уже разрушен. А задача только завершается
  if FLock = nil then
    Exit;


  FLock.Acquire;
  try
    // Если ошибка произошла в уже просроченной задаче - не регистрируем её
    if FTaskIDList.IndexOf(ATaskID) < 0 then
      Exit;

    // Запоминаем ошибку
    ADownloadError := TDownloadError.Create(AURL, AFileName,
      AErrorMessage, FID);
    // Добавляем её в список ошибок
    FErrorList.Add(ADownloadError);
  finally
    FLock.Release;
  end;
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
  FLock.Acquire;
  try
    Result := FTaskList.Count > 0;
  finally
    FLock.Release;
  end;
end;

function TDownloadManagerEx.GetHandle: HWND;
begin
  if FHandle = 0 then
    FHandle := System.Classes.AllocateHWnd(WndProc);

  Result := FHandle;
end;

function TDownloadManagerEx.GetOnError: TNotifyEventsEx;
begin
  if FOnError = nil then
    FOnError := TNotifyEventsEx.Create(Self);

  Result := FOnError;
end;

procedure TDownloadManagerEx.Main(const AURL, AFileName: String;
ATaskIndex, ATaskID: Integer);
var
  ADownloadError: TDownloadError;
  // AErrorIndex: Integer;
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

      Sleep(30000);

    finally
      FreeAndNil(ALoader);

      // Выполняем метод DoOnDownloadComplete в главном потоке,
      // а тем временем наш поток загрузки продолжает выполняться!!!
      TThread.Queue(nil,
        procedure
        begin
          DoOnDownloadComplete(ATaskIndex, ATaskID)
        end);
    end;
  except
    on E: Exception do
    begin
      DoOnDownloadError(AURL, AFileName, E.Message, ATaskID)
    end;
  end;
end;

procedure TDownloadManagerEx.NotifyDownloadComplete;
begin
  if (FOnDownloadComplete <> nil) then
    FOnDownloadComplete.CallEventHandlers(Self);
end;

procedure TDownloadManagerEx.OnAllDownloadComplete;
begin
  FTaskList.Clear;
  FCompletedTaskList.Clear;
  FTaskIDList.Clear;

  // Останавливаем таймер
  FTimer.Enabled := False;

  PostMessage(Handle, WM_DOWNLOAD_COMPLETE, 0, 0);
end;

procedure TDownloadManagerEx.OnTimer(Sender: TObject);
var
  ADownloadError: TDownloadError;
  ATask: ITask;
  I: Integer;
begin
  FLock.Acquire;
  try
    // Останавливаем таймер
    FTimer.Enabled := False;

    if (FTaskList.Count = 0) or (FCompletedTaskList.Count = FTaskList.Count)
    then
      Exit;

    Assert(Length(FDMRecArr) = FTaskList.Count);

    for I := 0 to FTaskList.Count - 1 do
    begin
      ATask := FTaskList[I];
      // Если эта задача ещё не завершилась
      if FCompletedTaskList.IndexOf(ATask) < 0 then
      begin
        // Запоминаем ошибку
        ADownloadError := TDownloadError.Create(FDMRecArr[I].URL,
          FDMRecArr[I].FileName, 'Обнаружено зависание', FID);

        // Добавляем её в список ошибок
        FErrorList.Add(ADownloadError);

        // Пытаемся отменить эту задачу
        ATask.Cancel;
      end;
    end;

    // Мы как бы всё загрузили, хоть и с ошибками
    OnAllDownloadComplete;
  finally
    FLock.Release;
  end;
end;

procedure TDownloadManagerEx.StartDownload(AID: Integer;
ADMRecs: TArray<TDMRec>);
var
  ATask: ITask;
  I: Integer;
begin
  FLock.Acquire;
  try
    Assert(Length(ADMRecs) > 0);
    FDMRecArr := ADMRecs;

    // Важно чтобы никакая друга загрузка не производилась
    Assert(FTaskList.Count = 0);
    Assert(FTaskIDList.Count = 0);

    FreeErrors;

    FID := AID; // Идентификатор загрузки

    for I := 0 to Length(ADMRecs) - 1 do
    begin
      // Увеличиваем уникальный номер задачи!!!
      Inc(FTaskID);
      ATask := CreateTask(ADMRecs[I].URL, ADMRecs[I].FileName, I, FTaskID);
      // Запоминаем эту задачу в списке запущенных задач
      FTaskList.Add(ATask);
      // Запоминаем её индекс в списке запущенных задач,
      // чтобы отличать её от старых - неактуальных
      FTaskIDList.Add(FTaskID);

      ATask.Start;
    end;

    // Перезапускаем таймер
    FTimer.Enabled := False;
    FTimer.Enabled := True;
  finally
    FLock.Release;
  end;
end;

procedure TDownloadManagerEx.WndProc(var Msg: TMessage);
begin
  with Msg do
    case Msg of
      WM_DOWNLOAD_COMPLETE:
        NotifyDownloadComplete;
    else
      DefWindowProc(FHandle, Msg, wParam, lParam);
    end;
end;

constructor TDMRec.Create(const AURL, AFileName: String);
begin
  Assert(not AURL.IsEmpty);
  Assert(not AFileName.IsEmpty);

  URL := AURL;
  FileName := AFileName;
end;

constructor TDownloadError.Create(const AURL, AFileName, AErrorMessage: string;
AID: Integer);
begin
  FURL := AURL;
  FFileName := AFileName;
  FErrorMessage := AErrorMessage;
  FID := AID;
end;

constructor TMyTask.Create(ATask: ITask; ATaskID: Integer);
begin
  Assert(ATask <> nil);
  Assert(ATaskID > 0);

  FTaskID := ATaskID;
  FTask := ATask;
end;

end.
