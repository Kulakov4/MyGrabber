unit PageParserInterface;

interface

uses
  MSHTML;

type
  IPageParser = interface(IInterface)
  ['{F5B57ADA-F210-4101-89E6-B778199ECB69}']
    function Parse(AHTMLDocument: IHTMLDocument2; var AURL: string): Boolean;
  end;

implementation

end.
