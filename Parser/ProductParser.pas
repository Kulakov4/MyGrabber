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
  System.Variants, System.SysUtils;

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
  A: IHTMLElement;
  AList: TArray<IHTMLElement>;
  ADataDownload: OleVariant;
  ADIV: TArray<IHTMLElement>;
  AFileName: string;
  LI: IHTMLElement;
  AHTMLImgElement: IHTMLImgElement;
  AIMG: TArray<IHTMLElement>;
  B: TArray<IHTMLElement>;
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

    // Получаем блок с изображением товара
    ADIV := TMyHTMLParser.Parse(AHTMLDocument.all, 'DIV',
      'product-image-block', 1);

    ADIV := TMyHTMLParser.Parse(ADIV[0].all as IHTMLElementCollection, 'DIV',
      'product-image-block__image', 1);

    AIMG := TMyHTMLParser.Parse(ADIV[0].all as IHTMLElementCollection, 'IMG',
      'product-image-block__image-element');

    // Если нашли хотя-бы одну картинку
    if Length(AIMG) > 0 then
    begin
      AHTMLImgElement := AIMG[0] as IHTMLImgElement;
      FProductsDS.W.ImageURL.F.AsString := AHTMLImgElement.src;
    end;

    // Получаем блок с артикулом
    P := TMyHTMLParser.Parse(AHTMLDocument.all as IHTMLElementCollection, 'P',
      'product-info__part-number-label', 1);

    B := TMyHTMLParser.Parse(P[0].all as IHTMLElementCollection, 'B',
      'product-info__part-number', 1);

    FProductsDS.W.ItemNumber.F.AsString := B[0].innerText;

    // Получаем список загрузки. Он должен быть один
    UL := TMyHTMLParser.Parse(AHTMLDocument.all, 'UL',
      'downloads-list-block', 1);

    // Получаем три элемента списка
    LIList := TMyHTMLParser.Parse(UL[0].all as IHTMLElementCollection, 'LI',
      'downloads-list-item-block');
    for LI in LIList do
    begin
      // Ищем ссылку на документацию
      AList := TMyHTMLParser.Parse(LI.all as IHTMLElementCollection, 'A',
        'downloads-format-icons__element');

      for A in AList do
      begin
        ADataDownload := A.getAttribute('data-download', 0);
        if VarIsNull(ADataDownload) then
          Continue;

        AFileName := ADataDownload;

        // На мужну только PDF-ки
        if not AFileName.EndsWith('.pdf', True) then
          Continue;

        SPAN := TMyHTMLParser.Parse(LI.all as IHTMLElementCollection, 'SPAN',
          'downloads-list-item-block__titel', 1);

        if SPAN[0].innerText = 'Документация' then
          FProductsDS.W.SpecificationURL.F.AsString := AFileName;

        if SPAN[0].innerText = 'Чертёж' then
          FProductsDS.W.DrawingURL.F.AsString := AFileName;

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
