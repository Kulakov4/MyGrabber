unit ParserManager;

interface

uses
  System.Classes, ParserInterface, PageParserInterface, DSWrap, NotifyEvents,
  MSHTML;

type
  TNotifyObj = class(TObject)
  private
    FURL: string;
  protected
  public
    property URL: string read FURL;
  end;

  TParserManager = class(TComponent)
  private
    FOnParseComplete: TNotifyEventsEx;
    FAfterParse: TNotifyEventsEx;
    FBeforeLoad: TNotifyEventsEx;
    FNotifyObj: TNotifyObj;
    FPageParser: IPageParser;
    FParser: IParser;
    function GetOnParseComplete: TNotifyEventsEx;
    function GetAfterParse: TNotifyEventsEx;
    function GetBeforeLoad: TNotifyEventsEx;
    procedure Main(const AURL: String; AParentID: Integer);
    procedure NotifyAfterParse(AURL: string);
    procedure NotifyBeforeLoad;
    procedure OnThreadTerminate(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AURL: String; AParser: IParser;
      APageParser: IPageParser; AParentID: Integer); reintroduce;
    destructor Destroy; override;
    property OnParseComplete: TNotifyEventsEx read GetOnParseComplete;
    property AfterParse: TNotifyEventsEx read GetAfterParse;
    property BeforeLoad: TNotifyEventsEx read GetBeforeLoad;
  end;

implementation

uses
  MyHTMLLoader, WebLoader, System.SysUtils, System.Variants, Winapi.ActiveX,
  System.Win.ComObj, Vcl.Forms;

constructor TParserManager.Create(AOwner: TComponent; AURL: String;
  AParser: IParser; APageParser: IPageParser; AParentID: Integer);
var
  myThread: TThread;
begin
  inherited Create(AOwner);
  Assert(AURL.Length > 0);
  Assert(AParentID > 0);
  FParser := AParser;
  FPageParser := APageParser;

  myThread := TThread.CreateAnonymousThread(
    procedure
    begin
      Main(AURL, AParentID);
    end);
  myThread.OnTerminate := OnThreadTerminate;
  myThread.FreeOnTerminate := True;
  myThread.Start;
end;

destructor TParserManager.Destroy;
begin
  inherited;
  if FOnParseComplete <> nil then
    FreeAndNil(FOnParseComplete);

  if FBeforeLoad <> nil then
    FreeAndNil(FBeforeLoad);

  if FAfterParse <> nil then
    FreeAndNil(FAfterParse);
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

procedure TParserManager.Main(const AURL: String; AParentID: Integer);
var
  AHTML: WideString;
  AHTMLDocument: IHTMLDocument2;
  ANextPageAvailable: Boolean;
  APageURL: String;
  V: Variant;
begin
  Assert(not AURL.IsEmpty);
  Assert(AParentID > 0);

  APageURL := AURL;
  // Цикл по всем страницам HTML документов
  repeat
    // Извещаем главный поток о том, что сейчас будет загрузка HTML документа
    TThread.Synchronize(TThread.CurrentThread,
      procedure()
      begin
        NotifyBeforeLoad;
      end);

    // Загружаем страницу
    AHTML := TWebDM.Instance.Load(APageURL);

    // Формируем HTML документ
    CoInitialize(nil);
    AHTMLDocument := coHTMLDocument.Create as IHTMLDocument2;
    try
      V := VarArrayCreate([0, 0], VarVariant);
      V[0] := AHTML; // присваиваем 0 элементу массива строку с html

      // пишем в интерфейс
      AHTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));

      // парсим наш HTML докумет на наличие категорий
      FParser.Parse(APageURL, AHTMLDocument, AParentID);

      // Извещаем главный поток о том, что парсинг документа закончен
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          NotifyAfterParse(APageURL);
        end);

      ANextPageAvailable := False;

      if Assigned(FPageParser) then
        // Парсим эту страницу на наличие ссылки на следующую страницу
        ANextPageAvailable := FPageParser.Parse(AHTMLDocument, APageURL);

    finally
      AHTMLDocument := nil;
      CoInitialize(nil);
    end;
  until not ANextPageAvailable;
end;

procedure TParserManager.NotifyAfterParse(AURL: string);
begin
  if FAfterParse = nil then
    Exit;

  if FNotifyObj = nil then
    FNotifyObj := TNotifyObj.Create;

  FNotifyObj.FURL := AURL;
  FAfterParse.CallEventHandlers(FNotifyObj);
end;

procedure TParserManager.NotifyBeforeLoad;
begin
  if FBeforeLoad <> nil then
    FBeforeLoad.CallEventHandlers(Self);
end;

procedure TParserManager.OnThreadTerminate(Sender: TObject);
begin
  if FOnParseComplete <> nil then
    FOnParseComplete.CallEventHandlers(Self);
end;

end.
