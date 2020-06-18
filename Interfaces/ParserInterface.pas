unit ParserInterface;

interface

uses
  DSWrap, MSHTML;

type
  IParser = interface(IInterface)
  ['{E263796E-1ACF-4BF9-A5B6-40D0BA72D537}']
    function GetW: TDSWrap;
    procedure Parse(AURL: string; AHTMLDocument: IHTMLDocument2; AParentID:
        Integer);
    property W: TDSWrap read GetW;
  end;

implementation

end.
