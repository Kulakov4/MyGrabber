unit HTMLPageParser;

interface

uses
  System.Classes, WebLoaderInterface, MSHTML, FireDAC.Comp.Client;

type
  THTMLPageParser = class(TComponent)
  private
    FParentID: Integer;
    FURL: string;
    FWebLoader: IWebLoader;
  protected
    function GetAbsoluteURL(const href: string): string;
    property ParentID: Integer read FParentID;
  public
    constructor Create(AOwner: TComponent; AWebLoader: IWebLoader); reintroduce;
    procedure Parse(const AURL: WideString; AFDMemTable: TFDMemTable; AParentID:
        Integer);
    procedure Process(AHTMLDocument: IHTMLDocument2; AFDMemTable: TFDMemTable);
        virtual;
  end;

implementation

uses
  System.Variants, Winapi.ActiveX, System.SysUtils;

constructor THTMLPageParser.Create(AOwner: TComponent; AWebLoader: IWebLoader);
begin
  inherited Create(AOwner);
  Assert(AWebLoader <> nil);
  FWebLoader := AWebLoader;
end;

function THTMLPageParser.GetAbsoluteURL(const href: string): string;
var
  i: Integer;
  S: string;
begin
  i := FURL.LastDelimiter('/');
  Assert(i > 0);
  S := FURL.Substring(0, i + 1);

  Assert(href.IndexOf('about:') = 0);
  Result := href.Replace('about:', S);
end;

procedure THTMLPageParser.Parse(const AURL: WideString; AFDMemTable:
    TFDMemTable; AParentID: Integer);
var
  AHTML: WideString;
  AHTMLDocument: IHTMLDocument2;
  V: Variant;
begin
  FParentID := AParentID;
  FURL := AURL;

  // Загружаем HTML страницу
  AHTML := FWebLoader.Load(AURL);

  // Создаем вариантный массив
  V := VarArrayCreate([0, 0], VarVariant);
  V[0] := AHTML; // присваиваем 0 элементу массива строку с html

  // Создаем интерфейс
  AHTMLDocument := coHTMLDocument.Create as IHTMLDocument2;

  // пишем в интерфейс
  AHTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));
  { все, теперь страницу можно обрабатывать при помощи MSHTML }

  // Запускаем обработку этого HTML документа
  Process(AHTMLDocument, AFDMemTable);
end;

procedure THTMLPageParser.Process(AHTMLDocument: IHTMLDocument2; AFDMemTable:
    TFDMemTable);
begin

end;

end.
