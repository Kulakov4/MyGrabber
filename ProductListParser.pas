unit ProductListParser;

interface

uses
  HTMLPageParser, FireDAC.Comp.Client, MSHTML;

type
  TProductListParser = class(THTMLPageParser)
  public
    procedure Process(AHTMLDocument: IHTMLDocument2; AFDMemTable: TFDMemTable);
        override;
  end;

implementation

uses
  ProductListInfoDataSet, MyHTMLParser;

procedure TProductListParser.Process(AHTMLDocument: IHTMLDocument2;
    AFDMemTable: TFDMemTable);
var
  A: TArray<IHTMLElement>;
  AHTMLAnchorElement: IHTMLAnchorElement;
  AHTMLElement: IHTMLElement;
  B: TArray<IHTMLElement>;
  C: TArray<IHTMLElement>;
  DS: TProductListInfoDS;
begin
  DS := AFDMemTable as TProductListInfoDS;

  A := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV', 'row subcategory-list-row', 1);

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

    DS.W.TryAppend;
    DS.W.ParentID.F.AsInteger := ParentID;
    DS.W.HREF.F.Value := GetAbsoluteURL(AHTMLAnchorElement.HREF);
    DS.W.Caption.F.Value := B[0].innerText;
    DS.W.ItemNumber.F.Value := C[0].innerText;
    DS.W.TryPost;
  end;
end;

end.
