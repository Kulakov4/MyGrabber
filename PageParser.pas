unit PageParser;

interface

uses
  System.Classes, MyHTMLLoader;

type
  TPageParser = class(TComponent)
  public
    function Parse(AMyHTMLRec: TMyHTMLRec; var ANextPageURL: string): Boolean;
  end;

implementation

uses
  MyHTMLParser, MSHTML, URLHelper;

function TPageParser.Parse(AMyHTMLRec: TMyHTMLRec; var ANextPageURL: string):
    Boolean;
var
  A: TArray<IHTMLElement>;
  AHTMLAnchorElement: IHTMLAnchorElement;
begin
  Result := False;

  A := TMyHTMLParser.Parse(AMyHTMLRec.HTMLDocument.all, 'DIV', 'pagination-light');
  if Length(A) = 0 then
    Exit;

  Assert(Length(A) = 1);

  A := TMyHTMLParser.Parse(A[0].all as IHTMLElementCollection, 'A',
    'pagination-light__controls pagination-light__controls--next');

  if Length(A) = 0 then
    Exit;

  AHTMLAnchorElement := A[0] as IHTMLAnchorElement;
  Result := True;
  ANextPageURL := TURLHelper.GetAbsoluteURL(AMyHTMLRec.URL, AHTMLAnchorElement.href);
end;

end.
