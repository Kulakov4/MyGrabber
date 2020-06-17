unit CategoryParser;

interface

uses
  MSHTML, System.Generics.Collections, CategoryInfoDataSet, FireDAC.Comp.Client,
  System.Classes, WebLoaderInterface, DSWrap,
  ParserInterface;

type
  TCategoryParser = class(TComponent, IParser)
  private
    FCategoryInfoDS: TCategoryInfoDS;
    function GetW: TDSWrap;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
      AParentID: Integer);
    property W: TDSWrap read GetW;
  end;

implementation

uses
  MyHTMLParser, System.SysUtils, URLHelper;

constructor TCategoryParser.Create(AOwner: TComponent);
begin
  inherited;
  FCategoryInfoDS := TCategoryInfoDS.Create(Self);
end;

function TCategoryParser.GetW: TDSWrap;
begin
  Result := FCategoryInfoDS.W;
end;

procedure TCategoryParser.Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
  AParentID: Integer);
var
  A: TArray<IHTMLElement>;
  AHTMLElement: IHTMLElement;
  AIHTMLAnchorElement: IHTMLAnchorElement;
  B: TArray<IHTMLElement>;
  ih: WideString;
  it: WideString;
begin
  Assert(AHTMLDocument <> nil);
  Assert(not AURL.IsEmpty);

  FCategoryInfoDS.EmptyDataSet;
  A := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV', 'off-grid');
  if Length(A) = 0 then
    Exit;

  Assert(Length(A) = 1);

  A := TMyHTMLParser.Parse(A[0].all as IHTMLElementCollection, 'A',
    'category-teaser off-grid__item');
  for AHTMLElement in A do
  begin
    B := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection, 'P',
      'category-teaser__title', 1);

    ih := B[0].innerHTML;
    it := B[0].innerText;

    AIHTMLAnchorElement := AHTMLElement as IHTMLAnchorElement;

    with FCategoryInfoDS.W do
    begin
      TryAppend;
      ParentID.F.AsInteger := AParentID;
      HREF.F.Value := TURLHelper.GetAbsoluteURL(AURL, AIHTMLAnchorElement.HREF);
      Caption.F.Value := B[0].innerText;
      TryPost;
    end;
  end;
end;

end.
