unit CategoryParser;

interface

uses
  MSHTML, System.Generics.Collections, CategoryInfoDataSet,
  FireDAC.Comp.Client, System.Classes, WebLoaderInterface, MyHTMLLoader;

type
  TCategoryParser = class(TComponent)
  private
  public
    procedure Parse(AMyHTMLRec: TMyHTMLRec; ACategoryInfoDS: TCategoryInfoDS;
        AParentID: Integer);
  end;

implementation

uses
  MyHTMLParser, System.SysUtils, URLHelper;

procedure TCategoryParser.Parse(AMyHTMLRec: TMyHTMLRec; ACategoryInfoDS:
    TCategoryInfoDS; AParentID: Integer);
var
  A: TArray<IHTMLElement>;
  AHTMLElement: IHTMLElement;
  AIHTMLAnchorElement: IHTMLAnchorElement;
  B: TArray<IHTMLElement>;
begin
  A := TMyHTMLParser.Parse(AMyHTMLRec.HTMLDocument.all, 'DIV', 'off-grid', 1);

  A := TMyHTMLParser.Parse(A[0].all as IHTMLElementCollection, 'A',
    'category-teaser off-grid__item');
  for AHTMLElement in A do
  begin
    B := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection, 'P',
      'category-teaser__title', 1);

    AIHTMLAnchorElement := AHTMLElement as IHTMLAnchorElement;

    ACategoryInfoDS.W.TryAppend;
    ACategoryInfoDS.W.ParentID.F.AsInteger := AParentID;
    ACategoryInfoDS.W.HREF.F.Value := TURLHelper.GetAbsoluteURL(AMyHTMLRec.URL,
      AIHTMLAnchorElement.HREF);
    ACategoryInfoDS.W.Caption.F.Value := B[0].innerText;
    ACategoryInfoDS.W.TryPost;
  end;
end;

end.
