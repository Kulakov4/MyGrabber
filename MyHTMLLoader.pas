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
  // ��������� HTML ��������
  AHTML := AWebLoader.Load(AURL);

  // ������� ���������� ������
  V := VarArrayCreate([0, 0], VarVariant);
  V[0] := AHTML; // ����������� 0 �������� ������� ������ � html

  // ����� � ���������
  AHTMLDocument.Write(PSafeArray(System.TVarData(V).VArray));
  { ���, ������ �������� ����� ������������ ��� ������ MSHTML }
end;

end.
