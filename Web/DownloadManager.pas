unit DownloadManager;

interface

uses
  System.Classes, NotifyEvents;

type
  TDownloadManager = class(TComponent)
  private
    FOnDownloadComplete: TNotifyEventsEx;
    function GetOnDownloadComplete: TNotifyEventsEx;
    procedure Main(const AURL, AFileName: String);
    procedure OnThreadTerminate(Sender: TObject);
  public
    destructor Destroy; override;
    procedure Download(const AURL, AFileName: String);
    property OnDownloadComplete: TNotifyEventsEx read GetOnDownloadComplete;
  end;

implementation

uses
  WebLoader, System.SysUtils;

destructor TDownloadManager.Destroy;
begin
  if FOnDownloadComplete <> nil then
    FreeAndNil(FOnDownloadComplete);

  inherited;
end;

procedure TDownloadManager.Download(const AURL, AFileName: String);
var
  myThread: TThread;
begin
  myThread := TThread.CreateAnonymousThread(
    procedure
    begin
      Main(AURL, AFileName);
    end);
  myThread.OnTerminate := OnThreadTerminate;
  myThread.FreeOnTerminate := True;
  myThread.Start;
end;

function TDownloadManager.GetOnDownloadComplete: TNotifyEventsEx;
begin
  if FOnDownloadComplete = nil then
    FOnDownloadComplete := TNotifyEventsEx.Create(Self);

  Result := FOnDownloadComplete;
end;

procedure TDownloadManager.Main(const AURL, AFileName: String);
var
  AMemoryStream: TMemoryStream;
begin
  AMemoryStream := TMemoryStream.Create;
  try
    // Загружаем файл в память
    TWebDM.Instance.Load(AURL, AMemoryStream);
    // Сохраняем данные в файл
    AMemoryStream.SaveToFile(AFileName);
  finally
    FreeAndNil(AMemoryStream);
  end;
end;

procedure TDownloadManager.OnThreadTerminate(Sender: TObject);
begin
  if FOnDownloadComplete <> nil then
    FOnDownloadComplete.CallEventHandlers(Self);
end;

end.
