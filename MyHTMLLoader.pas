unit MyHTMLLoader;

interface

uses
  System.Classes, MSHTML, WebLoaderInterface;

type
  TMyHTMLRec = record
    URL:  String;
    HTMLDocument: IHTMLDocument2;
  end;

  TMyHTMLLoader = class(TComponent)
  private
  public
    class function Load(AURL: WideString; AWebLoader: IWebLoader): TMyHTMLRec;
        static;
  end;

implementation

uses
  System.Variants, Winapi.ActiveX;

class function TMyHTMLLoader.Load(AURL: WideString; AWebLoader: IWebLoader):
    TMyHTMLRec;
var
  AHTML: WideString;
  V: Variant;
begin
  // Загружаем HTML страницу
  AHTML := AWebLoader.Load(AURL);

  // Создаем вариантный массив
  V := VarArrayCreate([0, 0], VarVariant);
  V[0] := AHTML; // присваиваем 0 элементу массива строку с html

  Result.URL := AURL;

  // Создаем интерфейс
  Result.HTMLDocument := coHTMLDocument.Create as IHTMLDocument2;

  // пишем в интерфейс
  Result.HTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));
  { все, теперь страницу можно обрабатывать при помощи MSHTML }
end;

end.
