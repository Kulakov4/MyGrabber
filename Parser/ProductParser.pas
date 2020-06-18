unit ProductParser;

interface

uses
  System.Classes, ParserInterface, DSWrap, MSHTML, ProductsDataSet,
  MyHTMLParser;

type
  TProductParser = class(TComponent, IParser)
  strict private
    function GetW: TDSWrap;
    procedure Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
      AParentID: Integer);
  private
    FProductsDS: TProductsDS;
  public
    constructor Create(AOwner: TComponent); override;
    property W: TDSWrap read GetW;
  end;

implementation

uses
  System.Variants;

constructor TProductParser.Create(AOwner: TComponent);
begin
  inherited;
  FProductsDS := TProductsDS.Create(Self);
end;

function TProductParser.GetW: TDSWrap;
begin
  Result := FProductsDS.W;
end;

procedure TProductParser.Parse(AURL: string; AHTMLDocument: IHTMLDocument2;
  AParentID: Integer);
var
  A: TArray<IHTMLElement>;
  ADataDownload: OleVariant;
  AHTMLElement: IHTMLElement;
  LIList: TArray<IHTMLElement>;
  P: TArray<IHTMLElement>;
  SPAN: TArray<IHTMLElement>;
  UL: TArray<IHTMLElement>;
begin
  FProductsDS.EmptyDataSet;

  FProductsDS.W.TryAppend;
  try
    P := TMyHTMLParser.Parse(AHTMLDocument.all, 'P',
      'product-info__short-description', 1);
    FProductsDS.W.Description.F.AsString := P[0].innerText;

    // Получаем список загрузки. Он должен быть один
    UL := TMyHTMLParser.Parse(AHTMLDocument.all, 'UL',
      'downloads-list-block', 1);

    // Получаем три элемента списка
    LIList := TMyHTMLParser.Parse(UL[0].all as IHTMLElementCollection, 'LI',
      'downloads-list-block');
    for AHTMLElement in LIList do
    begin
      // Ищем ссылку на документацию
      A := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection, 'A',
        'downloads-format-icons__element', 1);

      ADataDownload := A[0].getAttribute('data-download', 0);
      if not VarIsNull(ADataDownload) then
      begin
        SPAN := TMyHTMLParser.Parse(AHTMLElement.all as IHTMLElementCollection,
          'SPAN', 'downloads-list-item-block__titel', 1);
        if SPAN[0].innerText = 'Документация' then
          FProductsDS.W.Specification.F.AsString := ADataDownload;
      end;
    end;
    FProductsDS.W.ParentID.F.AsInteger := AParentID;
    FProductsDS.W.TryPost;
  except
    FProductsDS.W.TryCancel;
    raise;
  end;
end;

end.
