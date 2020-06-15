unit PageParser;

interface

uses
  System.Classes, PageParserInterface, MSHTML;

type
  TPageParser = class(TComponent, IPageParser)
  public
    function Parse(AHTMLDocument: IHTMLDocument2; AURL: string; var ANextPageURL:
        string): Boolean;
  end;

implementation

uses
  MyHTMLParser, URLHelper;

function TPageParser.Parse(AHTMLDocument: IHTMLDocument2; AURL: string; var
    ANextPageURL: string): Boolean;
var
  A: TArray<IHTMLElement>;
  AHTMLAnchorElement: IHTMLAnchorElement;
begin
  Result := False;

  A := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV', 'pagination-light');
  if Length(A) = 0 then
    Exit;

  Assert(Length(A) = 1);

  A := TMyHTMLParser.Parse(A[0].all as IHTMLElementCollection, 'A',
    'pagination-light__controls pagination-light__controls--next');

  if Length(A) = 0 then
    Exit;

  AHTMLAnchorElement := A[0] as IHTMLAnchorElement;
  Result := True;
  ANextPageURL := TURLHelper.GetAbsoluteURL(AURL, AHTMLAnchorElement.href);
end;

end.
