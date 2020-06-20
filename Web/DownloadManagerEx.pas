unit DownloadManagerEx;

interface

uses
  System.Classes, System.Generics.Collections, NotifyEvents, System.Threading;

type
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
    FID: Integer;
    function CreateTask(const AURL, AFileName: String;
      ATaskIndex: Integer): ITask;
    procedure DoOnDownloadComplete(ATaskIndex: Integer);
    function GetOnDownloadComplete: TNotifyEventsEx;
    function GetDownloading: Boolean;
    procedure Main(const AURL, AFileName: String; ATaskIndex: Integer);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure StartDownload(AID: Integer; ADMRecs: TArray<TDMRec>);
    property ID: Integer read FID;
    property Downloading: Boolean read GetDownloading;
    property OnDownloadComplete: TNotifyEventsEx read GetOnDownloadComplete;
  end;

implementation

uses
  System.SysUtils, WebLoader2;

constructor TDownloadManagerEx.Create(AOwner: TComponent);
begin
  inherited;
  FTaskList := TList<ITask>.Create;
  FCompletedTaskList := TList<ITask>.Create;
end;

destructor TDownloadManagerEx.Destroy;
begin
  FreeAndNil(FTaskList);
  FreeAndNil(FCompletedTaskList);
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

procedure TDownloadManagerEx.Main(const AURL, AFileName: String;
ATaskIndex: Integer);
var
  ALoader: TWebLoader2;
  AMemoryStream: TMemoryStream;
begin
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
end;

procedure TDownloadManagerEx.StartDownload(AID: Integer; ADMRecs:
    TArray<TDMRec>);
var
  ATask: ITask;
  i: Integer;
begin
  Assert(Length(ADMRecs) > 0);

  // Важно чтобы никакая друга загрузка не производилась
  Assert(FTaskList.Count = 0);

  FID := AID; // Идентификатор загрузки

  for i := 0 to Length(ADMRecs) - 1 do
  begin
    ATask := CreateTask(ADMRecs[i].URL, ADMRecs[i].FileName, i);
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

end.
