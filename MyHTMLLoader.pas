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
  // ��������� HTML ��������
  AHTML := AWebLoader.Load(AURL);

  // ������� ���������� ������
  V := VarArrayCreate([0, 0], VarVariant);
  V[0] := AHTML; // ����������� 0 �������� ������� ������ � html

  Result.URL := AURL;

  // ������� ���������
  Result.HTMLDocument := coHTMLDocument.Create as IHTMLDocument2;

  // ����� � ���������
  Result.HTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));
  { ���, ������ �������� ����� ������������ ��� ������ MSHTML }
end;

end.
