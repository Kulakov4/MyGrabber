unit ParserManager;

interface

uses
  System.Classes, ParserInterface, PageParserInterface, DSWrap, NotifyEvents,
  MSHTML;

type
  TParserManager = class(TComponent)
  private
    FDSWrap: TDSWrap;
    FHTML: WideString;
    FIndex: Integer;
    FOnParseComplete: TNotifyEventsEx;
    FPageParser: IPageParser;
    FParentID: Integer;
    FParser: IParser;
    FURL: string;
    FURLs: TArray<String>;
    procedure CreateParserThread;
    procedure CreateWebLoaderThread(AURL: string);
    function GetOnParseComplete: TNotifyEventsEx;
    procedure OnParserTerminate(Sender: TObject);
    procedure OnWebLoaderTerminate(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AURLs: TArray<String>;
      AParser: IParser; APageParser: IPageParser; ADSWrap: TDSWrap;
      AParentID: Integer); reintroduce;
    destructor Destroy; override;
    property OnParseComplete: TNotifyEventsEx read GetOnParseComplete;
  end;

implementation

uses
  MyHTMLLoader, WebLoader, System.SysUtils, System.Variants, Winapi.ActiveX,
  System.Win.ComObj, Vcl.Forms;

procedure TParserManager.CreateWebLoaderThread(AURL: string);
var
  myThread: TThread;
begin
  FURL := AURL;
  myThread := TThread.CreateAnonymousThread(
    procedure
    begin
      // Загружаем страницу и формируем HTML документ
      FHTML := TWebDM.Instance.Load(AURL);
    end);
  myThread.OnTerminate := OnWebLoaderTerminate;
  myThread.FreeOnTerminate := True;
  myThread.Start;
end;

procedure TParserManager.OnWebLoaderTerminate(Sender: TObject);
begin
  CreateParserThread;
end;

constructor TParserManager.Create(AOwner: TComponent; AURLs: TArray<String>;
AParser: IParser; APageParser: IPageParser; ADSWrap: TDSWrap;
AParentID: Integer);
begin
  inherited Create(AOwner);
  Assert(Length(AURLs) > 0);
  FURLs := AURLs;
  FIndex := 0;
  FParser := AParser;
  FPageParser := APageParser;
  FParentID := AParentID;
  FDSWrap := ADSWrap;
  CreateWebLoaderThread(FURLs[FIndex]);
end;

destructor TParserManager.Destroy;
begin
  inherited;
  if FOnParseComplete <> nil then
    FreeAndNil(FOnParseComplete);
end;

procedure TParserManager.CreateParserThread;
var
  AHTMLDocument: IHTMLDocument2;
  myThread: TThread;
  V: Variant;
begin
  Assert(not FURL.IsEmpty);

  myThread := TThread.CreateAnonymousThread(
    procedure
    begin
      CoInitialize(nil);
      AHTMLDocument := coHTMLDocument.Create as IHTMLDocument2;
      try
        V := VarArrayCreate([0, 0], VarVariant);
        V[0] := FHTML; // присваиваем 0 элементу массива строку с html

        // пишем в интерфейс
        AHTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));

        // парсим наш HTML докумет на наличие категорий
        FParser.Parse(FURL, AHTMLDocument, FParentID);
      finally
        AHTMLDocument := nil;
        CoInitialize(nil);
      end;
    end);
  myThread.OnTerminate := OnParserTerminate;
  myThread.FreeOnTerminate := True;
  myThread.Start;
end;

function TParserManager.GetOnParseComplete: TNotifyEventsEx;
begin
  if FOnParseComplete = nil then
    FOnParseComplete := TNotifyEventsEx.Create(Self);

  Result := FOnParseComplete;
end;

procedure TParserManager.OnParserTerminate(Sender: TObject);
var
  AURL: string;
  ANextPageAvailable: Boolean;
begin
  Assert(not FURL.IsEmpty);

  // Добавляем записи, которые парсер нам напарсил
  FDSWrap.AppendFrom(FParser.W);

  ANextPageAvailable := False;

{
  if Assigned(FPageParser) then
    // Парсим эту страницу на наличие ссылки на следующую страницу
    ANextPageAvailable := FPageParser.Parse(FHTMLDocument, FURL, AURL);
}
  // Если доступна ещё одна страница
  if ANextPageAvailable then
    CreateWebLoaderThread(AURL)
  else
  begin
    // Если обработали все ссылки
    if FIndex >= Length(FURLs) - 1 then
    begin
      if FOnParseComplete <> nil then
        FOnParseComplete.CallEventHandlers(Self);
    end
    else
    begin
      Inc(FIndex);
      CreateWebLoaderThread(FURLs[FIndex]);
    end;
  end;
end;

end.
