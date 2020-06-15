unit MyHTMLLoader;

interface

uses
  System.Classes, MSHTML, WebLoaderInterface;

type
  TMyHTMLLoader = class(TComponent)
  private
  public
    class procedure Load(AURL: WideString; AWebLoader: IWebLoader; AHTMLDocument:
        IHTMLDocument2); static;
  end;

implementation

uses
  System.Variants, Winapi.ActiveX;

class procedure TMyHTMLLoader.Load(AURL: WideString; AWebLoader: IWebLoader;
    AHTMLDocument: IHTMLDocument2);
var
  AHTML: WideString;
  V: Variant;
begin
  Assert(AHTMLDocument <> nil);
  // «агружаем HTML страницу
  AHTML := AWebLoader.Load(AURL);

  // —оздаем вариантный массив
  V := VarArrayCreate([0, 0], VarVariant);
  V[0] := AHTML; // присваиваем 0 элементу массива строку с html

  // пишем в интерфейс
  AHTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));
  { все, теперь страницу можно обрабатывать при помощи MSHTML }
end;

end.
