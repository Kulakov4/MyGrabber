unit ProductListParser;

interface

uses
  FireDAC.Comp.Client, MSHTML, MyHTMLLoader, ProductListInfoDataSet,
  System.Classes;

type
  TProductListParser = class(TComponent)
  public
    procedure Parse(AMyHTMLRec: TMyHTMLRec; AProductListInfoDS: TProductListInfoDS;
        AParentID: Integer);
  end;

implementation

uses
  MyHTMLParser, URLHelper;

procedure TProductListParser.Parse(AMyHTMLRec: TMyHTMLRec; AProductListInfoDS:
    TProductListInfoDS; AParentID: Integer);
var
  A: TArray<IHTMLElement>;
  AHTMLAnchorElement: IHTMLAnchorElement;
  AHTMLElement: IHTMLElement;
  B: TArray<IHTMLElement>;
  C: TArray<IHTMLElement>;
begin
  A := TMyHTMLParser.Parse(AMyHTMLRec.HTMLDocument.all, 'DIV', 'row subcategory-list-row', 1);

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

    AProductListInfoDS.W.TryAppend;
    AProductListInfoDS.W.ParentID.F.AsInteger := AParentID;
    AProductListInfoDS.W.HREF.F.Value := TURLHelper.GetAbsoluteURL(AMyHTMLRec.URL, AHTMLAnchorElement.HREF);
    AProductListInfoDS.W.Caption.F.Value := B[0].innerText;
    AProductListInfoDS.W.ItemNumber.F.Value := C[0].innerText;
    AProductListInfoDS.W.TryPost;
  end;
end;

end.
