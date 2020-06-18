unit ProductListParser;

interface

uses
  FireDAC.Comp.Client, MSHTML, ProductListDataSet, System.Classes,
  ParserInterface, DSWrap;

type
  TProductListParser = class(TComponent, IParser)
  strict private
  private
    FProductListDS: TProductListDS;
    function GetW: TDSWrap;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
      AParentID: Integer);
    property W: TDSWrap read GetW;
  end;

implementation

uses
  MyHTMLParser, URLHelper;

constructor TProductListParser.Create(AOwner: TComponent);
begin
  inherited;
  FProductListDS := TProductListDS.Create(Self);
end;

function TProductListParser.GetW: TDSWrap;
begin
  Result := FProductListDS.W;
end;

procedure TProductListParser.Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
  AParentID: Integer);
var
  A: TArray<IHTMLElement>;
  AHTMLAnchorElement: IHTMLAnchorElement;
  AHTMLElement: IHTMLElement;
  B: TArray<IHTMLElement>;
  C: TArray<IHTMLElement>;
begin
  FProductListDS.EmptyDataSet;
  A := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV',
    'row subcategory-list-row', 1);

  A := TMyHTMLParser.Parse(A[0].all as IHTMLElementCollection, 'DIV',
    'product-teaser__text-container');
  for AHTMLElement in A do
  begin
    // Дочерним элементом должна быть ссылка
    AHTMLAnchorElement := AHTMLElement.parentElement as IHTMLAnchorElement;

    B := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection, 'SPAN',
      'product-teaser__headline', 1);

    C := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection, 'SPAN',
      'product-teaser__info', 1);

    with FProductListDS.W do
    begin
      TryAppend;
      ParentID.F.AsInteger := AParentID;
      HREF.F.Value := TURLHelper.GetAbsoluteURL(AURL, AHTMLAnchorElement.HREF);
      Caption.F.Value := B[0].innerText;
      ItemNumber.F.Value := C[0].innerText;
      TryPost;
    end;
  end;
end;

end.
