unit ParserManager;

interface

uses
  System.Classes, ParserInterface, PageParserInterface, DSWrap, NotifyEvents,
  MSHTML, WebLoader, System.Generics.Collections;

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
    FLogID: Integer;
    FParentID: Integer;
    FNotifyObj: TNotifyObj;
    FOnError: TNotifyEventsEx;
    FPageParser: IPageParser;
    FParser: IParser;
    function GetOnParseComplete: TNotifyEventsEx;
    function GetAfterParse: TNotifyEventsEx;
    function GetBeforeLoad: TNotifyEventsEx;
    function GetOnError: TNotifyEventsEx;
    procedure Main(const AURL: String; AParentID: Integer);
    procedure NotifyAfterParse(AURL: string; ALogID: Integer);
    procedure NotifyBeforeLoad;
    procedure NotifyError(const AURL: String; ALogID: Integer;
      const AErrorMessage: String);
    procedure OnThreadTerminate(Sender: TObject);
  protected
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
  System.Win.ComObj, Vcl.Forms, WebLoader3;

constructor TParserManager.Create(AOwner: TComponent);
begin
  inherited;
  FErrors := TObjectList<TErrorNotify>.Create;
end;

destructor TParserManager.Destroy;
begin
  if FOnParseComplete <> nil then
    FreeAndNil(FOnParseComplete);

  if FBeforeLoad <> nil then
    FreeAndNil(FBeforeLoad);

  if FAfterParse <> nil then
    FreeAndNil(FAfterParse);

  FreeAndNil(FErrors);
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
  ANextPageAvailable: Boolean;
  APageURL: String;
  sl: TStringList;
  V: Variant;
begin
  try
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

      // Формируем HTML документ
      CoInitialize(nil);

      // Загружаем страницу
      AHTML := TWebDM.Instance.Load(APageURL);
      // AHTMLDocument := TWebLoaderForm.Instance.Load(APageURL);
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
            NotifyAfterParse(APageURL, LogID);
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
  except
    on E: Exception do
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin

          sl := TStringList.Create;
          try
            sl.Add(AHTML);
            sl.SaveToFile('error.html');
          finally
            FreeAndNil(sl);
          end;

          NotifyError(APageURL, LogID, E.Message);
        end);
  end;
end;

procedure TParserManager.NotifyAfterParse(AURL: string; ALogID: Integer);
begin
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
  if FBeforeLoad <> nil then
    FBeforeLoad.CallEventHandlers(Self);
end;

procedure TParserManager.NotifyError(const AURL: String; ALogID: Integer;
const AErrorMessage: String);
var
  AErrorNotify: TErrorNotify;
begin
  AErrorNotify := TErrorNotify.Create;

  AErrorNotify.FURL := AURL;
  AErrorNotify.FLogID := ALogID;
  AErrorNotify.FErrorMessage := AErrorMessage;

  FErrors.Add(AErrorNotify);

  if FOnError = nil then
    Exit;

  FOnError.CallEventHandlers(AErrorNotify);
end;

procedure TParserManager.OnThreadTerminate(Sender: TObject);
begin
  if FOnParseComplete <> nil then
    FOnParseComplete.CallEventHandlers(Self);

  FThread := nil;
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

end.
