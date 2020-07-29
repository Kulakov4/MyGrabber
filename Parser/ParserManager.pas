unit ParserManager;

interface

uses
  System.Classes, ParserInterface, PageParserInterface, DSWrap, NotifyEvents,
  MSHTML, WebLoader, System.Generics.Collections, Vcl.ExtCtrls,
  System.SyncObjs, Winapi.Messages, Winapi.Windows;

const
  WM_PARSE_COMPLETE = WM_USER + 1;

type
  TNotifyObj = class(TObject)
  private
    FLogID: Integer;
    FURL: string;
  protected
  public
    property LogID: Integer read FLogID;
    property URL: string read FURL;
  end;

  TErrorNotify = class(TNotifyObj)
  private
    FErrorMessage: string;
  public
    property ErrorMessage: string read FErrorMessage;
  end;

  TParserManager = class(TComponent)
  private
    FThread: TThread;
    FOnParseComplete: TNotifyEventsEx;
    FAfterParse: TNotifyEventsEx;
    FBeforeLoad: TNotifyEventsEx;
    FErrors: TObjectList<TErrorNotify>;
    FHandle: HWND;
    FLogID: Integer;
    FParentID: Integer;
    FNotifyObj: TNotifyObj;
    FOnError: TNotifyEventsEx;
    FPageParser: IPageParser;
    FPageURL: string;
    FParser: IParser;
    FTimeOutInterval: Integer;
    FTimer: TTimer;
    FLock: TCriticalSection;
    function GetOnParseComplete: TNotifyEventsEx;
    function GetAfterParse: TNotifyEventsEx;
    function GetBeforeLoad: TNotifyEventsEx;
    function GetHandle: HWND;
    function GetOnError: TNotifyEventsEx;
    procedure Main(const AURL: String; AParentID: Integer);
    procedure NotifyAfterParse(AURL: string; ALogID: Integer);
    procedure NotifyBeforeLoad;
    procedure NotifyError(const AURL: String; ALogID: Integer;
      const AErrorMessage: String);
    procedure NotifyParseComplete;
    procedure OnThreadTerminate(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure RestartTimer;
  protected
    procedure WndProc(var Msg: TMessage); virtual;
    property Handle: HWND read GetHandle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start(const AURL: String; AParentID: Integer; AParser: IParser;
      APageParser: IPageParser);
    property OnParseComplete: TNotifyEventsEx read GetOnParseComplete;
    property OnError: TNotifyEventsEx read GetOnError;
    property AfterParse: TNotifyEventsEx read GetAfterParse;
    property BeforeLoad: TNotifyEventsEx read GetBeforeLoad;
    property Errors: TObjectList<TErrorNotify> read FErrors;
    property LogID: Integer read FLogID write FLogID;
    property ParentID: Integer read FParentID;
  end;

implementation

uses
  System.SysUtils, System.Variants, Winapi.ActiveX,
  System.Win.ComObj, Vcl.Forms, WebLoader2;

constructor TParserManager.Create(AOwner: TComponent);
begin
  inherited;
  FErrors := TObjectList<TErrorNotify>.Create;
  FTimeOutInterval := 10000;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;
  FTimer.Interval := FTimeOutInterval;

  FLock := TCriticalSection.Create;

  Randomize;
end;

destructor TParserManager.Destroy;
begin
  FreeAndNil(FLock);

  if FOnParseComplete <> nil then
    FreeAndNil(FOnParseComplete);

  if FBeforeLoad <> nil then
    FreeAndNil(FBeforeLoad);

  if FAfterParse <> nil then
    FreeAndNil(FAfterParse);

  FreeAndNil(FErrors);

  if FHandle <> 0 then
    DeallocateHWnd(FHandle);

  inherited;
end;

function TParserManager.GetOnParseComplete: TNotifyEventsEx;
begin
  if FOnParseComplete = nil then
    FOnParseComplete := TNotifyEventsEx.Create(Self);

  Result := FOnParseComplete;
end;

function TParserManager.GetAfterParse: TNotifyEventsEx;
begin
  if FAfterParse = nil then
    FAfterParse := TNotifyEventsEx.Create(Self);

  Result := FAfterParse;
end;

function TParserManager.GetBeforeLoad: TNotifyEventsEx;
begin
  if FBeforeLoad = nil then
    FBeforeLoad := TNotifyEventsEx.Create(Self);

  Result := FBeforeLoad;
end;

function TParserManager.GetHandle: HWND;
begin
  if FHandle = 0 then
    FHandle := System.Classes.AllocateHWnd(WndProc);

  Result := FHandle;
end;

function TParserManager.GetOnError: TNotifyEventsEx;
begin
  if FOnError = nil then
    FOnError := TNotifyEventsEx.Create(Self);

  Result := FOnError;
end;

procedure TParserManager.Main(const AURL: String; AParentID: Integer);
var
  AHTML: WideString;
  AHTMLDocument: IHTMLDocument2;
  ALoader: TWebLoader2;
  ANextPageAvailable: Boolean;
  r: Integer;
  // sl: TStringList;
  V: Variant;
begin
  try
    Assert(not AURL.IsEmpty);
    Assert(AParentID > 0);

    FPageURL := AURL;
    // Цикл по всем страницам HTML документов
    repeat
      // Извещаем главный поток о том, что сейчас будет загрузка HTML документа
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          NotifyBeforeLoad;
        end);

      // Формируем HTML документ
      CoInitialize(nil);

      // Загружаем страницу
      ALoader := TWebLoader2.Create(nil);
      try
        AHTML := ALoader.Load(FPageURL);
      finally
        FreeAndNil(ALoader);
      end;

      // AHTML := TWebDM.Instance.Load(FPageURL);

      // Загадываем случайное число от 0 до 2
      r := Random(3);
      if r = 10 then
        Sleep(30000); // Засыпаем на 30 секунд

      // AHTMLDocument := TWebLoaderForm.Instance.Load(APageURL);
      AHTMLDocument := coHTMLDocument.Create as IHTMLDocument2;
      try
        V := VarArrayCreate([0, 0], VarVariant);
        V[0] := AHTML; // присваиваем 0 элементу массива строку с html

        // пишем в интерфейс
        AHTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));

        // парсим наш HTML докумет на наличие категорий
        FParser.Parse(FPageURL, AHTMLDocument, AParentID);

        // Извещаем главный поток о том, что парсинг документа закончен
        TThread.Synchronize(TThread.CurrentThread,
          procedure()
          begin
            NotifyAfterParse(FPageURL, LogID);
          end);

        ANextPageAvailable := False;

        if Assigned(FPageParser) then
          // Парсим эту страницу на наличие ссылки на следующую страницу
          ANextPageAvailable := FPageParser.Parse(AHTMLDocument, FPageURL);

      finally
        AHTMLDocument := nil;
        CoInitialize(nil);
      end;
    until not ANextPageAvailable;
  except
    on E: Exception do
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          (*
            sl := TStringList.Create;
            try
            sl.Add(AHTML);
            sl.SaveToFile('error.html');
            finally
            FreeAndNil(sl);
            end;
          *)
          NotifyError(FPageURL, FLogID, E.Message);
        end);
  end;
end;

procedure TParserManager.NotifyAfterParse(AURL: string; ALogID: Integer);
begin
  // Останавливаем таймер
  FTimer.Enabled := False;

  if FAfterParse = nil then
    Exit;

  if FNotifyObj = nil then
    FNotifyObj := TNotifyObj.Create;

  FNotifyObj.FURL := AURL;
  FNotifyObj.FLogID := ALogID;
  FAfterParse.CallEventHandlers(FNotifyObj);
end;

procedure TParserManager.NotifyBeforeLoad;
begin
  RestartTimer;

  if FBeforeLoad <> nil then
    FBeforeLoad.CallEventHandlers(Self);
end;

procedure TParserManager.NotifyError(const AURL: String; ALogID: Integer;
const AErrorMessage: String);
var
  AErrorNotify: TErrorNotify;
begin
  // Останавливаем таймер
  FTimer.Enabled := False;

  AErrorNotify := TErrorNotify.Create;

  AErrorNotify.FURL := AURL;
  AErrorNotify.FLogID := ALogID;
  AErrorNotify.FErrorMessage := AErrorMessage;

  FErrors.Add(AErrorNotify);

  if FOnError = nil then
    Exit;

  FOnError.CallEventHandlers(AErrorNotify);
end;

procedure TParserManager.NotifyParseComplete;
begin
  if FOnParseComplete <> nil then
    FOnParseComplete.CallEventHandlers(Self);
end;

procedure TParserManager.OnThreadTerminate(Sender: TObject);
begin
  FLock.Acquire;
  try
    // Останавливаем таймер
    FTimer.Enabled := False;

    FThread := nil;

    PostMessage(Handle, WM_PARSE_COMPLETE, 0, 0);
  finally
    FLock.Release;
  end;
end;

procedure TParserManager.OnTimer(Sender: TObject);
var
  AExitCode: Cardinal;
begin
  FLock.Acquire;
  try
    // Останавливаем таймер
    FTimer.Enabled := False;

    // Значит поток всё же как-то завершился
    if FThread = nil then
      Exit;

    // Поток всё ещё должен выполняться

    // Мы больше не будем реагировать на окончание работы этого потока
    FThread.OnTerminate := nil;

    AExitCode := 0;
    TerminateThread(FThread.Handle, AExitCode);
    FThread := nil;

    // Сообщаем об ошибке
    NotifyError(FPageURL, FLogID, 'Обнаружено зависание');

    // Чуть позже сообщим, что поток завершился
    PostMessage(Handle, WM_PARSE_COMPLETE, 0, 0);
  finally
    FLock.Release;
  end;
end;

procedure TParserManager.RestartTimer;
begin
  FTimer.Enabled := False;
  FTimer.Enabled := True;
end;

procedure TParserManager.Start(const AURL: String; AParentID: Integer;
AParser: IParser; APageParser: IPageParser);
begin
  Assert(AURL.Length > 0);
  Assert(AParentID > 0);
  FParser := AParser;
  FPageParser := APageParser;
  FParentID := AParentID;

  FErrors.Clear; // Очищаем все ошибки

  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      Main(AURL, AParentID);
    end);
  FThread.OnTerminate := OnThreadTerminate;
  FThread.FreeOnTerminate := True;
  FThread.Start;
end;

procedure TParserManager.WndProc(var Msg: TMessage);
begin
  with Msg do
    case Msg of
      WM_PARSE_COMPLETE:  NotifyParseComplete;
    else
      DefWindowProc(FHandle, Msg, wParam, lParam);
    end;
end;

end.
