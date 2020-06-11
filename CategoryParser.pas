unit CategoryParser;

interface

uses
  HTMLPageParser, MSHTML, System.Generics.Collections, CategoryInfoDataSet,
  FireDAC.Comp.Client, System.Classes, WebLoaderInterface;

type
  TCategoryParser = class(THTMLPageParser)
  private
  public
    procedure Process(AHTMLDocument: IHTMLDocument2; AFDMemTable: TFDMemTable);
        override;
  end;

implementation

uses
  MyHTMLParser, System.SysUtils;

procedure TCategoryParser.Process(AHTMLDocument: IHTMLDocument2; AFDMemTable:
    TFDMemTable);
var
  A: TArray<IHTMLElement>;
  AHTMLElement: IHTMLElement;
  AIHTMLAnchorElement: IHTMLAnchorElement;
  B: TArray<IHTMLElement>;
  DS: TCategoryInfoDS;
begin
  DS := AFDMemTable as TCategoryInfoDS;

  A := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV', 'off-grid', 1);

  A := TMyHTMLParser.Parse(A[0].all as IHTMLElementCollection, 'A',
    'category-teaser off-grid__item');
  for AHTMLElement in A do
  begin
    B := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection, 'P',
      'category-teaser__title', 1);

    AIHTMLAnchorElement := AHTMLElement as IHTMLAnchorElement;

    DS.W.TryAppend;
    DS.W.ParentID.F.AsInteger := ParentID;
    DS.W.HREF.F.Value := GetAbsoluteURL(AIHTMLAnchorElement.HREF);
    DS.W.Caption.F.Value := B[0].innerText;
    DS.W.TryPost;
  end;
end;

end.
